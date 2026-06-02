// Note write capabilities. Bullhorn entity: Note.
// Consumer: Concierge (post-send activity-log entry per agent.md §4 Step 13;
// action_type='bullhorn_activity_log_write' green tier per
// agents/_shared/autosend-policy.yaml) + Scribe (post-call note attachment).

import { BullhornClient } from "./client.js";
import type { BullhornNote, BullhornNoteWriteRequest } from "./types.js";

/**
 * Create a Note against a candidate / ClientContact. Used by Concierge for
 * the post-send activity-log entry (green tier; not customer-visible) and
 * by Scribe for the post-call tacit-knowledge attachment.
 *
 * Bullhorn PUT /entity/Note → returns { changedEntityId } for the new note.
 * No retry (writes are non-idempotent at the upstream).
 */
export async function createNote(
  client: BullhornClient,
  note: BullhornNoteWriteRequest,
): Promise<{ changedEntityType: string; changedEntityId: number; changeType: string }> {
  return client.request<{
    changedEntityType: string;
    changedEntityId: number;
    changeType: string;
  }>(`/entity/Note`, {
    method: "PUT",
    body: note,
  });
}

/**
 * Convenience wrapper for the Concierge activity-log pattern.
 * Equivalent to `createNote(client, { action: 'Activity', comments, personReference: { id: candidate_id } })`.
 */
export async function createActivityLogEntry(
  client: BullhornClient,
  candidate_id: number,
  comments: string,
): Promise<{ changedEntityType: string; changedEntityId: number; changeType: string }> {
  return createNote(client, {
    action: "Activity",
    comments,
    personReference: { id: candidate_id },
  });
}

/** Fetch a Note by id (mainly for test assertions; not a hot-path read). */
export async function getNote(
  client: BullhornClient,
  id: number,
): Promise<BullhornNote | null> {
  try {
    const res = await client.request<{ data: BullhornNote }>(
      `/entity/Note/${id}`,
      { query: { fields: "id,action,comments,dateAdded,personReference,commentingPerson" } },
    );
    return res.data;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}
