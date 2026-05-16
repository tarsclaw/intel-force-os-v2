'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import {
  forceSimulation,
  forceManyBody,
  forceLink,
  forceCenter,
  forceCollide,
  forceX,
  forceY,
  type Simulation,
  type SimulationLinkDatum,
} from 'd3-force';
import {
  Search,
  Sparkles,
  GitBranch,
  Lightbulb,
  Map as MapIcon,
  ZoomIn,
  ZoomOut,
  Crosshair,
  ExternalLink,
  Star,
  X,
} from 'lucide-react';
import { cn } from '@/lib/cn';
import { formatRelative } from '@/components/shared/relative-time';



type GraphNode = {
  id: string;
  label: string;
  community: number;
  source_file: string;
  file_type: string;
  d: number;
  // d3-force tags coordinates onto the node during the simulation.
  x?: number;
  y?: number;
  vx?: number;
  vy?: number;
  fx?: number | null;
  fy?: number | null;
};

type GraphEdge = {
  s: string;
  t: string;
  r: string;
  c: 'EXTRACTED' | 'INFERRED' | 'AMBIGUOUS';
};

type GraphData = {
  nodes: GraphNode[];
  edges: GraphEdge[];
  communities: Record<string, string>;
  _meta?: {
    source: 'tenant' | 'demo' | 'empty';
    status?: 'PENDING' | 'BUILDING' | 'READY' | 'FAILED' | 'STALE';
    version?: number;
    generatedAt?: string;
    nodeCount?: number;
    edgeCount?: number;
  };
};

type Mode = 'map' | 'path' | 'surprise';
type Tab = 'node' | 'results' | 'path' | 'surprise';

// High-contrast palette tuned for black canvas + community separation.
// Saturation and luminance balanced so adjacent communities never look similar
// even with 100+ communities. Picks alternate hue + sat ranges per index.
const COMM_COLORS = [
  '#34D399', '#22D3EE', '#FBBF24', '#F472B6', '#A78BFA',
  '#5EEAD4', '#FB7185', '#60A5FA', '#E879F9', '#FB923C',
  '#A3E635', '#F0ABFC', '#38BDF8', '#818CF8', '#FDE047',
  '#86EFAC', '#C4B5FD', '#FDA4AF', '#67E8F9', '#FCA5A5',
  '#10B981', '#06B6D4', '#F59E0B', '#EC4899', '#8B5CF6',
  '#14B8A6', '#EF4444', '#3B82F6', '#D946EF', '#F97316',
];
const FALLBACK_COLOR = '#5F6772';
const colorOf = (c: number) => COMM_COLORS[c % COMM_COLORS.length] || FALLBACK_COLOR;

// Convert a #RRGGBB hex colour to rgba(...) with the given alpha.
// Used for community-coloured radial illumination + glow effects.
function hexToRgba(hex: string, alpha: number): string {
  const h = hex.replace('#', '');
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}


interface BrainMapProps {
  slug: string;
  isDemo?: boolean; // (deprecated) — _meta.source from API now drives the banner
}

