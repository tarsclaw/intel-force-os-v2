import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from './cn';

const buttonVariants = cva(
  'inline-flex items-center justify-center gap-1.5 rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-emerald disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-brand-emerald text-canvas hover:bg-emerald-500',
        secondary: 'bg-surface-raised text-text-primary hover:bg-border',
        ghost: 'text-text-secondary hover:text-text-primary hover:bg-surface-raised',
        destructive: 'bg-red-500/10 text-red-400 hover:bg-red-500/20',
        outline: 'border border-border text-text-secondary hover:bg-surface-raised hover:text-text-primary',
      },
      size: {
        sm: 'h-7 px-2.5 text-xs',
        md: 'h-8 px-3',
        lg: 'h-10 px-4',
      },
    },
    defaultVariants: { variant: 'secondary', size: 'md' },
  },
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export function Button({ className, variant, size, ...props }: ButtonProps) {
  return <button className={cn(buttonVariants({ variant, size }), className)} {...props} />;
}
