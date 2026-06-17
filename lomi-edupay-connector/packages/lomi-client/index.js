const { createSchoolRegistry } = require("./school-registry");

const DEFAULT_BASE_URL = "https://sandbox.api.lomi.africa";

/**
 * @typedef {Object} EduPayFeeMetadata
 * @property {string} school_id
 * @property {string} student_id
 * @property {string} fee_code
 * @property {string} [term_id]
 * @property {string} [integration_source]
 */

/**
 * @typedef {Object} EduPayChargeInput
 * @property {number} amount
 * @property {string} [currency]
 * @property {string} payment_reference
 * @property {EduPayFeeMetadata} metadata
 * @property {{ name: string; email?: string; phone: string }} customer
 * @property {string} [description]
 * @property {string} [success_url]
 * @property {string} [error_url]
 * @property {string} [country_code]
 */

function buildIdempotencyKey(paymentReference) {
  const ref = String(paymentReference).trim();
  return `edupay_${ref}`;
}

function buildDescription(input) {
  if (input.description) {
    return input.description;
  }
  const { school_id, student_id, fee_code, term_id } = input.metadata;
  const term = term_id ? ` term=${term_id}` : "";
  return `EduPay fee ${input.payment_reference} school=${school_id} student=${student_id} fee=${fee_code}${term}`;
}

function mergeCardMetadata(input) {
  return {
    integration_source: "edupay",
    payment_reference: input.payment_reference,
    ...input.metadata,
  };
}

/**
 * @param {Object} options
 * @param {string} options.apiKey
 * @param {string} [options.baseUrl]
 * @param {(schoolId: string) => string | undefined} [options.resolveMemberAccountId]
 */
function createLomiClient(options) {
  const baseUrl = (options.baseUrl || DEFAULT_BASE_URL).replace(/\/$/, "");
  const apiKey = options.apiKey;
  const resolveMemberAccountId = options.resolveMemberAccountId ?? (() => undefined);

  if (!apiKey) {
    throw new Error("LOMI_API_KEY is required to create lomi client");
  }

  async function request(method, routePath, body, requestOptions = {}) {
    const headers = {
      "Content-Type": "application/json",
      "X-API-KEY": apiKey,
    };

    const memberAccountId = requestOptions.memberAccountId;
    if (memberAccountId) {
      headers["Lomi-Account"] = memberAccountId;
    }

    if (requestOptions.idempotencyKey) {
      headers["Idempotency-Key"] = requestOptions.idempotencyKey;
    }

    if (requestOptions.scenarioKey) {
      headers["X-Scenario-Key"] = requestOptions.scenarioKey;
    }

    const response = await fetch(`${baseUrl}${routePath}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    const data = await response.json().catch(() => ({}));

    if (!response.ok) {
      const message = data?.message || data?.error || "lomi API request failed";
      throw new Error(typeof message === "string" ? message : JSON.stringify(message));
    }

    return { status: response.status, data };
  }

  function resolveNetworkContext(metadata) {
    const schoolId = metadata?.school_id;
    if (!schoolId) {
      return { memberAccountId: undefined, mode: "merchant" };
    }
    const memberAccountId = resolveMemberAccountId(schoolId);
    return {
      memberAccountId,
      mode: memberAccountId ? "network" : "merchant",
    };
  }

  async function createWaveCharge(input, extra = {}) {
    const { memberAccountId, mode } = resolveNetworkContext(input.metadata);
    const payload = {
      amount: input.amount,
      currency: input.currency || "XOF",
      customer: {
        name: input.customer.name,
        email: input.customer.email || undefined,
        phoneNumber: input.customer.phone,
      },
      description: buildDescription(input),
      successUrl: input.success_url,
      errorUrl: input.error_url,
    };

    const result = await request("POST", "/charge/wave", payload, {
      memberAccountId,
      idempotencyKey: buildIdempotencyKey(input.payment_reference),
      scenarioKey: extra.scenarioKey,
    });

    return { ...result, lomi_mode: mode, member_account_id: memberAccountId ?? null };
  }

  async function createMtnCharge(input, extra = {}) {
    const { memberAccountId, mode } = resolveNetworkContext(input.metadata);
    const payload = {
      amount: input.amount,
      currency: input.currency || "XOF",
      customer: {
        name: input.customer.name,
        email: input.customer.email || undefined,
        phoneNumber: input.customer.phone,
      },
      description: buildDescription(input),
      countryCode: input.country_code || "CI",
      quantity: 1,
    };

    const result = await request("POST", "/charge/mtn", payload, {
      memberAccountId,
      idempotencyKey: buildIdempotencyKey(input.payment_reference),
      scenarioKey: extra.scenarioKey,
    });

    return { ...result, lomi_mode: mode, member_account_id: memberAccountId ?? null };
  }

  async function createCardCharge(input) {
    const { memberAccountId, mode } = resolveNetworkContext(input.metadata);
    const email = String(input.customer.email || "").trim();
    const name = String(input.customer.name || "").trim();

    if (!email || !name) {
      throw new Error("customer.email and customer.name are required for card charges");
    }

    const payload = {
      amount: input.amount,
      currency_code: input.currency || "XOF",
      customer_email: email,
      customer_name: name,
      customer_phone: input.customer.phone || undefined,
      payment_reference: input.payment_reference,
      description: buildDescription(input),
      metadata: mergeCardMetadata(input),
    };

    const result = await request("POST", "/charge/card", payload, {
      memberAccountId,
      idempotencyKey: buildIdempotencyKey(input.payment_reference),
    });

    return { ...result, lomi_mode: mode, member_account_id: memberAccountId ?? null };
  }

  async function getCardCharge(chargeId, memberAccountId) {
    return request("GET", `/charge/card/${encodeURIComponent(chargeId)}`, undefined, {
      memberAccountId,
    });
  }

  async function getTransaction(transactionId, memberAccountId) {
    return request("GET", `/transactions/${encodeURIComponent(transactionId)}`, undefined, {
      memberAccountId,
    });
  }

  return {
    createWaveCharge,
    createMtnCharge,
    createCardCharge,
    getCardCharge,
    getTransaction,
    resolveNetworkContext,
  };
}

/**
 * Factory with school registry wired in.
 */
function createEduPayLomiClient(options) {
  const registry = options.registryPath
    ? createSchoolRegistry(options.registryPath)
    : null;

  const client = createLomiClient({
    apiKey: options.apiKey,
    baseUrl: options.baseUrl,
    resolveMemberAccountId: (schoolId) =>
      registry ? registry.resolveMemberAccountId(schoolId) : undefined,
  });

  return {
    ...client,
    schools: registry,
  };
}

module.exports = {
  createLomiClient,
  createEduPayLomiClient,
  buildIdempotencyKey,
};
