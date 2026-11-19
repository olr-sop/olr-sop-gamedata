# development-workflow Specification

## Purpose
Define how gamedata work is classified and recorded: large or contract-changing work uses a full OpenSpec change, small local fixes and config/text work are tracked in git, and every task starts with a spec preflight.

## Requirements

### Requirement: Task triage

The gamedata repository SHALL use a full OpenSpec change for large, risky, cross-cutting or contract-changing work, and SHALL track small local features, fixes, small refactors and config/text work in git.

#### Scenario: Large or contract-changing work starts as a change

- **WHEN** a task is a large feature, a cross-cutting script refactor, a script or Luabind API change, a new LTX/XML key or section, a save-load change, an encoding policy change, a spawn/asset change, or any change to documented behavior
- **THEN** a folder `openspec/changes/<change-id>/` exists with a proposal, a spec delta and tasks before the files are edited

#### Scenario: Small local fix stays in git

- **WHEN** a small feature, bug fix or refactor of a couple of functions is local, low-risk and does not change a public contract, a config semantic or documented behavior
- **THEN** it is implemented without an OpenSpec change and recorded in the git commit

#### Scenario: Config and text work stays in git

- **WHEN** the work changes LTX/XML values, balance, text, comments, formatting or encoding according to the accepted `gamedata-encoding` policy
- **THEN** it is implemented without an OpenSpec change and recorded in the git commit

#### Scenario: Ambiguous task

- **WHEN** it is unclear whether the work is small or large
- **THEN** it is treated as large and a full OpenSpec change is created

### Requirement: Spec-first context

Before the first edit, the agent SHALL check active changes and the capability inventory, identify the governing spec, and state the planned record type. The agent SHALL query the code graph before broad text search and SHALL use the encoding toolkit for CP1251 text.

#### Scenario: Spec preflight

- **WHEN** a task starts
- **THEN** the agent has run `openspec list`, `openspec list --specs`, and read the governing spec or recorded that none exists

#### Scenario: Context statement

- **WHEN** the agent is ready to edit
- **THEN** it states `Context: change=<id|none>; spec=<capability|none>; record=<openspec|git>; files=...; verification=...`

#### Scenario: Code discovery order

- **WHEN** the agent needs a script symbol or call path
- **THEN** it queries CBM first, uses `enc.ps1` for CP1251/LTX text, and uses targeted search only for literals or gaps
