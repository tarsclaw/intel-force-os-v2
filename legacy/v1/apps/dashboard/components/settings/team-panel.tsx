'use client';

import { useState } from 'react';
import { UserPlus, Shield, Eye, Users, Loader2 } from 'lucide-react';
import { cn } from '../../lib/cn';
import { trpc } from '../../lib/trpc';

interface Member {
  role: string;
  user: { id: string; name: string | null; email: string; imageUrl: string | null };
}

const roleConfig: Record<string, { label: string; icon: React.ElementType; colour: string }> = {
  TENANT_OWNER: { label: 'Owner', icon: Shield, colour: 'text-brand-amber' },
  TENANT_MEMBER: { label: 'Member', icon: Users, colour: 'text-brand-emerald' },
  TENANT_VIEWER: { label: 'Viewer', icon: Eye, colour: 'text-text-muted' },
};

export function TeamPanel({ members }: { members: Member[] }) {
  const [showInvite, setShowInvite] = useState(false);
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteRole, setInviteRole] = useState<'TENANT_MEMBER' | 'TENANT_VIEWER'>('TENANT_MEMBER');
  const [success, setSuccess] = useState<string | null>(null);

  const inviteMutation = trpc.invitations.create.useMutation({
    onSuccess: (data) => {
      setShowInvite(false);
      setInviteEmail('');
      setSuccess(`Invitation created for ${data.email}. Share the invite link with them.`);
      setTimeout(() => setSuccess(null), 6000);
    },
  });

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-sm font-semibold text-text-primary">Team</h2>
        <button onClick={() => setShowInvite(true)}
          className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium bg-brand-emerald text-canvas rounded-md hover:bg-emerald-500 transition-colors">
          <UserPlus className="w-3.5 h-3.5" />Invite
        </button>
      </div>

      {success && <p className="mb-3 text-xs text-brand-emerald bg-brand-emerald/10 px-3 py-2 rounded">{success}</p>}
      {inviteMutation.error && <p className="mb-3 text-xs text-red-400">{inviteMutation.error.message}</p>}

      {showInvite && (
        <form onSubmit={(e) => { e.preventDefault(); inviteMutation.mutate({ email: inviteEmail, role: inviteRole }); }}
          className="mb-4 p-3 bg-surface-raised border border-border rounded-lg space-y-3">
          <h3 className="text-xs font-medium text-text-primary">Invite team member</h3>
          <input type="email" value={inviteEmail} onChange={(e) => setInviteEmail(e.target.value)}
            placeholder="email@company.com" required
            className="w-full bg-surface border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald" />
          <select value={inviteRole} onChange={(e) => setInviteRole(e.target.value as typeof inviteRole)}
            className="w-full bg-surface border border-border rounded-md px-3 py-2 text-sm text-text-primary focus:outline-none focus:border-brand-emerald">
            <option value="TENANT_MEMBER">Member — can view and take actions</option>
            <option value="TENANT_VIEWER">Viewer — read-only access</option>
          </select>
          <div className="flex gap-2">
            <button type="submit" disabled={inviteMutation.isPending}
              className="flex items-center gap-1.5 px-3 py-1.5 bg-brand-emerald text-canvas text-xs font-medium rounded-md hover:bg-emerald-500 disabled:opacity-50 transition-colors">
              {inviteMutation.isPending && <Loader2 className="w-3 h-3 animate-spin" />}
              Send invite
            </button>
            <button type="button" onClick={() => setShowInvite(false)} className="text-xs text-text-muted hover:text-text-secondary transition-colors px-2">Cancel</button>
          </div>
        </form>
      )}

      <table className="w-full text-sm" aria-label="Team members">
        <thead>
          <tr className="border-b border-border">
            <th className="text-left text-xs text-text-muted font-medium pb-2 pr-4">Member</th>
            <th className="text-left text-xs text-text-muted font-medium pb-2">Role</th>
          </tr>
        </thead>
        <tbody>
          {members.map((m) => {
            const cfg = roleConfig[m.role] ?? roleConfig['TENANT_VIEWER']!;
            const Icon = cfg.icon;
            return (
              <tr key={m.user.id} className="border-b border-border/50">
                <td className="py-2.5 pr-4">
                  <div className="flex items-center gap-2">
                    <div className="w-7 h-7 rounded-full bg-surface-raised flex items-center justify-center text-xs font-medium text-text-secondary shrink-0">
                      {(m.user.name ?? m.user.email).charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <p className="text-sm text-text-primary">{m.user.name ?? '—'}</p>
                      <p className="text-xs text-text-muted">{m.user.email}</p>
                    </div>
                  </div>
                </td>
                <td className="py-2.5">
                  <div className={cn('flex items-center gap-1.5 text-xs', cfg.colour)}>
                    <Icon className="w-3.5 h-3.5" />{cfg.label}
                  </div>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
