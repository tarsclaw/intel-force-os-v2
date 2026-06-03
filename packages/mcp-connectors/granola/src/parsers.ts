// Wire-shape parsers. The Granola MCP server returns each tool's result as
// a list of MCP content blocks (typically a single `{type: "text", text}`
// block whose body is JSON). These helpers extract + validate that JSON
// into the typed shapes consumers expect.
//
// Strict parsers: any malformed wire shape throws GranolaError rather than
// returning a partial. The IFOS layer is the contract; if Granola breaks
// the wire shape, we surface loudly rather than silently coercing.

import { GranolaError } from "./errors.js";
import type {
  GranolaAccountInfo,
  GranolaFolder,
  GranolaMeeting,
  GranolaPlanTier,
  GranolaToolCallResult,
  GranolaTranscript,
} from "./types.js";

/** Extract a single text-content block's parsed JSON. */
function extractJson(result: GranolaToolCallResult, tool_name: string): unknown {
  const textBlock = result.content.find((c) => c.type === "text");
  if (!textBlock || textBlock.type !== "text") {
    throw new GranolaError(
      `Granola MCP tool '${tool_name}' returned no text content block`,
    );
  }
  try {
    return JSON.parse(textBlock.text);
  } catch {
    throw new GranolaError(
      `Granola MCP tool '${tool_name}' returned non-JSON text content`,
    );
  }
}

function asObject(v: unknown, ctx: string): Record<string, unknown> {
  if (typeof v !== "object" || v === null || Array.isArray(v)) {
    throw new GranolaError(`Expected object in ${ctx}`);
  }
  return v as Record<string, unknown>;
}

function asArray(v: unknown, ctx: string): unknown[] {
  if (!Array.isArray(v)) {
    throw new GranolaError(`Expected array in ${ctx}`);
  }
  return v;
}

function asString(v: unknown, ctx: string): string {
  if (typeof v !== "string") {
    throw new GranolaError(`Expected string in ${ctx}`);
  }
  return v;
}

function asStringOrNull(v: unknown, ctx: string): string | null {
  if (v === null) return null;
  if (typeof v !== "string") {
    throw new GranolaError(`Expected string|null in ${ctx}`);
  }
  return v;
}

function asNumber(v: unknown, ctx: string): number {
  if (typeof v !== "number") {
    throw new GranolaError(`Expected number in ${ctx}`);
  }
  return v;
}

function asNumberOrNull(v: unknown, ctx: string): number | null {
  if (v === null) return null;
  if (typeof v !== "number") {
    throw new GranolaError(`Expected number|null in ${ctx}`);
  }
  return v;
}

function asBool(v: unknown, ctx: string): boolean {
  if (typeof v !== "boolean") {
    throw new GranolaError(`Expected boolean in ${ctx}`);
  }
  return v;
}

function parseMeetingObject(raw: unknown, ctx: string): GranolaMeeting {
  const o = asObject(raw, ctx);
  return {
    id: asString(o.id, `${ctx}.id`),
    title: asStringOrNull(o.title, `${ctx}.title`),
    start_time: asString(o.start_time, `${ctx}.start_time`),
    end_time: asStringOrNull(o.end_time, `${ctx}.end_time`),
    duration_minutes: asNumberOrNull(o.duration_minutes, `${ctx}.duration_minutes`),
    folder_id: asStringOrNull(o.folder_id, `${ctx}.folder_id`),
    attendees: asArray(o.attendees ?? [], `${ctx}.attendees`).map((a, i) =>
      asString(a, `${ctx}.attendees[${i}]`),
    ),
    notes_markdown: asStringOrNull(o.notes_markdown, `${ctx}.notes_markdown`),
    has_transcript: asBool(o.has_transcript ?? false, `${ctx}.has_transcript`),
    created_at: asString(o.created_at, `${ctx}.created_at`),
    updated_at: asString(o.updated_at, `${ctx}.updated_at`),
  };
}

