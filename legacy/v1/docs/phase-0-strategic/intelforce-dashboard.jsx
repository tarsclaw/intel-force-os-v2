import { useState, useEffect } from 'react';
import {
  LayoutDashboard,
  Network,
  ListTree,
  Settings,
  Shield,
  BarChart3,
  Search,
  Bell,
  ChevronDown,
  Zap,
  CheckCircle2,
  Clock,
  AlertCircle,
  Play,
  Sliders,
  X,
  Activity,
  TrendingUp,
  ArrowUpRight,
  Circle,
  Mail,
  FileText,
  Radar,
  Send,
  PenTool,
  Repeat,
  MessageSquare,
  UserPlus,
  BarChart4,
  ScrollText,
  Command,
  Users,
  Target,
  ChevronRight,
  Sparkles,
} from 'lucide-react';

// ============= DESIGN TOKENS =============
// Deep near-black canvas, emerald accent, warm amber highlights.
// Serif display (Fraunces) paired with clean geometric sans (Geist via Satoshi fallback).

const FontLoader = () => (
  <style>{`
    @import url('https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,400;0,9..144,500;0,9..144,600;1,9..144,400&family=Geist:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap');

    body, html, #root { background: #07090b; }
    * { font-family: 'Geist', system-ui, sans-serif; }
    .font-display { font-family: 'Fraunces', serif; letter-spacing: -0.02em; }
    .font-mono { font-family: 'JetBrains Mono', monospace; }

    @keyframes pulse-dot {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(1.4); }
    }
    .pulse-dot { animation: pulse-dot 2s ease-in-out infinite; }

    @keyframes flow {
      0% { stroke-dashoffset: 40; }
      100% { stroke-dashoffset: 0; }
    }
    .flow-line { stroke-dasharray: 4 6; animation: flow 1.8s linear infinite; }

    @keyframes shimmer {
      0% { background-position: -200% 0; }
      100% { background-position: 200% 0; }
    }
    .shimmer {
      background: linear-gradient(90deg, transparent, rgba(16,185,129,0.1), transparent);
      background-size: 200% 100%;
      animation: shimmer 3s ease-in-out infinite;
    }

    .grain {
      position: relative;
    }
    .grain::before {
      content: '';
      position: absolute;
      inset: 0;
      background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='3'/%3E%3CfeColorMatrix values='0 0 0 0 0.1 0 0 0 0 0.15 0 0 0 0 0.1 0 0 0 0.3 0'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
      opacity: 0.4;
      pointer-events: none;
      mix-blend-mode: overlay;
    }

    .scrollbar::-webkit-scrollbar { width: 6px; height: 6px; }
    .scrollbar::-webkit-scrollbar-track { background: transparent; }
    .scrollbar::-webkit-scrollbar-thumb { background: #1f2937; border-radius: 3px; }
  `}</style>
);

// ============= DATA MODEL =============

const TENANT = {
  name: 'Elm Row Dental',
  industry: 'Private Dental — Edinburgh',
  plan: 'Growth',
  lastSync: '12s ago',
};

const METRICS = [
  { label: 'Proposals drafted MTD', value: '£84,200', delta: '+41%', spark: [12, 18, 15, 24, 22, 31, 34] },
  { label: 'Leads surfaced', value: '238', delta: '+18%', spark: [8, 12, 18, 22, 19, 28, 32] },
  { label: 'Content repurposed', value: '47', delta: '+62%', spark: [3, 5, 8, 12, 14, 18, 22] },
  { label: 'Agent uptime', value: '99.94%', delta: 'stable', spark: [99, 99, 100, 100, 99, 100, 100] },
];

const DIRECTORS = [
  {
    id: 'sales',
    label: 'Sales Director',
    colour: '#10b981',
    position: { x: 740, y: 120 },
    status: 'active',
    subAgents: ['lead-hunter', 'proposal-builder', 'follow-up-pilot'],
  },
  {
    id: 'marketing',
    label: 'Marketing Director',
    colour: '#f59e0b',
    position: { x: 740, y: 320 },
    status: 'active',
    subAgents: ['content-creator', 'repurposer', 'caption-writer'],
  },
  {
    id: 'operations',
    label: 'Operations Director',
    colour: '#8b5cf6',
    position: { x: 740, y: 520 },
    status: 'active',
    subAgents: ['client-onboarder', 'reporting-engine', 'sop-writer'],
  },
];

const GATEWAYS_FIXED = [
  { id: 'gmail', label: 'Gmail', icon: Mail, position: { x: 60, y: 100 } },
  { id: 'hubspot', label: 'HubSpot', icon: Target, position: { x: 60, y: 200 } },
  { id: 'fathom', label: 'Fathom', icon: Radar, position: { x: 60, y: 300 } },
  { id: 'slack', label: 'Slack', icon: MessageSquare, position: { x: 60, y: 400 } },
  { id: 'calendly', label: 'Cal.com', icon: Clock, position: { x: 60, y: 500 } },
  { id: 'stripe', label: 'Stripe', icon: BarChart4, position: { x: 60, y: 600 } },
];

