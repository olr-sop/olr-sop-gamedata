# normalize-gamedata-encodings: Proposal

## Why

The new encoding policy is not yet applied to the tree. The baseline scan finds:

- 54 text files stored as UTF-8 that belong to CP1251 areas;
- 15 English XML files stored as Windows-1252, which is not a gamedata encoding;
- 3 shader files stored as CP1251 that should be UTF-8;
- 11 files with 10,187 characters already replaced by U+FFFD (lost Russian text);
- 7 files that need a human look at `?` runs or special-character damage.

Until these are fixed, the game may show garbled text and every agent reads or writes the affected files differently.

## What Changes

- Convert the non-English gamedata text to CP1251 (UTF-8 and Windows-1252 sources) and the 3 shader files to UTF-8 with `tools/encoding/enc.ps1 convert`.
- Convert every `config/text/eng/*.xml` to UTF-8.
- Align all XML declarations with the bytes (`fix-xml`): `windows-1251` for CP1251, `UTF-8` for English localization.
- Restore the 8 damaged LTX files that have a matching clean reference with `enc.ps1 restore`, then convert them to CP1251.
- Repair `w_hands_gravity.ltx`, `waterconfig.h`, `character_desc_simulation.xml`, `vent_destroy.ltx`, `ammo.ltx` and the three Windows-1252 XML files manually or from a reference.
- Re-run `scan` and replace `tools/encoding/BASELINE.md` with a clean snapshot.
- Do not change gameplay values, script logic or LTX keys. Only the byte encoding, declarations and lost comments may change.

## Impact

- `gamedata/config/**`, `gamedata/scripts/**` and `gamedata/shaders/**`: encoding-only changes plus restored comments; English localization under `config/text/eng/**` stays/becomes UTF-8.
- No engine changes.
- Save compatibility is unaffected: script identifiers, LTX keys and values stay identical.
- Review risk: restored comments come from an older reference and may describe a value that OLR has since changed. Values are never copied from the reference.
