const fs = require("fs");
const path = require("path");

/**
 * Resolves school_id → member account (acct_...) for Network phase.
 * Phase 1 schools have use_network_settlement: false and no member_account_id.
 */
function loadSchoolRegistry(registryPath) {
  const resolved = path.resolve(registryPath);
  if (!fs.existsSync(resolved)) {
    return { schools: {} };
  }

  const raw = fs.readFileSync(resolved, "utf8");
  const parsed = JSON.parse(raw);
  if (!parsed || typeof parsed !== "object" || !parsed.schools) {
    throw new Error(`Invalid school registry at ${resolved}: expected { schools: { ... } }`);
  }
  return parsed;
}

function createSchoolRegistry(registryPath) {
  const data = loadSchoolRegistry(registryPath);

  function getSchool(schoolId) {
    return data.schools[schoolId] ?? null;
  }

  /** Returns acct_... when school is on Network; otherwise undefined (Phase 1). */
  function resolveMemberAccountId(schoolId) {
    const school = getSchool(schoolId);
    if (!school) {
      return undefined;
    }
    if (!school.use_network_settlement) {
      return undefined;
    }
    const accountId = String(school.member_account_id || "").trim();
    if (!accountId) {
      throw new Error(
        `School ${schoolId} has use_network_settlement=true but member_account_id is missing`,
      );
    }
    if (!accountId.startsWith("acct_")) {
      throw new Error(`School ${schoolId} member_account_id must start with acct_`);
    }
    return accountId;
  }

  function listSchools() {
    return Object.entries(data.schools).map(([id, school]) => ({
      school_id: id,
      name: school.name,
      use_network_settlement: Boolean(school.use_network_settlement),
      member_account_id: school.member_account_id ?? null,
    }));
  }

  return {
    getSchool,
    resolveMemberAccountId,
    listSchools,
  };
}

module.exports = {
  loadSchoolRegistry,
  createSchoolRegistry,
};
