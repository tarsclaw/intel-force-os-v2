import { SignUp } from '@clerk/nextjs';

export default function SignUpPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-canvas">
      <div className="flex flex-col items-center gap-6">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-md bg-brand-emerald flex items-center justify-center">
            <span className="text-canvas text-sm font-bold">IF</span>
          </div>
          <span className="text-text-primary font-semibold text-base">Intel Force OS</span>
        </div>
        <SignUp />
      </div>
    </div>
  );
}
