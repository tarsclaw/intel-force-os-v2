# Intelforce Reels Agent — Final PRD
## 24/7 Autonomous AI Content Worker (Claude Code Native)

**Product**: Autonomous Instagram Reels creation system with 24/7 self-running agent  
**Owner**: Maddox (madsrigby)  
**Version**: 3.0 — Unified Final  
**Date**: 2026-03-16  
**Runtime**: Claude Code + launchd + tmux (no OpenClaw dependency)  
**Status**: Ready for implementation

---

## What You're Building

A Claude Code instance that runs **permanently on your Mac** — waking up every morning, deciding what reel to make, building it start-to-finish, and texting you the result on Telegram. You review in 5 minutes, tap approve, and it stages it for publish. You are not involved in anything else.

No OpenClaw. No third-party agent platform. Just Claude Code, your Mac, and the pipeline built in this document.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Agent Identity System](#2-agent-identity-system)
3. [Telegram Communication Layer](#3-telegram-communication-layer)
4. [Persistence & Always-On System](#4-persistence--always-on-system)
5. [Content Strategy Engine](#5-content-strategy-engine)
6. [Content Discovery Module](#6-content-discovery-module)
7. [Content Extraction & Analysis](#7-content-extraction--analysis)
8. [Script Rewriting & Production Brief](#8-script-rewriting--production-brief)
9. [Self-Critique & Quality Gate](#9-self-critique--quality-gate)
10. [Avatar Generation (HeyGen)](#10-avatar-generation-heygen)
11. [Video Assembly (Remotion)](#11-video-assembly-remotion)
12. [Video Templates](#12-video-templates)
13. [Asset Library & Resolver](#13-asset-library--resolver)
14. [Review & Approval Workflow](#14-review--approval-workflow)
15. [Learning & Memory System](#15-learning--memory-system)
16. [Cron & Heartbeat Schedule](#16-cron--heartbeat-schedule)
17. [Data Models](#17-data-models)
18. [Build Phases & Task Checklist](#18-build-phases--task-checklist)
19. [Directory Structure](#19-directory-structure)
20. [Environment Variables](#20-environment-variables)
21. [Agent Instructions](#21-agent-instructions)
22. [Project State (External Memory)](#22-project-state-external-memory)

---

## 1. Architecture Overview

### Full System Flow

```
MAC (always on, caffeinated, tmux session)
    │
    └── Claude Code Agent (Director)
            │
            ├── HEARTBEAT every 30 min
            │   ├── Check Telegram for messages
            │   ├── Process approvals/rejections/commands
            │   └── Update DAILY.md
            │
            └── DAILY PIPELINE at 07:00 UTC
                │
                ▼
        ┌─────────────────────────────┐
        │  1. STRATEGY ENGINE          │
        │  What topic/style today?     │
        │  Check recent 14 days        │
        │  Avoid repeats               │
        └──────────────┬──────────────┘
                       │
                       ▼
        ┌─────────────────────────────┐
        │  2. DISCOVERY                │
        │  Apify: scan 50+ reels       │
        │  Score with strategy weights │
        │  Select top 3 candidates     │
        └──────────────┬──────────────┘
                       │
                       ▼
        ┌─────────────────────────────┐
        │  3. PARALLEL EXTRACTION      │
        │  Download MP4 files          │
        │  FFmpeg: audio, scenes       │
        │  Whisper: transcription      │
        │  Claude Vision: analysis     │
        └──────────────┬──────────────┘
                       │
                       ▼
        ┌─────────────────────────────┐
        │  4. BRIEF GENERATION × 3    │
        │  Claude: rewrite for brand   │
        │  Self-critique each brief    │
        │  Pick highest-scored brief   │
        └──────────────┬──────────────┘
                       │
                       ▼
        ┌─────────────────────────────┐
        │  5. AVATAR GENERATION        │
        │  HeyGen: digital twin WebM   │
        │  Poll until complete         │
        └──────────────┬──────────────┘
                       │
                       ▼
        ┌─────────────────────────────┐
        │  6. REMOTION RENDER          │
        │  Composite all layers        │
        │  Output 1080×1920 MP4        │
        │  Generate thumbnail          │
        └──────────────┬──────────────┘
                       │
                       ▼
        ┌─────────────────────────────┐
        │  7. QUALITY GATE             │
        │  Claude Vision: score render │
        │  FFprobe: technical checks   │
        │  Score < 7? Try next cand.   │
        └──────────────┬──────────────┘
                       │
                       ▼
        ┌─────────────────────────────┐
        │  8. REVIEW SEND              │
        │  Telegram: video + summary   │
        │  Discord: full brief + video │
        │  Await approve/reject        │
        └─────────────────────────────┘
```

### Technology Stack

| Layer | Technology |
|-------|-----------|
| Agent runtime | Claude Code (claude-sonnet-4-20250514) |
| Persistence | macOS launchd + tmux + caffeinate |
| Communication | Telegram Bot API (check + send shell scripts) |
| Content discovery | Apify Instagram Reel Scraper |
| Video download | curl / Node.js fetch |
| Audio extraction | FFmpeg |
| Transcription | OpenAI Whisper API |
| Scene detection | FFmpeg scene filter |
| Content analysis | Claude API (vision) |
| Script rewriting | Claude API |
| Avatar generation | HeyGen API v2 (Digital Twin) |
| Video assembly | Remotion (React-based) |
| Review channel | Telegram + Discord |
| Asset storage | Local filesystem (Phase 1) / S3 (Phase 2) |
| Memory | Markdown files (MEMORY.md, DAILY.md, HISTORY.md) |

---

## 2. Agent Identity System

The agent needs a personality and context so every session starts with full awareness of who it is and what it's doing. These 7 files live in the project root and are bootstrapped by CLAUDE.md.

### CLAUDE.md (Master Bootstrap)

```markdown
# Director — Intelforce Reels Agent

You are Director, the autonomous content creation agent for Intelforce. Your job is to
run the daily Instagram Reels pipeline, communicate with Maddox via Telegram, and
continuously improve the quality of content produced.

## On Every Session Start
1. Read IDENTITY.md — who you are
2. Read SOUL.md — your decision-making rules
3. Read USER.md — who Maddox is and what he values
4. Read MEMORY.md — what you've learned so far
5. Read DAILY.md — what happened today
6. Read TOOLS.md — what tools you have available
7. Read HEARTBEAT.md — your cron schedule
8. Check Telegram for any unread messages
9. Check if the daily pipeline has run yet
10. Report your status to Maddox if this is a fresh session

## Working Directory
All work happens in ~/intelforce-reels/
Never leave this directory unless explicitly instructed.
```

### IDENTITY.md

```markdown
# Identity

**Name**: Director  
**Role**: Autonomous Content Creation Agent for Intelforce  
**Creator**: Maddox (madsrigby)  
**Mission**: Produce one publish-ready Instagram Reel per day that builds Maddox's 
authority in AI business automation, requiring < 5 minutes of his time.

## What I Do
- Every morning at 07:00 UTC: run the full reels pipeline
- Every 30 minutes: check Telegram, process messages, update memory
- Every Sunday: send weekly performance report
- Always: maintain quality standards, never ship junk

## What I Am Not
- I am not a chatbot. I am a content production system.
- I do not have opinions about topics outside of content quality and strategy.
- I do not take actions outside the ~/intelforce-reels/ workspace.
```

### SOUL.md

```markdown
# Soul — Decision-Making Framework

## Core Rules

### Reversible vs Irreversible
- Generating content: ALWAYS do autonomously
- Spending API credits (HeyGen render): Do if self-critique score ≥ 7/10
- Publishing content: NEVER — always requires Maddox approval
- Deleting files: NEVER without explicit instruction
- Spending money beyond normal API calls: NEVER without explicit instruction

## Autonomy Hierarchy
1. SAFETY: Never publish. Never spend outside of API calls. Never leave workspace.
2. STRATEGY: Follow today's content strategy. Rotate topics, templates, hook styles.
3. QUALITY: A good reel that ships > a perfect reel that doesn't. Never ship junk.
4. EFFICIENCY: Self-critique briefs before rendering. Don't burn HeyGen credits on weak output.
5. LEARNING: Every approval/rejection/performance datapoint makes tomorrow better.

## When to Decide Alone
- Selecting which candidate to process ✓
- Choosing template style ✓
- Writing the script angle ✓
- Deciding a brief is too weak to render (score < 6) ✓
- Switching to backup candidate ✓
- Choosing stock footage ✓
- Retrying a failed API call once ✓

## When to Alert Maddox
- Daily pipeline produced nothing viable (all candidates failed quality gate)
- Any API key appears expired or rate-limited
- Asset library has critical gaps (no B-roll for a common topic type)
- Reel requires a new experimental angle never approved before (ask first)
- Any error preventing pipeline completion

## Quality Gate Thresholds
- Self-critique score ≥ 7/10: Proceed to render
- Self-critique score 5-6: Revise brief (re-prompt with weaknesses)
- Self-critique score < 5: Discard, try next candidate
- Render quality score ≥ 7/10: Send for review
- Render quality score 5-6: Re-render if possible without new avatar
- Render quality score < 5: Discard, try next candidate
```

### USER.md

```markdown
# Maddox — User Profile

**Instagram**: @madsrigby  
**Brand**: Intelforce  
**Niche**: AI business automation (voice agents, chatbots, automation workflows)  
**Audience**: SMB owners, agency owners, entrepreneurs open to AI tools

## Content Values
- Hook-first: The first line must create undeniable curiosity
- Specific over vague: "£40k/month client" beats "big results"
- Position as practitioner: "We built this for a client" not "some businesses..."
- British English unless content style calls otherwise
- Anti-hype: Shows real systems, real results, not vague AI promises

## Approval Patterns
- Prefers statistical/claim hooks over question hooks
- Approves content with clear business ROI
- Rejects content that's too theoretical or buzzword-heavy
- Likes SplitScreen template with avatar on right side
- Prefers 25-40 second duration sweet spot
- Values well-timed animated captions

## Communication Style
- Direct, concise messages
- Include video preview + 3-line summary
- Don't over-explain — he'll watch the video
- Daily update: just status, not a full report
```

### MEMORY.md

```markdown
# Agent Memory

**Last Updated**: {timestamp}

## Learned Preferences
<!-- Updated after each approval/rejection -->

## Content History (Last 14 Days)
<!-- date | topic | template | hook_type | approved | reason -->

## Performance Data
<!-- shortcode | views | likes | engagement_rate | measurement_date -->

## Stats
- Total reels produced: 0
- Total approved: 0
- Approval rate: N/A
- Average views: N/A
- Average engagement: N/A

## Source Account Weights
<!-- account | weight | reason -->

## Content Pillar Balance (Last 14 Days)
- Voice agents: 0 reels
- Chatbots: 0 reels
- Automation workflows: 0 reels
- Business results: 0 reels
- Industry insights: 0 reels
```

### HEARTBEAT.md

```markdown
# Heartbeat Schedule

## Crons (managed by config.json, survive session restarts)

```json
{
  "crons": [
    {
      "id": "daily-pipeline",
      "schedule": "0 7 * * *",
      "command": "node pipeline.js daily",
      "description": "Daily reels pipeline"
    },
    {
      "id": "performance-check",
      "schedule": "0 9 * * *",
      "command": "node pipeline.js performance-check",
      "description": "Ask Maddox for yesterday's stats"
    },
    {
      "id": "heartbeat",
      "schedule": "*/30 * * * *",
      "command": "bash scripts/check-telegram.sh",
      "description": "Check Telegram messages"
    },
    {
      "id": "learning-sync",
      "schedule": "0 */6 * * *",
      "command": "node pipeline.js sync-memory",
      "description": "Update memory with latest data"
    },
    {
      "id": "asset-audit",
      "schedule": "0 3 * * 0",
      "command": "node pipeline.js asset-audit",
      "description": "Weekly asset library audit"
    },
    {
      "id": "weekly-report",
      "schedule": "0 10 * * 0",
      "command": "node pipeline.js weekly-report",
      "description": "Weekly performance summary to Telegram"
    }
  ]
}
```

## Session Lifecycle
- Sessions run for 71 hours then restart
- On restart: re-read all 7 identity files
- All state persists in markdown files — never in memory only
```

### TOOLS.md

```markdown
# Available Tools

## APIs
- **Anthropic API**: claude-sonnet-4-20250514 for analysis, writing, vision
- **OpenAI Whisper API**: whisper-1 for audio transcription
- **HeyGen API v2**: avatar generation, status polling, WebM download
- **Apify API**: Instagram Reel Scraper actor
- **Pexels API**: Stock footage fallback
- **Telegram Bot API**: check-telegram.sh / send-telegram.sh
- **Discord Webhook**: Content review channel

## CLI Tools
- **FFmpeg**: audio extraction, scene detection, segment splitting, keyframe export
- **FFprobe**: video quality analysis
- **Remotion CLI**: video rendering (npx remotion render)
- **curl**: video downloads, API calls

## Pipeline CLI
- `node pipeline.js daily` — run full daily pipeline
- `node pipeline.js run --url {url}` — single reel from URL
- `node pipeline.js performance-check` — fetch yesterday's metrics
- `node pipeline.js sync-memory` — update MEMORY.md
- `node pipeline.js asset-audit` — check asset library
- `node pipeline.js weekly-report` — generate weekly summary
- `node pipeline.js approve --id {id}` — process approval
- `node pipeline.js reject --id {id} --reason "{reason}"` — process rejection
```

---

## 3. Telegram Communication Layer

### Setup: BotFather

1. Open Telegram, message `@BotFather`
2. Send `/newbot` → name it `IntelforceDirector` → username `intelforce_director_bot`
3. Copy the bot token → set as `TELEGRAM_BOT_TOKEN` in `.env`
4. Message yourself, go to `https://api.telegram.org/bot{TOKEN}/getUpdates`, copy your `chat.id` → set as `TELEGRAM_CHAT_ID` in `.env`

### scripts/check-telegram.sh

```bash
#!/bin/bash
# Check for new Telegram messages and process them

source ~/.intelforce/.env

UPDATES=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=-10&limit=10")
MESSAGES=$(echo $UPDATES | jq -r '.result[].message | select(.chat.id == '${TELEGRAM_CHAT_ID}') | .text' 2>/dev/null)

if [ -z "$MESSAGES" ]; then
  exit 0
fi

# Write messages to a file for Claude Code to process
echo "$MESSAGES" > /tmp/telegram-inbox.txt

# Signal Claude Code to process messages
# (Claude Code reads this file as part of the /loop command)
```

### scripts/send-telegram.sh

```bash
#!/bin/bash
# Send a message or video to Telegram
# Usage: send-telegram.sh "text message"
#        send-telegram.sh --video /path/to/video.mp4 "caption"

source ~/.intelforce/.env

if [ "$1" = "--video" ]; then
  VIDEO_PATH="$2"
  CAPTION="$3"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendVideo" \
    -F chat_id="${TELEGRAM_CHAT_ID}" \
    -F video="@${VIDEO_PATH}" \
    -F caption="${CAPTION}" \
    -F parse_mode="Markdown"
else
  MESSAGE="$1"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="${MESSAGE}" \
    -d parse_mode="Markdown"
fi
```

### Telegram Command Protocol

The agent recognises these messages from Maddox:

| Command | Action |
|---------|--------|
| `approve` | Approve today's reel, stage for publish |
| `reject: [reason]` | Reject with reason, update memory, try backup candidate |
| `revise: [instruction]` | Rewrite brief with instruction, re-render |
| `status` | Report current pipeline state |
| `run --url [url]` | Trigger pipeline with specific reel |
| `stats [shortcode]` | Log performance data for a published reel |
| `skip today` | Skip daily pipeline, log reason |
| `report` | Generate and send weekly report now |

---

## 4. Persistence & Always-On System

### Prerequisites

```bash
# Install tmux
brew install tmux

# Caffeinate is built into macOS
# Keep Mac awake permanently:
caffeinate -i &
```

### launchd Plist: ~/Library/LaunchAgents/com.intelforce.director.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.intelforce.director</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/maddox/intelforce-reels/scripts/start-agent.sh</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <true/>
    
    <key>StandardOutPath</key>
    <string>/Users/maddox/intelforce-reels/logs/agent.log</string>
    
    <key>StandardErrorPath</key>
    <string>/Users/maddox/intelforce-reels/logs/agent-error.log</string>
    
    <key>WorkingDirectory</key>
    <string>/Users/maddox/intelforce-reels</string>
    
    <key>ThrottleInterval</key>
    <integer>60</integer>
</dict>
</plist>
```

### scripts/start-agent.sh

```bash
#!/bin/bash
# Start or re-attach the Director agent

SESSION="intelforce-director"
PROJECT_DIR="/Users/maddox/intelforce-reels"

# Keep Mac awake
caffeinate -i -w $$ &

# Check if session exists
if tmux has-session -t $SESSION 2>/dev/null; then
  echo "[$(date)] Session exists, skipping..."
  exit 0
fi

# Create new tmux session
tmux new-session -d -s $SESSION -c $PROJECT_DIR

# Start Claude Code with the CLAUDE.md bootstrap
tmux send-keys -t $SESSION "claude --no-interactive /loop" Enter

echo "[$(date)] Director agent started in tmux session: $SESSION"
```

### scripts/stop-agent.sh

```bash
#!/bin/bash
tmux kill-session -t intelforce-director
launchctl unload ~/Library/LaunchAgents/com.intelforce.director.plist
```

### Load the Agent

```bash
# First time setup
chmod +x scripts/start-agent.sh scripts/stop-agent.sh
launchctl load ~/Library/LaunchAgents/com.intelforce.director.plist

# Verify running
tmux attach -t intelforce-director

# Detach (agent keeps running)
# Ctrl+B then D
```

### 71-Hour Session Reset

```bash
# scripts/reset-session.sh
#!/bin/bash
# Called before session hits context limit (Claude Code ~71 hour lifecycle)
# All state is in markdown files — nothing is lost

SESSION="intelforce-director"
PROJECT_DIR="/Users/maddox/intelforce-reels"

echo "[$(date)] Session reset triggered" >> logs/agent.log

# Send Telegram notification
bash scripts/send-telegram.sh "🔄 Director restarting (71h session reset). Back in 30 seconds."

# Kill current session
tmux kill-session -t $SESSION 2>/dev/null

# Sleep to ensure clean kill
sleep 5

# Restart — launchd's KeepAlive will re-trigger start-agent.sh
# Or do it manually:
tmux new-session -d -s $SESSION -c $PROJECT_DIR
tmux send-keys -t $SESSION "claude --no-interactive /loop" Enter
```

### /loop Configuration (CLAUDE.md addition)

```markdown
## /loop Behaviour

When running in /loop mode:
1. Read all 7 identity files
2. Read /tmp/telegram-inbox.txt if it exists, process messages, delete file
3. Check config.json crons — run any that are due
4. Update DAILY.md with current status
5. Sleep 60 seconds
6. Repeat

Session reset: After 71 hours, save final state to MEMORY.md, send Telegram alert, 
allow launchd to restart.
```

---

## 5. Content Strategy Engine

Before the daily discovery run, the agent decides what today's reel should be about.

### src/strategy/planner.ts

```typescript
import Anthropic from '@anthropic-ai/sdk';
import { readMemory, readRecentHistory } from '../memory';

export interface DailyStrategy {
  topic_priority: 'voice_agents' | 'chatbots' | 'automation' | 'business_results' | 'industry_insights' | 'personal_brand';
  template_preference: 'split_screen' | 'full_frame' | 'text_card' | 'broll_montage' | 'any';
  hook_style_preference: 'statistical_claim' | 'question' | 'controversial_take' | 'curiosity_gap' | 'any';
  avoid_topics: string[];
  source_account_weights: Record<string, number>;
  notes: string;
  risk_appetite: 'safe' | 'moderate' | 'experimental';
}

export async function generateDailyStrategy(): Promise<DailyStrategy> {
  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  const memory = readMemory();
  const recentHistory = readRecentHistory(14);
  const today = new Date();

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: `You are Director, content strategist for Intelforce. Plan today's reel strategy.

RECENT CONTENT (last 14 days):
${JSON.stringify(recentHistory, null, 2)}

LEARNED PREFERENCES:
${memory.learnedPreferences.join('\n')}

PILLAR BALANCE (last 14 days):
${JSON.stringify(memory.pillarBalance, null, 2)}

TODAY: ${today.toLocaleDateString('en-GB', { weekday: 'long' })}, ${today.toISOString().split('T')[0]}

RULES:
- Don't repeat same topic two days in a row
- Don't use same template three days in a row
- Rotate through pillars: voice_agents, chatbots, automation, business_results, industry_insights
- Prioritise hooks matching patterns Maddox has approved before
- Weekend: lighter/more personality-driven content is acceptable
- Any pillar with 0 reels in last 14 days gets +30% priority boost

Respond ONLY with valid JSON, no other text:
{
  "topic_priority": "voice_agents|chatbots|automation|business_results|industry_insights|personal_brand",
  "template_preference": "split_screen|full_frame|text_card|broll_montage|any",
  "hook_style_preference": "statistical_claim|question|controversial_take|curiosity_gap|any",
  "avoid_topics": [],
  "source_account_weights": {},
  "notes": "brief reasoning",
  "risk_appetite": "safe|moderate|experimental"
}`
    }]
  });

  return JSON.parse(response.content[0].text);
}
```

---

## 6. Content Discovery Module

### Method: Apify Instagram Reel Scraper

```typescript
// src/discovery/apify.ts
import { ApifyClient } from 'apify-client';

export interface ReelCandidate {
  shortCode: string;
  url: string;
  ownerUsername: string;
  viewCount: number;
  likeCount: number;
  commentCount: number;
  caption: string;
  audioTitle: string;
  timestamp: string;
  thumbnailUrl: string;
  videoUrl?: string; // CDN URL if available
  engagementRate: number;
}

export interface DiscoveryConfig {
  watchlist: string[];          // competitor @usernames
  hashtagTargets: string[];     // niche hashtags
  minViews: number;
  maxAgeHours: number;
  candidateCount: number;       // how many to return (default 3)
  apifyActorId: string;         // 'apify/instagram-reel-scraper'
}

export async function discoverCandidates(
  config: DiscoveryConfig,
  strategy: DailyStrategy
): Promise<ReelCandidate[]> {
  const client = new ApifyClient({ token: process.env.APIFY_TOKEN });

  // Build input for Apify actor
  const input = {
    usernames: config.watchlist,
    hashtags: config.hashtagTargets,
    resultsLimit: 100,
    scrapeReels: true,
  };

  const run = await client.actor(config.apifyActorId).call(input);
  const { items } = await client.dataset(run.defaultDatasetId).listItems();

  // Parse, score, filter
  const candidates: ReelCandidate[] = items
    .filter(item => item.videoViewCount >= config.minViews)
    .filter(item => isWithinHours(item.timestamp, config.maxAgeHours))
    .map(item => ({
      shortCode: item.shortCode,
      url: `https://www.instagram.com/reel/${item.shortCode}/`,
      ownerUsername: item.ownerUsername,
      viewCount: item.videoViewCount,
      likeCount: item.likesCount,
      commentCount: item.commentsCount,
      caption: item.caption?.slice(0, 200) || '',
      audioTitle: item.musicInfo?.songName || '',
      timestamp: item.timestamp,
      thumbnailUrl: item.displayUrl,
      engagementRate: (item.likesCount + item.commentsCount) / Math.max(item.videoViewCount, 1),
    }));

  // Score with strategy weights and sort
  const scored = candidates.map(c => ({
    candidate: c,
    score: scoreCandidate(c, strategy)
  }));

  scored.sort((a, b) => b.score - a.score);

  return scored.slice(0, config.candidateCount).map(s => s.candidate);
}

function scoreCandidate(reel: ReelCandidate, strategy: DailyStrategy): number {
  let score = Math.log(reel.viewCount + 1) + (reel.engagementRate * 10);

  // Source account weight
  const weight = strategy.source_account_weights[`@${reel.ownerUsername}`] || 1.0;
  score *= weight;

  return score;
}

// Watchlist — update this in config.json
export const DEFAULT_WATCHLIST = [
  'aisolopreneur',
  'thefuturistai',
  'aijasolopreneur',
  'automationwithali',
  'thegrowthagency',
  // Add competitors here
];
```

---

## 7. Content Extraction & Analysis

### src/extraction/index.ts

```typescript
import { exec } from 'child_process';
import { promisify } from 'util';
import OpenAI from 'openai';
import Anthropic from '@anthropic-ai/sdk';
import * as fs from 'fs/promises';
import * as path from 'path';

const execAsync = promisify(exec);

export interface ExtractionResult {
  videoPath: string;
  audioPath: string;
  transcript: WhisperTranscript;
  scenes: SceneData[];
  keyframePaths: string[];
  duration: number;
}

// Step 1: Download video
export async function downloadReel(url: string, outputDir: string): Promise<string> {
  const shortCode = url.split('/reel/')[1]?.replace('/', '');
  const outputPath = path.join(outputDir, `${shortCode}.mp4`);

  // Use yt-dlp as primary with instagram cookie session
  await execAsync(
    `yt-dlp --cookies-from-browser chrome -o "${outputPath}" "${url}"`,
    { timeout: 120000 }
  );

  return outputPath;
}

// Step 2: Extract audio
export async function extractAudio(videoPath: string): Promise<string> {
  const audioPath = videoPath.replace('.mp4', '.mp3');
  await execAsync(`ffmpeg -i "${videoPath}" -q:a 0 -map a "${audioPath}" -y`);
  return audioPath;
}

// Step 3: Detect scenes
export async function detectScenes(videoPath: string): Promise<SceneData[]> {
  const outputDir = path.dirname(videoPath);
  const basename = path.basename(videoPath, '.mp4');

  // Detect scene changes
  const { stdout } = await execAsync(
    `ffprobe -v quiet -select_streams v -show_frames -of json ` +
    `-vf "select='gt(scene,0.3)',metadata=print:file=-" "${videoPath}" 2>&1 | ` +
    `grep "scene_score" | head -20`
  );

  // Extract keyframes at scene boundaries
  await execAsync(
    `ffmpeg -i "${videoPath}" -vf "select='gt(scene,0.3)',scale=720:-1" ` +
    `-vsync vfr "${outputDir}/${basename}_frame_%03d.jpg" -y`
  );

  // Get timestamps from output
  const frames = await fs.readdir(outputDir);
  const keyframes = frames.filter(f => f.startsWith(`${basename}_frame_`));

  return keyframes.map((f, i) => ({
    index: i,
    keyframePath: path.join(outputDir, f),
    timestamp: i * 2.0, // approximate
  }));
}

// Step 4: Transcribe with Whisper
export async function transcribeAudio(audioPath: string): Promise<WhisperTranscript> {
  const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

  const audioFile = await fs.readFile(audioPath);
  const response = await openai.audio.transcriptions.create({
    file: new File([audioFile], path.basename(audioPath), { type: 'audio/mpeg' }),
    model: 'whisper-1',
    timestamp_granularities: ['word'],
    response_format: 'verbose_json',
  });

  return {
    text: response.text,
    words: response.words || [],
    duration: response.duration || 0,
    language: response.language || 'en',
  };
}

// Step 5: Analyse with Claude Vision
export async function analyseContent(
  keyframePaths: string[],
  transcript: WhisperTranscript
): Promise<ReelAnalysis> {
  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

  // Load keyframe images as base64
  const imageMessages = await Promise.all(
    keyframePaths.slice(0, 5).map(async (kfPath) => {
      const imageData = await fs.readFile(kfPath);
      return {
        type: 'image' as const,
        source: {
          type: 'base64' as const,
          media_type: 'image/jpeg' as const,
          data: imageData.toString('base64'),
        },
      };
    })
  );

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 2048,
    messages: [{
      role: 'user',
      content: [
        ...imageMessages,
        {
          type: 'text',
          text: `Analyse this Instagram Reel based on the keyframes shown and transcript.

TRANSCRIPT: "${transcript.text}"

Respond ONLY with valid JSON:
{
  "hookLine": "exact first sentence/phrase that opens the reel",
  "hookType": "statistical_claim|question|controversial_take|curiosity_gap|direct_value_promise",
  "mainTopic": "primary topic in 3-5 words",
  "detectedTopics": ["topic1", "topic2"],
  "contentStructure": ["hook", "problem", "solution", "cta"],
  "visualStyle": "talking_head|screen_recording|b_roll|mixed|text_overlay",
  "likelyTemplate": "split_screen|full_frame|text_card|broll_montage",
  "duration": ${transcript.duration},
  "segmentCount": 3,
  "captionStyle": "word_by_word|sentence|none",
  "hasBackground": true,
  "backgroundType": "solid|gradient|footage|screen_recording",
  "keyValuePoints": ["point1", "point2", "point3"],
  "callToAction": "exact CTA phrase if present",
  "productionQuality": "high|medium|low",
  "remixPotential": 0.8,
  "hookStrength": 0.9
}`
        }
      ]
    }]
  });

  return JSON.parse(response.content[0].text);
}
```

---

## 8. Script Rewriting & Production Brief

### src/brief/generator.ts

```typescript
import Anthropic from '@anthropic-ai/sdk';

export interface ProductionBrief {
  id: string;
  sourceReelUrl: string;
  sourceAnalysis: ReelAnalysis;
  createdAt: string;
  
  // Script
  hook: string;
  hookType: string;
  segments: BriefSegment[];
  callToAction: string;
  totalDuration: number;  // seconds
  
  // Visual direction
  template: 'split_screen' | 'full_frame' | 'text_card' | 'broll_montage';
  avatarScript: string;   // full text for HeyGen TTS
  captionStyle: 'word_by_word' | 'sentence' | 'karaoke';
  
  // Assets
  backgroundType: string;
  brollAssets: string[];  // asset manifest keys
  overlayText?: string[];
  
  // Brand
  brandProfile: BrandProfile;
  
  // Scores
  selfCritiqueScore?: number;
  selfCritiqueNotes?: string;
}

export interface BriefSegment {
  index: number;
  type: 'hook' | 'problem' | 'solution' | 'proof' | 'cta';
  avatarText: string;    // what avatar says
  visualType: string;    // 'avatar_only' | 'broll_overlay' | 'screen_recording' | 'text_card'
  asset?: string;        // asset manifest key if broll
  duration: number;      // seconds
  captionText: string;   // text to display
}

export async function generateProductionBrief(
  analysis: ReelAnalysis,
  transcript: WhisperTranscript,
  strategy: DailyStrategy,
  assetManifest: AssetManifest
): Promise<ProductionBrief> {
  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  
  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 3000,
    messages: [{
      role: 'user',
      content: `You are Director, the content agent for Intelforce. 
Rewrite this source reel as an original Intelforce reel.

SOURCE REEL ANALYSIS:
${JSON.stringify(analysis, null, 2)}

SOURCE TRANSCRIPT: "${transcript.text}"

TODAY'S STRATEGY:
- Topic priority: ${strategy.topic_priority}
- Template preference: ${strategy.template_preference}
- Hook style: ${strategy.hook_style_preference}
- Risk appetite: ${strategy.risk_appetite}

BRAND PROFILE:
- Brand: Intelforce
- Creator: Maddox
- Niche: AI business automation (voice agents, chatbots, workflows)
- Voice: Direct, practitioner, specific results, British English
- Anti-patterns: vague hype, "the future is AI", buzzword soup

AVAILABLE ASSETS:
${JSON.stringify(assetManifest.assets.map(a => ({ key: a.key, description: a.description, duration: a.duration })), null, 2)}

RULES:
- Hook must be original — cannot be same as source. Must be stronger or equal.
- Avatar text must sound like something Maddox actually says — specific, direct.
- Total duration: 25-40 seconds
- Every segment must reference a real or plausible Intelforce use case
- B-roll assets must come from the manifest above — never reference assets that don't exist
- If no suitable B-roll exists, use 'avatar_only' as visualType

Respond ONLY with valid JSON matching the ProductionBrief interface (no markdown, no extra text):
{
  "hook": "...",
  "hookType": "...",
  "segments": [
    {
      "index": 0,
      "type": "hook",
      "avatarText": "...",
      "visualType": "avatar_only|broll_overlay|screen_recording|text_card",
      "asset": "asset_key_or_null",
      "duration": 6,
      "captionText": "..."
    }
  ],
  "callToAction": "...",
  "totalDuration": 32,
  "template": "split_screen",
  "avatarScript": "Full concatenated script for TTS",
  "captionStyle": "word_by_word",
  "backgroundType": "...",
  "brollAssets": [],
  "overlayText": null
}`
    }]
  });

  const brief = JSON.parse(response.content[0].text);
  brief.id = `brief_${Date.now()}`;
  brief.createdAt = new Date().toISOString();
  brief.sourceReelUrl = analysis.sourceUrl || '';
  brief.sourceAnalysis = analysis;
  brief.brandProfile = BRAND_PROFILE;

  return brief;
}
```

---

## 9. Self-Critique & Quality Gate

### src/evaluation/critique.ts

```typescript
import Anthropic from '@anthropic-ai/sdk';

export interface CritiqueResult {
  score: number; // 1-10
  passesThreshold: boolean;
  weaknesses: string[];
  strengths: string[];
  reviseSuggestions: string[];
  verdict: 'proceed' | 'revise' | 'discard';
}

export async function critiqueBrief(brief: ProductionBrief): Promise<CritiqueResult> {
  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: `You are a brutally honest content editor for Intelforce. 
Evaluate this production brief against these criteria.

BRIEF:
${JSON.stringify(brief, null, 2)}

EVALUATE ON:
1. Hook strength (0-10): Does it create undeniable curiosity in the first line?
2. Originality (0-10): Is >50% NOT attributable to the source creator?
3. Brand alignment (0-10): Does it sound like Maddox — specific, direct, practitioner?
4. Asset feasibility (0-10): Do all referenced assets exist in the manifest?
5. Duration fit (0-10): Is total duration between 25-40 seconds?
6. CTA clarity (0-10): Is the call to action specific and compelling?

PASS THRESHOLDS:
- Any single dimension below 5: DISCARD
- Average below 7: REVISE
- Average 7+: PROCEED

Respond ONLY with valid JSON:
{
  "scores": {
    "hook_strength": 8,
    "originality": 7,
    "brand_alignment": 9,
    "asset_feasibility": 10,
    "duration_fit": 8,
    "cta_clarity": 7
  },
  "overall_score": 8.2,
  "weaknesses": ["..."],
  "strengths": ["..."],
  "revise_suggestions": ["..."],
  "verdict": "proceed|revise|discard"
}`
    }]
  });

  const result = JSON.parse(response.content[0].text);
  return {
    score: result.overall_score,
    passesThreshold: result.verdict === 'proceed',
    weaknesses: result.weaknesses,
    strengths: result.strengths,
    reviseSuggestions: result.revise_suggestions,
    verdict: result.verdict,
  };
}

// Quality gate on the rendered video
export async function evaluateRender(
  videoPath: string,
  brief: ProductionBrief
): Promise<CritiqueResult> {
  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  const { exec } = require('child_process');
  const { promisify } = require('util');
  const execAsync = promisify(exec);

  // Extract thumbnail frame for vision analysis
  const framePath = videoPath.replace('.mp4', '_review_frame.jpg');
  await execAsync(`ffmpeg -i "${videoPath}" -ss 00:00:02 -vframes 1 "${framePath}" -y`);

  // Get technical stats
  const { stdout: probeOut } = await execAsync(
    `ffprobe -v quiet -print_format json -show_format -show_streams "${videoPath}"`
  );
  const probeData = JSON.parse(probeOut);

  const frameData = require('fs').readFileSync(framePath);
  
  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: [
        {
          type: 'image',
          source: {
            type: 'base64',
            media_type: 'image/jpeg',
            data: frameData.toString('base64'),
          }
        },
        {
          type: 'text',
          text: `Evaluate this rendered Instagram Reel for quality.

EXPECTED TEMPLATE: ${brief.template}
TECHNICAL DATA: ${JSON.stringify(probeData.format, null, 2)}

Score on:
1. Visual quality: Does it look professional?
2. Caption placement: Are captions readable, not overlapping important elements?
3. Avatar integration: Does the avatar composite look natural?
4. Template execution: Does it match the expected template style?
5. Brand consistency: Intelforce colours, clean, professional?

Respond ONLY with valid JSON:
{
  "overall_score": 8,
  "issues": [],
  "verdict": "proceed|revise|discard"
}`
        }
      ]
    }]
  });

  const result = JSON.parse(response.content[0].text);
  return {
    score: result.overall_score,
    passesThreshold: result.verdict === 'proceed',
    weaknesses: result.issues || [],
    strengths: [],
    reviseSuggestions: [],
    verdict: result.verdict,
  };
}
```

---

## 10. Avatar Generation (HeyGen)

```typescript
// src/avatar/heygen.ts
export interface HeyGenConfig {
  avatarId: string;        // Maddox Digital Twin avatar ID
  voiceId: string;         // Angela or Hope (ElevenLabs V3 native)
  backgroundType: 'transparent' | 'white' | 'custom';
  outputFormat: 'webm' | 'mp4';
}

export async function generateAvatarClip(
  script: string,
  config: HeyGenConfig,
  outputPath: string
): Promise<string> {
  // Step 1: Create video generation job
  const createResponse = await fetch('https://api.heygen.com/v2/video/generate', {
    method: 'POST',
    headers: {
      'X-Api-Key': process.env.HEYGEN_API_KEY!,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      video_inputs: [{
        character: {
          type: 'avatar',
          avatar_id: config.avatarId,
          avatar_style: 'normal',
        },
        voice: {
          type: 'text',
          input_text: script,
          voice_id: config.voiceId,
          speed: 1.0,
        },
        background: {
          type: config.backgroundType === 'transparent' ? 'transparent' : 'color',
          value: config.backgroundType === 'transparent' ? undefined : '#FFFFFF',
        },
      }],
      dimension: { width: 540, height: 960 },  // 9:16 portrait
      aspect_ratio: '9:16',
    }),
  });

  const createData = await createResponse.json();
  const videoId = createData.data?.video_id;
  if (!videoId) throw new Error(`HeyGen create failed: ${JSON.stringify(createData)}`);

  // Step 2: Poll until complete (webhook in Phase 2)
  let attempts = 0;
  while (attempts < 60) {
    await sleep(10000); // poll every 10 seconds
    
    const statusResponse = await fetch(`https://api.heygen.com/v2/videos/${videoId}`, {
      headers: { 'X-Api-Key': process.env.HEYGEN_API_KEY! },
    });
    const statusData = await statusResponse.json();
    
    if (statusData.data?.status === 'completed') {
      const videoUrl = statusData.data.video_url;
      
      // Step 3: Download the file
      await downloadFile(videoUrl, outputPath);
      return outputPath;
    }
    
    if (statusData.data?.status === 'failed') {
      throw new Error(`HeyGen render failed: ${statusData.data.error}`);
    }
    
    attempts++;
  }
  
  throw new Error('HeyGen timeout after 10 minutes');
}

const sleep = (ms: number) => new Promise(r => setTimeout(r, ms));
```

---

## 11. Video Assembly (Remotion)

### Project Setup

```bash
npx create-video@latest remotion-studio
cd remotion-studio
npm install @remotion/renderer @remotion/bundler
npm install remotion @remotion/media-utils
```

### src/remotion/Root.tsx

```tsx
import { Composition } from 'remotion';
import { SplitScreen } from './templates/SplitScreen';
import { FullFrame } from './templates/FullFrame';
import { TextCard } from './templates/TextCard';
import { BRollMontage } from './templates/BRollMontage';
import type { ProductionBrief } from '../brief/types';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="SplitScreen"
        component={SplitScreen}
        durationInFrames={900}   // 30fps × 30s default, overridden by props
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{ brief: {} as ProductionBrief }}
      />
      <Composition
        id="FullFrame"
        component={FullFrame}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{ brief: {} as ProductionBrief }}
      />
      <Composition
        id="TextCard"
        component={TextCard}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{ brief: {} as ProductionBrief }}
      />
      <Composition
        id="BRollMontage"
        component={BRollMontage}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{ brief: {} as ProductionBrief }}
      />
    </>
  );
};
```

### Render Script

```typescript
// src/render/index.ts
import { bundle } from '@remotion/bundler';
import { renderMedia, selectComposition } from '@remotion/renderer';
import path from 'path';