export function BrainMap({ slug }: BrainMapProps) {
  const [data, setData] = useState<GraphData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // load data
  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    fetch(`/api/brain/${slug}/graph`)
      .then((r) => {
        if (!r.ok) throw new Error(`Graph fetch failed: ${r.status}`);
        return r.json();
      })
      .then((g: GraphData) => {
        if (cancelled) return;
        setData(g);
        setLoading(false);
      })
      .catch((e) => {
        if (cancelled) return;
        setError(String(e));
        setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [slug]);

  if (loading) return <BrainSkeleton />;
  if (error) return <BrainError message={error} />;
  if (!data) return <BrainEmpty slug={slug} status={null} />;
  if (data.nodes.length === 0) {
    return <BrainEmpty slug={slug} status={data._meta?.status ?? 'PENDING'} />;
  }

  return <BrainMapInner data={data} slug={slug} />;
}

// =============================================================================
// Inner component — only renders once data is loaded
// =============================================================================

function BrainMapInner({ data, slug }: { data: GraphData; slug: string }) {
  const meta = data._meta;
  const isDemo = meta?.source === 'demo';
  const isBuilding = meta?.status === 'BUILDING';
  const containerRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const tooltipRef = useRef<HTMLDivElement>(null);
  const searchInputRef = useRef<HTMLInputElement>(null);

  // ---- Build adjacency + node lookup
  const { byId, adjacency } = useMemo(() => {
    const byId: Record<string, GraphNode> = {};
    for (const n of data.nodes) byId[n.id] = n;
    const adjacency: Record<
      string,
      { id: string; r: string; c: string; dir: 'in' | 'out' }[]
    > = {};
    for (const e of data.edges) {
      (adjacency[e.s] = adjacency[e.s] || []).push({ id: e.t, r: e.r, c: e.c, dir: 'out' });
      (adjacency[e.t] = adjacency[e.t] || []).push({ id: e.s, r: e.r, c: e.c, dir: 'in' });
    }
    return { byId, adjacency };
  }, [data]);

  // ---- Sim node + link types (d3-force tags coordinates onto our objects)
  type SimNode = GraphNode & {
    x?: number;
    y?: number;
    vx?: number;
    vy?: number;
    fx?: number | null;
    fy?: number | null;
  };
  type SimLink = { source: SimNode | string; target: SimNode | string; c: string; r: string };

  const nodesRef = useRef<SimNode[]>([]);
  const linksRef = useRef<SimLink[]>([]);
  const simRef = useRef<Simulation<SimNode, SimulationLinkDatum<SimNode>> | null>(null);
  const layoutReadyRef = useRef(false);

  // hoisted for d3-force forceCollide
  function sizeOf(n: GraphNode) {
    return 1.4 + Math.log2(1 + Math.max(1, n.d || 1)) * 0.45;
  }

  if (!layoutReadyRef.current) {
    // Seed each community on a ring so colors lobe out from the start.
    const communities = Array.from(new Set(data.nodes.map((n) => n.community)));
    const numComms = communities.length;
    const commCentroids: Record<number, { x: number; y: number }> = {};
    communities.forEach((c, i) => {
      const angle = (i / numComms) * Math.PI * 2;
      const radius = 360 + Math.random() * 80;
      commCentroids[c] = { x: Math.cos(angle) * radius, y: Math.sin(angle) * radius };
    });

    nodesRef.current = data.nodes.map((n) => {
      const c = commCentroids[n.community];
      return {
        ...n,
        x: c.x + (Math.random() - 0.5) * 100,
        y: c.y + (Math.random() - 0.5) * 100,
        vx: 0,
        vy: 0,
        fx: null,
        fy: null,
      };
    });
    linksRef.current = data.edges.map((e) => ({
      source: e.s,
      target: e.t,
      c: e.c,
      r: e.r,
    }));

    simRef.current = forceSimulation<SimNode>(nodesRef.current)
      .force(
        'link',
        forceLink<SimNode, SimulationLinkDatum<SimNode>>(
          linksRef.current as unknown as SimulationLinkDatum<SimNode>[],
        )
          .id((d) => d.id)
          .distance(28)
          .strength(0.55),
      )
      .force('charge', forceManyBody<SimNode>().strength(-45).distanceMax(280))
      .force('center', forceCenter(0, 0).strength(0.05))
      .force(
        'collide',
        forceCollide<SimNode>()
          .radius((d) => sizeOf(d) + 1.5)
          .strength(0.85),
      )
      .force(
        'commX',
        forceX<SimNode>((d) => commCentroids[d.community]?.x ?? 0).strength(0.07),
      )
      .force(
        'commY',
        forceY<SimNode>((d) => commCentroids[d.community]?.y ?? 0).strength(0.07),
      )
      .alphaDecay(0.012)
      .alphaMin(0.001)
      .velocityDecay(0.45);

    // pre-tick to settle
    for (let i = 0; i < 320; i++) simRef.current.tick();

    layoutReadyRef.current = true;
  }

  // ---- View state (refs to avoid re-renders during pan/zoom)
  const viewRef = useRef({ tx: 0, ty: 0, k: 1 });
  const hoveredRef = useRef<SimNode | null>(null);
  // Hovered node's depth-1 neighbour set + edges. Refs (not state) so mouse
  // moves don't trigger React re-renders — the canvas loop reads them directly.
  const hoverNeighborsRef = useRef<Set<string>>(new Set());
  const hoverEdgesRef = useRef<Set<string>>(new Set());
  // Per-node entry-timestamp for the scale-in animation when a node first
  // becomes part of the focused set. Cleared when the node leaves the set.
  const highlightEnterAtRef = useRef<Map<string, number>>(new Map());
  const draggingRef = useRef<SimNode | null>(null);
  const panningRef = useRef(false);
  const lastPointerRef = useRef({ x: 0, y: 0 });
  const sizeRef = useRef({ w: 0, h: 0, dpr: 1 });

  // ---- React state
  const [selected, setSelected] = useState<GraphNode | null>(null);
  const [highlighted, setHighlighted] = useState<Set<string>>(new Set());
  const [highlightedEdges, setHighlightedEdges] = useState<Set<string>>(new Set());
  const [searchTerm, setSearchTerm] = useState('');
  const [activeTab, setActiveTab] = useState<Tab>('node');
  const [mode, setMode] = useState<Mode>('map');
  const [pathState, setPathState] = useState<{
    from: GraphNode | null;
    to: GraphNode | null;
    path: Set<string> | null;
    pathArr: string[] | null;
  }>({ from: null, to: null, path: null, pathArr: null });
  const [paletteOpen, setPaletteOpen] = useState(false);

  // ---- Initial fit-to-view
  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;
    const { width, height } = el.getBoundingClientRect();
    let minX = Infinity,
      maxX = -Infinity,
      minY = Infinity,
      maxY = -Infinity;
    for (const n of nodesRef.current) {
      if (n.x == null || n.y == null) continue;
      if (n.x < minX) minX = n.x;
      if (n.x > maxX) maxX = n.x;
      if (n.y < minY) minY = n.y;
      if (n.y > maxY) maxY = n.y;
    }
    const spanX = maxX - minX || 1;
    const spanY = maxY - minY || 1;
    const margin = 80;
    const k = Math.min((width - margin * 2) / spanX, (height - margin * 2) / spanY, 1.2);
    const cx = (minX + maxX) / 2;
    const cy = (minY + maxY) / 2;
    viewRef.current = {
      tx: width / 2 - cx * k,
      ty: height / 2 - cy * k,
      k,
    };
    drawRef.current?.();
  }, []);

  // ---- Helpers
  const edgeKey = (a: string, b: string) => (a < b ? `${a}|${b}` : `${b}|${a}`);
  const screenToWorld = (sx: number, sy: number) => {
    const v = viewRef.current;
    return [(sx - v.tx) / v.k, (sy - v.ty) / v.k];
  };
  const pick = (sx: number, sy: number): SimNode | null => {
    const [wx, wy] = screenToWorld(sx, sy);
    let best: SimNode | null = null;
    let bestDist = Infinity;
    const v = viewRef.current;
    for (const n of nodesRef.current) {
      const dx = (n.x || 0) - wx;
      const dy = (n.y || 0) - wy;
      const r = sizeOf(n) + 5 / v.k;
      const dist = dx * dx + dy * dy;
      if (dist < r * r && dist < bestDist) {
        best = n;
        bestDist = dist;
      }
    }
    return best;
  };

  // ---- Render
  const drawRef = useRef<(() => void) | null>(null);
  drawRef.current = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    const { w, h, dpr } = sizeRef.current;
    const v = viewRef.current;

    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.fillStyle = '#0A0A0B';
    ctx.fillRect(0, 0, w, h);

    ctx.save();
    ctx.translate(v.tx, v.ty);
    ctx.scale(v.k, v.k);

    const hovered = hoveredRef.current;
    const isInteracting = selected !== null || hovered !== null || pathState.path !== null;

    // Unified focus set — click-highlighted ∪ hover-highlighted neighbour set.
    const focusNodes = new Set<string>(highlighted);
    for (const id of hoverNeighborsRef.current) focusNodes.add(id);
    const focusEdges = new Set<string>(highlightedEdges);
    for (const k of hoverEdgesRef.current) focusEdges.add(k);

    // Cubic ease-out for the scale-in animation on newly-focused nodes. The
    // scale is intentionally restrained (max ~1.25×) so the lines remain the
    // dominant figure — nodes are anchors, rays are the story.
    const easeOut = (x: number) => 1 - Math.pow(1 - Math.min(1, Math.max(0, x)), 3);
    const enterAt = highlightEnterAtRef.current;
    const enterDuration = 220;
    const nowMs = Date.now();
    const focusScale = (id: string) => {
      const t0 = enterAt.get(id);
      if (t0 == null) return 1;
      return 1 + 0.25 * easeOut((nowMs - t0) / enterDuration);
    };

    // hub halos — make high-degree nodes feel like centres of gravity even at
    // rest. Pulses with a slow sine so the brain feels alive without distracting.
    // Halo intensity ∝ degree; only draws for nodes above a threshold so we
    // don't blow GPU on 1000 little glows.
    const t = Date.now() / 1000;
    const pulse = 0.85 + Math.sin(t * 1.2) * 0.15;
    if (!isInteracting) {
      for (const n of nodesRef.current) {
        const d = n.d || 0;
        if (d < 4) continue;
        const baseR = sizeOf(n);
        const haloR = baseR + Math.min(20, d * 0.7) / v.k;
        const intensity = Math.min(0.32, 0.06 + d * 0.014) * pulse;
        const grad = ctx.createRadialGradient(n.x || 0, n.y || 0, baseR, n.x || 0, n.y || 0, haloR);
        grad.addColorStop(0, `rgba(52, 211, 153, ${intensity})`);
        grad.addColorStop(1, 'rgba(52, 211, 153, 0)');
        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.arc(n.x || 0, n.y || 0, haloR, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.globalAlpha = 1;
    }

    // Magical illumination — community-coloured aura around the focal node.
    // Restored to the previous (good) intensity after a too-aggressive
    // tone-down. The legend-spotlight gets its own quieter aura below.
    const focalNode = (hovered as SimNode | null) ?? (selected as SimNode | null);
    if (focalNode) {
      const focalC = colorOf(focalNode.community);
      const fx = focalNode.x || 0;
      const fy = focalNode.y || 0;
      const reach = (200 + Math.min(220, (focalNode.d || 1) * 16)) / v.k;
      const aura = ctx.createRadialGradient(fx, fy, 0, fx, fy, reach);
      const auraIntensity = 0.18 + Math.sin(t * 1.6) * 0.04;
      aura.addColorStop(0, hexToRgba(focalC, auraIntensity));
      aura.addColorStop(0.5, hexToRgba(focalC, auraIntensity * 0.4));
      aura.addColorStop(1, hexToRgba(focalC, 0));
      ctx.fillStyle = aura;
      ctx.beginPath();
      ctx.arc(fx, fy, reach, 0, Math.PI * 2);
      ctx.fill();
    }


    // edges (resting lattice) — stays at the same brightness whether or not
    // anything is focused. Focus creates the "magic" by ADDING brightness on
    // top of this baseline, not by dimming the rest. The whole canvas should
    // get brighter when you click, not darker.
    ctx.lineWidth = 0.7 / v.k;
    for (const e of linksRef.current) {
      const s = typeof e.source === 'object' ? e.source : byId[e.source];
      const t = typeof e.target === 'object' ? e.target : byId[e.target];
      if (!s || !t) continue;
      const ek = edgeKey(s.id, t.id);
      const isBright = focusEdges.has(ek);
      const onPath = pathState.path?.has(ek);
      if (isBright || onPath) continue;
      ctx.globalAlpha = isInteracting ? 0.16 : 0.18;
      ctx.strokeStyle = '#FFFFFF';
      ctx.setLineDash(e.c === 'INFERRED' ? [2 / v.k, 3 / v.k] : []);
      ctx.beginPath();
      ctx.moveTo(s.x || 0, s.y || 0);
      ctx.lineTo(t.x || 0, t.y || 0);
      ctx.stroke();
    }

    // edges (bright pass) — focused rays. Four-layer render: wide glow,
    // mid body in community colour, sharp white core for definition, plus
    // a travelling pulse that gives the connection a sense of motion.
    const dashOffset = -((nowMs / 32) % 14) / v.k;
    ctx.setLineDash([]);
    for (const e of linksRef.current) {
      const s = typeof e.source === 'object' ? e.source : byId[e.source];
      const t = typeof e.target === 'object' ? e.target : byId[e.target];
      if (!s || !t) continue;
      const ek = edgeKey(s.id, t.id);
      const isBright = focusEdges.has(ek);
      const onPath = pathState.path?.has(ek);
      if (!isBright && !onPath) continue;
      const sx = s.x || 0, sy = s.y || 0, tx = t.x || 0, ty = t.y || 0;
      const grad = ctx.createLinearGradient(sx, sy, tx, ty);
      if (onPath) {
        grad.addColorStop(0, '#34D399');
        grad.addColorStop(1, '#A7F3D0');
      } else {
        grad.addColorStop(0, colorOf(s.community));
        grad.addColorStop(1, colorOf(t.community));
      }
      // Layer 1 — wide soft glow
      ctx.setLineDash([]);
      ctx.globalAlpha = onPath ? 0.4 : 0.45;
      ctx.lineWidth = 7 / v.k;
      ctx.strokeStyle = grad;
      ctx.beginPath();
      ctx.moveTo(sx, sy);
      ctx.lineTo(tx, ty);
      ctx.stroke();
      // Layer 2 — mid body
      ctx.globalAlpha = onPath ? 0.95 : 0.85;
      ctx.lineWidth = 2.4 / v.k;
      ctx.strokeStyle = grad;
      ctx.beginPath();
      ctx.moveTo(sx, sy);
      ctx.lineTo(tx, ty);
      ctx.stroke();
      // Layer 3 — sharp white core
      ctx.globalAlpha = 0.85;
      ctx.lineWidth = 0.9 / v.k;
      ctx.strokeStyle = '#FFFFFF';
      if (e.c === 'INFERRED') ctx.setLineDash([3 / v.k, 4 / v.k]);
      else ctx.setLineDash([]);
      ctx.beginPath();
      ctx.moveTo(sx, sy);
      ctx.lineTo(tx, ty);
      ctx.stroke();
      // Layer 4 — travelling pulse
      ctx.globalAlpha = 0.55;
      ctx.lineWidth = 1.4 / v.k;
      ctx.setLineDash([3 / v.k, 12 / v.k]);
      ctx.lineDashOffset = dashOffset;
      ctx.strokeStyle = '#FFFFFF';
      ctx.beginPath();
      ctx.moveTo(sx, sy);
      ctx.lineTo(tx, ty);
      ctx.stroke();
    }
    ctx.setLineDash([]);
    ctx.lineDashOffset = 0;
    ctx.globalAlpha = 1;

    // nodes (resting) — stay vibrant whether or not something is focused.
    // We pull back only a touch (0.78) so the focused set visibly leads,
    // but the canvas as a whole stays bright and alive.
    for (const n of nodesRef.current) {
      const isSel = selected && n.id === selected.id;
      const isFocus = focusNodes.has(n.id);
      const isHover = hovered && hovered.id === n.id;
      const onPath = pathState.path?.has(n.id);
      if (isSel || isFocus || isHover || onPath) continue;
      const r = sizeOf(n);
      ctx.globalAlpha = isInteracting ? 0.78 : 0.92;
      ctx.fillStyle = colorOf(n.community);
      ctx.beginPath();
      ctx.arc(n.x || 0, n.y || 0, r, 0, Math.PI * 2);
      ctx.fill();
    }

    // nodes (bright pass) — animated. Each focused node scales from 1.0 → ~1.55
    // over 260ms with cubic ease-out, the moment it joins the focus set.
    for (const n of nodesRef.current) {
      const isSel = selected && n.id === selected.id;
      const isFocus = focusNodes.has(n.id);
      const isHover = hovered && hovered.id === n.id;
      const onPath = pathState.path?.has(n.id);
      if (!(isSel || isFocus || isHover || onPath)) continue;
      const baseR = sizeOf(n);
      const scale = focusScale(n.id);
      const r = baseR * scale;
      const baseColor = colorOf(n.community);
      // Outer halo — wider on the hovered node. Halo colour is the node's
      // own community colour so the cluster's identity carries into the glow.
      // Path-traced nodes override to emerald to mark the active path clearly.
      const haloR = r + (isHover ? 22 : 14) / v.k;
      const halo = ctx.createRadialGradient(n.x || 0, n.y || 0, r * 0.5, n.x || 0, n.y || 0, haloR);
      const haloHex = onPath ? '#34D399' : baseColor;
      const haloAlpha = isHover ? 0.65 : isSel ? 0.55 : 0.4;
      halo.addColorStop(0, hexToRgba(haloHex, haloAlpha));
      halo.addColorStop(1, hexToRgba(haloHex, 0));
      ctx.globalAlpha = 1;
      ctx.fillStyle = halo;
      ctx.beginPath();
      ctx.arc(n.x || 0, n.y || 0, haloR, 0, Math.PI * 2);
      ctx.fill();
      ctx.globalAlpha = 1;
      ctx.fillStyle = baseColor;
      ctx.beginPath();
      // Disc itself — already pre-scaled via `r` from focusScale. The hovered
      // node gets an extra nudge so it visibly leads the focus group.
      ctx.arc(n.x || 0, n.y || 0, r * (isHover ? 1.15 : 1), 0, Math.PI * 2);
      ctx.fill();
      // Selected/path-traced nodes get a crisp emerald ring on top
      if (isSel || onPath) {
        ctx.lineWidth = 1.4 / v.k;
        ctx.strokeStyle = '#34D399';
        ctx.beginPath();
        ctx.arc(n.x || 0, n.y || 0, r * 1.18 + 1.5 / v.k, 0, Math.PI * 2);
        ctx.stroke();
      }
    }

    // labels — only the hovered + selected node, plus path-traced nodes.
    // Labelling the whole focus set creates a wall of overlapping cards in tight
    // clusters. The right-sidebar already enumerates connections by name; the
    // graph job is to show the SHAPE of the connections, not duplicate the list.
    ctx.font = '11px Geist, system-ui, sans-serif';
    ctx.textBaseline = 'middle';
    const labelsToDraw: SimNode[] = [];
    for (const n of nodesRef.current) {
      const isSel = selected && n.id === selected.id;
      const isHover = hovered && hovered.id === n.id;
      const onPath = pathState.path?.has(n.id);
      if (isSel || isHover || onPath) labelsToDraw.push(n);
    }
    for (const n of labelsToDraw) {
      const label = (n.label || '').slice(0, 42);
      // Label hugs the rendered (post-scale) edge of the disc — keeps a
      // consistent gap as nodes animate in.
      const r = sizeOf(n) * focusScale(n.id) * (hovered?.id === n.id ? 1.15 : 1);
      const x = (n.x || 0) + r + 6 / v.k;
      const y = n.y || 0;
      const metrics = ctx.measureText(label);
      const padX = 5 / v.k;
      const wL = metrics.width + padX * 2;
      const hL = 16 / v.k;
      const rad = 3 / v.k;
      ctx.globalAlpha = 0.92;
      ctx.fillStyle = 'rgba(15, 18, 25, 0.96)';
      ctx.beginPath();
      ctx.moveTo(x - padX + rad, y - hL / 2);
      ctx.lineTo(x - padX + wL - rad, y - hL / 2);
      ctx.quadraticCurveTo(x - padX + wL, y - hL / 2, x - padX + wL, y - hL / 2 + rad);
      ctx.lineTo(x - padX + wL, y + hL / 2 - rad);
      ctx.quadraticCurveTo(x - padX + wL, y + hL / 2, x - padX + wL - rad, y + hL / 2);
      ctx.lineTo(x - padX + rad, y + hL / 2);
      ctx.quadraticCurveTo(x - padX, y + hL / 2, x - padX, y + hL / 2 - rad);
      ctx.lineTo(x - padX, y - hL / 2 + rad);
      ctx.quadraticCurveTo(x - padX, y - hL / 2, x - padX + rad, y - hL / 2);
      ctx.fill();
      ctx.lineWidth = 0.5 / v.k;
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.08)';
      ctx.stroke();
      ctx.globalAlpha = 1;
      ctx.fillStyle = '#FAFAFA';
      ctx.fillText(label, x, y);
    }

    ctx.restore();
  };

  // ---- Resize observer
  useEffect(() => {
    const el = containerRef.current;
    const canvas = canvasRef.current;
    if (!el || !canvas) return;
    const ro = new ResizeObserver(() => {
      const dpr = window.devicePixelRatio || 1;
      const { width: w, height: h } = el.getBoundingClientRect();
      sizeRef.current = { w, h, dpr };
      canvas.width = w * dpr;
      canvas.height = h * dpr;
      canvas.style.width = `${w}px`;
      canvas.style.height = `${h}px`;
      drawRef.current?.();
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  // ---- Animation loop
  useEffect(() => {
    let raf = 0;
    const loop = () => {
      drawRef.current?.();
      raf = requestAnimationFrame(loop);
    };
    raf = requestAnimationFrame(loop);
    return () => {
      cancelAnimationFrame(raf);
      simRef.current?.stop();
    };
  }, []);

  // ---- Pointer interactions
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    function handleDown(e: PointerEvent) {
      const rect = canvas!.getBoundingClientRect();
      const sx = e.clientX - rect.left;
      const sy = e.clientY - rect.top;
      const n = pick(sx, sy);
      lastPointerRef.current = { x: e.clientX, y: e.clientY };
      canvas!.setPointerCapture(e.pointerId);
      if (n) {
        draggingRef.current = n;
        const [wx, wy] = screenToWorld(sx, sy);
        n.fx = wx;
        n.fy = wy;
      } else {
        panningRef.current = true;
      }
    }

    function handleMove(e: PointerEvent) {
      const rect = canvas!.getBoundingClientRect();
      const sx = e.clientX - rect.left;
      const sy = e.clientY - rect.top;
      if (draggingRef.current) {
        const [wx, wy] = screenToWorld(sx, sy);
        draggingRef.current.fx = wx;
        draggingRef.current.fy = wy;
        if (simRef.current) simRef.current.alphaTarget(0.3).restart();
        return;
      }
      if (panningRef.current) {
        const dx = e.clientX - lastPointerRef.current.x;
        const dy = e.clientY - lastPointerRef.current.y;
        viewRef.current.tx += dx;
        viewRef.current.ty += dy;
        lastPointerRef.current = { x: e.clientX, y: e.clientY };
        return;
      }
      const hovered = pick(sx, sy);
      const prev = hoveredRef.current;
      hoveredRef.current = hovered;
      canvas!.style.cursor = hovered ? 'pointer' : 'default';
      // Recompute neighbour highlights only when the hovered identity changes —
      // saves rebuilding sets on every pointermove inside the same node.
      if (hovered?.id !== prev?.id) {
        const hi = new Set<string>();
        const he = new Set<string>();
        const enterAt = highlightEnterAtRef.current;
        const now = Date.now();
        if (hovered) {
          hi.add(hovered.id);
          for (const a of adjacency[hovered.id] || []) {
            hi.add(a.id);
            he.add(edgeKey(hovered.id, a.id));
          }
          // Stamp newly-entered nodes; preserve timestamp for ones already
          // animated in (e.g. they were neighbours of the previous hover or
          // are click-pinned) so they don't re-bounce on every mouse move.
          for (const id of hi) {
            if (!enterAt.has(id)) enterAt.set(id, now);
          }
        }
        // Drop stamps for nodes no longer in any focus set. Click-selection
        // (`highlighted`) keeps its members; live hover (`hi`) keeps its members.
        for (const id of Array.from(enterAt.keys())) {
          if (!hi.has(id) && !highlighted.has(id)) enterAt.delete(id);
        }
        hoverNeighborsRef.current = hi;
        hoverEdgesRef.current = he;
      }
      const tt = tooltipRef.current;
      if (tt) {
        if (hovered) {
          tt.style.display = 'block';
          tt.style.left = `${e.clientX + 14}px`;
          tt.style.top = `${e.clientY + 14}px`;
          const neighbourCount = (adjacency[hovered.id] || []).length;
          tt.innerHTML = `<div style="font-weight:500">${escapeHTML(hovered.label)}</div><div style="font-family: 'JetBrains Mono', monospace; font-size: 10px; color: #71717a; margin-top: 2px;">${escapeHTML(hovered.source_file)} · ${neighbourCount} connections</div>`;
        } else {
          tt.style.display = 'none';
        }
      }
    }

    function handleUp(e: PointerEvent) {
      const drag = draggingRef.current;
      const moved =
        Math.abs(e.clientX - lastPointerRef.current.x) > 3 ||
        Math.abs(e.clientY - lastPointerRef.current.y) > 3;
      if (drag) {
        drag.fx = null;
        drag.fy = null;
        if (simRef.current) simRef.current.alphaTarget(0);
        if (!moved) selectNode(drag);
      } else if (panningRef.current && !moved) {
        clearSelection();
      }
      draggingRef.current = null;
      panningRef.current = false;
      canvas!.releasePointerCapture(e.pointerId);
    }

    function handleWheel(e: WheelEvent) {
      e.preventDefault();
      const v = viewRef.current;
      // Figma-style two-mode wheel:
      //   • Pinch (browser sets ctrlKey on trackpad pinch) or Cmd+wheel → zoom
      //   • Plain wheel / two-finger scroll → pan
      // Magnitude-scaled zoom prevents the "instantly maxed out" feel that
      // happens with trackpads firing ~60 events/sec at a fixed step.
      const isZoom = e.ctrlKey || e.metaKey;
      if (isZoom) {
        const rect = canvas!.getBoundingClientRect();
        const sx = e.clientX - rect.left;
        const sy = e.clientY - rect.top;
        // Smooth log-scaled zoom: small deltas → small zoom, big deltas → big.
        // 1.0035 base keeps trackpad pinch silky; mouse wheels (deltaY ~100)
        // give ~30% per notch.
        const factor = Math.exp(-e.deltaY * 0.0035);
        const newK = Math.max(0.15, Math.min(8, v.k * factor));
        v.tx = sx - ((sx - v.tx) * newK) / v.k;
        v.ty = sy - ((sy - v.ty) * newK) / v.k;
        v.k = newK;
      } else {
        // Plain scroll = pan (matches Mac trackpad / Figma muscle memory).
        v.tx -= e.deltaX;
        v.ty -= e.deltaY;
      }
    }

    canvas.addEventListener('pointerdown', handleDown);
    canvas.addEventListener('pointermove', handleMove);
    canvas.addEventListener('pointerup', handleUp);
    canvas.addEventListener('wheel', handleWheel, { passive: false });
    canvas.addEventListener('pointerleave', () => {
      hoveredRef.current = null;
      hoverNeighborsRef.current = new Set();
      hoverEdgesRef.current = new Set();
      // Drop entry timestamps that aren't still pinned by a click selection.
      // Click-pinned nodes keep their timestamps, so they don't re-bounce.
      const enterAt = highlightEnterAtRef.current;
      for (const id of Array.from(enterAt.keys())) {
        if (!highlighted.has(id)) enterAt.delete(id);
      }
      const tt = tooltipRef.current;
      if (tt) tt.style.display = 'none';
    });
    return () => {
      canvas.removeEventListener('pointerdown', handleDown);
      canvas.removeEventListener('pointermove', handleMove);
      canvas.removeEventListener('pointerup', handleUp);
      canvas.removeEventListener('wheel', handleWheel);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // ---- Keyboard
  useEffect(() => {
    function handleKey(e: KeyboardEvent) {
      const inField =
        e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement;
      if (e.key === '/' && !inField && !paletteOpen) {
        e.preventDefault();
        searchInputRef.current?.focus();
      }
      if (e.key === 'Escape') {
        if (paletteOpen) setPaletteOpen(false);
        else {
          setSearchTerm('');
          clearSelection();
        }
      }
      if (e.key === 'k' && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setPaletteOpen(true);
      }
    }
    window.addEventListener('keydown', handleKey);
    return () => window.removeEventListener('keydown', handleKey);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [paletteOpen]);

  // ---- Selection
  function selectNode(n: GraphNode) {
    setSelected(n);
    setActiveTab('node');
    const hi = new Set<string>([n.id]);
    const he = new Set<string>();
    for (const a of adjacency[n.id] || []) {
      hi.add(a.id);
      he.add(edgeKey(n.id, a.id));
    }
    // Stamp entry times so the click-selected set animates in just like a hover.
    const enterAt = highlightEnterAtRef.current;
    const now = Date.now();
    for (const id of hi) if (!enterAt.has(id)) enterAt.set(id, now);
    setHighlighted(hi);
    setHighlightedEdges(he);
  }

  function clearSelection() {
    setSelected(null);
    setHighlighted(new Set());
    setHighlightedEdges(new Set());
    highlightEnterAtRef.current = new Map();
    setPathState({ from: null, to: null, path: null, pathArr: null });
  }

  function panTo(n: { x?: number; y?: number }) {
    const { w, h } = sizeRef.current;
    const k = Math.max(viewRef.current.k, 1.5);
    viewRef.current.tx = w / 2 - (n.x || 0) * k;
    viewRef.current.ty = h / 2 - (n.y || 0) * k;
    viewRef.current.k = k;
  }

  // Zoom centred on the canvas viewport (not the cursor) — used by the
  // explicit +/- buttons. Mouse-wheel zoom (in handleWheel) centres on the
  // cursor instead since that's where the user is looking.
  function zoomBy(factor: number) {
    const { w, h } = sizeRef.current;
    const v = viewRef.current;
    const cx = w / 2;
    const cy = h / 2;
    const newK = Math.max(0.15, Math.min(8, v.k * factor));
    v.tx = cx - ((cx - v.tx) * newK) / v.k;
    v.ty = cy - ((cy - v.ty) * newK) / v.k;
    v.k = newK;
  }

  // Reset to "fit all nodes in view" — recomputes from current node positions.
  function fitToView() {
    const { w, h } = sizeRef.current;
    let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity;
    for (const n of nodesRef.current) {
      const x = n.x || 0, y = n.y || 0;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
    if (!isFinite(minX)) return;
    const gw = Math.max(1, maxX - minX);
    const gh = Math.max(1, maxY - minY);
    const k = Math.min((w - 80) / gw, (h - 80) / gh, 2);
    const cx = (minX + maxX) / 2;
    const cy = (minY + maxY) / 2;
    viewRef.current.k = k;
    viewRef.current.tx = w / 2 - cx * k;
    viewRef.current.ty = h / 2 - cy * k;
  }

  // ---- Search
  function onSearchChange(v: string) {
    setSearchTerm(v);
    if (v.trim()) setActiveTab('results');
  }

  const results = useMemo(() => {
    if (!searchTerm.trim()) return [];
    const q = searchTerm.toLowerCase();
    return data.nodes
      .filter((n) => nodeMatches(n, q))
      .sort((a, b) => b.d - a.d)
      .slice(0, 200);
  }, [data, searchTerm]);

  // ---- Path BFS
  function findPath(fromId: string, toId: string): string[] | null {
    if (fromId === toId) return [fromId];
    const visited = new Set([fromId]);
    const queue: string[][] = [[fromId]];
    while (queue.length) {
      const path = queue.shift()!;
      const last = path[path.length - 1];
      for (const a of adjacency[last] || []) {
        if (a.id === toId) return [...path, toId];
        if (!visited.has(a.id)) {
          visited.add(a.id);
          queue.push([...path, a.id]);
        }
      }
    }
    return null;
  }

  function tracePath(fromName: string, toName: string) {
    const from = findNodeByName(data.nodes, fromName);
    const to = findNodeByName(data.nodes, toName);
    if (!from || !to) return { error: 'No match for one of the nodes.' };
    const path = findPath(from.id, to.id);
    if (!path) {
      setPathState({ from, to, path: null, pathArr: null });
      return { error: 'No path between these nodes.' };
    }
    const ps = new Set<string>(path);
    for (let i = 0; i < path.length - 1; i++) ps.add(edgeKey(path[i], path[i + 1]));
    setPathState({ from, to, path: ps, pathArr: path });
    return { ok: true };
  }

  // ---- Surprises
  const surprises = useMemo(() => {
    const out: { s: GraphNode; t: GraphNode; e: GraphEdge; score: number }[] = [];
    for (const e of data.edges) {
      if (e.c !== 'INFERRED') continue;
      const s = byId[e.s];
      const t = byId[e.t];
      if (!s || !t || s.community === t.community) continue;
      out.push({ s, t, e, score: Math.min(s.d, t.d) });
    }
    out.sort((a, b) => b.score - a.score);
    return out;
  }, [data, byId]);

  return (
    <div className="relative h-full w-full overflow-hidden flex">
      <div ref={containerRef} className="relative flex-1 overflow-hidden bg-black">
        <canvas ref={canvasRef} className="absolute inset-0 block" />
        <div ref={tooltipRef} className="brain-tooltip" />

        {/* Top-centre status banner — only for transient build states.
            Steady-state stats live in the bottom-right card so they don't
            overlap the search bar. */}
        {isBuilding && (
          <div className="absolute top-4 left-1/2 -translate-x-1/2 z-10 px-3 py-1.5 rounded-full bg-violet-400/10 border border-violet-400/30 text-violet-300 text-xs font-medium flex items-center gap-2 backdrop-blur-md pointer-events-none">
            <span className="relative flex h-2 w-2">
              <span className="absolute inset-0 rounded-full bg-violet-400 animate-ping" />
              <span className="relative inline-flex rounded-full h-2 w-2 bg-violet-400" />
            </span>
            Brain is evolving — refresh in ~2 minutes
          </div>
        )}
        {isDemo && !isBuilding && (
          <div className="absolute top-4 left-1/2 -translate-x-1/2 z-10 px-3 py-1.5 rounded-full bg-amber-400/10 border border-amber-400/30 text-amber-300 text-xs font-medium flex items-center gap-2 backdrop-blur-md pointer-events-none">
            <Sparkles className="w-3 h-3" />
            Demo brain — yours initialises when the wizard finishes
          </div>
        )}


        {/* Top toolbar */}
        <div className="absolute top-4 left-4 right-4 flex gap-2 items-start z-10 flex-wrap pointer-events-none">
          <div className="flex items-center p-1 bg-[rgb(15,17,20)]/85 backdrop-blur-md border border-white/[0.06] rounded-lg gap-0.5 pointer-events-auto">
            {[
              { id: 'map', label: 'Map', Icon: MapIcon },
              { id: 'path', label: 'Path', Icon: GitBranch },
              { id: 'surprise', label: 'Surprises', Icon: Lightbulb },
            ].map((b) => (
              <button
                key={b.id}
                onClick={() => {
                  setMode(b.id as Mode);
                  if (b.id === 'path') setActiveTab('path');
                  else if (b.id === 'surprise') setActiveTab('surprise');
                  else setActiveTab('node');
                }}
                className={cn(
                  'px-3 py-1.5 text-xs rounded-md transition-all flex items-center gap-1.5',
                  mode === b.id ? 'bg-white/[0.06] text-white' : 'text-zinc-400 hover:text-white',
                )}
              >
                <b.Icon className="w-3 h-3" />
                {b.label}
              </button>
            ))}
          </div>

          <div className="relative flex-1 max-w-md pointer-events-auto">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-zinc-500 pointer-events-none" />
            <input
              ref={searchInputRef}
              value={searchTerm}
              onChange={(e) => onSearchChange(e.target.value)}
              placeholder={`Search ${data.nodes.length.toLocaleString()} nodes — / to focus`}
              className="w-full h-8 pl-9 pr-12 rounded-lg bg-[rgb(15,17,20)]/85 backdrop-blur-md border border-white/[0.06] focus:border-emerald-400 text-xs text-white placeholder-zinc-500 outline-none transition-colors"
            />
            <kbd className="absolute right-2 top-1/2 -translate-y-1/2 text-[10px] font-mono px-1.5 py-0.5 bg-white/5 border border-white/10 rounded text-zinc-500">
              /
            </kbd>
          </div>

          <button
            onClick={() => setPaletteOpen(true)}
            className="h-8 px-3 flex items-center gap-2 rounded-lg bg-emerald-400/10 border border-emerald-400/30 text-emerald-300 text-xs font-medium hover:bg-emerald-400/15 transition-colors pointer-events-auto"
          >
            <Sparkles className="w-3 h-3" />
            Ask the brain
            <kbd className="text-[10px] font-mono px-1 py-0.5 bg-white/5 border border-white/10 rounded text-zinc-500 ml-1">
              ⌘K
            </kbd>
          </button>
        </div>

        {/* Communities legend (bottom-left) — simple, scrollable reference.
            Click pans to that cluster's centroid; no hover-spotlight or pin
            (those got in the way of normal canvas use). */}
        <CommunityLegend
          communities={data.communities}
          onJump={(cid) => {
            const members = nodesRef.current.filter((n) => n.community === cid);
            if (members.length === 0) return;
            const cx = members.reduce((s, n) => s + (n.x || 0), 0) / members.length;
            const cy = members.reduce((s, n) => s + (n.y || 0), 0) / members.length;
            panTo({ x: cx, y: cy });
          }}
        />

        {/* Zoom controls — explicit +/− and fit-to-view, top-right of the
            canvas. Backs up the wheel/pinch gestures with discoverable UI. */}
        <div className="absolute top-4 right-4 z-10 flex flex-col gap-1 bg-[rgb(15,17,20)]/85 backdrop-blur-md border border-white/[0.06] rounded-lg p-1 pointer-events-auto">
          <button
            onClick={() => zoomBy(1.3)}
            className="w-7 h-7 rounded-md flex items-center justify-center text-zinc-300 hover:bg-white/5 hover:text-white transition-colors"
            aria-label="Zoom in"
            title="Zoom in"
          >
            <ZoomIn className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={() => zoomBy(1 / 1.3)}
            className="w-7 h-7 rounded-md flex items-center justify-center text-zinc-300 hover:bg-white/5 hover:text-white transition-colors"
            aria-label="Zoom out"
            title="Zoom out"
          >
            <ZoomOut className="w-3.5 h-3.5" />
          </button>
          <div className="h-px bg-white/[0.06] my-0.5 mx-1" />
          <button
            onClick={fitToView}
            className="w-7 h-7 rounded-md flex items-center justify-center text-zinc-300 hover:bg-white/5 hover:text-white transition-colors"
            aria-label="Fit to view"
            title="Fit everything to view"
          >
            <Crosshair className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* Stats + evolution (bottom-right) — single card with build version,
            last-evolved time, density, and counts. Positioned to clear the
            global chat widget bar (lg:pb-24 in the layout). */}
        <BrainStatsCard
          nodes={data.nodes.length}
          edges={data.edges.length}
          communities={Object.keys(data.communities).length}
          version={meta?.version}
          generatedAt={meta?.generatedAt}
        />
      </div>

      <DetailPanel
        slug={slug}
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        selected={selected}
        adjacency={adjacency}
        byId={byId}
        communities={data.communities}
        searchTerm={searchTerm}
        results={results}
        onSelect={(n) => {
          selectNode(n);
          panTo(n);
        }}
        surprises={surprises}
        pathState={pathState}
        tracePath={tracePath}
        resultCount={results.length}
        surpriseCount={surprises.length}
      />

      {paletteOpen && (
        <AskBrainPalette
          slug={slug}
          nodes={data.nodes}
          onClose={() => setPaletteOpen(false)}
          onPick={(n) => {
            selectNode(n);
            panTo(n);
            setPaletteOpen(false);
          }}
        />
      )}
    </div>
  );
}

// =============================================================================
// Communities legend (bottom-left) — scrollable, hover-spotlight, pin-to-query
// =============================================================================

function CommunityLegend({
  communities,
  onJump,
}: {
  communities: Record<string, string>;
  onJump: (cid: number) => void;
}) {
  const entries = Object.entries(communities);
  return (
    <div className="absolute bottom-24 left-4 z-5 bg-[rgb(15,17,20)]/85 backdrop-blur-md border border-white/[0.06] rounded-lg max-w-xs pointer-events-auto overflow-hidden">
      <div className="px-3 py-2 text-[10px] uppercase tracking-wider text-zinc-500 font-semibold flex justify-between border-b border-white/[0.04]">
        <span>Communities</span>
        <span>{entries.length} labelled</span>
      </div>
      <div className="max-h-48 overflow-y-auto px-2 py-2 brain-legend-scroll">
        <div className="grid grid-cols-2 gap-x-2 gap-y-0.5 text-[11px] text-zinc-400">
          {entries.map(([cid, label]) => {
            const id = +cid;
            return (
              <button
                key={cid}
                onClick={() => onJump(id)}
                className="flex items-center gap-1.5 px-1.5 py-1 rounded text-left hover:bg-white/[0.04] hover:text-white transition-colors"
                title={label}
              >
                <span
                  className="w-2 h-2 rounded-full shrink-0"
                  style={{ background: colorOf(id) }}
                />
                <span className="truncate">{label}</span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

// =============================================================================
// Stats card (bottom-right) — counts + build version + last-evolved time
// =============================================================================

function BrainStatsCard({
  nodes,
  edges,
  communities,
  version,
  generatedAt,
}: {
  nodes: number;
  edges: number;
  communities: number;
  version?: number;
  generatedAt?: string | Date;
}) {
  const ts = generatedAt ? new Date(generatedAt) : null;
  const ageMin = ts ? (Date.now() - ts.getTime()) / 60000 : Infinity;
  const isFresh = ageMin < 10;
  const density = nodes > 0 ? (edges / nodes).toFixed(1) : '0.0';

  return (
    <div className="absolute bottom-24 right-4 z-5 flex items-center gap-2 pointer-events-auto">
      <div className="px-3 py-2 bg-[rgb(15,17,20)]/85 backdrop-blur-md border border-white/[0.06] rounded-lg flex items-center gap-3 text-[11px] text-zinc-500">
        {version != null && (
          <>
            <span className="flex items-center gap-1.5">
              <span className="relative flex h-1.5 w-1.5">
                {isFresh && (
                  <span className="absolute inset-0 rounded-full bg-emerald-400 animate-ping" />
                )}
                <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-emerald-400" />
              </span>
              <span className="text-emerald-300 font-medium">Build #{version}</span>
            </span>
            {ts && (
              <span className="text-zinc-500" suppressHydrationWarning>
                <span className="text-zinc-300">{formatRelative(ts)}</span> ago
              </span>
            )}
            <span className="text-zinc-700">·</span>
          </>
        )}
        <span>
          <span className="text-white font-mono font-semibold text-xs">
            {nodes.toLocaleString()}
          </span>{' '}
          nodes
        </span>
        <span className="text-zinc-700">·</span>
        <span>
          <span className="text-white font-mono font-semibold text-xs">
            {edges.toLocaleString()}
          </span>{' '}
          edges
        </span>
        <span className="text-zinc-700">·</span>
        <span>
          <span className="text-white font-mono font-semibold text-xs">{density}</span>{' '}
          density
        </span>
        <span className="text-zinc-700">·</span>
        <span>
          <span className="text-white font-mono font-semibold text-xs">{communities}</span>{' '}
          comm
        </span>
      </div>
    </div>
  );
}

// =============================================================================
// Detail panel
// =============================================================================

// =============================================================================
// Detail panel
// =============================================================================

function DetailPanel({
  slug,
  activeTab,
  setActiveTab,
  selected,
  adjacency,
  byId,
  communities,
  searchTerm,
  results,
  onSelect,
  surprises,
  pathState,
  tracePath,
  resultCount,
  surpriseCount,
}: {
  slug: string;
  activeTab: Tab;
  setActiveTab: (t: Tab) => void;
  selected: GraphNode | null;
  adjacency: Record<string, { id: string; r: string; c: string; dir: 'in' | 'out' }[]>;
  byId: Record<string, GraphNode>;
  communities: Record<string, string>;
  searchTerm: string;
  results: GraphNode[];
  onSelect: (n: GraphNode) => void;
  surprises: { s: GraphNode; t: GraphNode; e: GraphEdge; score: number }[];
  pathState: {
    from: GraphNode | null;
    to: GraphNode | null;
    path: Set<string> | null;
    pathArr: string[] | null;
  };
  tracePath: (a: string, b: string) => { ok?: boolean; error?: string };
  resultCount: number;
  surpriseCount: number;
}) {
  return (
    <aside className="w-[380px] shrink-0 bg-[rgb(13,16,20)] border-l border-white/5 flex flex-col">
      <div className="flex border-b border-white/5 px-3 gap-1 shrink-0">
        {[
          { id: 'node', label: 'Detail' },
          { id: 'results', label: 'Results', count: resultCount },
          { id: 'path', label: 'Path' },
          { id: 'surprise', label: 'Surprises', count: surpriseCount },
        ].map((t) => (
          <button
            key={t.id}
            onClick={() => setActiveTab(t.id as Tab)}
            className={cn(
              'py-3.5 px-2.5 text-xs font-medium border-b-2 transition-all',
              activeTab === t.id
                ? 'text-white border-emerald-400'
                : 'text-zinc-500 hover:text-zinc-300 border-transparent',
            )}
          >
            {t.label}
            {t.count !== undefined ? (
              <span
                className={cn(
                  'ml-1.5 font-mono text-[10px]',
                  activeTab === t.id ? 'text-emerald-400' : 'text-zinc-600',
                )}
              >
                {t.count}
              </span>
            ) : null}
          </button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto p-5 space-y-5">
        {activeTab === 'node' && (
          selected ? (
            <NodeDetail node={selected} adjacency={adjacency} byId={byId} communities={communities} onSelect={onSelect} />
          ) : (
            <DetailEmpty
              icon="◈"
              primary="Click any node"
              secondary="See its source, connections and rationale. Or press / to search the constellation."
            />
          )
        )}
        {activeTab === 'results' && (
          searchTerm ? (
            <ResultsList searchTerm={searchTerm} results={results} onSelect={onSelect} />
          ) : (
            <DetailEmpty icon="⌕" primary="Search the brain" secondary="Type in the bar above to highlight matching nodes and list them here." />
          )
        )}
        {activeTab === 'path' && <PathTab pathState={pathState} tracePath={tracePath} byId={byId} adjacency={adjacency} />}
        {activeTab === 'surprise' && (
          <SurprisesList surprises={surprises} communities={communities} onSelect={onSelect} slug={slug} />
        )}
      </div>
    </aside>
  );
}

function NodeDetail({
  node,
  adjacency,
  byId,
  communities,
  onSelect,
}: {
  node: GraphNode;
  adjacency: Record<string, { id: string; r: string; c: string; dir: 'in' | 'out' }[]>;
  byId: Record<string, GraphNode>;
  communities: Record<string, string>;
  onSelect: (n: GraphNode) => void;
}) {
  const adj = adjacency[node.id] || [];
  const inferredCount = adj.filter((a) => a.c === 'INFERRED').length;
  const isGod = node.d >= 10;
  const commLabel = communities[String(node.community)] || `Community ${node.community}`;

  return (
    <div className="space-y-5">
      <div className="pb-4 border-b border-white/5">
        <div className="flex items-center gap-1.5 text-[10px] uppercase tracking-wider text-zinc-500 font-semibold mb-2">
          {isGod && (
            <span className="px-2 py-0.5 bg-violet-400/10 text-violet-300 rounded-full font-medium tracking-wider flex items-center gap-1">
              <Star className="w-2.5 h-2.5 fill-current" /> god node
            </span>
          )}
          {isGod && <span>·</span>}
          <span style={{ color: colorOf(node.community) }} className="font-medium">
            {commLabel}
          </span>
        </div>
        <h1 className="font-display text-xl font-medium text-white tracking-tight leading-tight mb-2">
          {node.label}
        </h1>
        <div className="font-mono text-[11px] text-zinc-500 break-all flex items-start gap-1.5">
          <span className="text-zinc-400 shrink-0">
            {node.file_type === 'code' ? '⌗' : node.file_type === 'image' ? '◧' : '📄'}
          </span>
          <span>{node.source_file || '(no source)'}</span>
        </div>
      </div>

      <dl className="grid grid-cols-[80px_1fr] gap-x-3 gap-y-2 text-xs">
        <dt className="text-zinc-500 text-[11px] pt-0.5">community</dt>
        <dd className="text-white">
          <span className="inline-block w-2 h-2 rounded-full mr-1.5 align-middle" style={{ background: colorOf(node.community) }} />
          {commLabel}
        </dd>
        <dt className="text-zinc-500 text-[11px] pt-0.5">type</dt>
        <dd className="text-white">{node.file_type}</dd>
        <dt className="text-zinc-500 text-[11px] pt-0.5">edges</dt>
        <dd>
          <span className="inline-flex items-center gap-1 px-2 py-0.5 bg-white/5 rounded font-mono text-[11px]">
            <span className="text-emerald-400 font-medium">{node.d}</span> total
          </span>
          {inferredCount > 0 && (
            <span className="ml-1.5 inline-flex items-center gap-1 px-2 py-0.5 bg-white/5 rounded font-mono text-[11px]">
              <span className="text-amber-400 font-medium">{inferredCount}</span> inferred
            </span>
          )}
        </dd>
      </dl>

      <div>
        <div className="text-[10px] uppercase tracking-wider text-zinc-500 font-semibold mb-2 flex justify-between">
          <span>Connections</span>
          <span className="text-zinc-600 font-medium">{adj.length}</span>
        </div>
        <div className="space-y-1">
          {adj.slice(0, 30).map((a, i) => {
            const tn = byId[a.id];
            if (!tn) return null;
            return (
              <button
                key={`${a.id}-${i}`}
                onClick={() => onSelect(tn)}
                className="w-full flex items-center gap-2 px-2.5 py-1.5 rounded-md bg-white/[0.02] hover:bg-white/[0.05] border border-transparent hover:border-white/10 transition-colors text-left"
              >
                <span className="w-2 h-2 rounded-full shrink-0" style={{ background: colorOf(tn.community) }} />
                <span className="font-mono text-[10px] text-zinc-500 shrink-0">
                  {a.dir === 'out' ? '→' : '←'} {a.r}
                </span>
                <span className="text-xs text-white flex-1 truncate">{tn.label}</span>
                <span
                  className={cn(
                    'text-[9px] font-mono font-medium px-1.5 py-0.5 rounded shrink-0 tracking-wider',
                    a.c === 'EXTRACTED' && 'bg-emerald-400/10 text-emerald-300',
                    a.c === 'INFERRED' && 'bg-amber-400/10 text-amber-300',
                    a.c === 'AMBIGUOUS' && 'bg-red-400/10 text-red-300',
                  )}
                >
                  {a.c.slice(0, 3)}
                </span>
              </button>
            );
          })}
          {adj.length > 30 && (
            <div className="text-center text-[11px] text-zinc-600 py-2">
              + {adj.length - 30} more
            </div>
          )}
        </div>
      </div>

      <div className="flex gap-2">
        <button className="flex-1 py-2 px-3 bg-white/[0.04] border border-white/10 rounded-lg text-xs font-medium hover:border-white/20 transition-colors flex items-center justify-center gap-1.5">
          <ExternalLink className="w-3 h-3" /> Source
        </button>
        <button className="flex-1 py-2 px-3 bg-white/[0.04] border border-white/10 rounded-lg text-xs font-medium hover:border-white/20 transition-colors flex items-center justify-center gap-1.5">
          📄 Wiki
        </button>
      </div>
    </div>
  );
}

function ResultsList({
  searchTerm,
  results,
  onSelect,
}: {
  searchTerm: string;
  results: GraphNode[];
  onSelect: (n: GraphNode) => void;
}) {
  if (results.length === 0) {
    return (
      <DetailEmpty icon="∅" primary={`No matches for "${searchTerm}"`} secondary="Try a different term or check spelling." />
    );
  }
  return (
    <div className="space-y-2">
      <div className="text-[10px] uppercase tracking-wider text-zinc-500 font-semibold flex justify-between mb-2">
        <span>Matches for "{searchTerm}"</span>
        <span className="text-zinc-600">{results.length}</span>
      </div>
      <div className="space-y-1">
        {results.map((n) => (
          <button
            key={n.id}
            onClick={() => onSelect(n)}
            className="w-full text-left p-2.5 rounded-md hover:bg-white/[0.04] border border-transparent hover:border-white/10 transition-colors"
          >
            <div className="text-xs font-medium text-white flex items-center gap-2 mb-1">
              <span className="w-2 h-2 rounded-full shrink-0" style={{ background: colorOf(n.community) }} />
              <span className="truncate">{n.label}</span>
            </div>
            <div className="font-mono text-[10px] text-zinc-500 truncate">
              {n.source_file} · {n.d} edges
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

function PathTab({
  pathState,
  tracePath,
  byId,
  adjacency,
}: {
  pathState: {
    from: GraphNode | null;
    to: GraphNode | null;
    path: Set<string> | null;
    pathArr: string[] | null;
  };
  tracePath: (a: string, b: string) => { ok?: boolean; error?: string };
  byId: Record<string, GraphNode>;
  adjacency: Record<string, { id: string; r: string; c: string; dir: 'in' | 'out' }[]>;
}) {
  const fromRef = useRef<HTMLInputElement>(null);
  const toRef = useRef<HTMLInputElement>(null);
  const [error, setError] = useState<string | null>(null);

  function go() {
    setError(null);
    const from = fromRef.current?.value || '';
    const to = toRef.current?.value || '';
    const r = tracePath(from, to);
    if (r.error) setError(r.error);
  }

  return (
    <div className="space-y-4">
      <div className="text-[10px] uppercase tracking-wider text-zinc-500 font-semibold">
        Find shortest path
      </div>
      <div className="space-y-3">
        <div>
          <div className="text-[10px] uppercase tracking-wider text-zinc-500 font-semibold mb-1">From</div>
          <input
            ref={fromRef}
            placeholder="e.g. HR Agent"
            defaultValue={pathState.from?.label || ''}
            className="w-full h-9 px-3 bg-white/[0.04] border border-white/10 focus:border-emerald-400 rounded-lg text-xs text-white placeholder-zinc-600 outline-none transition-colors"
          />
        </div>
        <div>
          <div className="text-[10px] uppercase tracking-wider text-zinc-500 font-semibold mb-1">To</div>
          <input
            ref={toRef}
            placeholder="e.g. DPA Template"
            defaultValue={pathState.to?.label || ''}
            className="w-full h-9 px-3 bg-white/[0.04] border border-white/10 focus:border-emerald-400 rounded-lg text-xs text-white placeholder-zinc-600 outline-none transition-colors"
          />
        </div>
        <button
          onClick={go}
          className="w-full h-9 bg-emerald-400 hover:bg-emerald-300 text-emerald-950 rounded-lg text-xs font-semibold transition-colors flex items-center justify-center gap-1.5"
        >
          <GitBranch className="w-3 h-3" /> Trace path
        </button>
      </div>

      {error && <div className="p-3 bg-amber-400/10 border border-amber-400/30 rounded-lg text-xs text-amber-300">{error}</div>}

      {pathState.pathArr && pathState.pathArr.length > 0 && (
        <div className="p-4 bg-white/[0.02] border border-white/10 rounded-lg">
          <div className="text-[10px] uppercase tracking-wider text-zinc-500 font-semibold mb-3">
            {pathState.pathArr.length - 1} hops
          </div>
          {pathState.pathArr.map((id, i) => {
            const n = byId[id];
            const next = pathState.pathArr![i + 1];
            const a = next ? (adjacency[id] || []).find((x) => x.id === next) : null;
            return (
              <div key={id}>
                <div className="flex items-center gap-2 py-1">
                  <span className="font-mono text-[10px] text-zinc-600 w-4">{i + 1}</span>
                  <span className="w-2 h-2 rounded-full shrink-0" style={{ background: colorOf(n.community) }} />
                  <span className="text-xs text-white">{n.label}</span>
                </div>
                {a && (
                  <div className="pl-7 pb-1 font-mono text-[10px] text-zinc-500">
                    ↓ {a.r}{' '}
                    <span className={cn(a.c === 'INFERRED' ? 'text-amber-400' : 'text-emerald-300')}>
                      [{a.c.slice(0, 3)}]
                    </span>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      <p className="text-[11px] text-zinc-500 leading-relaxed pt-3 border-t border-white/5">
        Path search uses unweighted BFS. Inferred edges count the same as extracted — uncheck the INFERRED filter to restrict to verified-only paths.
      </p>
    </div>
  );
}

type EdgeDecision = 'APPROVED' | 'REJECTED' | 'UNCERTAIN' | null;

function edgeKeyFor(a: string, b: string): string {
  return a < b ? `${a}|${b}` : `${b}|${a}`;
}

function SurprisesList({
  surprises,
  communities,
  onSelect,
  slug,
}: {
  surprises: { s: GraphNode; t: GraphNode; e: GraphEdge; score: number }[];
  communities: Record<string, string>;
  onSelect: (n: GraphNode) => void;
  slug: string;
}) {
  const [decisions, setDecisions] = useState<Record<string, EdgeDecision>>({});
  const [pending, setPending] = useState<Record<string, boolean>>({});

  // Load existing reviews on mount
  useEffect(() => {
    let cancelled = false;
    fetch(`/api/brain/${slug}/edges`)
      .then((r) => r.json())
      .then((j: { reviews?: { edgeKey: string; decision: EdgeDecision }[] }) => {
        if (cancelled || !j.reviews) return;
        const map: Record<string, EdgeDecision> = {};
        for (const r of j.reviews) map[r.edgeKey] = r.decision;
        setDecisions(map);
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, [slug]);

  async function review(
    s: GraphNode,
    t: GraphNode,
    e: GraphEdge,
    decision: 'APPROVED' | 'REJECTED',
  ) {
    const ek = edgeKeyFor(s.id, t.id);
    setPending((p) => ({ ...p, [ek]: true }));
    // optimistic update
    setDecisions((d) => ({ ...d, [ek]: decision }));
    try {
      const r = await fetch(`/api/brain/${slug}/edges`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          sourceNodeId: s.id,
          targetNodeId: t.id,
          relation: e.r,
          decision,
        }),
      });
      if (!r.ok) throw new Error(`${r.status}`);
    } catch {
      // rollback
      setDecisions((d) => {
        const next = { ...d };
        delete next[ek];
        return next;
      });
    } finally {
      setPending((p) => ({ ...p, [ek]: false }));
    }
  }

  const filtered = surprises.filter(({ s, t }) => decisions[edgeKeyFor(s.id, t.id)] !== 'REJECTED');
  const rejectedCount = surprises.length - filtered.length;
  const approvedCount = surprises.filter(({ s, t }) => decisions[edgeKeyFor(s.id, t.id)] === 'APPROVED').length;

  return (
    <div className="space-y-3">
      <div className="text-[10px] uppercase tracking-wider text-zinc-500 font-semibold flex justify-between">
        <span>Cross-community inferred edges</span>
        <span className="text-zinc-600">{surprises.length}</span>
      </div>
      <p className="text-[11px] text-zinc-500 leading-relaxed">
        Connections the model inferred between concepts in different parts of the project.
        Approve to keep them in queries · reject to hide forever · the brain learns from each review.
      </p>
      {(approvedCount > 0 || rejectedCount > 0) && (
        <div className="flex gap-2 text-[10px] font-mono">
          {approvedCount > 0 && (
            <span className="px-2 py-0.5 rounded bg-emerald-400/10 text-emerald-300">
              {approvedCount} approved
            </span>
          )}
          {rejectedCount > 0 && (
            <span className="px-2 py-0.5 rounded bg-red-500/10 text-red-300">
              {rejectedCount} rejected · hidden from queries
            </span>
          )}
        </div>
      )}
      <div className="space-y-1.5">
        {surprises.slice(0, 60).map(({ s, t, e }, i) => {
          const ek = edgeKeyFor(s.id, t.id);
          const decision = decisions[ek];
          const isPending = pending[ek];
          return (
            <div
              key={`${s.id}-${t.id}-${i}`}
              className={cn(
                'p-2.5 rounded-md border transition-colors',
                decision === 'APPROVED'
                  ? 'border-emerald-400/20 bg-emerald-400/[0.03]'
                  : decision === 'REJECTED'
                    ? 'border-red-500/20 bg-red-500/[0.03] opacity-60'
                    : 'border-transparent hover:bg-white/[0.04] hover:border-white/10',
              )}
            >
              <button
                onClick={() => onSelect(s)}
                className="w-full text-left space-y-1"
              >
                <div className="flex items-center gap-1.5 text-xs flex-wrap">
                  <span className="w-2 h-2 rounded-full shrink-0" style={{ background: colorOf(s.community) }} />
                  <span className="text-white">{s.label}</span>
                  <span className="font-mono text-[10px] text-zinc-500">─ {e.r} →</span>
                  <span className="w-2 h-2 rounded-full shrink-0" style={{ background: colorOf(t.community) }} />
                  <span className="text-white">{t.label}</span>
                </div>
                <div className="font-mono text-[10px] text-zinc-500">
                  {communities[String(s.community)] || `C${s.community}`} → {communities[String(t.community)] || `C${t.community}`}
                </div>
              </button>
              <div className="flex items-center gap-1 mt-2 pt-2 border-t border-white/[0.04]">
                <button
                  disabled={isPending}
                  onClick={(e2) => {
                    e2.stopPropagation();
                    review(s, t, e, 'APPROVED');
                  }}
                  className={cn(
                    'flex-1 px-2 py-1 rounded text-[10px] font-medium transition-colors flex items-center justify-center gap-1',
                    decision === 'APPROVED'
                      ? 'bg-emerald-400/15 text-emerald-300'
                      : 'bg-white/[0.03] text-zinc-400 hover:bg-emerald-400/10 hover:text-emerald-300',
                    isPending && 'opacity-50',
                  )}
                >
                  ✓ {decision === 'APPROVED' ? 'Approved' : 'Approve'}
                </button>
                <button
                  disabled={isPending}
                  onClick={(e2) => {
                    e2.stopPropagation();
                    review(s, t, e, 'REJECTED');
                  }}
                  className={cn(
                    'flex-1 px-2 py-1 rounded text-[10px] font-medium transition-colors flex items-center justify-center gap-1',
                    decision === 'REJECTED'
                      ? 'bg-red-500/15 text-red-300'
                      : 'bg-white/[0.03] text-zinc-400 hover:bg-red-500/10 hover:text-red-300',
                    isPending && 'opacity-50',
                  )}
                >
                  ✗ {decision === 'REJECTED' ? 'Rejected' : 'Reject'}
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function DetailEmpty({ icon, primary, secondary }: { icon: string; primary: string; secondary: string }) {
  return (
    <div className="text-center py-8">
      <div className="text-4xl text-zinc-700 mb-3">{icon}</div>
      <div className="text-sm text-zinc-300 font-medium mb-1.5">{primary}</div>
      <div className="text-xs text-zinc-500 leading-relaxed max-w-xs mx-auto">{secondary}</div>
    </div>
  );
}

// =============================================================================
// Ask the brain palette (⌘K)
// =============================================================================

function AskBrainPalette({
  slug,
  nodes,
  onClose,
  onPick,
}: {
  slug: string;
  nodes: GraphNode[];
  onClose: () => void;
  onPick: (n: GraphNode) => void;
}) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [q, setQ] = useState('');
  const [answer, setAnswer] = useState<{ loading: boolean; text: string | null; cited: string[] } | null>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  const matches = useMemo(() => {
    if (!q.trim()) return [];
    return nodes.filter((n) => nodeMatches(n, q.toLowerCase())).sort((a, b) => b.d - a.d).slice(0, 8);
  }, [nodes, q]);

  // Stream the answer in real time. SSE shape from /api/brain/[slug]/ask:
  //   event: cited  data: { cited: string[] }
  //   event: token  data: { text: string }
  //   event: done   data: { inputTokens, outputTokens, length }
  //   event: error  data: { error: string }
  async function ask() {
    if (!q.trim()) return;
    setAnswer({ loading: true, text: '', cited: [] });

    try {
      const r = await fetch(`/api/brain/${slug}/ask`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: q, stream: true }),
      });

      if (!r.ok || !r.body) {
        const errBody = await r.text().catch(() => '');
        setAnswer({
          loading: false,
          text: `Could not reach the brain (${r.status}). ${errBody.slice(0, 200)}`,
          cited: [],
        });
        return;
      }

      const reader = r.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';
      let assembled = '';
      let cited: string[] = [];

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        buffer += decoder.decode(value, { stream: true });

        let idx;
        while ((idx = buffer.indexOf('\n\n')) !== -1) {
          const raw = buffer.slice(0, idx);
          buffer = buffer.slice(idx + 2);
          const evtLine = raw.split('\n').find((l) => l.startsWith('event: '));
          const dataLine = raw.split('\n').find((l) => l.startsWith('data: '));
          if (!evtLine || !dataLine) continue;
          const evt = evtLine.slice(7).trim();
          const data = JSON.parse(dataLine.slice(6));
          if (evt === 'cited') {
            cited = data.cited || [];
            setAnswer((prev) => ({
              loading: true,
              text: prev?.text ?? '',
              cited,
            }));
          } else if (evt === 'token') {
            assembled += data.text;
            setAnswer({ loading: true, text: assembled, cited });
          } else if (evt === 'done') {
            setAnswer({ loading: false, text: assembled, cited });
          } else if (evt === 'error') {
            setAnswer({
              loading: false,
              text: `Stream error: ${data.error}`,
              cited: [],
            });
          }
        }
      }

      // If the stream ended without a 'done' event, finalize with what we have
      setAnswer((prev) => ({
        loading: false,
        text: prev?.text || assembled || '(no answer)',
        cited: prev?.cited ?? cited,
      }));
    } catch (err) {
      setAnswer({
        loading: false,
        text: `Could not reach the brain. ${err instanceof Error ? err.message : ''}`,
        cited: [],
      });
    }
  }

  const seeded = [
    'How does HR Agent connect to Breathe HR?',
    'Why was Cloudflare Workers chosen as the runtime?',
    'Show every rationale captured in the spec',
    'What connects approvals to the audit log?',
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-[12vh] px-4 bg-black/70 backdrop-blur-sm" onClick={onClose}>
      <div
        onClick={(e) => e.stopPropagation()}
        className="w-full max-w-2xl bg-[rgb(13,16,20)] border border-white/10 rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[70vh]"
      >
        <div className="flex items-center gap-3 px-5 py-4 border-b border-white/5">
          <Sparkles className="w-4 h-4 text-emerald-400 shrink-0" />
          <input
            ref={inputRef}
            value={q}
            onChange={(e) => setQ(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter') ask();
            }}
            placeholder="Ask the brain — what's connected? where is X documented? why was Y chosen?"
            className="flex-1 bg-transparent text-sm text-white placeholder-zinc-500 outline-none"
          />
          <kbd className="text-[10px] font-mono px-1.5 py-0.5 bg-white/5 border border-white/10 rounded text-zinc-500 shrink-0">esc</kbd>
        </div>

        <div className="overflow-y-auto p-2 flex-1">
          {q.trim() ? (
            <>
              {answer ? (
                <div className="p-4 mx-1 mb-3 rounded-lg bg-emerald-400/[0.04] border border-emerald-400/20">
                  <div className="text-[10px] uppercase tracking-wider text-emerald-300 font-semibold mb-2 flex items-center gap-1.5">
                    <Sparkles className="w-3 h-3" />
                    {answer.loading ? 'Tracing through the graph…' : 'Answer'}
                  </div>
                  {answer.loading ? (
                    <div className="space-y-2">
                      <div className="h-2 w-full bg-white/5 rounded animate-pulse" />
                      <div className="h-2 w-4/5 bg-white/5 rounded animate-pulse" />
                      <div className="h-2 w-3/5 bg-white/5 rounded animate-pulse" />
                    </div>
                  ) : (
                    <p className="text-sm text-zinc-200 leading-relaxed">{answer.text}</p>
                  )}
                </div>
              ) : (
                <button
                  onClick={ask}
                  className="w-full flex items-center gap-3 p-3 mx-1 mb-2 rounded-lg bg-emerald-400/[0.06] hover:bg-emerald-400/[0.1] border border-emerald-400/20 text-emerald-300 text-sm transition-colors"
                >
                  <Sparkles className="w-4 h-4 shrink-0" />
                  <span className="flex-1 text-left">Trace "{q}" through the graph (~3,110 tokens)</span>
                  <kbd className="text-[10px] font-mono px-1.5 py-0.5 bg-white/5 border border-white/10 rounded text-zinc-500">↵</kbd>
                </button>
              )}
              {matches.length > 0 && (
                <>
                  <div className="px-4 py-2 text-[10px] uppercase tracking-wider text-zinc-500 font-semibold">
                    Or jump to a node — {matches.length} result{matches.length === 1 ? '' : 's'}
                  </div>
                  {matches.map((n) => (
                    <button
                      key={n.id}
                      onClick={() => onPick(n)}
                      className="w-full flex items-center gap-3 p-2.5 mx-1 rounded-md hover:bg-white/[0.04]"
                    >
                      <span className="w-2 h-2 rounded-full shrink-0" style={{ background: colorOf(n.community) }} />
                      <span className="text-sm text-white flex-1 text-left truncate">{n.label}</span>
                      <span className="font-mono text-[10px] text-zinc-500 shrink-0">{n.d} edges</span>
                    </button>
                  ))}
                </>
              )}
            </>
          ) : (
            <>
              <div className="px-4 py-2 text-[10px] uppercase tracking-wider text-zinc-500 font-semibold">
                Suggested questions
              </div>
              {seeded.map((s) => (
                <button
                  key={s}
                  onClick={() => setQ(s)}
                  className="w-full flex items-center gap-3 p-2.5 mx-1 rounded-md hover:bg-white/[0.04]"
                >
                  <span className="text-violet-400 shrink-0">?</span>
                  <span className="text-sm text-white flex-1 text-left">{s}</span>
                </button>
              ))}
              <div className="px-4 py-2 mt-3 text-[10px] uppercase tracking-wider text-zinc-500 font-semibold border-t border-white/5">
                Tip
              </div>
              <div className="px-4 py-2 text-xs text-zinc-500 leading-relaxed">
                Answers come <em>only</em> from your tenant brain — never from the open web. Every answer cites the graph nodes used.
              </div>
            </>
          )}
        </div>
      </div>
      <button onClick={onClose} className="absolute top-4 right-4 w-8 h-8 rounded-full bg-white/5 hover:bg-white/10 grid place-items-center" aria-label="Close">
        <X className="w-4 h-4 text-zinc-400" />
      </button>
    </div>
  );
}

// =============================================================================
// Loading + empty states
// =============================================================================

function BrainSkeleton() {
  return (
    <div className="h-full w-full grid place-items-center bg-[rgb(7,9,11)]">
      <div className="text-center">
        <div className="relative w-16 h-16 mx-auto mb-4">
          <div className="absolute inset-0 rounded-full bg-emerald-400/20 animate-ping" />
          <div className="absolute inset-2 rounded-full bg-emerald-400/40 animate-pulse" />
          <Sparkles className="absolute inset-0 m-auto w-6 h-6 text-emerald-300" />
        </div>
        <p className="text-sm text-zinc-300 font-medium">Loading the brain…</p>
        <p className="text-xs text-zinc-500 mt-1">Resolving 1,002 nodes and 1,137 connections</p>
      </div>
    </div>
  );
}

function BrainError({ message }: { message: string }) {
  return (
    <div className="h-full w-full grid place-items-center bg-[rgb(7,9,11)] p-8">
      <div className="text-center max-w-md">
        <div className="text-4xl text-red-400 mb-3">!</div>
        <p className="text-sm text-zinc-300 font-medium mb-2">Couldn't load brain data</p>
        <p className="text-xs text-zinc-500 font-mono mb-4">{message}</p>
        <button onClick={() => location.reload()} className="px-4 py-2 bg-white/5 border border-white/10 rounded-lg text-xs text-white hover:bg-white/10">
          Reload
        </button>
      </div>
    </div>
  );
}

function BrainEmpty({ slug, status }: { slug: string; status: string | null }) {
  if (status === 'BUILDING') {
    return (
      <div className="h-full w-full grid place-items-center bg-[rgb(7,9,11)] p-8">
        <div className="text-center max-w-md">
          <div className="relative w-16 h-16 mx-auto mb-4">
            <div className="absolute inset-0 rounded-full bg-violet-400/20 animate-ping" />
            <div className="absolute inset-2 rounded-full bg-violet-400/40 animate-pulse" />
            <Sparkles className="absolute inset-0 m-auto w-6 h-6 text-violet-300" />
          </div>
          <p className="text-sm text-zinc-200 font-medium mb-2">Building your brain</p>
          <p className="text-xs text-zinc-500 leading-relaxed">
            Indexing your handbook and decisions. Typically completes in ~2 minutes.
          </p>
        </div>
      </div>
    );
  }
  if (status === 'FAILED') {
    return (
      <div className="h-full w-full grid place-items-center bg-[rgb(7,9,11)] p-8">
        <div className="text-center max-w-md">
          <div className="text-4xl text-red-400 mb-3">!</div>
          <p className="text-sm text-zinc-200 font-medium mb-2">Brain build failed</p>
          <p className="text-xs text-zinc-500 leading-relaxed mb-6">
            Something went wrong while indexing. Check the wizard or contact support.
          </p>
          <button
            onClick={() => location.reload()}
            className="inline-flex items-center gap-2 px-4 py-2 bg-white/5 border border-white/10 rounded-lg text-xs text-white hover:bg-white/10"
          >
            Try again
          </button>
        </div>
      </div>
    );
  }
  return (
    <div className="h-full w-full grid place-items-center bg-[rgb(7,9,11)] p-8">
      <div className="text-center max-w-md">
        <Sparkles className="w-10 h-10 text-zinc-700 mx-auto mb-4" />
        <p className="text-sm text-zinc-200 font-medium mb-2">Your brain is empty</p>
        <p className="text-xs text-zinc-500 leading-relaxed mb-6">
          Once you upload a handbook and complete the configuration wizard, the brain will index every doc, decision, and connection — and it'll show up here.
        </p>
        <a
          href={`/t/${slug}/wizard`}
          className="inline-flex items-center gap-2 px-4 py-2 bg-emerald-400 text-emerald-950 rounded-lg text-xs font-semibold hover:bg-emerald-300 transition-colors"
        >
          Start wizard
        </a>
      </div>
    </div>
  );
}

// =============================================================================
// Helpers
// =============================================================================

function nodeMatches(n: GraphNode, q: string): boolean {
  const ql = q.toLowerCase();
  return (n.label || '').toLowerCase().includes(ql) || (n.source_file || '').toLowerCase().includes(ql);
}

function findNodeByName(nodes: GraphNode[], q: string): GraphNode | null {
  if (!q.trim()) return null;
  const ql = q.toLowerCase();
  let m = nodes.find((n) => (n.label || '').toLowerCase() === ql);
  if (m) return m;
  m = nodes.find((n) => (n.label || '').toLowerCase().includes(ql));
  return m || null;
}

function escapeHTML(s: string): string {
  return String(s).replace(/[&<>"']/g, (c) => {
    const map: Record<string, string> = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
    return map[c] || c;
  });
}

