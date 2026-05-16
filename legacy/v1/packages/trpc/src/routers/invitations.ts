import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, tenantProcedure } from '../init';
import { TeamInviteSchema } from '@intelforce/schemas';
import { randomUUID } from 'crypto';

export const invitationsRouter = router({
  list: tenantProcedure.query(async ({ ctx }) => {
    return ctx.db.invitation.findMany({
      where: { tenantId: ctx.tenantId, acceptedAt: null, expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
    });
  }),

  create: tenantProcedure
    .input(TeamInviteSchema)
    .mutation(async ({ ctx, input }) => {
      // Check if user already has a role in this tenant
      const existingUser = await ctx.db.user.findFirst({ where: { email: input.email } });
      if (existingUser) {
        const existingRole = await ctx.db.userRole.findFirst({
          where: { userId: existingUser.id, tenantId: ctx.tenantId, revokedAt: null },
        });
        if (existingRole) {
          throw new TRPCError({ code: 'CONFLICT', message: 'User already has a role in this tenant' });
        }
      }

      // Check for pending invitation
      const existing = await ctx.db.invitation.findFirst({
        where: { email: input.email, tenantId: ctx.tenantId, acceptedAt: null },
      });
      if (existing && existing.expiresAt > new Date()) {
        throw new TRPCError({ code: 'CONFLICT', message: 'Invitation already pending for this email' });
      }

      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7);

      const invitation = await ctx.db.invitation.create({
        data: {
          email: input.email,
          tenantId: ctx.tenantId,
          role: input.role as never,
          invitedById: ctx.userId,
          expiresAt,
          token: randomUUID(),
        },
      });

      // In production: send invitation email via Resend
      // For now: return the invitation with token for manual sharing
      return invitation;
    }),

  revoke: tenantProcedure
    .input(z.object({ id: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      const inv = await ctx.db.invitation.findFirst({
        where: { id: input.id, tenantId: ctx.tenantId },
      });
      if (!inv) throw new TRPCError({ code: 'NOT_FOUND' });

      // Delete the invitation (not accepted, so safe to delete)
      return ctx.db.invitation.delete({ where: { id: input.id } });
    }),

  // Accept an invitation — called when user clicks the invite link
  accept: tenantProcedure
    .input(z.object({ token: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      const inv = await ctx.db.invitation.findFirst({
        where: { token: input.token, acceptedAt: null, expiresAt: { gt: new Date() } },
      });
      if (!inv) throw new TRPCError({ code: 'NOT_FOUND', message: 'Invitation not found or expired' });

      // Get or create the user
      let user = await ctx.db.user.findFirst({ where: { clerkUserId: ctx.userId } });
      if (!user) {
        // In production: hydrate from Clerk
        user = await ctx.db.user.create({
          data: {
            clerkUserId: ctx.userId,
            email: inv.email,
          },
        });
      }

      // Grant role
      await ctx.db.userRole.upsert({
        where: { userId_tenantId: { userId: user.id, tenantId: inv.tenantId } },
        create: {
          userId: user.id,
          tenantId: inv.tenantId,
          role: inv.role,
          grantedBy: inv.invitedById,
        },
        update: {
          role: inv.role,
          revokedAt: null,
          grantedBy: inv.invitedById,
        },
      });

      // Mark accepted
      await ctx.db.invitation.update({
        where: { id: inv.id },
        data: { acceptedAt: new Date() },
      });

      return { tenantId: inv.tenantId };
    }),
});
