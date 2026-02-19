# Decisions

## Canonical Memory Model

- `memory/decisions.md` stores active, high-signal canonical rules only.
- Full historical detail for the pre-compaction log is archived at `memory/archive/decisions-2026-02-07-full.md`.
- New low-signal implementation-step history should go to `memory/archive/` instead of this file.

## Entry Template

```md
## YYYY-MM-DD HH:mm
Context: <task or feature>
Type: decision | preference
Rule: <one-line future behavior>
Why: <short reason this rule exists>
```

## Active Canonical Rules

## 2026-02-07 22:28
Context: Desktop auto-update setup
Type: decision
Rule: Keep desktop auto-update scaffolded but disabled by default until S3/CloudFront hosting and publish pipeline are configured.
Why: Avoid partially enabled update behavior before secure artifact hosting is ready.

## 2026-02-07 22:32
Context: AGENTS documentation standardization
Type: preference
Rule: Keep `AGENTS.md` in the CodexMonitor guide format while documenting The Car Lister's live project architecture and workflows.
Why: Maintain a consistent agent onboarding structure across projects with project-specific canonical content.

## 2026-02-07 22:39
Context: Facebook listing lookup resilience
Type: decision
Rule: Use layered selectors (primary, compact-layout fallback, broad fallback) when finding the Marketplace "More options for ..." button in desktop listing flows.
Why: Facebook layout changes with viewport size and class structure can hide the primary target selector.

## 2026-02-08 00:00
Context: Desktop posting image pipeline
Type: decision
Rule: In `PostListingJob`, download at most `ImageConfig.MAX_PHOTOS_PER_LISTING` images before upload steps.
Why: Marketplace uploads are capped at 20 photos, so downloading extras is unnecessary work and bandwidth.

## 2026-02-07 23:08
Context: Desktop posting publish/sync failure handling
Type: preference
Rule: Treat "published on Facebook but failed to sync URL to API" as a distinct `sync_failure` state (not generic post failure), and prioritize API-side recording first.
Why: This failure mode has potential data loss risk and must be visible/remediable separately.

## 2026-02-07 23:30
Context: Web posted/archive listing tables with clickable rows
Type: decision
Rule: In `TableRow` entries with `href`, action controls (external links, buttons) inside cells must call `event.stopPropagation()` to avoid triggering row navigation.
Why: Row-link overlays in shared table cells can intercept/bubble clicks and block intended per-cell actions.

## 2026-02-07 23:31
Context: Listing feed scraping fan-out controls
Type: decision
Rule: In `ListingFeedJob`, dedupe scraped feed links against existing user listings before creating listings, then cap child `ScrapingJob` fan-out to at most 20 new links.
Why: Prevent redundant duplicate listings and bound queue fan-out per feed run.

## 2026-02-07 23:35
Context: Web stale asset mitigation after long inactivity
Type: decision
Rule: Mount `DailyRefreshGuard` in web app startup to force one cache-busted reload per local day when returning after >=4 hours inactive.
Why: Daily long-idle refresh reduces risk of running outdated JS bundles without interrupting active sessions.

## 2026-02-08 21:01
Context: Scraping diagnostics for Cloudflare-protected listing URLs
Type: decision
Rule: Log scraping pipeline checkpoints (HTTP status, handler selection, HTML byte sizes, extraction quality) and flag low-confidence results (Unknown title or zero images) in `ScrapingJob`/`ListingScraper`.
Why: Some protected sites return block/challenge pages that previously looked like successful scrapes with unknown fields.

## 2026-02-11 12:10
Context: API scraping vehicle condition handling
Type: decision
Rule: Store an internal `condition_status` (`new`/`used`) on `Scraping`, default all records to `used`, and force mileage to `300` whenever `condition_status` is `new`.
Why: New-car mileage should be deterministic and not sourced from scrape output.

## 2026-02-10 21:50
Context: Selenium-based feed scraping reliability on Cloudflare-protected pages
Type: decision
Rule: In `SeleniumFetcher`, apply browser-like UA/language settings plus CDP stealth script and retry once when Cloudflare/challenge signatures are detected before failing.
Why: Some dealership feeds intermittently resolve to Cloudflare challenge/error pages and need hardened fetch behavior to return real listing links.

## 2026-02-10 21:55
Context: Listing scraper initial HTTP probe headers
Type: preference
Rule: Keep `ListingScraper#fetch_initial_html` request identity headers sourced from shared `SeleniumFetcher` defaults so browser fingerprints stay aligned across HTTP and Selenium stages.
Why: Divergent headers between preflight Net::HTTP and browser fetch can increase inconsistent blocking behavior.

