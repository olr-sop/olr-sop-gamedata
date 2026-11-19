# OLR / Gamedata — AGENTS.md

Entry point for coding agents. Read this before any task in this repository.

## 1. What this is

Game runtime and gamedata for **Oblivion Lost Remake**: X-Ray 1.6, Lua 5.1 (LuaJIT), LTX/XML configuration, HLSL shaders and binary assets. The engine source is a separate repository; this repository contains the data the engine loads.

## 2. Golden rules

- **Encoding is the first hazard.** Gamedata is Windows-1251, except shaders and English localization under `config/text/eng/`, which are UTF-8. Use `tools/encoding/enc.ps1` for every read, search and write; direct UTF-8 writes corrupt the game text.
- **Run only on explicit request.** The default is that the user runs the game, `luac`, editors and packing tools. Run them only when the user explicitly asks for that specific command.
- **Spec before code, always.** Start every task with the spec preflight. Use a full OpenSpec change for large, risky or contract-changing work; track small local features, fixes, small refactors and config/text work in git (section 8).
- **No blind mass edits.** Convert or rewrite only files inside the current change scope.
- **One repository, one change.** Engine and gamedata changes are separate commits.

## 3. Encoding policy and toolkit

| Area | Encoding |
| --- | --- |
| `gamedata/shaders/**` (`.ps`, `.vs`, `.s`, `.h`) | **UTF-8** (preferred; may contain Cyrillic comments) |
| `gamedata/config/text/eng/**` | **UTF-8** (other languages), declaration `encoding="UTF-8"` |
| `gamedata/config/text/rus/**` | **Windows-1251**, declaration `encoding="windows-1251"` |
| Other text under `gamedata/**` (`.script`, `.ltx`, `.xml`, `.txt`, ...) | **Windows-1251** |

Pure ASCII is valid in both and needs no conversion. UTF-8 BOM is unwanted.

`tools/encoding/enc.ps1` is the only supported entry point:

```powershell
pwsh tools/encoding/enc.ps1 scan gamedata                     # audit the tree
pwsh tools/encoding/enc.ps1 detect <file>                     # classify one file
pwsh tools/encoding/enc.ps1 read <file> -Lines 40             # correct UTF-8 output
pwsh tools/encoding/enc.ps1 grep <dir> "<regex>" -Max 20      # mixed-encoding search
pwsh tools/encoding/enc.ps1 write <target> -FromPath <utf8>   # write in policy encoding
pwsh tools/encoding/enc.ps1 fix-xml gamedata -Write          # align XML declarations with bytes
pwsh tools/encoding/enc.ps1 convert <path> -Write -Backup     # re-encode with round-trip check
pwsh tools/encoding/enc.ps1 restore <ltx> -Reference <clean> -Write -Backup
```

- `detect` actions: `ok`, `convert-to-cp1251`, `convert-to-utf8`, `strip-bom`, `damaged`, `mojibake`, `review`.
- `convert` and `restore` are dry-runs unless `-Write` is passed. Writes are atomic and round-trip checked; lossy conversions are refused.
- `restore` recovers `U+FFFD`-lost LTX text from a clean reference by `[section]` + key, preserving current OLR values.
- When text is damaged beyond automatic repair, compare the same relative path against an upstream/vanilla gamedata tree or an older release. Never guess Russian text from context alone.

## 4. Repository map

### Gamedata