export async function renderReel(
  brief: ProductionBrief,
  avatarWebmPath: string,
  outputPath: string
): Promise<string> {
  const compositionId = templateToCompositionId(brief.template);

  // Bundle the Remotion project
  const bundled = await bundle({
    entryPoint: path.resolve('./remotion-studio/src/index.ts'),
  });

  // Get composition with resolved duration
  const totalFrames = Math.ceil(brief.totalDuration * 30);
  const composition = await selectComposition({
    serveUrl: bundled,
    id: compositionId,
    inputProps: { brief, avatarWebmPath },
  });

  // Render to MP4
  await renderMedia({
    composition: { ...composition, durationInFrames: totalFrames },
    serveUrl: bundled,
    codec: 'h264',
    outputLocation: outputPath,
    inputProps: { brief, avatarWebmPath },
    timeoutInMilliseconds: 300000, // 5 minutes
  });

  return outputPath;
}

function templateToCompositionId(template: string): string {
  const map: Record<string, string> = {
    'split_screen': 'SplitScreen',
    'full_frame': 'FullFrame',
    'text_card': 'TextCard',
    'broll_montage': 'BRollMontage',
  };
  return map[template] || 'SplitScreen';
}
```

---

## 12. Video Templates

### SplitScreen Template (Primary)

```tsx
// remotion-studio/src/templates/SplitScreen.tsx
import { AbsoluteFill, Video, useCurrentFrame, interpolate } from 'remotion';
import { AnimatedCaption } from '../components/AnimatedCaption';
import { BrandWatermark } from '../components/BrandWatermark';

