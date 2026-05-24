// Error types for web-scraper. Maps to escalation codes per agents/_shared/escalation-codes.md.

export class ScraperError extends Error {
  constructor(
    message: string,
    public readonly url: string,
    public readonly cause?: unknown,
  ) {
    super(message);
    this.name = "ScraperError";
  }
}

export class ScraperTimeoutError extends ScraperError {
  constructor(url: string, timeoutMs: number) {
    super(`timeout after ${timeoutMs}ms`, url);
    this.name = "ScraperTimeoutError";
  }
}

export class ScraperRobotsBlockedError extends ScraperError {
  constructor(url: string) {
    super(`robots.txt disallows`, url);
    this.name = "ScraperRobotsBlockedError";
  }
}

export class ScraperRateLimitError extends ScraperError {
  constructor(url: string) {
    super(`local rate limit budget exhausted`, url);
    this.name = "ScraperRateLimitError";
  }
}