| Path | Responsibility |
| --- | --- |
| `gamedata/scripts/` | Lua 5.1 gameplay. `_g.script` is the global entry point; `bind_*` are binders; `se_*` / `sr_*` are server/client object parts; `xr_logic.script` and `xr_motivator.script` are the generic scheme and AI layers. Feature scripts are named by subsystem. |
| `gamedata/config/creatures/` | `actor.ltx`, stalker and monster configs, immunities, movement, senses. |
| `gamedata/config/weapons/` | `weapons.ltx`, `w_*.ltx`, ammo, upgrades, grenades. |
| `gamedata/config/misc/` | Items, artefacts, zones, devices, sound events. |
| `gamedata/config/gameplay/` | NPC profiles and levels, dialogs, supplies, simulation, infoportions. |
| `gamedata/config/environment/` | Weather, environment events, surge/blowout tuning. |
| `gamedata/config/ui/` | XML UI layouts. |
| `gamedata/config/text/rus/`, `text/eng/` | Localized strings: `rus` is CP1251, `eng` is UTF-8. |
| `gamedata/config/models/` | Model and destruction configs. |
| `gamedata/config/mp/` | Multiplayer configs. |
| `gamedata/config/pda_dialogs/` | PDA dialog data. |
| `gamedata/config/prefetch/`, `config/debug/` | Prefetch lists and debug/spawn menu configs. |
| `gamedata/config/scripts/` | **LTX state-machine definitions, not Lua scripts.** |
| `gamedata/ai/alife/`, `ai/common/` | ALife and AI `.efd` tables (probabilities, costs, effectiveness). |
| `gamedata/shaders/r1/` | Static D3D9 shaders. |
| `gamedata/shaders/r1a/` | ADVANCED R1 shaders. |
| `gamedata/shaders/r2/` | Deferred R2 shaders. |
| `gamedata/shaders/shared/` | Shared HLSL headers: `common.h`, `hmodel.h`, `sload.h`. |
| `gamedata/spawns/` | Spawn data; only `olr.spawn` is tracked, other spawn files are temporary. |
| `gamedata/levels/`, `meshes/`, `anims/`, `textures/`, `sounds/`, `lib/` | Binary assets and materials; do not edit without an explicit asset task. |

### Repository root

| Path | Responsibility |
| --- | --- |
| `bin/` | Built executables and DLLs. |
| `data/` | Runtime data and level resources. |
| `resources/` | SDK/tooling submodule (editors, build scripts, external sources). May be unavailable in a partial checkout. |
| `sources/` | SDK configuration files. |
| `patches/`, `import/`, `_packed/`, `Temp/` | Patch staging, import sources, packed output, temporary files. |
| `appdata/` | Local runtime data: logs, saves, screenshots, editor settings. |
| `start.cmd`, `start_drender.cmd` | Game launch: Release and DebugRender. |
| `_ae.cmd`, `_se.cmd`, `_le.cmd`, `_pe.cmd`, `__editor.cmd` | ActorEditor, ShaderEditor, LevelEditor, ParticleEditor, universal editor. |
| `fsgame.ltx`, `fs.ltx`, `compiler.ltx` | File-system and compiler path maps. |

## 5. Script conventions

- `scripts/` is Lua 5.1 gameplay. `_g.script` is the global entry point; `bind_*` are binders; `se_*` / `sr_*` are server/client object parts; `xr_logic.script` and `xr_motivator.script` are the generic scheme and AI layers.
- Feature scripts are named by subsystem. Do not rely on an exhaustive list: inspect neighbouring scripts and the matching LTX scheme in `config/scripts/` before adding or renaming a script.
- Persistent state is stored in xvars. New fields need a save/load path and a default for old saves; verify the current API in the scheme scripts and engine exports, not in stale documentation.
- Lua calls into C++ through Luabind. Verify signatures in the engine repository: `xray/xrGame/script_*_script.cpp` and `script_engine.cpp`.
- `lua_help.script` is outdated or absent; do not use it as an API reference.

## 6. Config conventions

- LTX sections inherit with `[section]:parent`; always check the include chain from `system.ltx` before assuming a value is final.
- `gamedata/config/scripts/` holds LTX state machines and smart-terrain logic. Lua scripts are only in `gamedata/scripts/`.
- The `encoding=` attribute in XML declarations is read by TinyXML. It **must match the bytes**: `windows-1251` for CP1251 files, `UTF-8` for English localization under `config/text/eng/`. A mismatch makes the parser fail or misread text. Use `enc.ps1 fix-xml` after conversion.
- Spawn editing: only `gamedata/spawns/olr.spawn` is tracked. Do not add temporary spawn files.
- A config change is incomplete until the affected values are checked in game by the user.

## 7. Shaders

- Shaders under `gamedata/shaders/` are UTF-8 and should stay UTF-8, including Cyrillic comments.
- `r1` and `r1a` are static pipelines, `r2` is deferred, `shared/` contains common headers.
- Shader names, defines and constant layouts must match the engine's `layers/xrRender_*` code; a shader change is coordinated with a separate engine commit.
- Bytecode cache is created by the game; never commit generated shader cache.

## 8. OpenSpec workflow

`openspec/specs/` is the accepted behavior baseline. Use a full OpenSpec change for large, risky, cross-cutting or contract-changing work; track small local features, fixes, small refactors and config/text work in git. Every task starts with a spec preflight, including git-only work.

