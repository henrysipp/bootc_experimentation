# The Car Lister Agent Guide

All docs must canonical, no past commentary, only live state.

## Agent Memory (Project Scratchpad)

Purpose: keep lightweight, durable project memory so agents avoid repeating mistakes and follow user/project preferences over time.

### Memory Location (Repo Root)

Store memory in the project root under `./memory/`:

- `memory/decisions.md` — active canonical rules only (high-signal, current behavior)
- `memory/mistakes.md` — mistakes, fixes, and prevention rules
- `memory/todo.md` — open loops and follow-up tasks
- `memory/context.md` — optional short-lived working context (can be compacted)
- `memory/archive/` — detailed historical decision logs moved out of canonical memory during compaction

### Automatic Write Rules

Agents should write memory entries when ANY of the following happens:

1. User states a stable preference or rule ("do it this way").
2. Agent makes a non-trivial mistake and corrects it.
3. A decision is made that affects future implementation.
4. A follow-up task is identified but not completed immediately.

Write target:
- Put durable behavior/rules in `memory/decisions.md`.
- Put implementation-step history and low-signal details in `memory/archive/*`.
- Keep `memory/mistakes.md` and `memory/todo.md` append-only.

Do NOT write:
- trivial chatter
- transient debug noise
- secrets/tokens/passwords
- private data not required for project execution

### Required Read Rules (Before Work)

Before starting a task, agents must read:

1. `memory/decisions.md`
2. recent entries in `memory/mistakes.md`
3. open items in `memory/todo.md`
4. `memory/archive/*` only when current files do not provide enough context

Then apply those constraints during planning and implementation.

### Entry Format (Canonical Decisions)

Use this compact format:

```md
## YYYY-MM-DD HH:mm
Context: <task or feature>
Type: decision | preference
Rule: <one-line future behavior>
Why: <short reason this rule exists>
```

### Mistake Entry Requirements

For entries in `memory/mistakes.md`, include:

- `Root cause:`
- `Fix applied:`
- `Prevention rule:`

### Maintenance

- Keep `memory/decisions.md` compact and high-signal (target: <= 150 lines).
- Compaction should move detailed historical entries to `memory/archive/` and keep `memory/decisions.md` as canonical rules.
- During compaction, preserve meaning and keep at least the latest 30 days of detail in `memory/archive/`.
- When compacting `memory/decisions.md`, append one compaction entry noting where full history was archived.

## Project Summary
The Car Lister is a Yarn workspaces monorepo for listing management, marketplace posting automation, and subscription workflows.

- Frontend (web): React + Vite
- Desktop app: Electron + React + TanStack Router + Zustand
- Backend API: Rails 8.1 + PostgreSQL + Solid Queue
- Marketing site: Astro
- CLI: Bun + Ink
- Shared packages: `packages/ui`, `packages/types`, `packages/config`, `packages/tsconfig`

## Monorepo Architecture

### Applications

- `api/` — Rails API (REST endpoints, jobs, scraping, billing webhooks)
- `apps/web/` — customer/admin web app
- `apps/desktop/` — desktop automation app (Electron main/preload/renderer)
- `apps/site/` — marketing site
- `apps/cli/` — CLI utility

### Shared Packages

- `packages/ui/` — shared React UI primitives
- `packages/types/` — shared TypeScript types
- `packages/config/` — shared Tailwind config
- `packages/tsconfig/` — shared TypeScript config presets

## API Architecture (Rails)

### Core Areas

- Controllers: `api/app/controllers/api/v1/*`
- Models: `api/app/models/*`
- Jobs: `api/app/jobs/*`
- Services: `api/app/services/*`
- Serializers: `api/app/serializers/*`
- Routes: `api/config/routes.rb`

### Data and Infra

- PostgreSQL with dedicated DBs for primary/cache/queue/cable (see `api/config/database.yml`)
- Solid Queue worker config in `api/config/queue.yml`
- Stripe webhook endpoint at `/webhooks/stripe`
- Mission Control Jobs mounted at `/jobs`

## Desktop Architecture (Electron)

### Process Split

- Main process: `apps/desktop/src/main.ts`
- Preload bridge: `apps/desktop/src/preload.ts`
- Renderer entry: `apps/desktop/src/renderer.tsx`
- Route tree: `apps/desktop/src/routes/*`

### Core Desktop Modules

- Facebook automation: `apps/desktop/src/facebook/*`
- Scheduler orchestration: `apps/desktop/src/scheduler/index.ts`
- Job system: `apps/desktop/src/jobs/*`
- IPC event hub: `apps/desktop/src/events/ipcEventHub.ts`
- Persistent client state: `apps/desktop/src/store/index.ts`
- Updater scaffold: `apps/desktop/src/updater/*`

## Web Architecture (React)

### Core Areas

- App entry: `apps/web/src/main.tsx`
- Routing: `apps/web/src/routes.tsx`
- Route shell: `apps/web/src/App.tsx`
- Auth state/provider: `apps/web/src/contexts/auth-context.tsx`
- API client and hooks: `apps/web/src/network/*`
- Pages: `apps/web/src/pages/*`
- Shared UI composition: `apps/web/src/components/*`

