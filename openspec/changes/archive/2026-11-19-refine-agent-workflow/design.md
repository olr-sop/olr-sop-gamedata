# refine-agent-workflow: Design

## Context

The current `AGENTS.md` says every task runs inside an OpenSpec change. Gamedata already has `gamedata-encoding` as an accepted policy, so small text and encoding repairs that conform to it do not need a new change. Script and config work is also often local and low-risk. The workflow should distinguish that work from large or contract-changing changes without losing the spec preflight.

## Goals / Non-Goals

**Goals:**

- Make spec consultation mandatory before any edit.
- Keep full OpenSpec changes for large, risky or contract-changing work.
- Keep small local fixes, small refactors and config/text work in git.
- Mirror the engine policy so an agent sees the same rules in both repositories.

**Non-Goals:**

- Change any gameplay, script, config or encoding behavior.
- Create a new OpenSpec change for every typo or config value.
- Replace git history for small work with a second log.

## Decisions

- **Two record types.** Full OpenSpec change or git commit. A lightweight OpenSpec change is optional only if the user asks for one.
- **Spec preflight is mandatory for both.** The agent checks active changes and the capability inventory, reads the governing spec and states the record type before editing.
- **Small means local and non-contractual.** One subsystem, a few files, no script API or Luabind change, no new LTX/XML key or section, no documented requirement change, no save-load or encoding-policy change.
- **Config values are git-only; config semantics are not.** Values, balance, text and comments are git-only. New keys, sections or meanings are a full change.
- **Encoding normalization is git-only only when it follows the accepted `gamedata-encoding` policy.** A policy change is a full change.
- **Ambiguous work defaults to a full change.**

## Risks / Trade-offs

- **Small behavior changes may drift from specs.** Mitigation: if an existing requirement changes, the task is not small; promote it. Stable small features can be captured by a later spec change.
- **Agents may misclassify work as small.** Mitigation: the context statement names the record type and governing spec; the default is a full change; the user reviews the diff.
- **Gamedata has several encoding hazards.** Mitigation: git-only text work still uses `enc.ps1` and records the verification.
