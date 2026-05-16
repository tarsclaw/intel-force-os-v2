import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from './cn';

const badgeVariants = cva(
  'inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium transition-colors',
  {
    variants: {
      variant: {
        default: 'bg-surface-raised text-text-secondary',
        emerald: 'bg-brand-emerald/10 text-brand-emerald',
        amber: 'bg-brand-amber/10 text-brand-amber',
        red: 'bg-red-500/10 text-red-400',
        muted: 'text-text-muted',
      },
    },
    defaultVariants: { variant: 'default' },
  },
);

interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement>, VariantProps<typeof badgeVariants> {}

export function Badge({ className, variant, ...props }: BadgeProps) {
  return <span className={cn(badgeVariants({ variant }), className)} {...props} />;
}
