# refine-agent-workflow: Tasks

## 1. Policy text

- [x] 1.1. Update `AGENTS.md` section 8 with the task triage and the mandatory spec preflight; verify the text no longer says every task is an OpenSpec change.
- [x] 1.2. Update `openspec/config.yaml` proposal/specs/tasks rules and apply/archive guidance; verify `openspec context --json` still succeeds.

## 2. Spec

- [x] 2.1. Add the `development-workflow` capability through the delta in this change; verify `openspec validate --all --strict` passes.

## 3. Verification

- [x] 3.1. Run `openspec status --change refine-agent-workflow --json` and confirm the proposal, spec delta, design and tasks are complete.
- [x] 3.2. Ask the user to review the policy and confirm that no game run is needed.
