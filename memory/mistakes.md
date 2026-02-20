# Mistakes

## Entry Template

## YYYY-MM-DD HH:mm
Context: <task or feature>
Type: mistake
Event: <what happened>
Action: <what changed / fix applied>
Rule: <one-line future behavior>
Root cause: <why it happened>
Fix applied: <what was changed>
Prevention rule: <how to avoid recurrence>

## 2026-02-10 21:50
Context: Selenium anti-detection options in `SeleniumFetcher`
Type: mistake
Event: Added `excludeSwitches` and `useAutomationExtension` via `Chrome::Options#add_option`, which caused a runtime failure: "These options are not w3c compliant".
Action: Removed non-W3C options and kept compatible hardening (`--disable-blink-features=AutomationControlled`, UA/language overrides, CDP script).
Rule: Only use Selenium/Chrome capabilities that are valid under current WebDriver W3C mode in this stack.
Root cause: Assumed ChromeDriver-specific experimental options could be injected the same way in this Selenium Ruby configuration.
Fix applied: Deleted incompatible options and reran live scrape to confirm successful output.
Prevention rule: Validate new Selenium options with one live `bin/rails runner` scrape immediately after adding them before stacking additional changes.

## 2026-02-11 21:38
Context: Deterministic queue scheduler reimplementation
Type: mistake
Event: Used `break` inside `times.each_with_object` in phase minute builders, which returned `nil` when truncating at end-of-window and caused schedule construction errors.
Action: Rewrote phase loops to explicit array accumulation and ensured bounded truncation returns arrays reliably.
Rule: Avoid `break` in `each_with_object` for value-producing methods where `nil` would propagate into later scheduling steps.
Root cause: Assumed `break` would only exit the block while preserving accumulator semantics.
Fix applied: Replaced `each_with_object` blocks with explicit `minutes = []` loops in `PostingSlotGenerator#phase_minutes` and `#posting_phase_minutes`.
Prevention rule: For scheduling builders, use explicit accumulators with predictable returns and add tests that exercise boundary truncation.

## 2026-02-11 22:16
Context: Manual execution of `PostingSlots::DailyQueueCreationJob`
Type: mistake
Event: Invoked the job with `(date, user_id:)`, but `perform` accepted zero arguments and crashed with `ArgumentError`.
Action: Updated job signature to accept optional `date` plus `user_id:`, normalize date input types, and keep zero-arg recurring behavior.
Rule: Jobs used by both recurring schedules and console backfills should support explicit targeting arguments without breaking scheduler-compatible defaults.
Root cause: `perform` was implemented only for recurring no-arg runs, while operational usage required targeted/manual execution.
Fix applied: Changed `perform(date = nil, user_id: nil)` and scoped users/date handling accordingly in `api/app/jobs/posting_slots/daily_queue_creation_job.rb`.
Prevention rule: Before running manual backfills, verify the job signature matches invocation shape (`perform_now` args/kwargs).

## 2026-02-12 08:58
Context: Posting slot assignment gap after daytime confirmations
Type: mistake
Event: Confirmation callback only searched `upcoming` posting slots, leaving due pending slots unclaimed until manual reassignment.
Action: Switched confirmation callback to run `PostingSlotAssigner` for the user's current local date.
Rule: Assignment triggers must consider all pending slots for the current date, not just future-time slots.
Root cause: Callback logic optimized for a single immediate slot claim and unintentionally excluded due slots.
Fix applied: Replaced `claim_available_slot` upcoming-slot query with `PostingSlotAssigner.new(user, date: user.settings_or_create.current_date).call`.
Prevention rule: Add tests that include due pending slots when validating confirmation-triggered auto-assignment.

