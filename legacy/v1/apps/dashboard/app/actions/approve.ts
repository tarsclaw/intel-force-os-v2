'use server';

import { auth } from '@clerk/nextjs/server';
import { revalidatePath } from 'next/cache';

export async function approveEscalation(
  correlationId: string,
  tenantId: string,
  tenantSlug: string,
  action: 'approve' | 'reject' | 'escalate',
  editedReply?: string,
): Promise<{ success: boolean; error?: string }> {
  const { userId } = await auth();
  if (!userId) return { success: false, error: 'Unauthorized' };

  const workerUrl = process.env.WORKER_URL;
  const apiKey = process.env.PORTAL_API_KEY;

  if (!workerUrl || !apiKey) {
    // Not yet configured — Teams card flow is still available
    console.warn('approval_service_unconfigured', { workerUrl: !!workerUrl, apiKey: !!apiKey });
    return {
      success: false,
      error: 'Web approval not yet configured. Use the Teams card instead.',
    };
  }

  try {
    const res = await fetch(`${workerUrl}/api/approve`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        auditId: correlationId,
        tenantId,
        action,
        editedReply,
        actorId: userId,
      }),
    });

    if (!res.ok) {
      const body = await res.text().catch(() => '');
      return { success: false, error: `Approval failed (${res.status})${body ? `: ${body}` : ''}` };
    }

    revalidatePath(`/t/${tenantSlug}/approvals`);
    revalidatePath(`/t/${tenantSlug}`);
    return { success: true };
  } catch (err) {
    const msg = err instanceof Error ? err.message : 'Unknown error';
    return { success: false, error: msg };
  }
}
