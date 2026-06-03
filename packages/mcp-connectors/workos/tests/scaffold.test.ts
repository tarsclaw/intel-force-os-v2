// Scaffold tests — verify public surface, exports, error hierarchy.
// Per review-mcp-connector §1 (capabilities-set-equal-with-README + exports).

import { describe, expect, it } from "vitest";

import {
  DEFAULT_BASE_URL,
  DEFAULT_TIMEOUT_MS,
  VERSION,
  WorkosAuthError,
  WorkosCache,
  WorkosClient,
  WorkosError,
  WorkosNotFoundError,
  WorkosRateLimitError,
  WorkosValidationError,
  getConnection,
  getDirectory,
  getDirectoryGroup,
  getDirectoryUser,
  getOrganization,
  listConnections,
  listDirectories,
  listDirectoryGroups,
  listDirectoryUsers,
  listOrganizations,
  rateCheck,
  rateConsume,
  resetRateLimit,
} from "../src/index.js";

describe("@ifos/workos — scaffold", () => {
  it("exports VERSION + DEFAULT_TIMEOUT_MS + DEFAULT_BASE_URL", () => {
    expect(VERSION).toBe("0.1.0");
    expect(DEFAULT_TIMEOUT_MS).toBe(15_000);
    expect(DEFAULT_BASE_URL).toBe("https://api.workos.com");
  });

  it("exports the bus-routed capability functions (set-equal with consumer tools.yaml)", () => {
    // Organization capabilities
    expect(typeof getOrganization).toBe("function");
    expect(typeof listOrganizations).toBe("function");
    // Connection capabilities (SSO link inspection)
    expect(typeof getConnection).toBe("function");
    expect(typeof listConnections).toBe("function");
    // Directory Sync capabilities (read-only SCIM mirror)
    expect(typeof getDirectory).toBe("function");
    expect(typeof listDirectories).toBe("function");
    expect(typeof getDirectoryUser).toBe("function");
    expect(typeof listDirectoryUsers).toBe("function");
    expect(typeof getDirectoryGroup).toBe("function");
    expect(typeof listDirectoryGroups).toBe("function");
  });

  it("exports internal helpers (NOT bus-routed; for consumer + tests)", () => {
    expect(typeof WorkosClient).toBe("function"); // class
    expect(typeof WorkosCache).toBe("function"); // class
    expect(typeof rateCheck).toBe("function");
    expect(typeof rateConsume).toBe("function");
    expect(typeof resetRateLimit).toBe("function");
  });

  it("exports a complete error hierarchy", () => {
    expect(new WorkosError("test") instanceof Error).toBe(true);
    expect(new WorkosAuthError("test") instanceof WorkosError).toBe(true);
    expect(new WorkosRateLimitError("test") instanceof WorkosError).toBe(true);
    expect(new WorkosNotFoundError("test") instanceof WorkosError).toBe(true);
    expect(new WorkosValidationError("test") instanceof WorkosError).toBe(true);
  });

  it("error names match class names (per Error.name conventions)", () => {
    expect(new WorkosError("x").name).toBe("WorkosError");
    expect(new WorkosAuthError("x").name).toBe("WorkosAuthError");
    expect(new WorkosRateLimitError("x").name).toBe("WorkosRateLimitError");
    expect(new WorkosNotFoundError("x").name).toBe("WorkosNotFoundError");
    expect(new WorkosValidationError("x").name).toBe("WorkosValidationError");
  });

  it("WorkosClient can be instantiated with a minimal config (no auth.ts dependency)", () => {
    const client = new WorkosClient({
      config: { secret_key: "sk_test_fake" },
    });
    expect(client).toBeInstanceOf(WorkosClient);
  });
});
