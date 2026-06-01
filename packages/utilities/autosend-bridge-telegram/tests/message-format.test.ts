import { describe, expect, it } from "vitest";

import {
  ID_TOKEN_RE,
  MAX_PREVIEW_CHARS,
  renderApprovalMessage,
  truncatePreview,
} from "../src/index.js";
import type { ProposeApprovalInput } from "../src/index.js";

const base: ProposeApprovalInput = {
  action_type: "xero_reminder_send_customer",
  tenant_slug: "migration-test",
  operator_telegram_chat_id: "987654321",
  target: "billing@beta-search-partners.co.uk",
  draft_preview: "short preview",
  vault_path: "/vault/migration-test/cash-conductor-drafts/INV-001-pos1.md",
};

describe("renderApprovalMessage", () => {
  it("emits the ID token as the first line so the Telegram bot parser can route replies", () => {
    const body = renderApprovalMessage(base, "approval-xyz", "2026-06-01T19:00:00.000Z");
    const firstLine = body.split("\n")[0];
    expect(firstLine).toBe("[ID:approval-xyz]");
  });

  it("includes all caller-visible fields the operator needs to decide", () => {
    const body = renderApprovalMessage(base, "approval-xyz", "2026-06-01T19:00:00.000Z");
    expect(body).toContain(base.action_type);
    expect(body).toContain(base.tenant_slug);
    expect(body).toContain(base.target);
    expect(body).toContain(base.vault_path);
    expect(body).toContain(base.draft_preview);
    expect(body).toContain("2026-06-01T19:00:00.000Z");
    expect(body).toContain("/approve approval-xyz");
    expect(body).toContain("/reject approval-xyz");
  });

  it("truncates oversized draft previews to MAX_PREVIEW_CHARS with an ellipsis", () => {
    const huge = "x".repeat(MAX_PREVIEW_CHARS + 250);
    const body = renderApprovalMessage(
      { ...base, draft_preview: huge },
      "approval-xyz",
      "2026-06-01T19:00:00.000Z",
    );
    // The truncated preview line is the only `x`-dominant line; its length
    // (excluding the ellipsis) should be MAX_PREVIEW_CHARS - 1.
    const xLine = body.split("\n").find((l) => l.startsWith("x"));
    expect(xLine).toBeDefined();
    expect(xLine!.length).toBe(MAX_PREVIEW_CHARS); // (MAX-1) chars + 1 ellipsis = MAX
    expect(xLine!.endsWith("…")).toBe(true);
  });

  it("leaves short previews untruncated and ellipsis-free", () => {
    const t = truncatePreview("short");
    expect(t).toBe("short");
  });

  it("ID_TOKEN_RE matches the token format we emit", () => {
    expect(ID_TOKEN_RE.test("[ID:11111111-2222-3333-4444-555555555555]")).toBe(true);
    expect(ID_TOKEN_RE.test("[id:DEADBEEFCAFE]")).toBe(true);
    expect(ID_TOKEN_RE.test("[ID:short]")).toBe(false); // <8 hex chars
    expect(ID_TOKEN_RE.test("ID:foo")).toBe(false);
  });
});