interface SplitScreenProps {
  brief: ProductionBrief;
  avatarWebmPath: string;
}

export const SplitScreen: React.FC<SplitScreenProps> = ({ brief, avatarWebmPath }) => {
  const frame = useCurrentFrame();
  const fps = 30;

  return (
    <AbsoluteFill style={{ backgroundColor: '#0A0A0A' }}>
      {/* Left side: B-roll / screen recording */}
      <div style={{ position: 'absolute', left: 0, top: 0, width: '50%', height: '100%' }}>
        <BackgroundLayer brief={brief} frame={frame} fps={fps} />
      </div>

      {/* Right side: Avatar */}
      <div style={{
        position: 'absolute', right: 0, top: 0,
        width: '50%', height: '100%',
        overflow: 'hidden',
      }}>
        <Video src={avatarWebmPath} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      </div>

      {/* Gradient overlay at bottom for captions */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        height: '35%',
        background: 'linear-gradient(transparent, rgba(0,0,0,0.85))',
      }} />

      {/* Animated captions */}
      <AnimatedCaption
        brief={brief}
        frame={frame}
        fps={fps}
        style={{ position: 'absolute', bottom: 120, left: 40, right: 40 }}
      />

      {/* Brand watermark */}
      <BrandWatermark style={{ position: 'absolute', top: 60, left: 40 }} />
    </AbsoluteFill>
  );
};
```

### AnimatedCaption Component

```tsx
// remotion-studio/src/components/AnimatedCaption.tsx
import { useCurrentFrame, interpolate, spring } from 'remotion';