const SUB_AGENTS = {
  'lead-hunter': {
    label: 'Lead Hunter',
    dept: 'Sales',
    icon: Radar,
    description: 'Scrapes UK Companies House + Apollo, qualifies against ICP, writes enriched leads to HubSpot.',
    tools: ['Apollo', 'Clay', 'HubSpot', 'Companies House'],
    status: 'active',
    lastRun: '2m ago',
    output: '38 new leads',
  },
  'proposal-builder': {
    label: 'Proposal Builder',
    dept: 'Sales',
    icon: FileText,
    description: 'Pulls discovery call notes from Fathom, references past winning proposals, drafts a scoped doc with pricing and timeline. Sent for review the moment the call ends.',
    tools: ['Fathom', 'HubSpot', 'DocuSign', 'Notion'],
    status: 'running',
    lastRun: '4m ago',
    output: '£24,000 engagement',
  },
  'follow-up-pilot': {
    label: 'Follow-Up Pilot',
    dept: 'Sales',
    icon: Send,
    description: 'Monitors CRM dormancy, sends on-brand follow-ups to cold prospects, books replies into Cal.com.',
    tools: ['Gmail', 'HubSpot', 'Cal.com'],
    status: 'active',
    lastRun: '18m ago',
    output: '21 sends · 7 replies',
  },
  'content-creator': {
    label: 'Content Creator',
    dept: 'Marketing',
    icon: PenTool,
    description: 'Trained on the practice\'s voice profile. Produces long-form content from a one-line brief.',
    tools: ['Notion', 'Google Docs'],
    status: 'running',
    lastRun: 'just now',
    output: '4 drafts',
  },
  'repurposer': {
    label: 'Repurposer',
    dept: 'Marketing',
    icon: Repeat,
    description: 'Takes one pillar piece and turns it into LinkedIn, Instagram carousel, YouTube Short script, email, and thread.',
    tools: ['Notion', 'Buffer', 'YouTube'],
    status: 'active',
    lastRun: '22m ago',
    output: '9 posts',
  },
  'caption-writer': {
    label: 'Caption Writer',
    dept: 'Marketing',
    icon: MessageSquare,
    description: 'Writes platform-native social captions with CTAs. Posts via Buffer/Later.',
    tools: ['Buffer', 'Google Drive'],
    status: 'active',
    lastRun: '8m ago',
    output: '17 captions',
  },
  'client-onboarder': {
    label: 'Client Onboarder',
    dept: 'Operations',
    icon: UserPlus,
    description: 'Fires on contract signature: welcome sequence, intake form, Slack channel, kickoff invite.',
    tools: ['DocuSign', 'Slack', 'ClickUp', 'Loom'],
    status: 'active',
    lastRun: '1h ago',
    output: '2 in progress',
  },
  'reporting-engine': {
    label: 'Reporting Engine',
    dept: 'Operations',
    icon: BarChart4,
    description: 'Pulls from Stripe, GA4, Meta Ads, CRM. Delivers weekly briefing in-Slack and PDF.',
    tools: ['Stripe', 'GA4', 'Meta Ads', 'Slack'],
    status: 'scheduled',
    lastRun: 'Friday 7am',
    output: 'Weekly pack',
  },
  'sop-writer': {
    label: 'SOP Writer',
    dept: 'Operations',
    icon: ScrollText,
    description: 'Ingests Loom recordings and auto-generates Notion-formatted Standard Operating Procedures.',
    tools: ['Loom', 'Notion', 'Google Docs'],
    status: 'idle',
    lastRun: 'yesterday',
    output: '34 in library',
  },
};

const ACTIVITY = [
  { time: '4m', agent: 'proposal-builder', action: 'Drafted proposal for Acme Dental Group — £24,000 engagement, sent to Jordan for review', status: 'completed' },
  { time: '12m', agent: 'lead-hunter', action: 'Qualified 14 new leads — pushed to HubSpot pipeline', status: 'completed' },
  { time: '22m', agent: 'content-creator', action: 'Drafted article "Why Invisalign costs what it costs"', status: 'completed' },
  { time: '1h', agent: 'follow-up-pilot', action: 'Sent 7 follow-ups to dormant prospects — 2 replies already', status: 'completed' },
  { time: '1h', agent: 'proposal-builder', action: 'Drafted proposal for Sterling Health — £18,000 retainer · 6 month term', status: 'completed' },
  { time: '3h', agent: 'proposal-builder', action: 'Drafted proposal for Greenfield Studio — £9,000 project scope', status: 'completed' },
  { time: '3h', agent: 'caption-writer', action: 'Generated 6 social captions for "Before & After" series', status: 'completed' },
  { time: '5h', agent: 'repurposer', action: 'Turned partner podcast ep #14 into 8 derivative pieces', status: 'completed' },
  { time: '8h', agent: 'sop-writer', action: 'Ingested Loom: "New patient intake protocol" — SOP published', status: 'completed' },
];

