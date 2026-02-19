# TODO

## Open

- Unify duplicated "More options" selector logic between `apps/desktop/src/facebook/listing/create.ts` and `apps/desktop/src/main.ts` (`facebook:test-find-more-options`) into a shared helper to prevent drift.
- Add durable "published-on-Facebook but not yet synced to API" reconciliation flow for desktop posting jobs, including server-side failure recording and retry-safe ack endpoint.
- Wire desktop scheduler/job failure handling to call `POST /api/v1/posting_slots/:public_id/fail` with `failure_stage` (`post_failure` vs `sync_failure`) and surface sync failures in UI.
- Detect Cloudflare/block pages in scraping fetch flow and fail fast (or mark as blocked) instead of persisting all-Unknown extraction results.
- Implement `PostingSlotGenerator` deterministic three-phase scheduling so `api/test/services/posting_slot_generator_queue_algorithm_test.rb` passes.
- After deploying low-confidence scrape retry logic, re-trigger scraping for listings currently stuck with all-Unknown core fields (including `vnZjz8EcvwMe1SY62oi2wAQ2`) and confirm they resolve or move to failed/retry-visible state.
- Add Windows installer code-signing/notarization equivalent for desktop CI once certificate/secrets strategy is finalized.
- Decide whether to replace `wtype` with a GNOME Shell extension (or portal-based approach) for Super+Copy/Paste to reduce synthetic-input tooling exposure.
