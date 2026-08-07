// CLI contract tests — spawn the real entrypoints (via tsx) and assert the
// shell-layer contract: single-line JSON stdout, exit codes 0/1/3, fake mode.
// No DB, no network: function-bound paths never touch psql, and the
// record-bound path is exercised at the IFOS_DB_URL-unset boundary (exit 3).

import { execFile } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import { readFixture } from "./test-helpers.js";

const PKG_ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const RESOLVE_CLI = join(PKG_ROOT, "bin", "resolve-approver.ts");
const SEED_CLI = join(PKG_ROOT, "bin", "seed-identity-map.ts");

interface CliRun {
  code: number;
  stdout: string;
  stderr: string;
}

function runCli(
  entry: string,
  args: string[],
  env: Record<string, string | undefined> = {},
): Promise<CliRun> {
  return new Promise((resolve) => {
    const child = execFile(
      process.execPath,
      ["--import", "tsx/esm", entry, ...args],
      {
        cwd: PKG_ROOT,
        timeout: 14_000,
        env: {
          ...process.env,
          IFOS_DB_URL: undefined,
          IFOS_ROUTING_FAKE: undefined,
          IFOS_ROUTING_REGISTRY: undefined,
          IFOS_VAULT_ROOT: undefined,
          ...env,
        } as NodeJS.ProcessEnv,
      },
      (err, stdout, stderr) => {
        const code =
          err && typeof (err as NodeJS.ErrnoException & { code?: unknown }).code === "number"
            ? ((err as unknown as { code: number }).code as number)
            : err
              ? 1
              : 0;
        resolve({ code, stdout, stderr });
      },
    );
    child.stdin?.end();
  });
}

let vaultRoot: string;
let registryPath: string;

function seedVault(tenant: string, opts: { identityMap?: boolean } = {}): void {
  mkdirSync(join(vaultRoot, tenant, "routing"), { recursive: true });
  writeFileSync(
    join(vaultRoot, tenant, "routing", "function-roles.yaml"),
    readFixture("function-roles.valid.yaml"),
  );
  if (opts.identityMap !== false) {
    writeFileSync(
      join(vaultRoot, tenant, "routing", "identity-map.yaml"),
      readFixture("identity-map.valid.yaml"),
    );
  }
}

beforeEach(() => {
  vaultRoot = mkdtempSync(join(tmpdir(), "ifos-routing-cli-"));
  registryPath = join(vaultRoot, "action-class-registry.yaml");
  writeFileSync(registryPath, readFixture("action-class-registry.yaml"));
});

afterEach(() => {
  rmSync(vaultRoot, { recursive: true, force: true });
});

