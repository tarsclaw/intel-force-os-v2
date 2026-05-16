export class WorkerError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number = 500,
  ) {
    super(message);
    this.name = 'WorkerError';
  }
}

export function isError(value: unknown): value is Error {
  return value instanceof Error;
}

export function errorMessage(value: unknown): string {
  if (value instanceof Error) return value.message;
  if (typeof value === 'string') return value;
  return 'Unknown error';
}