## 2026-02-11 21:38
Context: Queue algorithm delivery workflow
Type: preference
Rule: For queue-algorithm changes, write and lock Minitest coverage before implementing generator code changes.
Why: Test-first flow prevents regressions and keeps scheduling behavior explicit.

## 2026-02-11 21:38
Context: Queue slot scheduling rules
Type: decision
Rule: Use deterministic queue phases: delete slots every 5 minutes from start, update slots every 5 minutes after deletes, then posting slots with interval `floor(remaining_minutes / posting_slots_count)` starting 5 minutes after updates/deletes, with no slot after `posting_end_time`.
Why: Predictable scheduling is required for stable automation behavior and reliable assertions.

## 2026-02-11 22:16
Context: Manual posting-slot queue regeneration
Type: decision
Rule: `PostingSlots::DailyQueueCreationJob#perform` must accept optional `date` and `user_id:` arguments while remaining compatible with no-arg recurring execution.
Why: Operators need targeted backfills from Rails console without breaking scheduled daily runs.

## 2026-02-11 22:24
Context: Desktop queue main-list UI controls
Type: preference
Rule: Hide queue main-list action buttons by default and only show them when `VITE_DESKTOP_SHOW_MAIN_LIST_ACTION_BUTTONS` is truthy.
Why: Keep the default desktop main list simpler while preserving optional manual controls behind a feature flag.

## 2026-02-11 22:29
Context: Desktop queue bulk action controls
Type: preference
Rule: Show top-of-queue bulk action buttons for delete/update/post with labels `X = min(remaining queue items of that type, 5)` and execute up to 5 items per click.
Why: Provide quick queue operations while keeping batch size bounded.

## 2026-02-11 22:47
Context: Desktop queue batch action progress labels
Type: preference
Rule: While a top-of-queue batch action is running, show the live remaining count in the active button label (for delete/update/post).
Why: Operators need immediate visibility into batch progress.

## 2026-02-11 23:09
Context: Repo LoC reporting
Type: decision
Rule: `bin/loc-report` should exclude generated artifacts and binary assets by default while allowing `--include-generated` opt-in.
Why: Keep LoC metrics representative of maintained source code instead of generated/output files.

## 2026-02-12 08:54
Context: Desktop Facebook update-price edit flow
Type: preference
Rule: In `updateListingPrice`, detect `"Create new listing"` on the Facebook edit page before field edits and fail fast as "listing unavailable" when present.
Why: Some listings are removed/unavailable, and this check prevents misleading generic wait timeouts.

## 2026-02-12 08:58
Context: Posting slot auto-assignment after listing confirmation
Type: decision
Rule: On listing confirmation, run `PostingSlotAssigner` for the user's `settings.current_date` instead of claiming only an `upcoming` slot.
Why: Due pending posting slots must backfill automatically so configured posting volume (e.g. 15 slots) is fully claimable as listings become confirmed.

## 2026-02-12 09:21
Context: Desktop manual/scheduled post image download threshold
Type: decision
Rule: In `ImageProcessor`, required successful downloads must scale to available image URLs (`max(1, min(minRequired, urls.length))`) instead of always requiring 4.
Why: Single-photo listings should be allowed to post when their available image set is small, while still failing when zero usable images are downloaded.

## 2026-02-15 08:56
Context: Desktop Facebook listing description input
Type: decision
Rule: In desktop Facebook create-listing flow, Description textarea should use clipboard paste only; if paste fails, fail the job with a clear error.
Why: Pasted input more closely matches real user behavior while preserving reliability across browser contexts where clipboard APIs can fail.

## 2026-02-15 11:16
Context: Desktop Facebook form handler design for textarea paste flow
Type: preference
Rule: Keep clipboard-first Description behavior in a dedicated `textarea-paste` form handler path instead of conditional logic inside the generic textarea handler.
Why: A dedicated handler keeps generic textarea behavior clean and makes specialized input strategies explicit.

## 2026-02-15 12:38
Context: Desktop queue main-list post control visibility
Type: preference
Rule: Keep `VITE_DESKTOP_SHOW_MAIN_LIST_ACTION_BUTTONS` defaulted to enabled so row-level queue action buttons (including `Post`) are visible unless explicitly turned off.
Why: Operators need direct per-listing post actions available by default in the desktop queue UI.

