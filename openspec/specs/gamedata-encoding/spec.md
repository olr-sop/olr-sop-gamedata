# gamedata-encoding Specification

## Purpose
Guarantee that every text file in the gamedata tree is stored in the correct encoding, that agents can read and search mixed encodings safely, and that already-damaged text is detected and repaired from a reference without corrupting gameplay values.

## Requirements

### Requirement: Encoding policy

The repository SHALL define one encoding target per area: `gamedata/shaders/**` is UTF-8; `gamedata/config/text/eng/**` is UTF-8; `gamedata/config/text/rus/**` and all other text under `gamedata/**` are Windows-1251.

#### Scenario: Shader source is UTF-8

- **WHEN** a shader file under `gamedata/shaders/` is created or edited
- **THEN** it is stored as UTF-8 and may contain Cyrillic comments

#### Scenario: Game data text is CP1251

- **WHEN** a `.script`, `.ltx`, `.xml` or other text file outside `shaders/` and `text/eng/` is created or edited
- **THEN** it is stored as Windows-1251 with no UTF-8 BOM

#### Scenario: Pure ASCII is accepted

- **WHEN** a text file contains only ASCII characters
- **THEN** the scanner accepts it without conversion because it is valid in both encodings

#### Scenario: English localization is UTF-8

- **WHEN** an XML file under `gamedata/config/text/eng/` is created or edited
- **THEN** it is stored as UTF-8 and its declaration says `encoding="UTF-8"`

#### Scenario: Russian localization is CP1251

- **WHEN** an XML file under `gamedata/config/text/rus/` is created or edited
- **THEN** it is stored as Windows-1251 and its declaration says `encoding="windows-1251"`

#### Scenario: XML declaration matches the bytes

- **WHEN** any gamedata XML file is saved or converted
- **THEN** its `encoding=` declaration names the encoding of the bytes, because TinyXML uses it to choose UTF-8 or legacy parsing

### Requirement: Safe text reading

The toolkit SHALL decode a text file according to its actual encoding and emit correct UTF-8 text, so callers never see mojibake from CP1251 files.

#### Scenario: Reading a CP1251 script

- **WHEN** the user reads `gamedata/scripts/xr_logic.script` through the toolkit
- **THEN** Russian strings and comments are printed as readable UTF-8 text

#### Scenario: Reading a limited range

- **WHEN** the user requests the first N lines or a regex match with context
- **THEN** only that range is printed, which keeps agent context small

### Requirement: Lossless conversion

The toolkit SHALL refuse to write a converted file unless decoding the encoded bytes reproduces the original text exactly.

#### Scenario: UTF-8 to CP1251 conversion

- **WHEN** a UTF-8 text file contains only characters representable in CP1251
- **THEN** the toolkit converts it to CP1251 and the round-trip check passes

#### Scenario: Lossy conversion is refused

- **WHEN** a file contains U+FFFD or another character that CP1251 cannot represent
- **THEN** the toolkit reports `LOSSY` and does not write the file unless `-Force` is given

### Requirement: Mixed-encoding search

The toolkit SHALL search text across files with different encodings in one pass, decoding each file according to its detected encoding.

#### Scenario: Searching scripts and configs together

- **WHEN** the user runs `grep` over `gamedata/scripts` or `gamedata/config`
- **THEN** matches from CP1251, UTF-8 and ASCII files are returned with relative path and line number

### Requirement: Damage detection

The toolkit SHALL classify files as `ascii`, `utf8`, `utf8-bom`, `cp1251`, `utf16`, `binary` or `empty`, and report lost characters (`U+FFFD`), suspicious `?` runs and mojibake markers separately.

#### Scenario: A file with lost text is reported

- **WHEN** `scan` or `detect` inspects a file containing U+FFFD
- **THEN** the file is reported as `damaged` with the number of lost characters

#### Scenario: Policy mismatch is reported

- **WHEN** a gamedata text file is UTF-8 but the policy target is CP1251
- **THEN** the file is reported with action `convert-to-cp1251`

### Requirement: Reference-based repair

The toolkit SHALL recover U+FFFD-damaged LTX text from a reference copy by matching `[section]` and key names, without overwriting OLR-specific values.

#### Scenario: Comments are restored from a clean reference

- **WHEN** a damaged LTX line contains a key with a lost comment and the reference has one matching key in the same section
- **THEN** the comment is restored and the current value is preserved

#### Scenario: Ambiguous lines are left untouched

- **WHEN** no unique reference line can be matched
- **THEN** the line is reported as unresolved instead of being guessed

### Requirement: Encoding conformance

Every text file under `gamedata/**` SHALL match the encoding policy, and the repository SHALL record a scan proving it.

#### Scenario: Full tree conforms

- **WHEN** `tools/encoding/enc.ps1 scan gamedata` runs after the change
- **THEN** no file is reported with action `convert-to-cp1251`, `convert-to-utf8` or `strip-bom`

#### Scenario: Lost text is either restored or recorded

- **WHEN** a file still contains U+FFFD after repair
- **THEN** the remaining lost characters are listed as unresolved in the change and the file is not silently converted

#### Scenario: Values are preserved

- **WHEN** a damaged LTX file is repaired from a reference
- **THEN** the current OLR values and keys remain unchanged and only comment text is restored
