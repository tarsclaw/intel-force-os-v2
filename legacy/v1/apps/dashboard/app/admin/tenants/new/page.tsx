import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { WizardShell } from '../../../../components/wizard/wizard-shell';

export const metadata = { title: 'New Tenant' };

export default async function NewTenantPage() {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const draft = {
    id: 'admin-draft-new',
    currentStep: 1,
    draftData: {} as Record<string, Record<string, unknown>>,
  };

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-base font-semibold text-text-primary">New Tenant</h1>
        <p className="text-xs text-text-muted mt-0.5">Configure and provision a new tenant</p>
      </div>
      <WizardShell draft={draft} />
    </div>
  );
}
