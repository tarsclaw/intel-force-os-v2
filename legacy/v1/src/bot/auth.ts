import { createRemoteJWKSet, jwtVerify } from 'jose';
import type { Env } from '../index';

const JWKS_URL = 'https://login.botframework.com/v1/.well-known/keys';
const ISSUER = 'https://api.botframework.com';

// Module-level cache so the JWKS isn't fetched on every request within the same isolate
let cachedJwks: ReturnType<typeof createRemoteJWKSet> | null = null;
let cacheTimestamp = 0;
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

function getJwks(): ReturnType<typeof createRemoteJWKSet> {
  const now = Date.now();
  if (!cachedJwks || now - cacheTimestamp > CACHE_TTL_MS) {
    cachedJwks = createRemoteJWKSet(new URL(JWKS_URL));
    cacheTimestamp = now;
  }
  return cachedJwks;
}

export interface JWTResult {
  valid: boolean;
  error?: string;
}

export async function verifyBotToken(request: Request, env: Env): Promise<JWTResult> {
  const auth = request.headers.get('Authorization');
  if (!auth?.startsWith('Bearer ')) {
    return { valid: false, error: 'Missing Authorization header' };
  }

  const token = auth.slice(7);

  try {
    await jwtVerify(token, getJwks(), {
      issuer: ISSUER,
      audience: env.MICROSOFT_APP_ID,
    });
    return { valid: true };
  } catch (err) {
    const msg = err instanceof Error ? err.message : 'JWT verification failed';
    return { valid: false, error: msg };
  }
}

// Bot Framework access token for making outbound calls to Teams
export async function getBotToken(
  appId: string,
  appPassword: string,
): Promise<string> {
  const resp = await fetch(
    'https://login.microsoftonline.com/botframework.com/oauth2/v2.0/token',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: appId,
        client_secret: appPassword,
        scope: 'https://api.botframework.com/.default',
      }),
    },
  );

  if (!resp.ok) {
    throw new Error(`Bot token request failed: ${resp.status}`);
  }

  const data = (await resp.json()) as { access_token: string };
  return data.access_token;
}
