'use client';

import { useState, useCallback } from 'react';
import { CheckCircle, Circle, Loader2, ChevronRight } from 'lucide-react';
import { cn } from '../../lib/cn';
import { trpc } from '../../lib/trpc';
import { Step1Basics } from './steps/step1-basics';
import { Step2Plan } from './steps/step2-plan';
import { Step3Voice } from './steps/step3-voice';
import { Step4Brand } from './steps/step4-brand';
import { Step5AgentConfig } from './steps/step5-agent-config';
import { Step6Integrations } from './steps/step6-integrations';
import { Step7Review } from './steps/step7-review';
import { Step8OAuth } from './steps/step8-oauth';
import { Step9Provisioning } from './steps/step9-provisioning';

export interface WizardDraft {
  id: string;
  currentStep: number;
  draftData: Record<string, Record<string, unknown>>;
}

interface WizardShellProps {
  draft: WizardDraft;
}

const STEPS = [
  { num: 1, label: 'Basics' },
  { num: 2, label: 'Plan' },
  { num: 3, label: 'Voice' },
  { num: 4, label: 'Brand' },
  { num: 5, label: 'Agents' },
  { num: 6, label: 'Integrations' },
  { num: 7, label: 'Review' },
  { num: 8, label: 'OAuth' },
  { num: 9, label: 'Live' },
];

export function WizardShell({ draft }: WizardShellProps) {
  const [currentStep, setCurrentStep] = useState(Math.min(draft.currentStep, 7));
  const [stepData, setStepData] = useState<Record<number, Record<string, unknown>>>(
    Object.fromEntries(
      Object.entries(draft.draftData).map(([k, v]) => [Number(k.replace('step', '')), v]),
    ),
  );
  const [tenantSlug, setTenantSlug] = useState<string | null>(null);

  const saveStepMutation = trpc.wizard.saveStep.useMutation();
  const submitMutation = trpc.wizard.submit.useMutation();

  const isSaving = saveStepMutation.isPending || submitMutation.isPending;

  const saveStep = useCallback(async (step: number, data: Record<string, unknown>) => {
    setStepData((prev) => ({ ...prev, [step]: data }));
    await saveStepMutation.mutateAsync({ draftId: draft.id, step, data });
  }, [draft.id, saveStepMutation]);

  function goNext() {
    setCurrentStep((s) => Math.min(s + 1, 9));
  }

  function goBack() {
    setCurrentStep((s) => Math.max(s - 1, 1));
  }

  async function handleSubmit(confirmSlug: string) {
    const result = await submitMutation.mutateAsync({ draftId: draft.id, confirmSlug });
    setTenantSlug(result.tenant.slug);
    setCurrentStep(8);
  }

  const completedSteps = new Set(
    Object.keys(stepData)
      .map(Number)
      .filter((n) => Object.keys(stepData[n] ?? {}).length > 0),
  );

  return (
    <div className="flex gap-6">
      {/* Step indicator — left rail */}
      <aside className="w-44 shrink-0">
        <nav aria-label="Wizard steps">
          <ol className="space-y-1">
            {STEPS.map(({ num, label }) => {
              const isComplete = completedSteps.has(num) && num < currentStep;
              const isCurrent = num === currentStep;
              const isLocked = num > Math.max(currentStep, draft.currentStep);

              return (
                <li key={num}>
                  <button
                    onClick={() => !isLocked && setCurrentStep(num)}
                    disabled={isLocked}
                    className={cn(
                      'w-full flex items-center gap-2.5 px-3 py-2 rounded-md text-sm transition-colors text-left',
                      isCurrent && 'bg-surface-raised text-text-primary',
                      !isCurrent && !isLocked && 'text-text-secondary hover:text-text-primary hover:bg-surface-raised',
                      isLocked && 'text-text-muted cursor-not-allowed opacity-50',
                    )}
                  >
                    <span className="shrink-0">
                      {isComplete ? (
                        <CheckCircle className="w-4 h-4 text-brand-emerald" />
                      ) : isCurrent ? (
                        <div className="w-4 h-4 rounded-full border-2 border-brand-emerald" />
                      ) : (
                        <Circle className="w-4 h-4 text-text-muted" />
                      )}
                    </span>
                    <span className="text-sm">{label}</span>
                  </button>
                </li>
              );
            })}
          </ol>
        </nav>
        {isSaving && (
          <div className="flex items-center gap-1.5 mt-4 px-3">
            <Loader2 className="w-3 h-3 animate-spin text-text-muted" />
            <span className="text-xs text-text-muted">Auto-saving…</span>
          </div>
        )}
      </aside>

      {/* Step content */}
      <div className="flex-1 min-w-0 bg-surface border border-border rounded-lg p-6">
        {currentStep === 1 && (
          <Step1Basics
            data={stepData[1] ?? {}}
            onSave={(d) => saveStep(1, d)}
            onNext={goNext}
            draftId={draft.id}
          />
        )}
        {currentStep === 2 && (
          <Step2Plan data={stepData[2] ?? {}} onSave={(d) => saveStep(2, d)} onNext={goNext} onBack={goBack} />
        )}
        {currentStep === 3 && (
          <Step3Voice data={stepData[3] ?? {}} onSave={(d) => saveStep(3, d)} onNext={goNext} onBack={goBack} />
        )}
        {currentStep === 4 && (
          <Step4Brand data={stepData[4] ?? {}} onSave={(d) => saveStep(4, d)} onNext={goNext} onBack={goBack} />
        )}
        {currentStep === 5 && (
          <Step5AgentConfig data={stepData[5] ?? {}} plan={String(stepData[2]?.['plan'] ?? 'STARTER')} onSave={(d) => saveStep(5, d)} onNext={goNext} onBack={goBack} />
        )}
        {currentStep === 6 && (
          <Step6Integrations data={stepData[6] ?? {}} plan={String(stepData[2]?.['plan'] ?? 'STARTER')} onSave={(d) => saveStep(6, d)} onNext={goNext} onBack={goBack} />
        )}
        {currentStep === 7 && (
          <Step7Review
            allStepData={stepData}
            onBack={goBack}
            onSubmit={handleSubmit}
            isSaving={isSaving}
          />
        )}
        {currentStep === 8 && (
          <Step8OAuth tenantSlug={tenantSlug ?? ''} onNext={goNext} />
        )}
        {currentStep === 9 && (
          <Step9Provisioning tenantSlug={tenantSlug ?? ''} />
        )}
      </div>
    </div>
  );
}

// Shared step footer component
export function StepFooter({
  onBack,
  onNext,
  nextLabel = 'Continue',
  nextDisabled = false,
  isSaving = false,
  showBack = true,
}: {
  onBack?: () => void;
  onNext?: () => void;
  nextLabel?: string;
  nextDisabled?: boolean;
  isSaving?: boolean;
  showBack?: boolean;
}) {
  return (
    <div className="flex items-center justify-between mt-6 pt-4 border-t border-border">
      <div>
        {showBack && onBack && (
          <button
            type="button"
            onClick={onBack}
            className="text-sm text-text-muted hover:text-text-secondary transition-colors"
          >
            ← Back
          </button>
        )}
      </div>
      {onNext && (
        <button
          type="button"
          onClick={onNext}
          disabled={nextDisabled || isSaving}
          className="flex items-center gap-1.5 px-4 py-2 bg-brand-emerald text-canvas text-sm font-medium rounded-md hover:bg-emerald-500 disabled:opacity-50 transition-colors"
        >
          {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : null}
          {nextLabel}
          {!isSaving && <ChevronRight className="w-4 h-4" />}
        </button>
      )}
    </div>
  );
}
