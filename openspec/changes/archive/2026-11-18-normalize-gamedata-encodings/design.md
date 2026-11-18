# normalize-gamedata-encodings: Design

## Context

The baseline scan (`tools/encoding/BASELINE.md`) separates four problems:

1. 54 gamedata text files outside `config/text/eng` are valid UTF-8 but the policy requires CP1251.
2. 3 shader headers are CP1251 but the policy requires UTF-8.
3. 8 LTX files contain 9,000+ characters replaced by `U+FFFD` and have a clean CP1251 reference with the same relative path.
4. 3 files have lost text without an automatic reference match: `w_hands_gravity.ltx`, `character_desc_simulation.xml`, `waterconfig.h`.

The conversion tool already verifies round-trips and refuses lossy writes. The open question is ordering and how to avoid changing behavior while repairing text.

## Decisions

### D1: Tool-driven, never ad-hoc conversion

Every write goes through `tools/encoding/enc.ps1`. No `Get-Content | Set-Content`, no `>` redirection. This guarantees detection, round-trip verification, atomic writes and backups.

### D2: XML declarations must match the bytes

TinyXML reads the `encoding=` attribute. `UTF-8` makes it parse the bytes as
UTF-8; any other value is treated as a legacy single-byte encoding. Therefore
CP1251 XML declares `windows-1251`, English localization declares `UTF-8`, and
`enc.ps1 fix-xml` keeps every declaration aligned with the file.

### D3: Order of operations

1. Commit or back up the pre-change state.
2. Convert the 3 CP1251 shader headers to UTF-8 (small, isolated).
3. Convert the 54 plain UTF-8 files in non-English areas to CP1251, and the 15 Windows-1252 English XML files to UTF-8 (`config/text/eng`), one area at a time (`config/ui`, `config/gameplay`, `config/misc`, ...).
4. Restore the 8 damaged LTX files from references, then convert each to CP1251.
5. Repair the 3 manual files.
6. Re-scan and review every `review`/`damaged` entry.

Converting before restoring keeps the restore step focused on text, not encoding.

### D4: Restore comments, never values

`restore` matches `[section]` and key name and copies only the reference comment text. Current values, keys, indentation of the value and OLR-specific sections stay untouched. If a key has several reference candidates, the line is left unresolved rather than guessed.

### D5: Encoding is the only allowed diff

The diff for each converted file must be explainable as:
- byte-level re-encoding of the same characters, and/or
- restored comment text from a reference.

Any changed numeric value, section name, key or script identifier is a defect of the change, not a side effect.

### D6: Manual repairs are explicit

`w_hands_gravity.ltx` (549 lost characters), `character_desc_simulation.xml` (17) and `waterconfig.h` (36) have no automatic reference. They get a hand-written replacement from a reference tree or a translated reconstruction, reviewed as normal content. They are never bulk-converted with `-Force`.

## Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| Reference comment describes a value OLR has changed | Only comments are copied; values stay current. Spot-check sections with changed values. |
| A file is valid UTF-8 but intentionally used as UTF-8 by the engine | Policy check: only shaders and `config/text/eng/**` are UTF-8. XML declarations are aligned with the bytes. User verifies UI strings in game. |
| BOM remains in a converted file | `scan` reports `strip-bom`; `convert` removes it. |
| A lossy conversion silently drops a character | Round-trip check refuses unless `-Force`. |
| Wrong file converted outside scope | Tasks name file groups; `scan` diff before/after; backup in `%TEMP%`. |

## Rollback

- Prefer a Git commit before step 1; `git revert` restores the exact bytes.
- `-Backup` copies originals to `%TEMP%\olr-enc-backup\<timestamp>\<relative-path>`.
- No generated artifact or cache is part of the change.

## Out of scope

- Engine repository changes.
- Gameplay values, balance, script logic, LTX key names.
- Binary assets (`textures`, `sounds`, `meshes`, `levels`, `anims`).
- Files without a reference: they are repaired manually or remain documented as unresolved.

## Acceptance

The change is done when:

- `enc.ps1 scan gamedata` reports no `convert-to-*`, `strip-bom`, `damaged` or `mojibake` action;
- every remaining `review` entry is documented;
- `openspec validate --all --strict` passes;
- the user has verified the affected UI/dialog/config areas in game.