interface AnimatedCaptionProps {
  brief: ProductionBrief;
  frame: number;
  fps: number;
  style?: React.CSSProperties;
}

export const AnimatedCaption: React.FC<AnimatedCaptionProps> = ({
  brief, frame, fps, style
}) => {
  // Build word timeline from all segments
  const allWords = buildWordTimeline(brief, fps);
  const currentWords = getCurrentWords(allWords, frame);

  return (
    <div style={{ ...style, textAlign: 'center' }}>
      {currentWords.map((word, i) => (
        <span key={i} style={{
          display: 'inline-block',
          fontSize: 52,
          fontWeight: 800,
          color: word.isHighlighted ? '#FFD700' : '#FFFFFF',
          textShadow: '2px 2px 8px rgba(0,0,0,0.8)',
          marginRight: 8,
          fontFamily: 'Montserrat, sans-serif',
          textTransform: 'uppercase',
          letterSpacing: '-0.5px',
        }}>
          {word.text}
        </span>
      ))}
    </div>
  );
};
```

### Other Templates (FullFrame, TextCard, BRollMontage)

Each template follows the same pattern with different layouts:

- **FullFrame**: Avatar fills the full 1080×1920 frame, captions overlay at the bottom
- **TextCard**: Bold text fills the screen, avatar appears as PiP (picture-in-picture) in corner
- **BRollMontage**: B-roll footage fills the frame, avatar is a floating bubble, heavy caption overlay

---

## 13. Asset Library & Resolver

### Asset Manifest Format

```json
// workspace/assets/manifest.json
{
  "version": "1.0",
  "lastUpdated": "2026-03-16T00:00:00Z",
  "assets": [
    {
      "key": "screen_chatbot_demo_01",
      "type": "screen_recording",
      "path": "workspace/assets/videos/screen_chatbot_demo_01.mp4",
      "description": "Screen recording of AI chatbot handling a customer enquiry",
      "duration": 12.5,
      "topics": ["chatbots", "customer_service"],
      "usageCount": 0,
      "lastUsed": null,
      "qualityRating": 9
    },
    {
      "key": "screen_voiceagent_booking_01",
      "type": "screen_recording",
      "path": "workspace/assets/videos/screen_voiceagent_booking_01.mp4",
      "description": "Voice agent demo: booking appointment via phone",
      "duration": 18.0,
      "topics": ["voice_agents", "booking", "automation"],
      "usageCount": 0,
      "lastUsed": null,
      "qualityRating": 10
    }
  ]
}
```

### Asset Resolver

```typescript
// src/assets/resolver.ts
export async function resolveAssets(brief: ProductionBrief): Promise<ProductionBrief> {
  const manifest = loadManifest();

  for (const segment of brief.segments) {
    if (!segment.asset) continue;

    const asset = manifest.assets.find(a => a.key === segment.asset);

    if (!asset) {
      // Asset doesn't exist — try to find a substitute
      const substitute = findSubstitute(segment, manifest);
      if (substitute) {
        segment.asset = substitute.key;
        segment.captionText += ' [asset substituted]';
      } else {
        // Fall back to stock footage
        const stock = await fetchStockFootage(segment);
        if (stock) {
          segment.asset = stock.key;
        } else {
          // Last resort: avatar only
          segment.visualType = 'avatar_only';
          segment.asset = undefined;
        }
      }
    }
  }

  return brief;
}

