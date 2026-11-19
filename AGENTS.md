# Agent Instructions

## Context and documentation

- The DocC catalog, `Sources/GruffixToasts/GruffixToasts.docc/`, is the single source of documentation for library consumers and contributors, and is published to GitHub Pages. At the start of every session, read its landing page, `GruffixToasts.md`, if it exists, then read the articles relevant to the task. Do not duplicate explanations already in code comments.
- `scratchpad/README.md` indexes working designs and possible future work. These documents contain current thinking and open questions, not necessarily approved decisions or implemented behavior.
- Stories describe intended work. Pull requests and completed stories preserve history. Put lasting explanations in code comments or the appropriate documentation as implementation lands; update or remove obsolete scratchpad material as part of the agreed work.
- When adding a document, add it to the appropriate index in the same change. For a DocC article, that is a topic group on the landing page.
- Before writing or changing code, read `.coding-heuristics.md` if it exists. Compare new and modified code against it before handing work over. If it is absent, report that briefly and follow existing code conventions without inventing a replacement.
- Precedence: explicit user instructions in the current session override this file. Root rules apply everywhere; directory-specific instructions govern their area. Use the DocC catalog for implemented behavior and `scratchpad/` for working designs. All remain subject to the agent platform's higher-priority instructions. If an unresolved conflict materially affects the task, explain it and ask.

## Project baseline

- This is a Swift package that ships the `GruffixToasts` library. There is no Xcode project. Source lives in `Sources/GruffixToasts/`, tests in `Tests/GruffixToastsTests/`.
- Swift tools 6.2, Swift 6 language mode with complete strict concurrency checking.
- Target Swift settings in `Package.swift`: default `MainActor` isolation, `NonisolatedNonsendingByDefault` and `InferIsolatedConformances`. Code is written against these; don't work around them.
- Minimum deployment targets: iOS 27.0.
- Do not use APIs unavailable on these targets without an availability check.

## Hard rules

- Never commit directly to `main` or merge a pull request. Humans perform those actions. Agents may commit on branches, push, or open pull requests only when the user or a directory-specific workflow in this repo authorizes it.
- No new dependencies without asking. This includes packages, development tools and introducing additional Apple or third-party frameworks.
- No secrets, credentials or personal data in the repo.
- Do what was asked, at the size it was asked. Discussion and casual remarks do not authorize implementation. If uncertainty would materially change the scope or design, ask before starting.
- Ask before changing `Package.swift`: tools version, platforms, products, targets, dependencies or Swift settings. Keep edits minimal and confirm the package still resolves and builds afterward.
- Ask before adding resources or a privacy manifest (`PrivacyInfo.xcprivacy`) to the package.

## Public API and versioning

- The package follows Semantic Versioning and is in its 0.x phase: breaking changes bump the minor version; additions and fixes bump the patch version.
- Humans own versions. Never create tags, publish releases or choose the version number.
- Default to `internal`. Make a symbol `public` only when a consumer needs it, and ask before adding public API. Don't use `open` unless subclassing is intended.
- Ask before any breaking change: removing, renaming, or changing the signature or behavior of a public symbol. Adding a case to a public enum is breaking, because it breaks consumers' exhaustive `switch` statements. The 0.x phase changes the version number a breaking change produces, not the need for approval.
- Prefer deprecating with `@available(*, deprecated, renamed:)` for at least one release before removing a public symbol.
- Every `public` symbol has a documentation comment.
- Record every user-visible change under "Unreleased" in `CHANGELOG.md` (Keep a Changelog format). Create the file with the first such change if it doesn't exist.
- In every handoff, classify the change as patch or minor under the 0.x rule above, and list all public API additions, changes, deprecations and removals.

## Verification

Pick the mode from the task. If unclear, use the lightest plausible mode and state which one you chose.