## 2026-02-15 08:56
Context: Desktop form handler integration harness tests
Type: mistake
Event: Initial integration harness used a local HTTP server, which failed in sandboxed environments with `listen EPERM`.
Action: Switched harness loading to `page.setContent` from static HTML to remove local port binding dependency.
Rule: For Puppeteer integration tests intended to run in restricted environments, prefer `page.setContent` over spinning up local HTTP servers unless network behavior is explicitly under test.
Root cause: Assumed local loopback socket binding would be allowed in all development/sandbox contexts.
Fix applied: Reworked `tests/form-handlers.integration.test.ts` to read HTML fixture and inject it directly into the page.
Prevention rule: Default to socket-free harness setup first, and only add HTTP server infrastructure when test assertions require true origin/network semantics.

## 2026-02-15 12:40
Context: Desktop Facebook description textarea paste path
Type: mistake
Event: Description paste behavior depended on `label === "Description"` routing inside the generic `textarea` handler path, so label drift/variation could silently bypass clipboard paste.
Action: Added explicit `textarea-paste` field type, wired dedicated handler mapping, and switched create-listing Description field to use `textarea-paste` directly.
Rule: For behavior-specific form input strategies, use explicit field types instead of label-based branching.
Root cause: Specialized behavior selection was coupled to display label text rather than form schema intent.
Fix applied: Updated `FieldType`, `fieldHandlers` map, `createVehicleListing` form spec, and integration test to call `textarea-paste` path directly.
Prevention rule: Keep special handlers addressable by explicit field type and validate with focused integration tests.

## 2026-02-15 12:42
Context: Desktop textarea paste failure handling in posting flow
Type: mistake
Event: `textarea-paste` handler attempted natural typing fallback after clipboard paste failure, leading to downstream protocol/session errors instead of immediate explicit failure.
Action: Removed typing fallback; handler now throws immediately when clipboard paste fails.
Rule: `textarea-paste` must be clipboard-only and error fast on failure.
Root cause: Reliability fallback preference conflicted with operator requirement for strict paste behavior.
Fix applied: Updated `TextareaPasteFieldHandler` to throw on unsuccessful paste and keep success path clipboard-only.
Prevention rule: Do not add fallback input modes to strict handlers unless product requirements explicitly change.

## 2026-02-18 20:48
Context: Desktop create-listing publish transition
Type: mistake
Event: `createVehicleListing` no longer clicked `Next` and `Publish` before URL inspection, allowing false success without posting.
Action: Restored `Next` click, `Publish` navigation wait, redirect delay, and notification modal dismissal before listing URL checks.
Rule: In create-listing flow, preserve publish-transition steps before any success/URL lookup logic.
Root cause: Interim debugging edits removed the publish transition and were not reverted.
Fix applied: Reinserted publish sequence in `apps/desktop/src/facebook/listing/create.ts`.
Prevention rule: For debug-only workflow changes in posting code, gate via flags/scripts and keep production publish path intact.

## 2026-02-19 21:09
Context: Fedora 43 image build Chrome repo setup
Type: mistake
Event: Used `dnf5 config-manager addrepo --from-repofile=... --add-or-replace`, which fails because those options are incompatible in current dnf5.
Action: Replaced with `--overwrite` and hardened Google key cleanup to remove stale key IDs before re-import.
Rule: For dnf5 `addrepo --from-repofile`, use `--overwrite` for idempotence and never combine with `--add-or-replace`.
Root cause: Assumed older config-manager flag combinations were still valid in this dnf5 release.
Fix applied: Updated `build_files/build.sh` addrepo flags and key-removal logic (`7fac5991`/`d38b4796` cleanup).
Prevention rule: Verify exact dnf5 subcommand option compatibility with `--help` before using mixed flag patterns in build scripts.

## 2026-02-19 21:13
Context: Fedora 43 image build Chrome repository source
Type: mistake
Event: Switched to direct Google repofile URL for dnf5 and hit 404 at build time.
Action: Replaced manual Google repo setup with Fedora third-party repository flow.
Rule: Prefer distro-maintained repository definitions over vendor repofile URLs in long-lived build scripts.
Root cause: Assumed the direct Google `.repo` URL path was still published and stable.
Fix applied: Updated `build_files/build.sh` to install `fedora-workstation-repositories` and enable `google-chrome` via `dnf5 config-manager setopt`.
Prevention rule: For external repos, validate URL accessibility or use distro repository packages where available.