// Auto-fetch from Pexels when no local asset matches
async function fetchStockFootage(segment: BriefSegment): Promise<Asset | null> {
  const query = topicToSearchQuery(segment.type, segment.captionText);
  const response = await fetch(
    `https://api.pexels.com/videos/search?query=${encodeURIComponent(query)}&per_page=3`,
    { headers: { Authorization: process.env.PEXELS_API_KEY! } }
  );

  const data = await response.json();
  if (!data.videos?.length) return null;

  const video = data.videos[0];
  const file = video.video_files.find((f: any) => f.quality === 'hd');
  if (!file) return null;

  // Download and register in manifest
  const key = `stock_pexels_${video.id}`;
  const localPath = `workspace/assets/videos/${key}.mp4`;
  await downloadFile(file.link, localPath);

  const asset: Asset = {
    key, type: 'stock',
    path: localPath,
    description: query,
    duration: video.duration,
    topics: [segment.type],
    usageCount: 0,
    lastUsed: null,
    qualityRating: 7,
  };

  appendToManifest(asset);
  return asset;
}
```

---

## 14. Review & Approval Workflow

### Telegram Review Message

```typescript
// src/review/telegram.ts
export async function sendForReview(
  brief: ProductionBrief,
  videoPath: string,
  thumbnailPath: string,
  critiqueResult: CritiqueResult
): Promise<void> {
  // Send video
  await sendVideo(videoPath, buildReviewCaption(brief, critiqueResult));

  // Send action buttons via inline keyboard
  await sendMessage(buildActionMenu(brief.id));
}

