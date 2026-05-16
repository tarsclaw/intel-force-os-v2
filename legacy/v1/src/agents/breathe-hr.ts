/**
 * Breathe HR API client
 * API docs: https://developer.breathehr.com/
 * Base URL: https://api.breathehr.com/v1
 *
 * Auth: Bearer token (API key from Breathe HR admin settings)
 * Set per tenant via Wrangler secret or Secrets Vault.
 */

const BREATHE_BASE = 'https://api.breathehr.com/v1';

export interface BreatheEmployee {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
  job_title: string | null;
  department: { name: string } | null;
  start_date: string | null;
  line_manager: { first_name: string; last_name: string; email: string } | null;
  status: 'Active' | 'Inactive';
}

export interface BreatheLeaveAllowance {
  allowance_type: { name: string };
  allowance: number;
  used: number;
  remaining: number;
  unit: 'days' | 'hours';
  year: number;
}

export interface BreatheEmployeeSummary {
  id: number;
  fullName: string;
  email: string;
  jobTitle: string | null;
  department: string | null;
  startDate: string | null;
  lineManagerName: string | null;
  leaveAllowances: BreatheLeaveAllowance[];
}

async function breatheFetch<T>(
  path: string,
  apiKey: string,
): Promise<T> {
  const resp = await fetch(`${BREATHE_BASE}${path}`, {
    headers: {
      Authorization: `Bearer ${apiKey}`,
      Accept: 'application/json',
    },
  });

  if (!resp.ok) {
    throw new Error(`Breathe HR API ${resp.status}: ${path}`);
  }

  return resp.json() as Promise<T>;
}

// Search for an employee by name (case-insensitive partial match)
export async function findEmployee(
  apiKey: string,
  name: string,
): Promise<BreatheEmployee | null> {
  // Breathe HR supports filtering via query params
  const query = encodeURIComponent(name.trim());
  const data = await breatheFetch<{ employees: BreatheEmployee[] }>(
    `/employees?search=${query}`,
    apiKey,
  );

  if (!data.employees?.length) return null;

  // Exact match first, then partial
  const lower = name.toLowerCase();
  return (
    data.employees.find(
      (e) => `${e.first_name} ${e.last_name}`.toLowerCase() === lower,
    ) ??
    data.employees.find(
      (e) =>
        e.first_name.toLowerCase().includes(lower) ||
        e.last_name.toLowerCase().includes(lower),
    ) ??
    null
  );
}

// Get an employee's leave allowances for the current year
export async function getLeaveAllowances(
  apiKey: string,
  employeeId: number,
): Promise<BreatheLeaveAllowance[]> {
  const data = await breatheFetch<{ leave_allowances: BreatheLeaveAllowance[] }>(
    `/employees/${employeeId}/leave_allowances`,
    apiKey,
  );
  return data.leave_allowances ?? [];
}

// Full employee summary — combined from employee + leave endpoints
export async function getEmployeeSummary(
  apiKey: string,
  employeeName: string,
): Promise<BreatheEmployeeSummary | null> {
  const employee = await findEmployee(apiKey, employeeName);
  if (!employee) return null;

  let leaveAllowances: BreatheLeaveAllowance[] = [];
  try {
    leaveAllowances = await getLeaveAllowances(apiKey, employee.id);
  } catch {
    // Leave endpoint unavailable — return partial data
  }

  return {
    id: employee.id,
    fullName: `${employee.first_name} ${employee.last_name}`,
    email: employee.email,
    jobTitle: employee.job_title,
    department: employee.department?.name ?? null,
    startDate: employee.start_date,
    lineManagerName: employee.line_manager
      ? `${employee.line_manager.first_name} ${employee.line_manager.last_name}`
      : null,
    leaveAllowances,
  };
}

// Format employee summary as a tool response string
export function formatEmployeeSummary(summary: BreatheEmployeeSummary): string {
  const lines = [
    `Employee: ${summary.fullName} (${summary.email})`,
    `Job title: ${summary.jobTitle ?? 'not set'}`,
    `Department: ${summary.department ?? 'not set'}`,
    `Start date: ${summary.startDate ?? 'not set'}`,
    `Line manager: ${summary.lineManagerName ?? 'not set'}`,
  ];

  if (summary.leaveAllowances.length > 0) {
    lines.push('');
    lines.push('Leave allowances:');
    for (const allowance of summary.leaveAllowances) {
      lines.push(
        `  ${allowance.allowance_type.name}: ${allowance.remaining} ${allowance.unit} remaining of ${allowance.allowance} total (${allowance.used} used)`,
      );
    }
  }

  return lines.join('\n');
}
