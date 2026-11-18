# Encoding toolkit

One entry point for every text encoding problem in this repository:
`enc.ps1`. It reads and writes UTF-8 and Windows-1251 (CP1251) correctly,
detects already-damaged text, and converts files safely with a round-trip
check. No PowerShell profile or external module is required (PowerShell 5.1+
on Windows, `pwsh` 7+ recommended).

`enc.ps1` is written in pure ASCII and works in Windows PowerShell 5.1 and
PowerShell 7. If script execution is blocked in Windows PowerShell, run it with
`powershell -ExecutionPolicy Bypass -File tools/encoding/enc.ps1 ...`.

## Encoding policy

| Area | Encoding |
| --- | --- |
| `gamedata/shaders/**` (`.ps`, `.vs`, `.s`, `.h`) | **UTF-8** (preferred) |
| `gamedata/config/text/eng/**` (other languages) | **UTF-8**, declaration `encoding="UTF-8"` |
| `gamedata/config/text/rus/**` | **Windows-1251**, declaration `encoding="windows-1251"` |
| Other text under `gamedata/**` (`.script`, `.ltx`, `.xml`, `.txt`, ...) | **Windows-1251** |
| Everything else in the repo (`docs/`, `tools/`, markdown) | **UTF-8** |

Pure ASCII is valid in both encodings and is left alone. A UTF-8 BOM is
unwanted for shaders; the tool strips it on conversion.

## Commands

```powershell
# Aggregate report: encodings, policy mismatches, damaged files
pwsh tools/encoding/enc.ps1 scan gamedata

# Classify one file or a tree
pwsh tools/encoding/enc.ps1 detect gamedata/config/creatures/m_stalker.ltx -Json

# Read any file as correct UTF-8 (optionally only some lines / a regex)
pwsh tools/encoding/enc.ps1 read gamedata/scripts/xr_logic.script -Lines 40
pwsh tools/encoding/enc.ps1 read gamedata/config/defines.ltx -Pattern "money"

# Search mixed encodings without the two-pass ripgrep hack
pwsh tools/encoding/enc.ps1 grep gamedata/scripts "function .*actor" -Max 20

# Create or replace a file from a UTF-8 working copy
pwsh tools/encoding/enc.ps1 write gamedata/scripts/foo.script -FromPath $env:TEMP\edit.tmp -Backup

# Align XML declarations with the actual bytes/policy
pwsh tools/encoding/enc.ps1 fix-xml gamedata -Write -Backup

# Convert to the policy encoding; dry-run unless -Write is given
pwsh tools/encoding/enc.ps1 convert gamedata/config -Write -Backup

# Recover U+FFFD-damaged LTX text from a reference copy
pwsh tools/encoding/enc.ps1 restore <damaged.ltx> -Reference <clean.ltx> -Write -Backup
```

### Arbitrary text trees

`scan`, `detect` and `convert` accept `-AllText` to process every non-binary file
instead of a fixed extension list. This is how the engine repository was
converted to UTF-8. Binary extensions (`pdf`, images, binaries, archives) and
`*.bak` backups are always skipped. Files above 5 MiB are skipped in this mode.

Detection distinguishes CP1251 from Windows-1252 by looking for multi-letter
Cyrillic words. That keeps German/French names in vendored code intact while
still decoding Russian comments correctly.

### Safety

* `convert` and `restore` are **dry-runs by default**. Add `-Write` to apply.
* `-Backup` copies originals to `%TEMP%\olr-enc-backup\<timestamp>\` before writing.
* Every write is round-trip checked: if the target encoding cannot represent a
  character (for example U+FFFD or an emoji going to CP1251), the file is
  refused unless `-Force` is passed.
* Writes are atomic (temp file + rename).
* A UTF-8 BOM is preserved by default; `convert -StripBom -To utf8` removes it.
  Use `-Bom` when a UTF-8 source file must carry a BOM for MSVC (engine sources).
* The `encoding=` attribute in XML declarations is read by TinyXML. It must
  match the bytes: `windows-1251` for CP1251 files and `UTF-8` for English
  localization. `fix-xml` aligns it automatically; a mismatch breaks the parser.

### Damage model

* `U+FFFD` (`�`) means text was already lost during an earlier bad conversion.
  `restore` replaces damaged LTX comment/value lines from a reference file,
  matched by `[section]` + key, and leaves OLR-specific values untouched.
* `???` or a high density of `?` in a file that also contains Cyrillic is
  reported as `review`; those lines need a human or a reference diff.
* Classic Latin-1 mojibake (`Ð...`, `Ñ...`, `â€...`) is reported as `mojibake`.
  Such text is usually reversible, but review the result before committing.

### Repair workflow

1. `scan` the tree and pick `damaged` files.
2. Find a clean reference with the same relative path (upstream gamedata,
   an older repository snapshot, or a released script/config pack).
3. Run `restore` without `-Write`, review the reported unresolved lines.
4. Run `convert` to the policy encoding (CP1251 for LTX, UTF-8 for shaders).
5. `scan` again; the file must be `ok`.
6. Record the change in OpenSpec and commit only with the user's approval.

## Exit codes

`0` success, `1` usage or I/O error, `2` differences found (`convert` in a
future check mode). The script prints English-only diagnostics, so it behaves
the same on any Windows locale.