## API Client Generation

Both web and desktop generate typed clients from `api/public/openapi.json`.

- Web script: `apps/web/script/gen-client`
- Desktop script: `apps/desktop/script/gen-client`
- Output path: `src/types/generated.ts` (inside each app)

Regenerate clients after API route/schema changes.

## IPC and Event Pattern (Desktop)

Use this flow for renderer <-> main communication:

1. Add/extend `ipcMain.handle(...)` in `apps/desktop/src/main.ts`.
2. Expose a typed preload API in `apps/desktop/src/preload.ts`.
3. Consume only `window.electronAPI.*` in renderer code.
4. For push events, use the centralized hub (`createIpcEventHub`) instead of ad hoc listeners.

Event channels currently include:

- `scheduler:event`
- `job:completed`
- `chrome:ready`

## Scheduler and Jobs (Desktop)

- Scheduler polls queue/user state and emits renderer events: `apps/desktop/src/scheduler/index.ts`
- Job queue/runner execute slot actions and manual jobs: `apps/desktop/src/jobs/*`
- Job types include:
  - `PostListingJob`
  - `UpdatePriceJob`
  - `MarkSoldJob`

Keep scheduler logic centralized; avoid duplicating posting orchestration in renderer components.

## Key Paths

### Root

- Workspace scripts: `package.json`
- Turbo pipeline: `turbo.json`
- Dev process matrix: `Procfile.dev`

### API

- Routes: `api/config/routes.rb`
- DB config: `api/config/database.yml`
- Queue config: `api/config/queue.yml`
- Background worker launcher: `api/bin/jobs`
- OpenAPI spec: `api/public/openapi.json`

### Web

- Entry: `apps/web/src/main.tsx`
- Router: `apps/web/src/routes.tsx`
- API hooks: `apps/web/src/network/*`
- Tests: `apps/web/tests/*`

### Desktop

- Main process: `apps/desktop/src/main.ts`
- Preload API: `apps/desktop/src/preload.ts`
- Scheduler: `apps/desktop/src/scheduler/index.ts`
- Jobs: `apps/desktop/src/jobs/*`
- Browser automation: `apps/desktop/src/facebook/*`
- Forge config: `apps/desktop/forge.config.ts`

### Site and CLI

- Site pages/layouts: `apps/site/src/pages/*`, `apps/site/src/layouts/*`
- CLI entry: `apps/cli/src/cli/index.tsx`

## Architecture Guidelines

### Monorepo Guidelines

- Keep shared UI/types in `packages/*`; avoid copy/pasting across apps.
- Keep app-specific integration logic in the owning app folder.
- When API contracts change, regenerate clients for web and desktop.

### Web Guidelines

- Keep route composition in `apps/web/src/routes.tsx`.
- Keep auth/session behavior centralized in `apps/web/src/contexts/auth-context.tsx`.
- Put API side effects in `apps/web/src/network/*` hooks, not in presentational components.

### Desktop Guidelines

- Keep privileged logic in main process modules; renderer stays UI-focused.
- Restrict persistence keys through the allowlist in `apps/desktop/src/main.ts`.
- Prefer scheduler/job modules for background automation work over component-level timers.

### API Guidelines

- Keep business logic in service/model layers, not controllers.
- Use jobs for long-running scraping/posting flows.
- Preserve versioned API shape under `api/app/controllers/api/v1`.

## Running Locally

```bash
yarn install
yarn dev
```

Individual workspaces:

```bash
yarn dev:web
yarn dev:desktop
yarn dev:site
yarn dev:cli
```

API (from `api/`):

```bash
bin/rails server -p 3001
bin/jobs
```

## Build and Packaging

```bash
yarn build
```

Desktop package (from `apps/desktop/`):

```bash
yarn make
```

## Tests and Lint

```bash
yarn lint
yarn test
```

Web-focused:

```bash
cd apps/web && yarn test:run
```

API-focused:

```bash
cd api && bin/rails test
```

Desktop-focused:

```bash
cd apps/desktop && yarn lint
```

## Validation

At the end of a task:

1. Run `yarn lint`.
2. Run `yarn test`.
3. If API files changed, run `cd api && bin/rails test`.
4. If web or desktop API usage changed, regenerate client types with each app's `gen-client` script.
5. If desktop main/preload code changed, run relevant desktop tests in `apps/desktop/tests/*`.

## Notes

- Desktop auto-update is scaffolded and disabled by default (`DESKTOP_AUTO_UPDATE_ENABLED=false`) until hosting/publish pipeline is finalized.
- Web and desktop depend on typed API clients generated from `api/public/openapi.json`.
- API uses magic-link auth and token refresh flows exposed through `/api/v1/*` endpoints.
- Root `yarn dev` uses Turbo; `Procfile.dev` can run all services via Overmind.