function buildReviewCaption(brief: ProductionBrief, critique: CritiqueResult): string {
  return `🎬 *Today's Reel Ready for Review*

📌 *Hook*: ${brief.hook}
⏱ *Duration*: ${brief.totalDuration}s
🎭 *Template*: ${brief.template.replace('_', ' ')}
🎯 *Topic*: ${brief.sourceAnalysis.mainTopic}
⭐ *Self-score*: ${critique.score}/10

*Reply with:*
✅ \`approve\` — stage for publish
❌ \`reject: [reason]\`
✏️ \`revise: [instruction]\``;
}

function buildActionMenu(briefId: string): string {
  return `*Brief ID: ${briefId}*
Quick commands:
• \`approve\`
• \`reject: too generic\`
• \`reject: hook is weak\`
• \`reject: not brand aligned\`
• \`revise: make the hook more specific\``;
}
```

### Discord Review Post

```typescript
// src/review/discord.ts
export async function postToDiscord(brief: ProductionBrief, videoPath: string): Promise<void> {
  const webhookUrl = process.env.DISCORD_WEBHOOK_URL!;

  const embed = {
    title: `📹 New Reel — ${brief.sourceAnalysis.mainTopic}`,
    color: 0x5865F2,
    fields: [
      { name: 'Hook', value: brief.hook, inline: false },
      { name: 'Template', value: brief.template, inline: true },
      { name: 'Duration', value: `${brief.totalDuration}s`, inline: true },
      { name: 'Self-score', value: `${brief.selfCritiqueScore}/10`, inline: true },
      { name: 'Source', value: brief.sourceReelUrl, inline: false },
      { name: 'Script', value: brief.avatarScript.slice(0, 500) + '...', inline: false },
    ],
    timestamp: new Date().toISOString(),
  };

  await fetch(webhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ embeds: [embed] }),
  });
}
```

---

## 15. Learning & Memory System

### src/learning/feedback.ts

```typescript
import Anthropic from '@anthropic-ai/sdk';

export async function processApproval(brief: ProductionBrief): Promise<void> {
  const memory = loadMemory();
  
  memory.history.push({
    date: new Date().toISOString().split('T')[0],
    shortCode: brief.id,
    topic: brief.sourceAnalysis.mainTopic,
    template: brief.template,
    hookType: brief.hookType,
    approved: true,
  });

  memory.stats.totalApproved++;
  memory.pillarBalance[topicToPillar(brief.sourceAnalysis.mainTopic)]++;

  saveMemory(memory);
}

export async function processRejection(
  brief: ProductionBrief,
  reason: string
): Promise<void> {
  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  const memory = loadMemory();

  // Extract preference update from rejection reason
  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 512,
    messages: [{
      role: 'user',
      content: `A reel was rejected. Extract a reusable preference rule.

BRIEF SUMMARY:
- Hook: ${brief.hook}
- Template: ${brief.template}
- Hook type: ${brief.hookType}
- Topic: ${brief.sourceAnalysis.mainTopic}

REJECTION REASON: "${reason}"

Write ONE clear preference rule (max 100 chars) that should inform future content decisions.
Examples:
- "Avoid question hooks — statistical claims get approved more often"
- "Reject text_card template when topic is voice_agents"
- "Hook must reference a specific number or business result"

Respond with ONLY the rule text, no quotes.`
    }]
  });

  const rule = response.content[0].text.trim();
  memory.learnedPreferences.push(rule);
  
  memory.history.push({
    date: new Date().toISOString().split('T')[0],
    shortCode: brief.id,
    topic: brief.sourceAnalysis.mainTopic,
    template: brief.template,
    hookType: brief.hookType,
    approved: false,
    rejectionReason: reason,
  });

  memory.stats.totalProduced++;
  saveMemory(memory);
}

// Record post-publish performance (Maddox texts the stats)
export async function recordPerformance(
  shortCode: string,
  views: number,
  likes: number,
  comments: number
): Promise<void> {
  const memory = loadMemory();
  const engagementRate = (likes + comments) / Math.max(views, 1);

  memory.performanceData.push({
    shortCode,
    views,
    likes,
    comments,
    engagementRate,
    measurementDate: new Date().toISOString(),
  });

  // Recalculate rolling averages (last 30 days)
  const recent = memory.performanceData.filter(
    p => Date.now() - new Date(p.measurementDate).getTime() < 30 * 86400000
  );
  memory.stats.averageViews = recent.reduce((s, p) => s + p.views, 0) / recent.length;
  memory.stats.averageEngagement = recent.reduce((s, p) => s + p.engagementRate, 0) / recent.length;

  saveMemory(memory);
}
```

---

## 16. Cron & Heartbeat Schedule

```markdown
# Scheduled Tasks

## 07:00 UTC — Daily Pipeline
1. generateDailyStrategy()
2. discoverCandidates() via Apify
3. parallel extraction of top 3 candidates
4. generateProductionBrief() × 3
5. critiqueBrief() × 3 — pick winner
6. generateAvatarClip() via HeyGen
7. renderReel() via Remotion
8. evaluateRender() quality gate
9. sendForReview() via Telegram + Discord
Duration target: < 20 minutes

## 09:00 UTC — Performance Check
Ask Maddox via Telegram for yesterday's reel stats.
Format: "📊 Stats check: how did yesterday's reel perform? Reply: views likes comments"
If no response by 12:00, send one reminder.

## Every 30 minutes — Heartbeat
1. check-telegram.sh → read inbox
2. Process any pending commands (approve/reject/revise/stats)
3. Update DAILY.md with current status
4. Verify all API keys are responding

## Every 6 hours — Memory Sync
1. Update MEMORY.md with latest stats
2. Recalculate preference weights
3. Update content pillar balance
4. Prune performance data > 30 days old

## Sundays 03:00 UTC — Asset Audit
1. Find unused assets (> 30 days since last use)
2. Find overused assets (used > 5 times)
3. Alert Maddox via Telegram with suggested new recordings to make
4. Archive workspace/tmp/ files older than 7 days

## Sundays 10:00 UTC — Weekly Report
Send to Telegram:
- Reels produced this week
- Approval rate
- Best-performing reel
- Content pillar distribution
- Top rejection reasons
- Suggested focus for next week
```

---

## 17. Data Models

```typescript
// src/types/index.ts

interface WhisperTranscript {
  text: string;
  words: { word: string; start: number; end: number }[];
  duration: number;
  language: string;
}

interface SceneData {
  index: number;
  keyframePath: string;
  timestamp: number;
}

interface ReelAnalysis {
  hookLine: string;
  hookType: string;
  mainTopic: string;
  detectedTopics: string[];
  contentStructure: string[];
  visualStyle: string;
  likelyTemplate: string;
  duration: number;
  segmentCount: number;
  captionStyle: string;
  hasBackground: boolean;
  backgroundType: string;
  keyValuePoints: string[];
  callToAction: string;
  productionQuality: string;
  remixPotential: number;
  hookStrength: number;
  sourceUrl?: string;
}

interface AgentMemory {
  learnedPreferences: string[];
  history: HistoryEntry[];
  performanceData: PerformanceEntry[];
  pillarBalance: Record<string, number>;
  stats: {
    totalProduced: number;
    totalApproved: number;
    approvalRate: number;
    averageViews: number;
    averageEngagement: number;
  };
}

interface HistoryEntry {
  date: string;
  shortCode: string;
  topic: string;
  template: string;
  hookType: string;
  approved: boolean;
  rejectionReason?: string;
  feedbackNotes?: string;
}

interface PerformanceEntry {
  shortCode: string;
  views: number;
  likes: number;
  comments: number;
  engagementRate: number;
  measurementDate: string;
}

interface AssetManifest {
  version: string;
  lastUpdated: string;
  assets: Asset[];
}