describe("resolve-approver CLI", () => {
  it("resolves a function-bound action → single-line JSON ResolveResult, exit 0", async () => {
    seedVault("t1");
    const run = await runCli(RESOLVE_CLI, [
      "--tenant",
      "t1",
      "--action-type",
      "xero_reminder_send_customer",
      "--vault-root",
      vaultRoot,
      "--registry",
      registryPath,
    ]);
    expect(run.code).toBe(0);
    expect(run.stdout.trim().split("\n")).toHaveLength(1); // single-line JSON
    const result = JSON.parse(run.stdout) as Record<string, unknown>;
    expect(result["person_ref"]).toBe("aad-priya-finance");
    expect(result["ladder_step"]).toBe("function_role");
    expect(result["function"]).toBe("finance");
    expect(result["trust_bucket"]).toBe(3);
    expect(result["ttl_minutes"]).toBeNull();
    expect(result["on_expiry"]).toBe("hold");
    expect(result["reason"]).toBeTruthy();
    expect(result["fake"]).toBeUndefined();
  });

  it("missing function-roles.yaml → exit 3 (caller falls back to single operator)", async () => {
    const run = await runCli(RESOLVE_CLI, [
      "--tenant",
      "t1",
      "--action-type",
      "xero_reminder_send_customer",
      "--vault-root",
      vaultRoot,
      "--registry",
      registryPath,
    ]);
    expect(run.code).toBe(3);
    const err = JSON.parse(run.stderr) as Record<string, unknown>;
    expect(err["ok"]).toBe(false);
    expect(String(err["error"])).toContain("function_roles_missing");
  });

  it("missing registry → exit 3", async () => {
    seedVault("t1");
    const run = await runCli(RESOLVE_CLI, [
      "--tenant",
      "t1",
      "--action-type",
      "xero_reminder_send_customer",
      "--vault-root",
      vaultRoot,
      "--registry",
      join(vaultRoot, "no-such-registry.yaml"),
    ]);
    expect(run.code).toBe(3);
    expect(String((JSON.parse(run.stderr) as Record<string, unknown>)["error"])).toContain(
      "registry_missing",
    );
  });

  it("unregistered action_type → exit 3", async () => {
    seedVault("t1");
    const run = await runCli(RESOLVE_CLI, [
      "--tenant",
      "t1",
      "--action-type",
      "made_up_action",
      "--vault-root",
      vaultRoot,
      "--registry",
      registryPath,
    ]);
    expect(run.code).toBe(3);
    expect(String((JSON.parse(run.stderr) as Record<string, unknown>)["error"])).toContain(
      "action_type_unregistered",
    );
  });

  it("record-bound args without IFOS_DB_URL → exit 3 (owner lookup impossible)", async () => {
    seedVault("t1");
    const run = await runCli(RESOLVE_CLI, [
      "--tenant",
      "t1",
      "--action-type",
      "gmail_outlook_send_to_candidate",
      "--entity-type",
      "candidate",
      "--entity-id",
      "CAND-1",
      "--vault-root",
      vaultRoot,
      "--registry",
      registryPath,
    ]);
    expect(run.code).toBe(3);
    expect(String((JSON.parse(run.stderr) as Record<string, unknown>)["error"])).toContain(
      "IFOS_DB_URL",
    );
  });

  it("bad args → exit 1 (missing --action-type; mismatched entity flags)", async () => {
    const missing = await runCli(RESOLVE_CLI, ["--tenant", "t1"]);
    expect(missing.code).toBe(1);
    expect(String((JSON.parse(missing.stderr) as Record<string, unknown>)["error"])).toContain(
      "--action-type",
    );

    const mismatched = await runCli(RESOLVE_CLI, [
      "--tenant",
      "t1",
      "--action-type",
      "xero_reminder_send_customer",
      "--entity-type",
      "candidate",
    ]);
    expect(mismatched.code).toBe(1);
  });

  it("IFOS_ROUTING_FAKE returns the injected ResolveResult verbatim with fake:true, exit 0", async () => {
    const injected = {
      person_ref: "aad-fake",
      ladder_step: "single_operator_fallback",
      escalation_plan: [],
      ttl_minutes: null,
      on_expiry: "hold",
      breaks_quiet_hours: false,
      trust_bucket: 3,
      reason: "fixture",
    };
    // No vault, no registry, no DB — fake mode must short-circuit everything.
    const run = await runCli(
      RESOLVE_CLI,
      ["--tenant", "t1", "--action-type", "anything_at_all"],
      { IFOS_ROUTING_FAKE: JSON.stringify(injected) },
    );
    expect(run.code).toBe(0);
    expect(JSON.parse(run.stdout)).toEqual({ ...injected, fake: true });
  });

  it("malformed IFOS_ROUTING_FAKE → exit 1", async () => {
    const run = await runCli(
      RESOLVE_CLI,
      ["--tenant", "t1", "--action-type", "x"],
      { IFOS_ROUTING_FAKE: "not-json" },
    );
    expect(run.code).toBe(1);
  });
});

