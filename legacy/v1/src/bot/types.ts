// Minimal Bot Framework Activity types — covers what we need without the full SDK

export interface BotActivity {
  type: 'message' | 'conversationUpdate' | 'invoke' | 'event' | string;
  id: string;
  timestamp: string;
  serviceUrl: string;
  channelId: string;
  from: BotAccount;
  conversation: Conversation;
  recipient: BotAccount;
  replyToId?: string;
  text?: string;
  value?: Record<string, unknown>;
  channelData?: {
    tenant?: { id: string };
    channel?: { id: string; name: string };
    teamsChannelId?: string;
  };
  membersAdded?: BotAccount[];
  membersRemoved?: BotAccount[];
  attachments?: Attachment[];
}

export interface BotAccount {
  id: string;
  name: string;
  aadObjectId?: string;
  role?: string;
}

export interface Conversation {
  id: string;
  tenantId?: string;
  conversationType?: 'personal' | 'channel' | 'groupChat' | string;
  isGroup?: boolean;
}

export interface Attachment {
  contentType: string;
  content: unknown;
}

export interface CardActionValue {
  action: CardAction;
  auditId: string | number;
  conversationId: string;
  editedReply?: string;
  approvalMode?: string;
  companyTone?: string;
  weeklyReportEnabled?: string;
}

export type CardAction =
  | 'approve'
  | 'edit'
  | 'reject'
  | 'acknowledge'
  | 'request_backup'
  | 'save_config'
  | 'cancel_config'
  | 'start_setup'
  | 'report_feedback';