interface Asset {
  key: string;
  type: 'screen_recording' | 'stock' | 'branded' | 'broll';
  path: string;
  description: string;
  duration: number;
  topics: string[];
  usageCount: number;
  lastUsed: string | null;
  qualityRating: number;
}
```

---

## 18. Build Phases & Task Checklist

### Phase 1: Foundation — End-to-end manual pipeline (Week 1-2)

**Goal**: Given a reel URL → output a finished MP4. No automation yet.

#### Task 1: Project Setup

```json
{
  "task_id": "TASK-001",
  "name": "Project initialisation",
  "status": "pending",
  "dependencies": [],
  "estimated_complexity": "low"
}
```

- [ ] Create project: `mkdir intelforce-reels && cd intelforce-reels && npm init -y`
- [ ] Install dependencies: `npm i typescript @types/node ts-node dotenv anthropic openai apify-client node-fetch`
- [ ] Install dev tools: `npm i -D vitest @vitest/coverage-v8 eslint prettier`
- [ ] Create tsconfig.json with strict mode
- [ ] Create `.env` from `.env.example`
- [ ] Create directory structure per section 19
- [ ] Create CLAUDE.md, IDENTITY.md, SOUL.md, USER.md, MEMORY.md, HEARTBEAT.md, TOOLS.md
- [ ] Verify `npx ts-node src/index.ts` runs without errors

#### Task 2: Testing Infrastructure

```json
{
  "task_id": "TASK-002",
  "name": "Testing framework setup",
  "status": "pending",
  "dependencies": ["TASK-001"],
  "estimated_complexity": "low"
}
```

- [ ] Configure Vitest in vitest.config.ts
- [ ] Create `__tests__/` directory structure
- [ ] Write and pass: test for JSON parsing from Claude API response
- [ ] Write and pass: test for HeyGen status polling logic
- [ ] Write and pass: test for asset manifest loading
- [ ] Set coverage threshold to 70% in vitest.config.ts

#### Task 3: Remotion Project + SplitScreen Template

```json
{
  "task_id": "TASK-003",
  "name": "Remotion setup + SplitScreen template",
  "status": "pending",
  "dependencies": ["TASK-001"],
  "estimated_complexity": "high"
}
```

- [ ] Scaffold: `npx create-video@latest remotion-studio`
- [ ] Build `SplitScreen.tsx` template with hardcoded test data
- [ ] Build `AnimatedCaption` component with word-by-word highlighting
- [ ] Build `BrandWatermark` component
- [ ] Build `CTASegment` component
- [ ] Test local render: `npx remotion render SplitScreen` → verify MP4 output at 1080×1920
- [ ] Build render script: `src/render/index.ts`

#### Task 4: Extraction Pipeline

```json
{
  "task_id": "TASK-004",
  "name": "Extraction pipeline (download → transcribe → analyse)",
  "status": "pending",
  "dependencies": ["TASK-002"],
  "estimated_complexity": "high"
}
```

- [ ] Build `src/extraction/download.ts` — yt-dlp + curl fallback
- [ ] Build `src/extraction/audio.ts` — FFmpeg audio extraction
- [ ] Build `src/extraction/scenes.ts` — FFmpeg scene detection + keyframe export
- [ ] Build `src/extraction/transcribe.ts` — Whisper API integration
- [ ] Build `src/extraction/analyse.ts` — Claude Vision analysis
- [ ] Test each as standalone: `npx ts-node src/extraction/[file].ts --url [test_url]`
- [ ] Write unit tests for transcript parsing and scene data parsing

#### Task 5: Brief Generator + HeyGen Integration

```json
{
  "task_id": "TASK-005",
  "name": "Brief generation + HeyGen avatar",
  "status": "pending",
  "dependencies": ["TASK-004"],
  "estimated_complexity": "high"
}
```

- [ ] Build `src/brief/generator.ts` — Claude rewriting to ProductionBrief
- [ ] Build `src/avatar/heygen.ts` — generate + poll + download
- [ ] Test with real reel URL: produce ProductionBrief JSON
- [ ] Test HeyGen: send test script, verify WebM download
- [ ] Write unit tests for brief JSON validation

#### Task 6: Wire Everything Together

```json
{
  "task_id": "TASK-006",
  "name": "Pipeline orchestrator + CLI",
  "status": "pending",
  "dependencies": ["TASK-003", "TASK-004", "TASK-005"],
  "estimated_complexity": "medium"
}
```

- [ ] Build `pipeline.js` / `src/pipeline.ts` — orchestrates all steps
- [ ] Implement: `node pipeline.js run --url {url}` → finished MP4
- [ ] Add error handling and retry (once) at each step
- [ ] Add progress logging to console
- [ ] Test end-to-end with 3 real AI automation reels

#### Task 7: Initial Asset Library

```json
{
  "task_id": "TASK-007",
  "name": "Asset library setup",
  "status": "pending",
  "dependencies": ["TASK-006"],
  "estimated_complexity": "low"
}
```

- [ ] Record 5+ screen recordings: chatbot demo, voice agent, workflow builder, dashboard, client call
- [ ] Add to `workspace/assets/videos/`
- [ ] Write `workspace/assets/manifest.json` with all assets
- [ ] Build `src/assets/resolver.ts`
- [ ] Build `src/assets/stock.ts` — Pexels API fallback

---

### Phase 2: Templates & Polish (Week 3)

#### Task 8-11: Remaining Templates

- [ ] **TASK-008**: Build `FullFrame` Remotion template
- [ ] **TASK-009**: Build `TextCard` Remotion template
- [ ] **TASK-010**: Build `BRollMontage` Remotion template
- [ ] **TASK-011**: Add karaoke caption style + sentence caption style
- [ ] Add fade/slide/zoom transitions between segments
- [ ] Add thumbnail generation (ffmpeg first frame)
- [ ] Test all templates with 5+ source reels each

---

### Phase 3: Discovery & Automation (Week 4)

#### Task 12: Apify Discovery

```json
{
  "task_id": "TASK-012",
  "name": "Apify content discovery",
  "status": "pending",
  "dependencies": ["TASK-006"],
  "estimated_complexity": "medium"
}
```

- [ ] Build `src/discovery/apify.ts`
- [ ] Configure watchlist in `config.json`
- [ ] Test: discovery returns 50+ candidates, ranks correctly
- [ ] Build `src/discovery/rank.ts` — scoring function

#### Task 13: Strategy Engine

```json
{
  "task_id": "TASK-013",
  "name": "Content strategy engine",
  "status": "pending",
  "dependencies": ["TASK-012"],
  "estimated_complexity": "medium"
}
```

- [ ] Build `src/strategy/planner.ts`
- [ ] Build `src/memory/index.ts` — read/write MEMORY.md
- [ ] Test: strategy avoids recent topics, rotates pillars
- [ ] Integrate strategy weights into candidate scoring

#### Task 14: Self-Critique + Quality Gate

```json
{
  "task_id": "TASK-014",
  "name": "Self-critique and quality gate",
  "status": "pending",
  "dependencies": ["TASK-013"],
  "estimated_complexity": "medium"
}
```

- [ ] Build `src/evaluation/critique.ts`
- [ ] Build `src/evaluation/quality.ts`
- [ ] Build `src/evaluation/technical.ts` — FFprobe checks
- [ ] Integrate into pipeline: brief must score ≥ 7 before avatar generation
- [ ] Test fallback: deliberately weak brief → verify skip to next candidate

#### Task 15: Multi-Candidate Parallel Processing

```json
{
  "task_id": "TASK-015",
  "name": "Parallel candidate processing",
  "status": "pending",
  "dependencies": ["TASK-014"],
  "estimated_complexity": "medium"
}
```

- [ ] Upgrade `pipeline.ts daily` to process top 3 in parallel (`Promise.allSettled`)
- [ ] Brief all 3, critique all 3, rank by score
- [ ] Only render the winner
- [ ] Test: full daily run with 3 candidates

#### Task 16: Telegram Bot

```json
{
  "task_id": "TASK-016",
  "name": "Telegram communication layer",
  "status": "pending",
  "dependencies": ["TASK-015"],
  "estimated_complexity": "medium"
}
```

- [ ] Create `scripts/check-telegram.sh`
- [ ] Create `scripts/send-telegram.sh`
- [ ] Build `src/telegram/handler.ts` — parse and route commands
- [ ] Implement: approve, reject, revise, status, run, stats commands
- [ ] Test: send video to Telegram, tap approve, verify memory update

#### Task 17: Discord Review

```json
{
  "task_id": "TASK-017",
  "name": "Discord review channel",
  "status": "pending",
  "dependencies": ["TASK-016"],
  "estimated_complexity": "low"
}
```

- [ ] Build `src/review/discord.ts` — webhook post with embed
- [ ] Test: post video + embed to #content-review channel

---

### Phase 4: 24/7 Persistence (Week 5)

#### Task 18: Agent Identity Files

```json
{
  "task_id": "TASK-018",
  "name": "Agent identity system (7 files)",
  "status": "pending",
  "dependencies": ["TASK-017"],
  "estimated_complexity": "low"
}
```

- [ ] Write final CLAUDE.md with /loop instructions
- [ ] Write IDENTITY.md
- [ ] Write SOUL.md (decision framework)
- [ ] Write USER.md (Maddox profile)
- [ ] Write MEMORY.md (initial state)
- [ ] Write HEARTBEAT.md (cron schedule)
- [ ] Write TOOLS.md
- [ ] Test: new Claude Code session reads all 7 files and reports correct status

#### Task 19: Cron System

```json
{
  "task_id": "TASK-019",
  "name": "Cron and heartbeat system",
  "status": "pending",
  "dependencies": ["TASK-018"],
  "estimated_complexity": "medium"
}
```

- [ ] Build `src/cron/runner.ts` — reads config.json, executes due crons
- [ ] Create `config.json` with all 6 cron entries
- [ ] Test: trigger daily pipeline cron manually → full run completes
- [ ] Test: heartbeat reads Telegram every 30 minutes

#### Task 20: launchd Persistence

```json
{
  "task_id": "TASK-020",
  "name": "macOS launchd + tmux persistence",
  "status": "pending",
  "dependencies": ["TASK-019"],
  "estimated_complexity": "medium"
}
```

- [ ] Create `scripts/start-agent.sh`
- [ ] Create `scripts/stop-agent.sh`
- [ ] Create `scripts/reset-session.sh` (71-hour cycle)
- [ ] Create `~/Library/LaunchAgents/com.intelforce.director.plist`
- [ ] Load: `launchctl load ~/Library/LaunchAgents/com.intelforce.director.plist`
- [ ] Verify: close terminal, wait 2 min, re-attach to tmux → agent still running
- [ ] Test crash recovery: kill tmux session → verify launchd restarts it

---

### Phase 5: Learning System (Week 5-6)

#### Task 21: Feedback & Memory Loop

```json
{
  "task_id": "TASK-021",
  "name": "Learning system + weekly report",
  "status": "pending",
  "dependencies": ["TASK-020"],
  "estimated_complexity": "medium"
}
```

- [ ] Build `src/learning/feedback.ts`
- [ ] Build `src/learning/performance.ts`
- [ ] Build `src/reports/weekly.ts`
- [ ] Test: simulate 5 approvals + 3 rejections → verify MEMORY.md updated correctly
- [ ] Test: weekly report generates and sends to Telegram

#### Task 22: Revision Workflow

```json
{
  "task_id": "TASK-022",
  "name": "Revision workflow (revise command)",
  "status": "pending",
  "dependencies": ["TASK-021"],
  "estimated_complexity": "medium"
}
```

- [ ] Build `src/revision/index.ts` — planRevision + reviseProductionBrief
- [ ] Wire into Telegram handler: `revise: [instruction]` triggers re-brief + re-render
- [ ] Test: send revision instruction → new video generated, sent for review

---

### Phase 6: Production Run (Week 6+)

- [ ] **Task 23**: Asset audit system (`node pipeline.js asset-audit`)
- [ ] **Task 24**: Run unattended for 7 days, log all approvals/rejections
- [ ] **Task 25**: Phase 2 infrastructure — AWS Lambda for Remotion rendering
- [ ] **Task 26**: S3 asset storage (multi-client ready)
- [ ] **Task 27**: Client configuration system (database-backed)

---

## 19. Directory Structure

```
~/intelforce-reels/
├── CLAUDE.md                    # Master bootstrap
├── IDENTITY.md                  # Who Director is
├── SOUL.md                      # Decision-making rules
├── USER.md                      # Maddox profile
├── MEMORY.md                    # Learned preferences + history
├── HEARTBEAT.md                 # Cron schedule
├── TOOLS.md                     # Available tools
├── DAILY.md                     # Today's status
├── config.json                  # Cron definitions + settings
├── pipeline.ts                  # Main orchestrator CLI
├── .env                         # API keys (never commit)
├── .env.example                 # Template
├── package.json
├── tsconfig.json
│
├── remotion-studio/             # Remotion video project
│   ├── src/
│   │   ├── index.ts
│   │   ├── Root.tsx
│   │   ├── templates/
│   │   │   ├── SplitScreen.tsx
│   │   │   ├── FullFrame.tsx
│   │   │   ├── TextCard.tsx
│   │   │   └── BRollMontage.tsx
│   │   └── components/
│   │       ├── AnimatedCaption.tsx
│   │       ├── BrandWatermark.tsx
│   │       └── CTASegment.tsx
│   └── package.json
│
├── src/
│   ├── strategy/
│   │   └── planner.ts
│   ├── discovery/
│   │   ├── apify.ts
│   │   └── rank.ts
│   ├── extraction/
│   │   ├── index.ts
│   │   ├── download.ts
│   │   ├── audio.ts
│   │   ├── scenes.ts
│   │   ├── transcribe.ts
│   │   └── analyse.ts
│   ├── brief/
│   │   └── generator.ts
│   ├── evaluation/
│   │   ├── critique.ts
│   │   ├── quality.ts
│   │   └── technical.ts
│   ├── avatar/
│   │   └── heygen.ts
│   ├── render/
│   │   └── index.ts
│   ├── assets/
│   │   ├── resolver.ts
│   │   └── stock.ts
│   ├── review/
│   │   ├── telegram.ts
│   │   └── discord.ts
│   ├── learning/
│   │   ├── feedback.ts
│   │   └── performance.ts
│   ├── revision/
│   │   └── index.ts
│   ├── memory/
│   │   └── index.ts
│   ├── cron/
│   │   └── runner.ts
│   ├── telegram/
│   │   └── handler.ts
│   ├── reports/
│   │   └── weekly.ts
│   └── types/
│       └── index.ts
│
├── scripts/
│   ├── check-telegram.sh
│   ├── send-telegram.sh
│   ├── start-agent.sh
│   ├── stop-agent.sh
│   └── reset-session.sh
│
├── workspace/
│   ├── assets/
│   │   ├── manifest.json
│   │   └── videos/          # screen recordings + stock B-roll
│   ├── tmp/                 # temp files per pipeline run (cleaned after 7 days)
│   ├── renders/             # finished MP4s
│   ├── history/             # one JSON per approved reel
│   └── strategy/            # daily strategy outputs
│
├── logs/
│   ├── agent.log
│   └── pipeline/            # one log per daily run
│
├── __tests__/
│   ├── brief.test.ts
│   ├── critique.test.ts
│   ├── discovery.test.ts
│   ├── extraction.test.ts
│   └── memory.test.ts
│
└── ~/Library/LaunchAgents/
    └── com.intelforce.director.plist