describe("seed-identity-map CLI", () => {
  it("--add writes a loadable identity-map.yaml and reports counts", async () => {
    const run = await runCli(SEED_CLI, [
      "--tenant",
      "t1",
      "--vault-root",
      vaultRoot,
      "--add",
      "--bullhorn-user-id",
      "101",
      "--m365-object-id",
      "aad-sarah",
      "--email",
      "sarah@firm.co.uk",
      "--display-name",
      "Sarah Khan",
      "--telegram-user-id",
      "7700101",
    ]);
    expect(run.code).toBe(0);
    const out = JSON.parse(run.stdout) as Record<string, unknown>;
    expect(out["ok"]).toBe(true);
    expect(out["total_rows"]).toBe(1);
    expect(out["added"]).toBe(1);
    expect(out["updated"]).toBe(0);
    const written = readFileSync(
      join(vaultRoot, "t1", "routing", "identity-map.yaml"),
      "utf-8",
    );
    expect(written).toContain("bullhorn_user_id: 101");
    expect(written).toContain("source: manual");
  });

  it("--csv imports rows and a second import merges by bullhorn_user_id", async () => {
    const csvPath = join(vaultRoot, "people.csv");
    writeFileSync(
      csvPath,
      [
        "bullhorn_user_id,m365_object_id,email,display_name,telegram_user_id,source",
        '101,aad-sarah,sarah@firm.co.uk,"Khan, Sarah",7700101,csv_import',
        "102,aad-jane,jane@firm.co.uk,Jane Founder,,",
      ].join("\n"),
    );
    const first = await runCli(SEED_CLI, [
      "--tenant",
      "t1",
      "--vault-root",
      vaultRoot,
      "--csv",
      csvPath,
    ]);
    expect(first.code).toBe(0);
    expect((JSON.parse(first.stdout) as Record<string, unknown>)["total_rows"]).toBe(2);

    // Second import: update 101, add 103.
    writeFileSync(
      csvPath,
      [
        "bullhorn_user_id,m365_object_id,email,display_name",
        "101,aad-sarah-NEW,sarah.new@firm.co.uk,Sarah Khan",
        "103,aad-tom,tom@firm.co.uk,Tom Ops",
      ].join("\n"),
    );
    const second = await runCli(SEED_CLI, [
      "--tenant",
      "t1",
      "--vault-root",
      vaultRoot,
      "--csv",
      csvPath,
    ]);
    expect(second.code).toBe(0);
    const out = JSON.parse(second.stdout) as Record<string, unknown>;
    expect(out["total_rows"]).toBe(3);
    expect(out["added"]).toBe(1);
    expect(out["updated"]).toBe(1);
    const written = readFileSync(
      join(vaultRoot, "t1", "routing", "identity-map.yaml"),
      "utf-8",
    );
    expect(written).toContain("aad-sarah-NEW");
    expect(written).toContain("Tom Ops");
    expect(written).toContain("jane@firm.co.uk"); // untouched row survives the merge
  });

  it("--csv with a missing required column → exit 1", async () => {
    const csvPath = join(vaultRoot, "bad.csv");
    writeFileSync(csvPath, "bullhorn_user_id,email\n101,a@b.co\n");
    const run = await runCli(SEED_CLI, [
      "--tenant",
      "t1",
      "--vault-root",
      vaultRoot,
      "--csv",
      csvPath,
    ]);
    expect(run.code).toBe(1);
    expect(String((JSON.parse(run.stderr) as Record<string, unknown>)["error"])).toContain(
      "m365_object_id",
    );
  });

  it("--render-confirmation prints the Diagnostic-style cited summary", async () => {
    seedVault("t1");
    const run = await runCli(SEED_CLI, [
      "--tenant",
      "t1",
      "--vault-root",
      vaultRoot,
      "--render-confirmation",
    ]);
    expect(run.code).toBe(0);
    // §10.6 shape: "finance → Priya (source: graph_inferred), confirm?"
    expect(run.stdout).toContain("finance → Priya Finance (source: graph_inferred) — confirm?");
    expect(run.stdout).toContain("ops_data → Tom Ops (source: diagnostic_confirmed) — confirm?");
    expect(run.stdout).toContain("firm default approver (ladder step 3) → Jane Founder");
    // Citations: each section names the vault file it came from.
    expect(run.stdout).toContain(join(vaultRoot, "t1", "routing", "function-roles.yaml"));
    expect(run.stdout).toContain(join(vaultRoot, "t1", "routing", "identity-map.yaml"));
    expect(run.stdout).toContain("bullhorn 101 → Sarah Khan");
  });

  it("--render-confirmation without function-roles.yaml → exit 3", async () => {
    const run = await runCli(SEED_CLI, [
      "--tenant",
      "t1",
      "--vault-root",
      vaultRoot,
      "--render-confirmation",
    ]);
    expect(run.code).toBe(3);
  });
});