1. **Light** (pairing, scaffolding, small edits): touched files are clean in Xcode diagnostics and checked against `.coding-heuristics.md`. Don't build or run tests unless asked.
2. **Structural** (moving code between targets or packages, writing tests): build all affected targets and run the relevant tests. New tests must run; report failures as findings.
3. **Feature** (delegated stories): full build and test suite, plus a list of manual checks for anything not automated. Done when it meets the Definition of done below.

Build and test with `xcodebuild` against iOS, not `swift build` or `swift test`, which target the host Mac and fail for this iOS-only package:

- Build: `xcodebuild build -scheme GruffixToasts -destination 'generic/platform=iOS Simulator'`
- Test: `xcodebuild test -scheme GruffixToasts -destination 'platform=iOS Simulator,name=<device>'`, using an available iOS 27 simulator from `xcrun simctl list devices available`.

If a task grows beyond its mode (shared code, public APIs, many files), stop and ask whether to continue, move to a stricter mode, or reduce scope.

Directory-specific instructions may define their own verification mode, which overrides these defaults within that directory.

Always report the mode used, what was run, and what was skipped. If verification is unavailable or fails, say so and leave the work marked unverified. Do not claim completion.

## Definition of done

### Feature stories

1. **Acceptance criteria:** every criterion in the story is met, and the pull request description addresses each one.
2. **Build and tests:** the package builds on every supported platform; the full test suite passes, reported as passed, failed and skipped; new behavior has tests; CI is green once it exists.
3. **No new warnings:** compiler or DocC.
4. **Heuristics:** code is checked against `.coding-heuristics.md`, and deviations are explained in the pull request.
5. **Public API:** changes are listed in the pull request and approved, every `public` symbol has a documentation comment, and the change is classified as patch or minor.
6. **Docs:** a `CHANGELOG.md` "Unreleased" entry, and DocC updated for user-visible behavior.
7. **Manual checks:** a list of what wasn't automated, always including VoiceOver and Reduce Motion.
8. **Pull request:** one branch and pull request per story, targeting `main`, with "Closes #N" in the description and no links to agent session chats. A human merges.
9. **Honest status:** anything unverified is listed. A story with unverified items is not done.

### Analysis spikes

1. Every question in the story is answered, and the report is posted on the issue.
2. No code changes unless the story explicitly pre-approves them.
3. Recommendations and decisions for the owner are listed separately.

## You are a guest

### On the laptop

- Keep project exploration and edits inside the repo. Do not inspect unrelated personal files or change files outside the repo without asking. Normal access to installed SDKs and tools, and their ordinary build caches and temporary files, is allowed.
- Files the user attaches from outside the repo grant access to those exact files only, not their folder. If they reference other files, ask the user to attach them. Don't list, search or open anything else outside the repo without explicit permission.
- Clearing build caches is limited to this project's own DerivedData folder and the package's `.build/` folder. Never clear all of DerivedData or other projects' caches.
- Don't change global or system settings, including shell profiles, `git config --global`, Xcode preferences or system settings.
- Don't install anything without asking.
- Don't leave background processes you started running when the session ends.
- Don't upload project code, data, logs or screenshots to external services except the repo's GitHub remote without asking. Never include secrets or personal data in an upload.
- Physical devices are off limits unless explicitly authorized for the current task. Use simulators by default. If a test needs a physical device, the user connects it and grants permission for that occasion. Permission ends when the task ends. Without that permission, never install builds, run apps or interact with a physical device.

### In the repo

- Touch only the files the task needs. Don't reformat, rename or tidy unrelated content.
- Never discard the user's work. Do not use `git reset --hard`, `git clean`, `git checkout -- .`, `git restore .`, `git stash drop`, force pushes or branch deletion. Do not amend pushed commits or rebase shared branches.
- Inspect existing changes before editing. Continue when your work is independent and will not overwrite, stage or commit changes you did not make, unless a directory-specific workflow says otherwise. If changes overlap or ownership is unclear, stop and ask.
- Don't delete files unless the agreed task explicitly requires it.
- Leave things as you found them, plus only the agreed changes.

Routine steps needed for an assigned task are authorized within these boundaries. Ask when an action would cross a boundary or requires a decision the user has not made.