// ============= COMPONENTS =============

const StatusDot = ({ status }) => {
  const colours = {
    active: 'bg-emerald-400',
    running: 'bg-amber-400',
    scheduled: 'bg-sky-400',
    idle: 'bg-zinc-500',
    completed: 'bg-emerald-400',
  };
  const isLive = status === 'active' || status === 'running';
  return (
    <span className={`inline-block w-1.5 h-1.5 rounded-full ${colours[status]} ${isLive ? 'pulse-dot' : ''}`} />
  );
};

const StatusPill = ({ status }) => {
  const variants = {
    active: { bg: 'bg-emerald-400/10', ring: 'ring-emerald-400/30', text: 'text-emerald-300', label: 'ACTIVE' },
    running: { bg: 'bg-amber-400/10', ring: 'ring-amber-400/30', text: 'text-amber-300', label: 'RUNNING' },
    scheduled: { bg: 'bg-sky-400/10', ring: 'ring-sky-400/30', text: 'text-sky-300', label: 'SCHEDULED' },
    idle: { bg: 'bg-zinc-500/10', ring: 'ring-zinc-500/30', text: 'text-zinc-400', label: 'IDLE' },
  };
  const v = variants[status] || variants.idle;
  return (
    <span className={`inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-medium tracking-wider ring-1 ${v.bg} ${v.ring} ${v.text}`}>
      <StatusDot status={status} />
      {v.label}
    </span>
  );
};

const Sparkline = ({ data, colour = '#10b981' }) => {
  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;
  const pts = data.map((v, i) => `${(i / (data.length - 1)) * 100},${30 - ((v - min) / range) * 24}`).join(' ');
  return (
    <svg viewBox="0 0 100 30" className="w-full h-8 overflow-visible">
      <polyline fill="none" stroke={colour} strokeWidth="1.5" points={pts} strokeLinecap="round" strokeLinejoin="round" />
      <polyline fill={`${colour}20`} stroke="none" points={`0,30 ${pts} 100,30`} />
    </svg>
  );
};

const MetricCard = ({ m, i }) => (
  <div className="relative bg-[#0d1014] rounded-2xl p-5 ring-1 ring-white/5 hover:ring-emerald-400/20 transition-all group overflow-hidden">
    <div className="flex items-start justify-between mb-3">
      <p className="text-[11px] tracking-[0.14em] uppercase text-zinc-500 font-medium">{m.label}</p>
      <span className={`text-[10px] tabular-nums font-mono ${m.delta.includes('+') ? 'text-emerald-400' : 'text-zinc-500'}`}>{m.delta}</span>
    </div>
    <p className="font-display text-3xl font-light text-zinc-100 mb-2">{m.value}</p>
    <Sparkline data={m.spark} colour={i % 2 === 0 ? '#10b981' : '#f59e0b'} />
  </div>
);

// ============= HIERARCHY VIEW =============

