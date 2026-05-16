const UK_PHONE = /(\+44|0)\s*\d[\d\s]{8,12}/g;
const NHS_NUMBER = /\b\d{3}[\s-]?\d{3}[\s-]?\d{4}\b/g;
const EMAIL = /[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}/g;
const SORT_CODE = /\b\d{2}[\s\-]\d{2}[\s\-]\d{2}\b/g;
const BANK_ACCOUNT = /\b\d{8}\b/g;

export function redactPII(text: string): string {
  return text
    .replace(UK_PHONE, '[REDACTED_PHONE]')
    .replace(NHS_NUMBER, '[REDACTED_NHS]')
    .replace(EMAIL, '[REDACTED_EMAIL]')
    .replace(SORT_CODE, '[REDACTED_SORT_CODE]')
    .replace(BANK_ACCOUNT, '[REDACTED_ACCOUNT]');
}

export function redactName(aadObjectId: string): string {
  // v1: return truncated AAD ID as a placeholder
  // v1.1: Graph API lookup to get initials
  return aadObjectId.slice(0, 8) + '...';
}
