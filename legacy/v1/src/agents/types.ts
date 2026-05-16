export interface AgentInput {
  message: string;
  context: {
    employee_name: string;
    employee_aad_id: string;
    channel: string;
    channel_name: string;
    timestamp: string;
    company_name: string;
  };
}

export interface Citation {
  snippet: string;
  page: number | null;
  source: string | null;
  url: string | null;
}

export interface AgentResponse {
  draft_reply: string;
  sensitivity_score: number;
  sensitivity_category: SensitivityCategory | null;
  confidence: number;
  handbook_citations: Citation[];
  escalation_recommended: boolean;
  reasoning: string;
}

export type SensitivityCategory =
  | 'grievance'
  | 'resignation'
  | 'mental_health'
  | 'harassment'
  | 'health'
  | 'low_confidence'
  | 'system_unavailable'
  | 'other';

export const ESCALATION_FALLBACK: AgentResponse = {
  draft_reply:
    "I've flagged this for your attention — I wasn't able to process it and I want to make sure you see it. I'll have someone follow up with you shortly.",
  sensitivity_score: 1.0,
  sensitivity_category: 'system_unavailable',
  confidence: 0.0,
  handbook_citations: [],
  escalation_recommended: true,
  reasoning: 'Agent unavailable — fallback escalation triggered.',
};

export function sensitivityLabel(score: number): string {
  if (score >= 0.7) return 'High';
  if (score >= 0.4) return 'Medium';
  return 'Low';
}

export function sensitivityColor(score: number): string {
  if (score >= 0.7) return 'Attention';
  if (score >= 0.4) return 'Warning';
  return 'Good';
}

export function confidencePercent(score: number): string {
  return Math.round(score * 100).toString();
}
