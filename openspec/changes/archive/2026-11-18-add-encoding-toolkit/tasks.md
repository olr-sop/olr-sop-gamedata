# add-encoding-toolkit: Tasks

## 1. Tooling

- [x] 1.1. Add `tools/encoding/enc.ps1` with `scan`, `detect`, `read`, `grep`, `convert`, `restore`.
- [x] 1.2. Keep the script pure ASCII so Windows PowerShell 5.1 and PowerShell 7 parse it identically.
- [x] 1.3. Make `convert` and `restore` dry-run by default, atomic on write, with optional backups.
- [x] 1.4. Add round-trip verification and refuse lossy conversions.
- [x] 1.5. Add `tools/encoding/README.md` with policy, examples and repair workflow.

## 2. Verification

- [x] 2.1. `read` and `grep` return correct Cyrillic from CP1251 files.
- [x] 2.2. `convert` converts a UTF-8 LTX copy to CP1251 with a clean round-trip.
- [x] 2.3. `convert` refuses a damaged file that contains U+FFFD.
- [x] 2.4. `restore` recovers comments on a copy of `m_stalker.ltx` and reports unresolved lines.
- [x] 2.5. Generate `tools/encoding/BASELINE.md` from `scan`.

## 3. Integration

- [x] 3.1. Reference the toolkit and the encoding policy from `AGENTS.md`.
- [x] 3.2. Reference the toolkit from `openspec/config.yaml`.
- [x] 3.3. Validate the change with `openspec validate add-encoding-toolkit --strict`.

## 4. Follow-up

- [ ] 4.1. Normalize existing files in the separate `normalize-gamedata-encodings` change.
