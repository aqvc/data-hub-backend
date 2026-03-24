# AGENTS.md

## Working Style

- Keep changes scoped to the request. Prefer small, reviewable patches over broad cleanup.
- Follow the existing project shape before introducing new abstractions.
- Match the repo's naming, whitespace, and control-flow style in touched files.
- Do not rewrite working code just to make it more "standard Rails" unless the task requires it.
- If the codebase already has some inconsistency, prefer the stronger local pattern nearest to the code you are editing.

## Rails Architecture

- Keep controllers and GraphQL mutations thin. They should mainly validate inputs, load records, call services, and format responses.
- If a controller or mutation method is getting bigger than roughly 10 lines of business logic, extract a service.
- Prefer plain Ruby service objects in `app/services` for workflows, orchestration, search/filtering, external API calls, and multi-record writes.
- Service names should be explicit and domain-first, for example `PositionSetupService` or `CandidatesSearchService`.
- Prefer a `call` entrypoint for services. If a service exposes a more specific verb such as `setup_all`, use that only when it clearly improves readability.
- Keep models focused on associations, validations, enums, small query helpers, and tightly-related callbacks.

## GraphQL Conventions

- Follow the existing `Mutations::BaseMutation` pattern.
- Define explicit `argument` and `field` declarations near the top of the mutation.
- In `resolve`, prefer:
  1. Find/load records.
  2. Return a GraphQL error when required records are missing.
  3. Delegate business logic to a service when the flow is non-trivial.
  4. Return a small hash matching declared fields.
- Use `raise_exception(...)` from `BaseMutation` for mutation failures so GraphQL errors stay consistent.
- Keep mutation responses compact. Do not add extra payload fields unless the client needs them.

## Model Conventions

- Keep associations explicit and use ordered associations only where the app depends on stable ordering.
- Prefer constants plus string-backed enums for status-like fields when that pattern already exists in the app.
- Put small domain helpers and URL builders on the model only when they are directly about that record.
- Be conservative with callbacks. Reuse the existing callback style where needed, but do not add heavy workflows to callbacks when a service/job would be clearer.
- Use validations and custom validators for data rules that belong to a single model.

## Service Conventions

- Initialize services with the minimum required dependencies.
- Keep `call` or the public entrypoint short and push detail into private methods.
- Prefer guard clauses over deep nesting.
- When a service performs side effects, keep the order of operations obvious.
- Rescue only when there is a clear recovery/logging reason. If rescuing, log with the project's existing mechanism.
- Avoid generic utility services. Prefer domain-specific names and behavior.

## Background Jobs And Integrations

- Queue background jobs for delayed or external side effects such as email, SMS, file processing, or third-party API work.
- Keep job scheduling in the mutation/controller/service layer, not scattered across unrelated models unless the callback behavior is intentional and already established.
- Reuse existing integration patterns for providers like Stripe, Twilio, S3, OpenAI, and Rollbar before adding new client wrappers.

## Query And Persistence Style

- Prefer ActiveRecord queries first. Drop to raw SQL only when the query is genuinely awkward or performance-sensitive.
- Keep query objects/services readable. A little duplication is better than a clever abstraction that hides intent.
- Use bang methods when failure should be loud inside services/setup flows. Use non-bang methods when the caller is expected to branch on success/failure.
- Preserve tenant scoping and authorization assumptions already present in the app.

## Testing Style

- Use Minitest with fixtures if the project already does.
- Add focused tests for new business logic, especially services, model validations, and non-trivial mutations.
- Do not invent a new testing stack inside an established Rails app.
- If coverage is currently sparse, add the smallest useful test around the behavior you changed rather than trying to normalize the whole suite.

## Migrations And Schema

- Keep migrations small and reversible when practical.
- Follow existing naming conventions for columns, tables, and timestamps.
- Do not mix unrelated schema changes into a feature task.

## Review Checklist

- Is the business logic in the right place, or should it move to a service?
- Does the change preserve existing tenant, auth, and GraphQL error behavior?
- Are naming and return shapes consistent with nearby code?
- Are callbacks, jobs, and side effects still easy to follow?
- Is there a focused test worth adding for the changed behavior?

## Default Commands

- Install gems: `bundle install`
- Run app: `bin/rails server`
- Run tests: `bin/rails test`
- Run one test file: `bin/rails test path/to/test_file.rb`

## Non-Goals

- Do not introduce new architectural patterns without a clear project need.
- Do not perform repo-wide linting or formatting changes unless explicitly requested.
- Do not refactor untouched areas opportunistically.