```bash
openspec list --json                # active changes
openspec list --specs --json        # capability inventory
openspec show <capability> --type spec --json --no-scenarios
openspec status --change <id>       # artifact checklist and next step
openspec validate --all --strict    # must pass before archive
openspec archive <id> -y            # merge deltas and archive
```

Before the first edit:

1. Run `openspec list --json` and `openspec list --specs --json`.
2. Read the governing spec with `openspec show ...`; read the full spec only when it governs the task.
3. Query CBM (`search_graph`, `trace_path`, `get_file_outline`), then use `enc.ps1 grep` for CP1251 text and targeted `rg` only for literals or gaps.
4. State `Context: change=<id|none>; spec=<capability|none>; record=<openspec|git>; files=...; verification=...`.

Use a full change when the work is a large feature, cross-cutting script refactor, script or Luabind API change, new LTX/XML key or section, save-load change, encoding policy change, spawn/asset change, or any change to documented behavior. Use git only for small local features and fixes, small refactors of a couple of functions, config values/text, comments, formatting and encoding normalization that follows `gamedata-encoding`, provided they do not change a documented requirement, a config semantic or a public contract. If a small task grows or changes a contract, stop and create a full change before continuing. If a git-only feature becomes a supported behavior, capture it in a later full change. When unsure, use a full change.

Rules:

- One change per behavior: `openspec/changes/<verb>-<topic>/` with `proposal.md`, `specs/<capability>/spec.md` and `tasks.md`.
- Requirements and scenarios are written in English. Proposals and task notes may be Russian.
- Requirements use `### Requirement:` with at least one `#### Scenario:` containing WHEN/THEN.
- Encoding work must name source encoding, target encoding and the verification command, whether it is a full change or a git-only fix.
- Do not create an OpenSpec change for git-only work and do not edit `openspec/specs/` by hand; only archive merges deltas.
- The final task of a full change is user verification in game; git-only work names its local verification and asks the user to check in game when behavior is involved.

## 9. Supporting tools

Recommended for any user of this repository:

- **lemma** — durable project memory: https://github.com/xenitV1/lemma
- **codebase-memory-mcp** — local code graph over MCP: https://github.com/DeusData/codebase-memory-mcp

In this workspace they are already configured:

- **Code graph:** MCP server `cbm-gamedata`, project `Q-OLRDev-OLR`, root `Q:/OLRDev/OLR`. Index this repository root, not `gamedata/` (a nested project root breaks git-aware paths and the watcher). Only `gamedata/` is indexed; graph paths start with `gamedata/` and are case-sensitive. `.script` is indexed as Lua; XML and shaders are indexed. `*.ltx` and `*.ini` are excluded because the graph cannot parse them usefully. Use `search_graph`, `trace_path`, `get_code_snippet`, `get_file_outline` before broad scans; use `enc.ps1`/`rg` for config text. Check `index_status` and re-index after large changes with `index_repository`.
- **Exact text:** the graph is UTF-8 and does not replace the file. Read comments, Russian strings and CP1251 bytes with `enc.ps1 read`.
- **Memory:** lemma stores durable facts, bug patterns and rejected approaches. Save non-obvious findings; do not store trivia or secrets.
- OpenSpec is the source of truth; CBM and lemma only reduce discovery cost.

## 10. Run and verify

- The user runs the game (`start.cmd`, `start_drender.cmd`), `luac`, editors and packing tools by default. Run them only when the user explicitly asks for that specific command.
- The agent's definition of done is: files changed, encoding verified with `enc.ps1`, the governing spec named, OpenSpec tasks updated for a full change or the git commit described for git-only work, and a short verification request for the user.

## 11. Do not

- Do not write gamedata text in UTF-8, and do not convert shaders to CP1251.
- Do not edit `textures/`, `sounds/`, `meshes/`, `levels/` or `anims/` without an explicit asset task.
- Do not modify `*.bak`, `* — копия*` or generated caches.
- Do not shell-convert files with `>` / `Out-File`; use `enc.ps1`.
- Do not bypass the spec preflight: check specs and active changes before any edit. Large, risky or contract-changing work goes through an OpenSpec change; git-only work is recorded in the commit.
- Do not commit or push unless the user explicitly asks.