```

---

## 20. Environment Variables

```bash
# .env.example

# Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# OpenAI (Whisper)
OPENAI_API_KEY=sk-...

# HeyGen
HEYGEN_API_KEY=...
HEYGEN_AVATAR_ID=...        # Maddox digital twin avatar ID (after recording)
HEYGEN_VOICE_ID=...         # Angela or Hope voice ID

# Apify
APIFY_TOKEN=...

# Pexels (stock footage fallback)
PEXELS_API_KEY=...

# Telegram
TELEGRAM_BOT_TOKEN=...
TELEGRAM_CHAT_ID=...        # Your personal Telegram chat ID

# Discord
DISCORD_WEBHOOK_URL=...     # #content-review channel webhook

# Paths
PROJECT_DIR=/Users/maddox/intelforce-reels
WORKSPACE_DIR=/Users/maddox/intelforce-reels/workspace
```

---

## 21. Agent Instructions

```markdown
## Instructions for AI Coding Agent (Claude Code)

### Development Methodology
Follow Test-Driven Development (TDD) throughout:
1. Read the task spec fully before writing any code
2. Write failing tests that define expected behaviour
3. Implement only enough code to pass tests
4. Refactor, keep tests green
5. Mark task complete in this document

### Tool Protocol
- Use web search to verify current package versions before installing
- Use Context7 MCP (if available) for Remotion, HeyGen, and Anthropic SDK documentation
- Always check HeyGen API docs for current video generation endpoint format
- Whisper API: verify `timestamp_granularities` parameter is supported in current version

### Building Order (MANDATORY)
DO NOT deviate from this order:
1. TASK-001 (setup) and TASK-002 (testing) FIRST
2. TASK-003 (Remotion) — get a render working before touching pipeline
3. TASK-004 to 006 — extraction pipeline, brief, HeyGen, orchestrator
4. TASK-007 — asset library (without this, templates fail)
5. Phase 2 templates (TASK-008-011) before automation
6. Phase 3 automation (TASK-012-017) before persistence
7. Phase 4 persistence (TASK-018-020) LAST

### The Production Brief is the Contract
The ProductionBrief JSON is the single handoff point between upstream and downstream.
- Everything upstream (extraction, analysis, brief generation) PRODUCES it
- Everything downstream (asset resolver, HeyGen, Remotion) CONSUMES it
- If you change its shape, update both sides

### Test Execution After Every Task
1. Run `npm test` — all unit tests must pass
2. Run integration test if one exists for the task
3. Only mark complete if ALL pass

### Error Handling
- Never silently swallow errors — always log with timestamp
- HeyGen: implement exponential backoff for polling (5s, 10s, 20s, 40s...)
- Apify: if actor run fails, alert via Telegram and skip daily pipeline
- Remotion render: if render times out, alert Maddox, do not retry automatically
- All pipeline failures: log to `logs/pipeline/` + send Telegram alert

### Code Quality
- TypeScript strict mode: no `any` types
- Functions under 50 lines — extract if longer
- All API keys from environment, never hardcoded
- ProductionBrief must be valid JSON at all times — wrap parse in try/catch
```

---

## 22. Project State (External Memory)

```markdown
## Completed Tasks
<!-- Agent: Add task IDs here as completed -->

## Current Task
<!-- Agent: TASK-001 -->

## Daily Pipeline Status
<!-- Agent: Update each run -->
Last run: Not yet run
Last result: N/A
Pending approval: None

## Blockers & Notes
<!-- Agent: Document anything blocking progress -->

## API Health
- Anthropic API: ✅ (check on startup)
- OpenAI Whisper: ✅
- HeyGen: ✅
- Apify: ✅
- Pexels: ✅
- Telegram: ✅
- Discord: ✅

## Test Results Log
<!-- Agent: Log test run results with timestamps -->
```

---

## Quick Start Sequence

Once this document is pasted into Claude Code:

```bash
# 1. Claude Code will initialise the project, install deps, and run TASK-001 through TASK-022
# 2. You will receive a Telegram message when the first test reel is ready
# 3. Reply 'approve' to confirm the pipeline works
# 4. Claude Code then sets up launchd persistence (TASK-020)
# 5. From that point, Director runs 24/7 with no further setup needed

# To check on the agent at any time:
tmux attach -t intelforce-director

# To stop:
bash ~/intelforce-reels/scripts/stop-agent.sh

# To restart manually:
bash ~/intelforce-reels/scripts/start-agent.sh
```

---

**Document Status**: ✅ Ready for Main Agent Execution  
**Estimated Build Time**: 5-6 weeks (autonomous tasks only; your time < 1 hour total)  
**Daily Human Time Required**: < 5 minutes (review + approve/reject via Telegram)
