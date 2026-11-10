# AGENTS

## Purpose

`aspace-codex-adapter/` owns the A'Space contract for the codex fork
(`Amdkn/codex`, pinned commit `27fcd7c`, Apache-2.0).
It is the only A'Space code in the fork: upstream files are byte-identical
(D-N048 H-M2).

## Ownership

This scope owns:

- `contract.json`: pinned commit, CLI surface, telemetry switches
- `smoke_test.sh`: 5 checks (contract pins, version, help, exec help, no-network via `unshare -n`)
- `README.md`: how to build and run the contract

## Local Contracts

- `CODEX_HOME` is always a scratch dir, never `~/.codex`.
- Every invocation forces `-c analytics.enabled=false -c feedback.enabled=false`.
- `OTEL_SDK_DISABLED=1`; `OTEL_*` endpoint vars stay unset.
- Never run `exec`, `review`, `login`, `logout`, `update`, `app-server`,
  `exec-server` or `fork` from this adapter.

## Work Guidance

- Keep the adapter lean: contract + smoke test + docs, no runtime code.
- Any change to the pinned commit requires a design amendment (D5),
  never a silent fast-forward.

## Verification

```sh
bash aspace-codex-adapter/smoke_test.sh [chemin-du-binaire]
```

## Child DOX Index

- (none — no subfolders)

## DOX note

No upstream `AGENTS.md` exists in this repo (only `CLAUDE.md` at the
root); it was intentionally left unchanged: D-N048 H-M2 requires the
upstream tree byte-identical except this directory. This file is the
local contract for the adapter boundary.