const HierarchyView = ({ onSelectAgent }) => {
  return (
    <div className="relative bg-[#0a0d10] rounded-2xl ring-1 ring-white/5 overflow-hidden grain" style={{ height: 720 }}>
      <div className="absolute top-0 left-0 right-0 px-6 py-4 flex items-center justify-between z-10 border-b border-white/5 bg-[#0a0d10]/80 backdrop-blur">
        <div className="flex items-center gap-3">
          <Network className="w-4 h-4 text-emerald-400" />
          <h3 className="font-display text-lg text-zinc-100 font-light tracking-tight">Agentic Hierarchy</h3>
          <span className="text-xs text-zinc-500">· 9 agents configured · 3 directors · last activity just now</span>
        </div>
        <div className="flex items-center gap-4 text-[10px] tracking-wider uppercase text-zinc-500">
          <span className="flex items-center gap-1.5"><StatusDot status="active" /> Trigger</span>
          <span className="flex items-center gap-1.5"><span className="w-1.5 h-1.5 rounded-full bg-emerald-400" /> Gateway</span>
          <span className="flex items-center gap-1.5"><span className="w-1.5 h-1.5 rounded-full bg-purple-400" /> Director</span>
          <span className="flex items-center gap-1.5"><span className="w-1.5 h-1.5 rounded-full bg-amber-400" /> Agent</span>
          <span className="flex items-center gap-1.5"><span className="w-1.5 h-1.5 rounded-full bg-sky-400" /> Workspace</span>
        </div>
      </div>

      <svg viewBox="0 0 1500 720" className="absolute inset-0 w-full h-full" preserveAspectRatio="xMidYMid meet">
        {/* background grid */}
        <defs>
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#151a20" strokeWidth="0.5" />
          </pattern>
          <radialGradient id="gatewayGlow">
            <stop offset="0%" stopColor="#10b981" stopOpacity="0.35" />
            <stop offset="100%" stopColor="#10b981" stopOpacity="0" />
          </radialGradient>
          <linearGradient id="edgeActive" x1="0" x2="1">
            <stop offset="0%" stopColor="#10b981" stopOpacity="0.1" />
            <stop offset="50%" stopColor="#10b981" stopOpacity="0.7" />
            <stop offset="100%" stopColor="#10b981" stopOpacity="0.1" />
          </linearGradient>
          <linearGradient id="edgeAmber" x1="0" x2="1">
            <stop offset="0%" stopColor="#f59e0b" stopOpacity="0.1" />
            <stop offset="50%" stopColor="#f59e0b" stopOpacity="0.5" />
            <stop offset="100%" stopColor="#f59e0b" stopOpacity="0.1" />
          </linearGradient>
          <linearGradient id="edgePurple" x1="0" x2="1">
            <stop offset="0%" stopColor="#8b5cf6" stopOpacity="0.1" />
            <stop offset="50%" stopColor="#8b5cf6" stopOpacity="0.5" />
            <stop offset="100%" stopColor="#8b5cf6" stopOpacity="0.1" />
          </linearGradient>
        </defs>
        <rect width="100%" height="100%" fill="url(#grid)" opacity="0.3" />

        {/* Gateway connections */}
        {GATEWAYS_FIXED.map((g) => (
          <path
            key={`g-${g.id}`}
            d={`M ${g.position.x + 130} ${g.position.y + 20} Q 350 ${g.position.y + 20}, 450 340`}
            fill="none"
            stroke="#10b981"
            strokeOpacity="0.25"
            strokeWidth="1"
            className="flow-line"
          />
        ))}

        {/* Gateway glow */}
        <circle cx="520" cy="340" r="75" fill="url(#gatewayGlow)" />

        {/* Central Gateway node */}
        <g transform="translate(420,290)">
          <rect x="0" y="0" width="200" height="100" rx="20" fill="#0d1014" stroke="#10b981" strokeWidth="1.5" strokeOpacity="0.6" />
          <circle cx="100" cy="35" r="12" fill="#10b981" fillOpacity="0.15" stroke="#10b981" strokeOpacity="0.8" />
          <text x="100" y="39" textAnchor="middle" fill="#10b981" fontSize="11" fontFamily="JetBrains Mono">⌘</text>
          <text x="100" y="65" textAnchor="middle" fill="#e4e4e7" fontSize="14" fontFamily="Geist" fontWeight="500">Gateway</text>
          <text x="100" y="82" textAnchor="middle" fill="#71717a" fontSize="10" fontFamily="Geist">Routing by intent</text>
        </g>

        {/* Director connections from Gateway */}
        {DIRECTORS.map((d) => (
          <path
            key={`d-edge-${d.id}`}
            d={`M 620 340 Q 700 340, 740 ${d.position.y + 40}`}
            fill="none"
            stroke={d.id === 'sales' ? 'url(#edgeActive)' : d.id === 'marketing' ? 'url(#edgeAmber)' : 'url(#edgePurple)'}
            strokeWidth="2"
          />
        ))}

        {/* Directors */}
        {DIRECTORS.map((d) => (
          <g key={d.id} transform={`translate(${d.position.x},${d.position.y})`}>
            <rect x="0" y="0" width="230" height="80" rx="18" fill="#0d1014" stroke={d.colour} strokeWidth="1.5" strokeOpacity="0.5" />
            <circle cx="22" cy="40" r="6" fill={d.colour} />
            <text x="38" y="34" fill="#e4e4e7" fontSize="13" fontFamily="Geist" fontWeight="500">{d.label}</text>
            <text x="38" y="52" fill="#71717a" fontSize="10" fontFamily="Geist">Subagents {d.subAgents.length} · claude-sonnet-4.6</text>
            <g transform="translate(180,28)">
              <rect x="0" y="0" width="42" height="16" rx="8" fill={`${d.colour}20`} stroke={`${d.colour}60`} />
              <text x="21" y="11" textAnchor="middle" fill={d.colour} fontSize="8" fontFamily="Geist" fontWeight="600">ACTIVE</text>
            </g>
          </g>
        ))}

        {/* Sub-agent connections and nodes */}
        {DIRECTORS.map((d) =>
          d.subAgents.map((subId, idx) => {
            const sub = SUB_AGENTS[subId];
            const x = 1050;
            const y = d.position.y - 40 + idx * 50;
            const edgeColour = d.id === 'sales' ? 'url(#edgeActive)' : d.id === 'marketing' ? 'url(#edgeAmber)' : 'url(#edgePurple)';
            return (
              <g key={subId}>
                <path d={`M 970 ${d.position.y + 40} Q 1010 ${y + 17}, ${x} ${y + 17}`} fill="none" stroke={edgeColour} strokeWidth="1.25" />
                <g
                  transform={`translate(${x},${y})`}
                  style={{ cursor: 'pointer' }}
                  onClick={() => onSelectAgent(subId)}
                >
                  <rect x="0" y="0" width="330" height="34" rx="10" fill="#0d1014" stroke="#1f2937" strokeWidth="1" className="hover:stroke-emerald-400 transition-all" />
                  <circle cx="14" cy="17" r="3" fill={
                    sub.status === 'active' ? '#10b981' :
                    sub.status === 'running' ? '#f59e0b' :
                    sub.status === 'scheduled' ? '#38bdf8' : '#6b7280'
                  } />
                  <text x="28" y="21" fill="#e4e4e7" fontSize="11" fontFamily="Geist" fontWeight="500">{sub.label}</text>
                  <text x="165" y="21" fill="#71717a" fontSize="9.5" fontFamily="Geist">{sub.output}</text>
                  <text x="300" y="21" fill="#52525b" fontSize="9" fontFamily="JetBrains Mono" textAnchor="middle">{sub.lastRun}</text>
                </g>
              </g>
            );
          })
        )}

        {/* Gateway nodes (left side) */}
        {GATEWAYS_FIXED.map((g) => (
          <g key={g.id} transform={`translate(${g.position.x},${g.position.y})`}>
            <rect x="0" y="0" width="130" height="40" rx="10" fill="#0d1014" stroke="#1f2937" strokeWidth="1" />
            <circle cx="20" cy="20" r="10" fill="#111418" />
            <text x="40" y="25" fill="#a1a1aa" fontSize="11" fontFamily="Geist" fontWeight="500">{g.label}</text>
          </g>
        ))}
      </svg>

      {/* Floating legend / hint */}
      <div className="absolute bottom-4 right-4 bg-[#0d1014]/90 backdrop-blur rounded-lg px-3 py-2 ring-1 ring-white/5 text-[10px] text-zinc-500 flex items-center gap-2">
        <Sparkles className="w-3 h-3 text-emerald-400" />
        Click any agent to inspect · drag-and-pan view · export as JSON
      </div>
    </div>
  );
};