## 2026-02-15 12:46
Context: Desktop description paste reliability
Type: decision
Rule: In `pasteFromClipboard`, attempt OS clipboard paste first, then a secondary synthetic paste-style input on the active editable element; if both fail, error fast.
Why: Focus can succeed while clipboard permissions/context still fail, so a second paste strategy reduces false negatives without reintroducing typing fallback.

## 2026-02-17 00:00
Context: Desktop CI packaging targets
Type: decision
Rule: Keep dedicated manual GitHub Actions workflows per desktop OS; Windows builds run on `windows-latest` with `yarn make --platform=win32 --arch=<x64|arm64>` and upload `apps/desktop/out/make` artifacts.
Why: Mirrors existing macOS release workflow structure while making Windows artifacts reproducible from CI.

## 2026-02-16 21:06
Context: Selenium feed scraping browser disconnect handling
Type: decision
Rule: In `SeleniumFetcher`, ignore transient timeout/socket errors raised during `driver.quit` and keep timeout error formatting based on both exception class and wrapped timeout message text.
Why: Browser shutdown transport failures should not mask a completed fetch or leak uncaught `Net::ReadTimeout` failures into feed jobs.

## 2026-02-17 00:00
Context: Web support page placeholder contact flow
Type: preference
Rule: In the web Support page, show a simple support box that directs users to email `support@automarketlister.com`.
Why: Provide an immediate support path while fuller support tooling is pending.

## 2026-02-17 19:47
Context: Desktop app failure handling during automation
Type: preference
Rule: Keep the tab open only if the app crashes after clicking "Publish"; close the tab if it fails during form filling.
Why: Preserve post-publish failure state while keeping earlier form failures cleanly reset.

## 2026-02-18 20:27
Context: Marketing site theme
Type: preference
Rule: Disable dark mode on the marketing site by using class-based dark mode without applying the `dark` class.
Why: Keep marketing pages light-only for now.

## 2026-02-18 18:23
Context: Desktop Facebook create-listing pacing
Type: preference
Rule: Insert a 1-second delay after filling Description and before clicking `Next` in `createVehicleListing`.
Why: Adds a short human-like pause at the exact transition requested for desktop posting reliability.

## 2026-02-18 18:29
Context: Desktop Facebook description input strategy
Type: preference
Rule: In `createVehicleListing`, keep Description on `textarea-paste` and require explicit textarea focus verification before paste.
Why: Preserve clipboard-first behavior while preventing paste from targeting the wrong element.

## 2026-02-18 20:35
Context: Desktop Facebook paste-debug workflow
Type: preference
Rule: Use a dedicated TSX debug runner that connects to the desktop remote-debug Chrome context with Node-safe helpers (no direct Electron imports) when validating Facebook Description paste/preview behavior.
Why: Reproduces real app browser/session conditions better than isolated unit/integration harnesses.

## 2026-02-18 20:38
Context: Desktop Description paste implementation ownership
Type: decision
Rule: Keep Description paste+focus behavior in a shared logger-free helper (`form/descriptionPaste.ts`) and reuse it from both production form handlers and debug scripts.
Why: Avoid logic duplication and keep debug tooling runnable outside Electron.

## 2026-02-18 20:41
Context: Desktop clipboard fallback on controlled textareas
Type: decision
Rule: In `pasteFromClipboard` fallback for textarea/input, set value via native element prototype setter and dispatch paste-like `beforeinput`/`input` events (plus `change`) instead of direct `.value` assignment only.
Why: Controlled React-style fields can show temporary DOM text but revert on blur unless updates go through the expected native event/value path.

## 2026-02-18 20:43
Context: Desktop native clipboard paste reliability
Type: decision
Rule: In `pasteFromClipboard`, strengthen the primary native paste path with explicit focus/select prep and one retry before using synthetic fallback.
Why: Increase success rate of trusted keyboard paste so synthetic event fallback is needed less often.

## 2026-02-19 10:47
Context: Base image browser tooling
Type: decision
Rule: Install `chromium` in `build_files/build.sh` alongside Firefox in the base image package set.
Why: Ensure Chromium is available in built environments that require Chrome-compatible browser tooling.

## 2026-02-19 11:46
Context: Silverblue image package set
Type: decision
Rule: Install Ghostty in `build_files/build.sh` via `dnf5 copr enable scottames/ghostty` and `dnf5 install ghostty` so it is baked into the image.
Why: User wants Ghostty managed by the image build rather than ad hoc host installation.
