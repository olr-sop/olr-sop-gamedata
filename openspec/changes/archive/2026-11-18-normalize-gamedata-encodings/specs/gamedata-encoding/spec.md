# normalize-gamedata-encodings Delta: gamedata-encoding

## MODIFIED Requirements

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

## ADDED Requirements

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