// ============= ACTIVITY LOG =============

const ActivityLogView = ({ onSelectAgent }) => (
  <div className="bg-[#0d1014] rounded-2xl ring-1 ring-white/5 overflow-hidden">
    <div className="px-6 py-4 border-b border-white/5 flex items-center justify-between">
      <div>
        <h3 className="font-display text-lg text-zinc-100 font-light tracking-tight">Agent Activity Log</h3>
        <p className="text-xs text-zinc-500 mt-0.5">Live · auto-refresh every 3s · all 9 agents</p>
      </div>
      <div className="flex items-center gap-2">
        <button className="text-[11px] text-zinc-400 px-3 py-1.5 rounded-md ring-1 ring-white/10 hover:ring-emerald-400/30 hover:text-emerald-300 transition">Filter</button>
        <button className="text-[11px] text-zinc-400 px-3 py-1.5 rounded-md ring-1 ring-white/10 hover:ring-emerald-400/30 hover:text-emerald-300 transition">Export CSV</button>
      </div>
    </div>

    <div className="grid grid-cols-[48px_1fr_180px_130px_120px] px-6 py-3 border-b border-white/5 text-[10px] tracking-wider uppercase text-zinc-500 font-medium">
      <span>№</span>
      <span>Agent / Action</span>
      <span>Status</span>
      <span className="text-right">Last Run</span>
      <span className="text-right">Output</span>
    </div>

    <div className="divide-y divide-white/5">
      {Object.entries(SUB_AGENTS).map(([id, sub], idx) => {
        const Icon = sub.icon;
        return (
          <div
            key={id}
            onClick={() => onSelectAgent(id)}
            className="grid grid-cols-[48px_1fr_180px_130px_120px] px-6 py-4 items-center hover:bg-white/[0.02] cursor-pointer transition group"
          >
            <span className="font-mono text-[11px] text-zinc-600">#{idx + 1}</span>
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-zinc-800 to-zinc-900 ring-1 ring-white/5 flex items-center justify-center">
                <Icon className="w-4 h-4 text-zinc-400 group-hover:text-emerald-400 transition" />
              </div>
              <div>
                <p className="text-sm text-zinc-200 font-medium">{sub.label}</p>
                <p className="text-[11px] text-zinc-500">{sub.dept}</p>
              </div>
            </div>
            <StatusPill status={sub.status} />
            <span className="text-right text-xs text-zinc-400 font-mono">{sub.lastRun}</span>
            <span className="text-right text-xs text-zinc-300 font-medium">{sub.output}</span>
          </div>
        );
      })}
    </div>
  </div>
);

