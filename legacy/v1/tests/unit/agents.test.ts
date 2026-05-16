import { describe, it, expect } from 'vitest';
import { ESCALATION_FALLBACK, sensitivityLabel, sensitivityColor } from '../../src/agents/types';

describe('AgentResponse helpers', () => {
  it('labels sensitivity correctly', () => {
    expect(sensitivityLabel(0.1)).toBe('Low');
    expect(sensitivityLabel(0.5)).toBe('Medium');
    expect(sensitivityLabel(0.8)).toBe('High');
    expect(sensitivityLabel(0.7)).toBe('High');
    expect(sensitivityLabel(0.4)).toBe('Medium');
    expect(sensitivityLabel(0.39)).toBe('Low');
  });

  it('maps sensitivity to card colors', () => {
    expect(sensitivityColor(0.1)).toBe('Good');
    expect(sensitivityColor(0.5)).toBe('Warning');
    expect(sensitivityColor(0.9)).toBe('Attention');
  });

  it('escalation fallback always recommends escalation', () => {
    expect(ESCALATION_FALLBACK.escalation_recommended).toBe(true);
    expect(ESCALATION_FALLBACK.sensitivity_score).toBe(1.0);
    expect(ESCALATION_FALLBACK.confidence).toBe(0.0);
    expect(ESCALATION_FALLBACK.draft_reply).toBeTruthy();
  });
});
