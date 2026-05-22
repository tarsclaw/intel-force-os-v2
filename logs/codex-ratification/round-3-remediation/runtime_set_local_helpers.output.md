RATIFIED

Round-3 verdict: the cross-cutting Risk #11 helper fix is incorporated. `agents/_shared/hook-helpers.sh`, `agents/_shared/voice-loader.sh`, and `scripts/run-codex-ratification.sh` now bracket `SET LOCAL ifos.tenant_slug` with `BEGIN`/`COMMIT`. Shellcheck passes and the helper test suites remain green: hook-helpers 20/20, voice-loader 9/9.
