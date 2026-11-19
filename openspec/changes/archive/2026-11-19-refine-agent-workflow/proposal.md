# refine-agent-workflow: Proposal

## Why

Gamedata uses the same absolute rule as the engine: every task, including a small fix or a config value change, must run inside an OpenSpec change. That creates empty artifacts, archive noise and unnecessary context work. It also lets an agent skip spec consultation when it treats a task as small.

Gamedata should use the same task triage as the engine: a full OpenSpec change for large, risky or contract-changing work, and a git commit for small local fixes, small refactors and config/text work. The spec preflight remains mandatory for both.

## What Changes

- Add a `development-workflow` capability that defines task triage for gamedata.
- Replace the absolute "every task is a change" rule in `AGENTS.md` with the triage.
- Require a full OpenSpec change for large features, cross-cutting script refactors, changes to a script/Luabind API, LTX/XML semantics, save-load behavior, encoding policy, spawn/assets or any documented behavior.
- Track small features, bug fixes, small refactors of a couple of functions and config/text work in git.
- Require a spec preflight and a context statement before any edit, including git-only work.
- Stop and create a full change when a small task grows or changes a contract.

## Capabilities

### New Capabilities

- `development-workflow`: how gamedata work is classified, recorded and verified.

### Modified Capabilities

None.

## Impact

- `AGENTS.md` and `openspec/config.yaml`.
- New `openspec/specs/development-workflow/spec.md` after archive.
- No gameplay, script or config behavior changes.
