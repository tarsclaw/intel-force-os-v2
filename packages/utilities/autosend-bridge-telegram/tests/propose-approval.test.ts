import { describe, expect, it } from "vitest";

import {
  BridgeInputError,
  BridgeTransportError,
  DEFAULT_TIMEOUT_SECONDS,
  ID_TOKEN_RE,
  proposeApproval,
} from "../src/index.js";
import type { ProposeApprovalInput } from "../src/index.js";

import {
  makeDecisionSource,
  makeFakeClock,
  makeRecordingTransport,
} from "./test-helpers.js";

const validInput: ProposeApprovalInput = {
  action_type: "xero_reminder_send_customer",
  tenant_slug: "migration-test",
  operator_telegram_chat_id: "987654321",
  target: "billing@beta-search-partners.co.uk",
  draft_preview: "Hi — just a friendly nudge on INV-001 (£1,500) due 14 May.",
  vault_path: "/vault/migration-test/cash-conductor-drafts/INV-001-pos1.md",
  originating_decision_log_id: "dlog-42",
};

describe("proposeApproval — posting + payload shape", () => {
  it("posts to the operator chat and returns a stable approval_id", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(Date.parse("2026-06-01T15:00:00.000Z"));

    const r = await proposeApproval(validInput, {
      transport,
      decisions,
      clock,
      generateApprovalId: () => "11111111-2222-3333-4444-555555555555",
    });

    expect(r.approval_id).toBe("11111111-2222-3333-4444-555555555555");
    expect(r.posted_at_iso).toBe("2026-06-01T15:00:00.000Z");
    expect(r.expires_at_iso).toBe("2026-06-01T19:00:00.000Z"); // +PT4H default
    expect(transport.posts).toHaveLength(1);
    expect(transport.posts[0].chat_id).toBe("987654321");
  });

  it("embeds the [ID:<approval_id>] token at the head of the message body", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(0);

    const r = await proposeApproval(validInput, {
      transport,
      decisions,
      clock,
      generateApprovalId: () => "deadbeef-cafe-1234-5678-abcdefabcdef",
    });

    const firstLine = transport.posts[0].text.split("\n")[0];
    expect(firstLine).toBe(`[ID:${r.approval_id}]`);
    expect(ID_TOKEN_RE.test(firstLine)).toBe(true);
  });

  it("includes vault path + /approve and /reject commands so the operator can act", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(0);

    const r = await proposeApproval(validInput, {
      transport,
      decisions,
      clock,
    });

    const body = transport.posts[0].text;
    expect(body).toContain(validInput.vault_path);
    expect(body).toContain(`/approve ${r.approval_id}`);
    expect(body).toContain(`/reject ${r.approval_id}`);
    expect(body).toContain(validInput.target);
  });

  it("respects a caller-supplied timeout_seconds in the computed expires_at", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(Date.parse("2026-06-01T15:00:00.000Z"));

    const r = await proposeApproval(
      { ...validInput, timeout_seconds: 30 * 60 }, // PT30M
      { transport, decisions, clock },
    );

    expect(r.expires_at_iso).toBe("2026-06-01T15:30:00.000Z");
  });

  it("falls back to DEFAULT_TIMEOUT_SECONDS (PT4H) when timeout omitted", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(0);

    const r = await proposeApproval(validInput, { transport, decisions, clock });

    expect(Date.parse(r.expires_at_iso) - Date.parse(r.posted_at_iso)).toBe(
      DEFAULT_TIMEOUT_SECONDS * 1000,
    );
  });
});

describe("proposeApproval — input validation", () => {
  it("rejects an action_type not registered in SupportedActionType", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    await expect(
      proposeApproval(
        // @ts-expect-error — deliberate runtime-validation test
        { ...validInput, action_type: "delete_candidate_record" },
        { transport, decisions },
      ),
    ).rejects.toBeInstanceOf(BridgeInputError);
    expect(transport.posts).toHaveLength(0); // no message posted on validation fail
  });

  it("rejects missing required fields with BridgeInputError", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    await expect(
      proposeApproval({ ...validInput, tenant_slug: "" }, { transport, decisions }),
    ).rejects.toBeInstanceOf(BridgeInputError);
    await expect(
      proposeApproval({ ...validInput, operator_telegram_chat_id: "" }, { transport, decisions }),
    ).rejects.toBeInstanceOf(BridgeInputError);
    await expect(
      proposeApproval({ ...validInput, draft_preview: "" }, { transport, decisions }),
    ).rejects.toBeInstanceOf(BridgeInputError);
  });

  it("rejects non-positive timeout_seconds", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    await expect(
      proposeApproval({ ...validInput, timeout_seconds: 0 }, { transport, decisions }),
    ).rejects.toBeInstanceOf(BridgeInputError);
    await expect(
      proposeApproval({ ...validInput, timeout_seconds: -10 }, { transport, decisions }),
    ).rejects.toBeInstanceOf(BridgeInputError);
  });
});

describe("proposeApproval — transport failures", () => {
  it("wraps Telegram postMessage failure as BridgeTransportError (NOT a timeout)", async () => {
    const transport = makeRecordingTransport();
    transport.setFailWith(new Error("HTTP 503 from Telegram"));
    const decisions = makeDecisionSource();

    await expect(
      proposeApproval(validInput, { transport, decisions }),
    ).rejects.toBeInstanceOf(BridgeTransportError);
    expect(transport.posts).toHaveLength(0);
  });
});