export function parseListMeetings(result: GranolaToolCallResult): GranolaMeeting[] {
  const json = extractJson(result, "list_meetings");
  const obj = asObject(json, "list_meetings");
  // Granola docs show the meeting list under either `meetings` or `data` —
  // accept both for forward-compat (verify exact shape during W5-live).
  const list = (obj.meetings ?? obj.data ?? obj.items) as unknown;
  return asArray(list, "list_meetings.meetings").map((m, i) =>
    parseMeetingObject(m, `list_meetings.meetings[${i}]`),
  );
}

export function parseMeeting(result: GranolaToolCallResult): GranolaMeeting | null {
  const json = extractJson(result, "get_meeting");
  if (json === null) return null;
  return parseMeetingObject(json, "get_meeting");
}

export function parseListFolders(result: GranolaToolCallResult): GranolaFolder[] {
  const json = extractJson(result, "list_meeting_folders");
  const obj = asObject(json, "list_meeting_folders");
  const list = (obj.folders ?? obj.data ?? obj.items) as unknown;
  return asArray(list, "list_meeting_folders.folders").map((f, i) => {
    const o = asObject(f, `list_meeting_folders.folders[${i}]`);
    return {
      id: asString(o.id, `folders[${i}].id`),
      name: asString(o.name, `folders[${i}].name`),
      parent_folder_id: asStringOrNull(
        o.parent_folder_id,
        `folders[${i}].parent_folder_id`,
      ),
      meeting_count: asNumber(o.meeting_count ?? 0, `folders[${i}].meeting_count`),
      created_at: asString(o.created_at, `folders[${i}].created_at`),
      updated_at: asString(o.updated_at, `folders[${i}].updated_at`),
    };
  });
}

export function parseTranscript(result: GranolaToolCallResult): GranolaTranscript | null {
  const json = extractJson(result, "get_meeting_transcript");
  if (json === null) return null;
  const o = asObject(json, "get_meeting_transcript");
  return {
    meeting_id: asString(o.meeting_id, "transcript.meeting_id"),
    language: asString(o.language ?? "en", "transcript.language"),
    duration_seconds: asNumber(
      o.duration_seconds ?? 0,
      "transcript.duration_seconds",
    ),
    segments: asArray(o.segments ?? [], "transcript.segments").map((s, i) => {
      const so = asObject(s, `transcript.segments[${i}]`);
      return {
        start_seconds: asNumber(so.start_seconds, `segments[${i}].start_seconds`),
        end_seconds: asNumber(so.end_seconds, `segments[${i}].end_seconds`),
        speaker: asStringOrNull(so.speaker, `segments[${i}].speaker`),
        text: asString(so.text, `segments[${i}].text`),
      };
    }),
    generated_at: asString(o.generated_at, "transcript.generated_at"),
  };
}

export function parseAccountInfo(result: GranolaToolCallResult): GranolaAccountInfo {
  const json = extractJson(result, "get_account_info");
  const o = asObject(json, "get_account_info");
  const tier = asString(o.plan_tier, "account.plan_tier");
  if (tier !== "free" && tier !== "paid") {
    throw new GranolaError(
      `Granola get_account_info returned unknown plan_tier '${tier}' ` +
        `(expected 'free' | 'paid' per docs)`,
    );
  }
  return {
    workspace_id: asString(o.workspace_id, "account.workspace_id"),
    workspace_name: asString(o.workspace_name, "account.workspace_name"),
    plan_tier: tier as GranolaPlanTier,
    user_email: asStringOrNull(o.user_email, "account.user_email"),
    transcripts_enabled: asBool(
      o.transcripts_enabled ?? tier === "paid",
      "account.transcripts_enabled",
    ),
    folders_enabled: asBool(
      o.folders_enabled ?? tier === "paid",
      "account.folders_enabled",
    ),
  };
}
