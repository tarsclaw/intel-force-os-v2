# CortexOS quirks discovered during IFOS setup

Captured from Day 0 setup, 2026-05-16. Things that are true but not in the
cortextOS README. Read this before debugging anything cortextOS-related.

## 1. cortextos install ignores CTX_INSTANCE_ID env var (v0.1.1)

Symptom: running install with CTX_INSTANCE_ID=ifos-v2 exported writes state
to ~/.cortextos/default/ regardless.

Diagnosis (grep src/cli): src/cli/install.ts:83 declares the option as
.option('--instance <id>', 'Instance ID', 'default'). Other commands
(status, list-agents, etc.) use the pattern
options.instance || process.env.CTX_INSTANCE_ID || 'default'. The install
command lacks the env-var fallback — the flag's default 'default' wins
even when env is set.

Workaround: always pass --instance explicitly:
    cortextos-ifos install --instance ifos-v2

Or use the ifosctl-install wrapper function in this repo's .envrc.

Upstream fix: PR adding process.env.CTX_INSTANCE_ID to fallback in
src/cli/install.ts. Confirmed against cortextos@0.1.1 SHA
c21fbfe991a0030ea055bd8e2389a0801a424383.

## 2. node-pty native module needs rebuild on Node 25+

Symptom: install reports node-pty spawn test failed: posix_spawnp failed.

Cause: cortextOS pins node-pty@1.1.0 (built for Node 20/22 LTS). Node
25.x has a different N-API ABI.

Workaround: after npm install, run npm rebuild node-pty. For
predictability, pin Node 22 via .nvmrc (already done at
~/code/cortex-os-ifos/.nvmrc).

## 3. npm link failed warning during install — benign for our setup

Symptom: install reports "npm link failed. Run manually..." claiming
agents cannot use bus commands in PTY sessions.

Cause: install tries to npm-link cortextos globally. We've already
npm-linked the IFOS clone under cortextos-ifos. Second link fails.

Real issue (deferred to Day 1): agents are taught to invoke bus
commands as plain cortextos. That resolves to the personal install
binary, not the IFOS one. We need to shim PATH in the agent environment
when scaffolding the first IFOS agent.

## 4. Personal install dashboard.env clobbered by failed install attempts

Symptom: ~/.cortextos/default/dashboard.env overwritten with new
credentials on each install run that mis-routed to default.

Current state: personal admin password is orcinitrust2024. Backup at
~/.cortextos/default/dashboard.env.post-ifos-install-2026-05-16.

Mitigation: ifosctl-install wrapper in .envrc always passes
--instance ifos-v2.

## 5. Two distinct instances now live on this machine

| Resource | Personal | IFOS |
|---|---|---|
| Source tree | ~/cortextos/ | ~/code/cortex-os-ifos/ |
| Global binary | cortextos | cortextos-ifos |
| State dir | ~/.cortextos/default/ | ~/.cortextos/ifos-v2/ |
| Dashboard port | 3000 | 3100 |
| HUD port | 3002 | 3101 |
| PM2 process names | cortextos-daemon, cortextos-dashboard | not yet — will be ifos-daemon, ifos-dashboard |
| Dashboard admin password | orcinitrust2024 | 27bf484543deadff2c3468f0 |
| Bus signing key | yes | yes (separate HMAC-SHA256) |

Verify isolation any time with two terminals:
- Terminal 1 (env loaded): cortextos-ifos status -> IFOS agents
- Terminal 2 (no env): cortextos status -> personal agents

## 6. CTX_FRAMEWORK_ROOT in dashboard.env is set from PWD at install time

Symptom: dashboard.env is generated with CTX_FRAMEWORK_ROOT pointing at
the directory you ran install from, not at the cortextos source tree
that's actually running.

Cause: install command captures process.cwd() instead of resolving the
actual binary's source location.

Workaround: after install, edit dashboard.env to point CTX_FRAMEWORK_ROOT
at the correct source tree:
- For IFOS: /Users/madsadmin/code/cortex-os-ifos
- For personal: /Users/madsadmin/cortextos

Upstream fix: install.ts should resolve __dirname or use the npm package
install path, not cwd.
