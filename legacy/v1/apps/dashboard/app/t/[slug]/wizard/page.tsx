import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { Sparkles, ShieldCheck, Save } from 'lucide-react';
import { WizardShell } from '../../../../components/wizard/wizard-shell';
import { PageHeader, Card, CardBody, StatusPill } from '@/components/shared';

export const metadata = { title: 'Setup Wizard' };

// The wizard auto-saves as you go (per step). On submit (step 7),
// Phase 4 will kick off a brain build using the uploaded handbook.
// Until then, submission completes the tenant config but skips brain ingestion.
export default async function WizardPage({ params }: { params: Promise<{ slug: string }> }) {
  const { userId } = await auth();
  if (!userId) redirect('/sign-in');

  const { slug } = await params;
  void slug;

  const mockDraft = {
    id: 'draft-placeholder',
    currentStep: 1,
    draftData: {} as Record<string, Record<string, unknown>>,
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Set up a new tenant"
        description="9 steps · auto-saves as you go · the agent goes live in roughly 60 seconds after submission"
        actions={
          <div className="flex items-center gap-2">
            <StatusPill tone="info" icon={Save}>
              Auto-saving
            </StatusPill>
            <StatusPill tone="muted">Draft</StatusPill>
          </div>
        }
      />

      {/* Operator-first banner */}
      <Card>
        <CardBody className="flex flex-wrap items-center gap-x-5 gap-y-2 py-4">
          <div className="flex items-center gap-2 text-sm">
            <ShieldCheck className="w-4 h-4 text-emerald-400 shrink-0" />
            <span className="text-text-secondary">
              <strong className="text-text-primary">Operator-first.</strong> You configure on
              behalf of the customer — they don't see the wizard.
            </span>
          </div>
          <div className="flex items-center gap-2 text-sm">
            <Sparkles className="w-4 h-4 text-violet-400 shrink-0" />
            <span className="text-text-secondary">
              Step 7 kicks off the brain build automatically.
            </span>
          </div>
        </CardBody>
      </Card>

      {/* Wizard shell */}
      <Card>
        <CardBody className="p-6">
          <WizardShell draft={mockDraft} />
        </CardBody>
      </Card>
    </div>
  );
}
