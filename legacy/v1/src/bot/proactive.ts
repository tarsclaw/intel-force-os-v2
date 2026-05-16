import { sendCard } from './teams-api';
import { buildWeeklyReportCard } from '../cards/report';
import { getAllTenantIds, getTenantConfig, getConversationRef } from '../storage/config';
import { getWeeklyStats } from '../storage/audit';
import type { Env } from '../index';

export async function sendWeeklyReports(
  env: Env,
  ctx: ExecutionContext,
): Promise<void> {
  const tenantIds = await getAllTenantIds(env.TENANT_CONFIG);
  console.log('weekly_report_start', { tenantCount: tenantIds.length });

  for (const tenantId of tenantIds) {
    ctx.waitUntil(sendReportForTenant(tenantId, env));
  }
}

async function sendReportForTenant(tenantId: string, env: Env): Promise<void> {
  try {
    const config = await getTenantConfig(env.TENANT_CONFIG, tenantId);
    if (!config) return;
    if (!config.weeklyReportEnabled) return;
    if (config.subscriptionStatus !== 'active') return;

    const weekStart = lastMonday();
    const stats = await getWeeklyStats(env.AUDIT_DB, tenantId, weekStart);

    if (stats.total === 0) return; // No messages this week, skip

    const weekEnd = new Date(weekStart.getTime() + 6 * 86_400_000);
    const card = buildWeeklyReportCard({
      customerName: config.customerName,
      weekStartDate: formatShortDate(weekStart),
      weekEndDate: formatShortDate(weekEnd),
      messagesHandled: stats.total,
      approvedAsIs: stats.approved,
      approvedAsIsPercent: pct(stats.approved, stats.total),
      edited: stats.edited,
      editedPercent: pct(stats.edited, stats.total),
      rejected: stats.rejected,
      escalated: stats.escalated,
      avgConfidence: (stats.avgConfidence * 5).toFixed(1),
      topPatterns: [],
      thisWeekPriority: generatePriority(stats),
    });

    const ref = await getConversationRef(
      env.TENANT_CONFIG,
      tenantId,
      config.hrLeadAadId,
    );

    if (!ref) {
      console.warn('weekly_report_no_ref', { tenantId });
      return;
    }

    await sendCard(ref.serviceUrl, ref.conversationId, card, env.MICROSOFT_APP_ID, env.MICROSOFT_APP_PASSWORD);
    console.log('weekly_report_sent', { tenantId, total: stats.total });
  } catch (err) {
    console.error('weekly_report_error', {
      tenantId,
      error: err instanceof Error ? err.message : 'unknown',
    });
  }
}

function generatePriority(stats: Awaited<ReturnType<typeof getWeeklyStats>>): string {
  const editRate = stats.total > 0 ? stats.edited / stats.total : 0;
  const escalateRate = stats.total > 0 ? stats.escalated / stats.total : 0;

  if (editRate > 0.3) {
    return `${Math.round(editRate * 100)}% of drafts were edited before sending — review the prompt tone and policy coverage this week.`;
  }
  if (escalateRate > 0.2) {
    return `${stats.escalated} escalations this week (${Math.round(escalateRate * 100)}%) — check if the agent's sensitivity threshold needs adjusting.`;
  }
  if (stats.total === 0) {
    return 'No messages handled this week. Is the bot connected to the right channel?';
  }
  return `All steady. ${stats.approved} out of ${stats.total} messages approved as-is (${pct(stats.approved, stats.total)}%).`;
}

function lastMonday(): Date {
  const now = new Date();
  const day = now.getUTCDay();
  const diff = day === 0 ? 6 : day - 1;
  const monday = new Date(now);
  monday.setUTCDate(monday.getUTCDate() - diff);
  monday.setUTCHours(0, 0, 0, 0);
  return monday;
}

function formatShortDate(date: Date): string {
  return date.toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    timeZone: 'UTC',
  });
}

function pct(part: number, total: number): number {
  if (total === 0) return 0;
  return Math.round((part / total) * 100);
}