// ============= CONFIG CENTRE PREVIEW =============

const ConfigCentreView = () => {
  const steps = [
    { n: 1, label: 'Company profile', status: 'complete', desc: 'Business name, industry, ICP, brand voice' },
    { n: 2, label: 'Integrations', status: 'complete', desc: '6 of 8 connected · 2 optional pending' },
    { n: 3, label: 'Agent selection', status: 'current', desc: '9 core agents · Voice Receptionist add-on · HR Agent add-on' },
    { n: 4, label: 'Voice & context training', status: 'upcoming', desc: 'Upload past proposals, SOPs, brand docs' },
    { n: 5, label: 'Go-live checklist', status: 'upcoming', desc: 'Per-agent smoke test before switching on' },
  ];
  return (
    <div className="grid grid-cols-[340px_1fr] gap-6">
      <div className="bg-[#0d1014] rounded-2xl ring-1 ring-white/5 p-5">
        <p className="text-[10px] tracking-[0.18em] uppercase text-emerald-400 font-medium mb-2">Deployment</p>
        <h3 className="font-display text-xl text-zinc-100 font-light mb-1">72-hour onboarding</h3>
        <p className="text-xs text-zinc-500 mb-5">From contract to live dashboard in five guided steps</p>

        <div className="space-y-3">
          {steps.map((s) => (
            <div key={s.n} className="flex gap-3">
              <div className={`flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-mono ${
                s.status === 'complete' ? 'bg-emerald-400/15 text-emerald-300 ring-1 ring-emerald-400/30' :
                s.status === 'current' ? 'bg-amber-400/15 text-amber-300 ring-1 ring-amber-400/40' :
                'bg-zinc-800 text-zinc-500'
              }`}>
                {s.status === 'complete' ? '✓' : s.n}
              </div>
              <div className="flex-1 min-w-0">
                <p className={`text-sm font-medium ${s.status === 'upcoming' ? 'text-zinc-500' : 'text-zinc-200'}`}>{s.label}</p>
                <p className="text-[11px] text-zinc-500 mt-0.5">{s.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="bg-[#0d1014] rounded-2xl ring-1 ring-white/5 p-6">
        <div className="flex items-start justify-between mb-6">
          <div>
            <p className="text-[10px] tracking-[0.18em] uppercase text-zinc-500 font-medium mb-1">Step 3 of 5</p>
            <h3 className="font-display text-2xl text-zinc-100 font-light">Select your agents</h3>
            <p className="text-sm text-zinc-500 mt-1">All nine core agents are included in the Growth plan. Add-ons are billed separately.</p>
          </div>
          <button className="bg-emerald-400 hover:bg-emerald-300 text-emerald-950 text-sm font-medium px-4 py-2 rounded-lg flex items-center gap-1.5 transition">
            Continue <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        <div className="mb-3">
          <p className="text-[10px] tracking-wider uppercase text-zinc-600 font-medium mb-3">Core agents · included</p>
          <div className="grid grid-cols-3 gap-3">
            {Object.entries(SUB_AGENTS).map(([id, sub]) => {
              const Icon = sub.icon;
              return (
                <div key={id} className="bg-[#080a0d] rounded-lg p-3 ring-1 ring-emerald-400/20 relative">
                  <div className="absolute top-2 right-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                  </div>
                  <div className="w-7 h-7 rounded-md bg-gradient-to-br from-zinc-800 to-zinc-900 ring-1 ring-white/5 flex items-center justify-center mb-2">
                    <Icon className="w-3.5 h-3.5 text-emerald-300" />
                  </div>
                  <p className="text-xs text-zinc-200 font-medium mb-0.5">{sub.label}</p>
                  <p className="text-[10px] text-zinc-500">{sub.dept}</p>
                </div>
              );
            })}
          </div>
        </div>

        <div className="mt-6">
          <p className="text-[10px] tracking-wider uppercase text-zinc-600 font-medium mb-3">Add-ons · billed separately</p>
          <div className="grid grid-cols-2 gap-3">
            {[
              { label: 'Voice Receptionist', price: '£600/mo + £750 setup', selected: true, icon: MessageSquare },
              { label: 'HR Agent (Teams)', price: '£500/mo + £1,000 setup', selected: true, icon: Users },
              { label: 'SEO Brief Generator', price: '£300/mo', selected: false, icon: Search },
              { label: 'Paid Ads Copywriter', price: '£400/mo', selected: false, icon: Target },
            ].map((a) => {
              const AIcon = a.icon;
              return (
                <div key={a.label} className={`p-4 rounded-lg ring-1 flex items-center justify-between cursor-pointer transition ${
                  a.selected ? 'bg-emerald-400/[0.04] ring-emerald-400/30' : 'bg-[#080a0d] ring-white/5 hover:ring-white/10'
                }`}>
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-md bg-gradient-to-br from-zinc-800 to-zinc-900 ring-1 ring-white/5 flex items-center justify-center">
                      <AIcon className="w-4 h-4 text-zinc-300" />
                    </div>
                    <div>
                      <p className="text-sm text-zinc-200 font-medium">{a.label}</p>
                      <p className="text-[11px] text-zinc-500 font-mono">{a.price}</p>
                    </div>
                  </div>
                  <div className={`w-9 h-5 rounded-full p-0.5 transition ${a.selected ? 'bg-emerald-400' : 'bg-zinc-700'}`}>
                    <div className={`w-4 h-4 bg-white rounded-full transition ${a.selected ? 'translate-x-4' : ''}`} />
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
};

// ============= AGENT DETAIL MODAL =============

const AgentDetail = ({ agentId, onClose }) => {
  if (!agentId) return null;
  const agent = SUB_AGENTS[agentId];
  if (!agent) return null;
  const Icon = agent.icon;

  return (
    <div
      className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-6"
      onClick={onClose}
    >
      <div
        className="bg-[#0d1014] rounded-2xl ring-1 ring-white/10 max-w-xl w-full overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="relative p-6 border-b border-white/5">
          <button
            onClick={onClose}
            className="absolute top-4 right-4 w-8 h-8 rounded-lg hover:bg-white/5 flex items-center justify-center text-zinc-500 hover:text-zinc-300 transition"
          >
            <X className="w-4 h-4" />
          </button>

          <div className="flex items-start gap-4">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-emerald-400/20 to-emerald-400/5 ring-1 ring-emerald-400/30 flex items-center justify-center">
              <Icon className="w-5 h-5 text-emerald-300" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[10px] tracking-[0.18em] uppercase text-zinc-500 font-medium">{agent.dept} · AI Agent</p>
              <h2 className="font-display text-2xl text-zinc-100 font-light mt-1">{agent.label}</h2>
            </div>
          </div>
        </div>

        <div className="p-6 space-y-6">
          <div>
            <p className="text-[10px] tracking-wider uppercase text-zinc-500 font-medium mb-2">What it does</p>
            <p className="text-sm text-zinc-300 leading-relaxed">{agent.description}</p>
          </div>

          <div>
            <p className="text-[10px] tracking-wider uppercase text-zinc-500 font-medium mb-2">Connected to</p>
            <div className="flex flex-wrap gap-2">
              {agent.tools.map((t) => (
                <span key={t} className="text-[11px] px-2.5 py-1 rounded-md bg-[#080a0d] ring-1 ring-white/10 text-zinc-300 font-medium">
                  <span className="inline-block w-1.5 h-1.5 rounded-full bg-emerald-400 mr-1.5 align-middle" />
                  {t}
                </span>
              ))}
            </div>
          </div>

          <div>
            <p className="text-[10px] tracking-wider uppercase text-zinc-500 font-medium mb-2">Recent activity</p>
            <div className="space-y-2">
              {ACTIVITY.filter((a) => a.agent === agentId).slice(0, 3).map((a, i) => (
                <div key={i} className="flex items-start gap-3 text-xs">
                  <span className="text-zinc-600 font-mono mt-0.5">{a.time} ago</span>
                  <span className="text-zinc-300 flex-1">{a.action}</span>
                </div>
              ))}
              {ACTIVITY.filter((a) => a.agent === agentId).length === 0 && (
                <p className="text-xs text-zinc-600 italic">No activity in last 24 hours</p>
              )}
            </div>
          </div>

          <div>
            <p className="text-[10px] tracking-wider uppercase text-zinc-500 font-medium mb-2">Status</p>
            <div className="flex items-center gap-3">
              <StatusPill status={agent.status} />
              <span className="text-xs text-zinc-500">· last run {agent.lastRun}</span>
            </div>
          </div>
        </div>

        <div className="p-4 bg-[#080a0d] border-t border-white/5 flex items-center gap-2">
          <button className="flex-1 bg-white/5 hover:bg-white/10 text-zinc-200 text-sm font-medium px-4 py-2.5 rounded-lg flex items-center justify-center gap-2 transition">
            <Sliders className="w-4 h-4" /> Configure
          </button>
          <button className="flex-1 bg-emerald-400 hover:bg-emerald-300 text-emerald-950 text-sm font-semibold px-4 py-2.5 rounded-lg flex items-center justify-center gap-2 transition">
            <Play className="w-4 h-4" /> Run now
          </button>
        </div>
      </div>
    </div>
  );
};

// ============= MAIN APP =============

export default function IntelForceDashboard() {
  const [view, setView] = useState('hierarchy');
  const [selectedAgent, setSelectedAgent] = useState(null);
  const [now, setNow] = useState(new Date());

  useEffect(() => {
    const t = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(t);
  }, []);

  const navItems = [
    { id: 'hierarchy', label: 'Hierarchy', icon: Network },
    { id: 'activity', label: 'Activity', icon: ListTree },
    { id: 'config', label: 'Configuration', icon: Settings },
  ];

  return (
    <div className="min-h-screen bg-[#07090b] text-zinc-200">
      <FontLoader />

      {/* Top bar */}
      <div className="border-b border-white/5 bg-[#07090b]/80 backdrop-blur sticky top-0 z-30">
        <div className="px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-8">
            <div className="flex items-center gap-2">
              <div className="w-7 h-7 rounded-md bg-gradient-to-br from-emerald-400 to-emerald-600 flex items-center justify-center">
                <Command className="w-4 h-4 text-emerald-950" strokeWidth={2.5} />
              </div>
              <span className="font-display text-base text-zinc-100 font-medium tracking-tight">IntelForce<span className="text-emerald-400">.</span>OS</span>
            </div>

            <div className="flex items-center gap-1 bg-[#0d1014] rounded-lg p-1 ring-1 ring-white/5">
              {navItems.map((n) => {
                const NIcon = n.icon;
                return (
                  <button
                    key={n.id}
                    onClick={() => setView(n.id)}
                    className={`text-[12px] font-medium px-3 py-1.5 rounded-md transition flex items-center gap-2 ${
                      view === n.id ? 'bg-white/5 text-zinc-100' : 'text-zinc-500 hover:text-zinc-300'
                    }`}
                  >
                    <NIcon className="w-3.5 h-3.5" />
                    {n.label}
                  </button>
                );
              })}
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="text-right">
              <p className="text-[11px] text-zinc-500">Tenant</p>
              <p className="text-xs text-zinc-200 font-medium flex items-center gap-1.5">
                {TENANT.name}
                <ChevronDown className="w-3 h-3 text-zinc-500" />
              </p>
            </div>
            <div className="w-px h-6 bg-white/10" />
            <button className="relative w-8 h-8 rounded-md hover:bg-white/5 flex items-center justify-center text-zinc-400">
              <Bell className="w-4 h-4" />
              <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 rounded-full bg-emerald-400" />
            </button>
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-amber-400 to-amber-600 ring-2 ring-white/10" />
          </div>
        </div>
      </div>

      {/* Header / greeting */}
      <div className="px-6 py-8">
        <div className="flex items-end justify-between mb-8">
          <div>
            <p className="text-[11px] tracking-[0.18em] uppercase text-emerald-400 font-medium mb-2">
              <span className="pulse-dot inline-block w-1.5 h-1.5 rounded-full bg-emerald-400 mr-2 align-middle" />
              Live · {TENANT.lastSync}
            </p>
            <h1 className="font-display text-[42px] leading-none text-zinc-100 font-light tracking-tight">
              Good afternoon, Maddox.
            </h1>
            <p className="text-sm text-zinc-400 mt-3">
              {TENANT.name} · {TENANT.industry} · {TENANT.plan} plan
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button className="text-[12px] text-zinc-300 px-3.5 py-2 rounded-lg ring-1 ring-white/10 hover:bg-white/5 transition flex items-center gap-1.5">
              <Play className="w-3.5 h-3.5" /> Run all
            </button>
            <button className="text-[12px] text-emerald-950 bg-emerald-400 hover:bg-emerald-300 font-semibold px-3.5 py-2 rounded-lg transition flex items-center gap-1.5">
              <Zap className="w-3.5 h-3.5" /> New agent
            </button>
          </div>
        </div>

        {/* Metrics row */}
        <div className="grid grid-cols-4 gap-3 mb-8">
          {METRICS.map((m, i) => <MetricCard key={i} m={m} i={i} />)}
        </div>

        {/* Main view */}
        {view === 'hierarchy' && <HierarchyView onSelectAgent={setSelectedAgent} />}
        {view === 'activity' && <ActivityLogView onSelectAgent={setSelectedAgent} />}
        {view === 'config' && <ConfigCentreView />}

        {/* Footer strip */}
        <div className="mt-8 pt-6 border-t border-white/5 flex items-center justify-between text-[11px] text-zinc-600">
          <div className="flex items-center gap-4">
            <span className="flex items-center gap-1.5"><Shield className="w-3 h-3" /> UK-sovereign · data in London</span>
            <span>·</span>
            <span>Running on OpenClaw orchestration layer</span>
          </div>
          <div className="flex items-center gap-4 font-mono">
            <span>v0.9.3</span>
            <span>·</span>
            <span>{now.toLocaleTimeString('en-GB')}</span>
          </div>
        </div>
      </div>

      <AgentDetail agentId={selectedAgent} onClose={() => setSelectedAgent(null)} />
    </div>
  );
}
