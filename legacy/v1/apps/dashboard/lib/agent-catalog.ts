// Static agent catalog — name, director, description, integrations, default
// schedule. The runtime status (RUNNING / ACTIVE / SCHEDULED / IDLE) and the
// recent-activity feed are derived from the Prisma `invocation` + `escalation`
// tables at request time; see lib/agent-activity.ts.

export type Director = 'HR' | 'Sales' | 'Marketing' | 'Operations';
export type AgentStatus = 'ACTIVE' | 'RUNNING' | 'SCHEDULED' | 'IDLE';
export type AgentModel = 'claude-opus-4-7' | 'claude-sonnet-4-6';

export interface AgentSpec {
  key: string;          // stable id, matches Invocation.agent string
  name: string;
  director: Director;
  defaultStatus: AgentStatus;
  model: AgentModel;
  description: string;
  schedule: string;
  output: string;       // human-readable headline label, e.g. "£24,200 engagement"
  integrations: string[];
}

export const AGENT_CATALOG: AgentSpec[] = [
  // ── HR Director ───────────────────────────────────────────────────────
  {
    key: 'hr-assistant',
    name: 'HR Assistant',
    director: 'HR',
    defaultStatus: 'ACTIVE',
    model: 'claude-sonnet-4-6',
    description:
      'Answers employee HR questions across Teams, Slack, and email. Combines handbook lookup with live Breathe HR data (leave entitlement, absence history, department mapping). Drafts a reply for HR Lead approval; sensitivity ≥ 0.7 escalates directly without a draft.',
    schedule: 'On-demand',
    output: 'Drafts ready for review',
    integrations: ['Microsoft Teams', 'Slack', 'Email', 'Breathe HR', 'Company handbook'],
  },
  {
    key: 'email-handler',
    name: 'Email Handler',
    director: 'HR',
    defaultStatus: 'ACTIVE',
    model: 'claude-sonnet-4-6',
    description:
      'Watches the shared HR inbox, classifies incoming threads (policy question, leave request, grievance, payroll), and routes each to the right downstream action. Threads tagged for HR Lead before any reply leaves the inbox.',
    schedule: 'On email',
    output: 'Inbox triaged',
    integrations: ['Email', 'Breathe HR'],
  },
  // ── Sales Director ────────────────────────────────────────────────────
  {
    key: 'proposal-builder',
    name: 'Proposal Builder',
    director: 'Sales',
    defaultStatus: 'RUNNING',
    model: 'claude-opus-4-7',
    description:
      'Pulls discovery call notes from Fathom, references past winning proposals stored in Notion, and drafts a scoped engagement with pricing and timeline. Sent for review the moment a call ends.',
    schedule: 'On call-end',
    output: '£24,200 engagement',
    integrations: ['Fathom', 'HubSpot', 'Notion'],
  },
  {
    key: 'lead-hunter',
    name: 'Lead Hunter',
    director: 'Sales',
    defaultStatus: 'ACTIVE',
    model: 'claude-opus-4-7',
    description:
      'Queries Companies House and Apollo/Clay, qualifies against the client ICP, and writes enriched lead records to HubSpot. De-duplicates against existing contacts and assigns scores by firmographic fit.',
    schedule: 'Daily 08:00',
    output: '38 qualified leads',
    integrations: ['HubSpot', 'Companies House', 'Clay'],
  },
  {
    key: 'follow-up-pilot',
    name: 'Follow-Up Pilot',
    director: 'Sales',
    defaultStatus: 'ACTIVE',
    model: 'claude-opus-4-7',
    description:
      'Monitors CRM for dormant prospects (>14 days of inactivity), generates voice-matched follow-ups, and books replies into Calendly. Current run: 21 sends with 7 replies (33% open rate).',
    schedule: 'Hourly',
    output: '21 sends · 7 replies',
    integrations: ['Gmail', 'HubSpot', 'Calendly'],
  },
  // ── Marketing Director ────────────────────────────────────────────────
  {
    key: 'content-creator',
    name: 'Content Creator',
    director: 'Marketing',
    defaultStatus: 'RUNNING',
    model: 'claude-opus-4-7',
    description:
      'Trained on the client voice profile (URL samples + tone description from onboarding). Produces long-form content from a one-line brief — blog posts, LinkedIn articles, email sequences. Drafts staged in Notion for review.',
    schedule: 'On-brief',
    output: '4 drafts queued',
    integrations: ['Notion', 'Google Docs'],
  },
  {
    key: 'repurposer',
    name: 'Repurposer',
    director: 'Marketing',
    defaultStatus: 'ACTIVE',
    model: 'claude-opus-4-7',
    description:
      'Takes one pillar piece (podcast, long-form article, webinar) and turns it into LinkedIn post, Instagram carousel, YouTube Short script, email, and X thread — all voice-matched and ready for Buffer.',
    schedule: 'On pillar publish',
    output: '9 derivative pieces',
    integrations: ['Notion', 'Buffer'],
  },
  {
    key: 'caption-writer',
    name: 'Caption Writer',
    director: 'Marketing',
    defaultStatus: 'ACTIVE',
    model: 'claude-opus-4-7',
    description:
      'Writes platform-native social captions with CTAs tuned per network. Sources assets from Drive, writes captions in client tone, queues them in Buffer with optimal timing based on historical engagement.',
    schedule: 'Daily 07:00',
    output: '17 captions ready',
    integrations: ['Buffer', 'Google Drive'],
  },
  // ── Operations Director ───────────────────────────────────────────────
  {
    key: 'client-onboarder',
    name: 'Client Onboarder',
    director: 'Operations',
    defaultStatus: 'ACTIVE',
    model: 'claude-sonnet-4-6',
    description:
      'Fires on contract signature via DocuSign webhook. Creates the Slack channel, sends the welcome sequence, dispatches the intake form, and drops the kickoff invite in the client calendar.',
    schedule: 'On contract sign',
    output: '2 in progress',
    integrations: ['DocuSign', 'Slack', 'ClickUp'],
  },
  {
    key: 'reporting-engine',
    name: 'Reporting Engine',
    director: 'Operations',
    defaultStatus: 'SCHEDULED',
    model: 'claude-sonnet-4-6',
    description:
      'Aggregates Stripe revenue, GA4 traffic, Meta Ads performance, and CRM pipeline. Delivers a weekly intelligence briefing to Slack and as a PDF — ready before Monday standup.',
    schedule: 'Friday 07:00',
    output: 'Weekly briefing',
    integrations: ['Stripe', 'GA4', 'Meta Ads', 'Slack'],
  },
  {
    key: 'sop-writer',
    name: 'SOP Writer',
    director: 'Operations',
    defaultStatus: 'IDLE',
    model: 'claude-sonnet-4-6',
    description:
      'Ingests Loom screen recordings and auto-generates Notion-formatted SOPs from the narration and screen actions. Library has 34 SOPs. Idle — no new Looms queued.',
    schedule: 'On Loom upload',
    output: '34 SOPs in library',
    integrations: ['Loom', 'Notion'],
  },
];

export function findAgent(key: string): AgentSpec | undefined {
  return AGENT_CATALOG.find((a) => a.key === key);
}
