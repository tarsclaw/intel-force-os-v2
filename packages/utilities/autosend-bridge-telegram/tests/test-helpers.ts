// Shared test doubles — kept thin so each test reads at the assertion layer
// rather than re-declaring fakes.

import type {
  Clock,
  DecisionSource,
  PendingDecision,
  TelegramTransport,
} from "../src/types.js";

export function makeFakeClock(startMs = 0): Clock & {
  advance(ms: number): void;
  getNowMs(): number;
  getSleeps(): number[];
} {
  let now = startMs;
  const sleeps: number[] = [];
  return {
    nowMs: () => now,
    sleepMs: async (ms) => {
      sleeps.push(ms);
      now += ms;
    },
    advance(ms) {
      now += ms;
    },
    getNowMs() {
      return now;
    },
    getSleeps() {
      return sleeps;
    },
  };
}

export interface RecordingTransport extends TelegramTransport {
  posts: { chat_id: string; text: string }[];
  setFailWith(err: Error): void;
}

export function makeRecordingTransport(): RecordingTransport {
  let failWith: Error | null = null;
  const t: RecordingTransport = {
    posts: [],
    setFailWith(err) {
      failWith = err;
    },
    async postMessage(input) {
      if (failWith) throw failWith;
      t.posts.push(input);
      return { message_id: `msg-${t.posts.length}` };
    },
  };
  return t;
}

export interface InMemoryDecisionSource extends DecisionSource {
  setDecision(d: PendingDecision): void;
  fetches: string[];
}

export function makeDecisionSource(): InMemoryDecisionSource {
  const store = new Map<string, PendingDecision>();
  const fetches: string[] = [];
  return {
    fetches,
    setDecision(d) {
      store.set(d.approval_id, d);
    },
    async fetchDecision(approval_id) {
      fetches.push(approval_id);
      return store.get(approval_id) ?? null;
    },
  };
}
