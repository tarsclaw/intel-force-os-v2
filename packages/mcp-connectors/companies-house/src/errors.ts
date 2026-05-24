// Error types for Companies House connector. Maps to escalation codes per
// agents/_shared/escalation-codes.md and tools.yaml §2 failure_modes.

export class CHError extends Error {
  constructor(
    message: string,
    public readonly endpoint: string,
    public readonly status?: number,
    public readonly cause?: unknown,
  ) {
    super(message);
    this.name = "CHError";
  }
}

export class CHAuthError extends CHError {
  constructor(endpoint: string) {
    super("Companies House API key invalid or missing", endpoint, 401);
    this.name = "CHAuthError";
  }
}

export class CHRateLimitError extends CHError {
  constructor(endpoint: string) {
    super("rate limit exceeded; back off 60s and retry", endpoint, 429);
    this.name = "CHRateLimitError";
  }
}

export class CHNotFoundError extends CHError {
  constructor(endpoint: string) {
    super("resource not found", endpoint, 404);
    this.name = "CHNotFoundError";
  }
}
