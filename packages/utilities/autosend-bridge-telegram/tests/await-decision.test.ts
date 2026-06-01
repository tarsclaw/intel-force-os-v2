import { describe, expect, it } from "vitest";

import {
  awaitApprovalDecision,
  awaitApprovalDecisionOrThrow,
  BridgeInputError,
  BridgeTimeoutError,
  proposeApproval,
} from "../src/index.js";
import type { ProposeApprovalInput } from "../src/index.js";

import {
  makeDecisionSource,
  makeFakeClock,
  makeRecordingTransport,
} from "./test-helpers.js";

const validInput: ProposeApprovalInput = {
  action_type: "gmail_outlook_send_to_candidate",
  tenant_slug: "migration-test",
  operator_telegram_chat_id: "987654321",
  target: "alice@example.com",
  draft_preview: "Hi Alice — following up on the Senior PM role we discussed last week...",
  vault_path: "/vault/migration-test/concierge-drafts/2026-06-01-alice.md",
};

describe("awaitApprovalDecision — happy path", () => {
  it("returns approved + decided_by when operator approves before deadline", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(Date.parse("2026-06-01T15:00:00.000Z"));
    const deps = { transport, decisions, clock };

    const proposed = await proposeApproval(validInput, deps);
    // Operator approves 5 minutes later (well within PT4H)
    decisions.setDecision({
      approval_id: proposed.approval_id,
      outcome: "approved",
      decided_by: "tg-user-555",
      decided_at_iso: "2026-06-01T15:05:00.000Z",
    });

    const r = await awaitApprovalDecision(
      {
        approval_id: proposed.approval_id,
        poll_interval_seconds: 30,
        expires_at_iso: proposed.expires_at_iso,
      },
      deps,
    );

    expect(r.outcome).toBe("approved");
    expect(r.decided_by).toBe("tg-user-555");
    expect(r.decided_at_iso).toBe("2026-06-01T15:05:00.000Z");
  });

  it("returns rejected when operator rejects", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(0);
    const deps = { transport, decisions, clock };

    const proposed = await proposeApproval(validInput, deps);
    decisions.setDecision({
      approval_id: proposed.approval_id,
      outcome: "rejected",
      decided_by: "tg-user-555",
      decided_at_iso: new Date(clock.nowMs()).toISOString(),
    });

    const r = await awaitApprovalDecision(
      { approval_id: proposed.approval_id, expires_at_iso: proposed.expires_at_iso },
      deps,
    );
    expect(r.outcome).toBe("rejected");
  });
});

describe("awaitApprovalDecision — polling cadence + deadline", () => {
  it("polls at the configured interval until decision lands", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(Date.parse("2026-06-01T15:00:00.000Z"));
    const deps = { transport, decisions, clock };

    const proposed = await proposeApproval(validInput, deps);
    // Operator only decides after ~90 seconds: we expect 3 polls (0s, 30s, 60s, 90s — fourth poll finds it)
    const decisionAt = clock.getNowMs() + 90_000;
    let placed = false;
    decisions.fetchDecision = async (id) => {
      decisions.fetches.push(id);
      if (!placed && clock.getNowMs() >= decisionAt) {
        placed = true;
        return {
          approval_id: id,
          outcome: "approved",
          decided_by: "tg-user-555",
          decided_at_iso: new Date(clock.getNowMs()).toISOString(),
        };
      }
      return null;
    };

    const r = await awaitApprovalDecision(
      {
        approval_id: proposed.approval_id,
        poll_interval_seconds: 30,
        expires_at_iso: proposed.expires_at_iso,
      },
      deps,
    );

    expect(r.outcome).toBe("approved");
    expect(decisions.fetches.length).toBeGreaterThanOrEqual(4); // 4 polls: 0s, 30s, 60s, 90s
    expect(clock.getSleeps()).toEqual([30_000, 30_000, 30_000]); // 3 sleeps between 4 polls
  });

  it("returns timeout when deadline passes without a decision", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(Date.parse("2026-06-01T15:00:00.000Z"));
    const deps = { transport, decisions, clock };

    const proposed = await proposeApproval(
      { ...validInput, timeout_seconds: 60 }, // 1-minute window for the test
      deps,
    );

    const r = await awaitApprovalDecision(
      {
        approval_id: proposed.approval_id,
        poll_interval_seconds: 30,
        expires_at_iso: proposed.expires_at_iso,
      },
      deps,
    );

    expect(r.outcome).toBe("timeout");
    expect(r.decided_by).toBeUndefined();
    // Should have woken at the deadline exactly, not overrun
    expect(clock.getNowMs()).toBe(Date.parse(proposed.expires_at_iso));
  });

  it("never sleeps past the deadline — caps the final sleep at remaining-window", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(Date.parse("2026-06-01T15:00:00.000Z"));
    const deps = { transport, decisions, clock };

    // 45-second window with a 30s poll interval: first sleep is 30s, second
    // sleep must be capped to the remaining 15s — NOT another 30s.
    const proposed = await proposeApproval(
      { ...validInput, timeout_seconds: 45 },
      deps,
    );

    await awaitApprovalDecision(
      {
        approval_id: proposed.approval_id,
        poll_interval_seconds: 30,
        expires_at_iso: proposed.expires_at_iso,
      },
      deps,
    );

    expect(clock.getSleeps()).toEqual([30_000, 15_000]);
  });
});

describe("awaitApprovalDecisionOrThrow", () => {
  it("throws BridgeTimeoutError on expiry instead of returning timeout", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(0);
    const deps = { transport, decisions, clock };

    const proposed = await proposeApproval(
      { ...validInput, timeout_seconds: 60 },
      deps,
    );

    await expect(
      awaitApprovalDecisionOrThrow(
        {
          approval_id: proposed.approval_id,
          poll_interval_seconds: 30,
          expires_at_iso: proposed.expires_at_iso,
        },
        deps,
        60,
      ),
    ).rejects.toBeInstanceOf(BridgeTimeoutError);
  });

  it("returns the decision unwrapped when it arrives in time", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    const clock = makeFakeClock(0);
    const deps = { transport, decisions, clock };

    const proposed = await proposeApproval(validInput, deps);
    decisions.setDecision({
      approval_id: proposed.approval_id,
      outcome: "approved",
      decided_by: "tg-user-555",
      decided_at_iso: new Date(clock.nowMs()).toISOString(),
    });

    const r = await awaitApprovalDecisionOrThrow(
      { approval_id: proposed.approval_id, expires_at_iso: proposed.expires_at_iso },
      deps,
    );

    expect(r.outcome).toBe("approved");
    expect(r.decided_by).toBe("tg-user-555");
  });
});

describe("awaitApprovalDecision — input validation", () => {
  it("rejects empty approval_id", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    await expect(
      awaitApprovalDecision({ approval_id: "" }, { transport, decisions }),
    ).rejects.toBeInstanceOf(BridgeInputError);
  });

  it("rejects invalid expires_at_iso", async () => {
    const transport = makeRecordingTransport();
    const decisions = makeDecisionSource();
    await expect(
      awaitApprovalDecision(
        { approval_id: "abc", expires_at_iso: "not-an-iso-date" },
        { transport, decisions },
      ),
    ).rejects.toBeInstanceOf(BridgeInputError);
  });
});
