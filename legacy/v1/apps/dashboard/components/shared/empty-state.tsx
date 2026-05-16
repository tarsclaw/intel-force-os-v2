import { cn } from '../../lib/cn';

interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  description?: string;
  action?: React.ReactNode;
  className?: string;
}

export function EmptyState({ icon, title, description, action, className }: EmptyStateProps) {
  return (
    <div className={cn('flex flex-col items-center justify-center py-16 px-4 text-center', className)}>
      {icon && (
        <div className="w-12 h-12 rounded-full bg-surface-raised flex items-center justify-center mb-4 text-text-muted">
          {icon}
        </div>
      )}
      <p className="text-sm font-medium text-text-primary mb-1">{title}</p>
      {description && (
        <p className="text-sm text-text-muted max-w-xs mb-4">{description}</p>
      )}
      {action}
    </div>
  );
}
