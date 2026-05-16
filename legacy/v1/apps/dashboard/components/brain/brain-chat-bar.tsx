'use client';

import { useState, useRef, useEffect, useCallback } from 'react';
import { Sparkles, Send, X, Loader2, BookOpen } from 'lucide-react';
import { cn } from '@/lib/cn';
import { useSidebar } from '@/components/shared/sidebar-context';

// ─────────────────────────────────────────────────────────────────────────────
// BrainChatBar — fixed-position chat widget at the bottom of every tenant
// page. Customers can ask their second brain (handbook + decisions + audit)
// without navigating to /brain. Streams answers via the existing
// /api/brain/[slug]/ask endpoint.
//
// States:
//   • Collapsed: slim 48px bar with placeholder + keyboard hint
//   • Focused:   expands a card above with the input + last answer
//   • Streaming: shows token-by-token answer with a stop button
//
// Keyboard:
//   ⌘/  — focus the input from anywhere in the dashboard
//   Esc — collapse / dismiss
//   ⌘↵  — submit (also plain ↵)
// ─────────────────────────────────────────────────────────────────────────────

interface Message {
  role: 'user' | 'assistant';
  text: string;
  cited?: string[];
  loading?: boolean;
}

export function BrainChatBar({ slug }: { slug: string }) {
  const { collapsed: sidebarCollapsed } = useSidebar();
  const [expanded, setExpanded] = useState(false);
  const [input, setInput] = useState('');
  const [history, setHistory] = useState<Message[]>([]);
  const [streaming, setStreaming] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const abortRef = useRef<AbortController | null>(null);

  const focus = useCallback(() => {
    setExpanded(true);
    setTimeout(() => inputRef.current?.focus(), 30);
  }, []);

  const collapse = useCallback(() => {
    if (streaming) {
      abortRef.current?.abort();
      setStreaming(false);
    }
    setExpanded(false);
  }, [streaming]);

  // Global shortcut: ⌘/ focuses the input from anywhere
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      const target = e.target as HTMLElement | null;
      const isTyping =
        target &&
        (target.tagName === 'INPUT' ||
          target.tagName === 'TEXTAREA' ||
          target.isContentEditable);
      if ((e.metaKey || e.ctrlKey) && e.key === '/') {
        e.preventDefault();
        focus();
      } else if (e.key === 'Escape' && expanded && !isTyping) {
        collapse();
      }
    }
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [expanded, focus, collapse]);

  async function submit() {
    const q = input.trim();
    if (!q || streaming) return;
    setInput('');
    setHistory((h) => [
      ...h.slice(-4), // keep last 4 to avoid unbounded growth
      { role: 'user', text: q },
      { role: 'assistant', text: '', loading: true, cited: [] },
    ]);
    setStreaming(true);

    const ac = new AbortController();
    abortRef.current = ac;

    try {
      const r = await fetch(`/api/brain/${slug}/ask`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: q, stream: true }),
        signal: ac.signal,
      });

      if (!r.ok || !r.body) {
        const errText = await r.text().catch(() => '');
        setHistory((h) => {
          const copy = [...h];
          const last = copy[copy.length - 1];
          if (last?.role === 'assistant') {
            last.text = `Could not reach the brain (${r.status}). ${errText.slice(0, 160)}`;
            last.loading = false;
          }
          return copy;
        });
        setStreaming(false);
        return;
      }

      const reader = r.body.getReader();
      const dec = new TextDecoder();
      let buf = '';
      while (true) {
        const { value, done } = await reader.read();
        if (done) break;
        buf += dec.decode(value, { stream: true });
        // SSE blocks separated by \n\n
        let idx;
        while ((idx = buf.indexOf('\n\n')) !== -1) {
          const block = buf.slice(0, idx);
          buf = buf.slice(idx + 2);
          const ev = parseSSE(block);
          if (!ev) continue;
          if (ev.event === 'token' && ev.data?.text) {
            setHistory((h) => {
              const copy = [...h];
              const last = copy[copy.length - 1];
              if (last?.role === 'assistant') {
                last.text += ev.data.text;
              }
              return copy;
            });
          } else if (ev.event === 'cited' && Array.isArray(ev.data?.cited)) {
            setHistory((h) => {
              const copy = [...h];
              const last = copy[copy.length - 1];
              if (last?.role === 'assistant') last.cited = ev.data.cited;
              return copy;
            });
          } else if (ev.event === 'error') {
            setHistory((h) => {
              const copy = [...h];
              const last = copy[copy.length - 1];
              if (last?.role === 'assistant') {
                last.text = `Stream error: ${ev.data?.error ?? 'unknown'}`;
                last.loading = false;
              }
              return copy;
            });
          } else if (ev.event === 'done') {
            setHistory((h) => {
              const copy = [...h];
              const last = copy[copy.length - 1];
              if (last?.role === 'assistant') last.loading = false;
              return copy;
            });
          }
        }
      }
    } catch (err: unknown) {
      if ((err as Error).name === 'AbortError') {
        // User stopped — mark current assistant message as completed
        setHistory((h) => {
          const copy = [...h];
          const last = copy[copy.length - 1];
          if (last?.role === 'assistant') {
            last.loading = false;
            if (!last.text) last.text = '(stopped)';
          }
          return copy;
        });
      } else {
        setHistory((h) => {
          const copy = [...h];
          const last = copy[copy.length - 1];
          if (last?.role === 'assistant') {
            last.text = `Network error: ${(err as Error).message}`;
            last.loading = false;
          }
          return copy;
        });
      }
    } finally {
      setStreaming(false);
      abortRef.current = null;
    }
  }

  const lastAssistant = [...history].reverse().find((m) => m.role === 'assistant');
  const lastUser = [...history].reverse().find((m) => m.role === 'user');

  return (
    <div className="fixed bottom-0 left-0 right-0 z-30 pointer-events-none hidden lg:block">
      {/* Position respects the dynamic sidebar width controlled by the
          SidebarProvider. Mobile is handled separately by the bottom tab bar. */}
      <div
        className={cn(
          'transition-[padding] duration-200 ease-out',
          sidebarCollapsed ? 'lg:pl-14' : 'lg:pl-56',
        )}
      >
        <div className="max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8 pb-3 pointer-events-auto">
          {/* Expanded answer card — slides up above the bar */}
          {expanded && history.length > 0 && (
            <div className="mb-2 bg-[rgb(15,17,20)]/95 backdrop-blur-md border border-white/[0.08] rounded-2xl shadow-2xl overflow-hidden animate-in fade-in slide-in-from-bottom-2 duration-200">
              <div className="px-4 py-2.5 border-b border-white/[0.04] flex items-center gap-2">
                <Sparkles className="w-3.5 h-3.5 text-emerald-400" />
                <p className="text-[11px] tracking-wider uppercase text-zinc-500 font-semibold">
                  Brain answer
                </p>
                {lastAssistant?.cited && lastAssistant.cited.length > 0 && (
                  <span className="text-[10px] text-zinc-500 ml-auto flex items-center gap-1">
                    <BookOpen className="w-3 h-3" />
                    {lastAssistant.cited.length} citations
                  </span>
                )}
              </div>
              <div className="px-4 py-3 max-h-72 overflow-y-auto">
                {lastUser && (
                  <p className="text-xs text-zinc-500 mb-2 italic line-clamp-2">
                    Q. {lastUser.text}
                  </p>
                )}
                {lastAssistant && (
                  <div className="text-sm text-zinc-100 leading-relaxed whitespace-pre-wrap">
                    {lastAssistant.text || (lastAssistant.loading ? '' : '—')}
                    {lastAssistant.loading && (
                      <span className="inline-block w-2 h-4 ml-0.5 align-middle bg-emerald-400/80 animate-pulse" />
                    )}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Slim bar */}
          <div
            className={cn(
              'flex items-center gap-2 bg-[rgb(15,17,20)]/95 backdrop-blur-md border rounded-2xl shadow-2xl transition-all duration-200',
              expanded
                ? 'border-emerald-400/40 ring-1 ring-emerald-400/15'
                : 'border-white/[0.08] hover:border-white/[0.14]',
            )}
          >
            <button
              onClick={focus}
              className="flex items-center gap-2 pl-4 pr-2 py-3 shrink-0 cursor-text"
              aria-label="Ask the brain"
            >
              <Sparkles
                className={cn(
                  'w-4 h-4 transition-colors',
                  expanded ? 'text-emerald-400' : 'text-zinc-400',
                )}
              />
            </button>
            <input
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onFocus={() => setExpanded(true)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  submit();
                } else if (e.key === 'Escape') {
                  collapse();
                  inputRef.current?.blur();
                }
              }}
              placeholder="Ask the handbook anything — leave policy, escalation rules, who-does-what…"
              className="flex-1 bg-transparent text-sm text-zinc-100 placeholder-zinc-500 outline-none py-3 pr-2"
            />
            {streaming ? (
              <button
                onClick={() => abortRef.current?.abort()}
                className="mr-2 px-3 py-1.5 text-xs font-medium rounded-lg bg-amber-400/10 border border-amber-400/30 text-amber-300 hover:bg-amber-400/15 transition-colors flex items-center gap-1.5"
              >
                <Loader2 className="w-3 h-3 animate-spin" />
                Stop
              </button>
            ) : (
              <button
                onClick={submit}
                disabled={!input.trim()}
                className={cn(
                  'mr-2 px-3 py-1.5 text-xs font-medium rounded-lg transition-colors flex items-center gap-1.5',
                  input.trim()
                    ? 'bg-emerald-400/10 border border-emerald-400/30 text-emerald-300 hover:bg-emerald-400/15'
                    : 'bg-white/[0.03] border border-white/[0.06] text-zinc-600 cursor-not-allowed',
                )}
              >
                <Send className="w-3 h-3" />
                Ask
              </button>
            )}
            {!expanded && (
              <kbd className="hidden md:inline-flex mr-3 text-[10px] font-mono px-1.5 py-0.5 bg-white/5 border border-white/10 rounded text-zinc-500">
                ⌘/
              </kbd>
            )}
            {expanded && (
              <button
                onClick={collapse}
                className="mr-2 w-7 h-7 flex items-center justify-center rounded-lg hover:bg-white/5 text-zinc-500 hover:text-zinc-200 transition-colors"
                aria-label="Collapse"
              >
                <X className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

// Parse one SSE block of the form:
//   event: token
//   data: {"text":"..."}
function parseSSE(block: string): { event: string; data: Record<string, unknown> } | null {
  let event = 'message';
  let data = '';
  for (const line of block.split('\n')) {
    if (line.startsWith('event:')) event = line.slice(6).trim();
    else if (line.startsWith('data:')) data += line.slice(5).trim();
  }
  if (!data) return null;
  try {
    return { event, data: JSON.parse(data) };
  } catch {
    return null;
  }
}
