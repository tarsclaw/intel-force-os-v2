import { describe, it, expect } from 'vitest';
import { redactPII } from '../../src/utils/redact';

describe('PII redaction', () => {
  it('redacts UK phone numbers', () => {
    expect(redactPII('Call me on 07700 900123')).toBe('Call me on [REDACTED_PHONE]');
    expect(redactPII('My number is +44 7700 900456')).toContain('[REDACTED_PHONE]');
  });

  it('redacts email addresses', () => {
    expect(redactPII('Email sarah@acme.com please')).toBe('Email [REDACTED_EMAIL] please');
  });

  it('leaves non-PII text untouched', () => {
    const text = 'I would like to know the holiday carry-over policy.';
    expect(redactPII(text)).toBe(text);
  });

  it('handles multiple PII items in one message', () => {
    const input = 'Contact sarah@acme.com or call 07700 900123';
    const result = redactPII(input);
    expect(result).toContain('[REDACTED_EMAIL]');
    expect(result).toContain('[REDACTED_PHONE]');
    expect(result).not.toContain('sarah@acme.com');
    expect(result).not.toContain('07700 900123');
  });
});
