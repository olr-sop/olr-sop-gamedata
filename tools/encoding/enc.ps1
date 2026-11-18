<#
.SYNOPSIS
  Encoding toolkit for the OLR gamedata tree (UTF-8 / Windows-1251).

.DESCRIPTION
  One entry point for reading, searching, converting and repairing mixed-encoding
  text without corrupting Cyrillic. Intended for both humans and coding agents.

  Policy (relative to the repository root):
    gamedata/shaders/**  -> UTF-8 (preferred)
    gamedata/**          -> Windows-1251 (CP1251)
    everything else      -> UTF-8

  Commands:
    scan      Aggregate encoding/damage report for a tree.
    detect    Classify files (encoding, damage, policy mismatch).
    read      Print a file decoded correctly, optionally filtered by regex.
    grep      Regex search across mixed encodings, decoded correctly.
    convert   Convert files to their policy encoding (dry-run by default).
    restore   Recover U+FFFD-lost text from a reference file (LTX comments).

  Exit codes: 0 = ok, 1 = usage/error, 2 = differences found in check mode.

.EXAMPLE
  pwsh tools/encoding/enc.ps1 scan gamedata
  pwsh tools/encoding/enc.ps1 detect gamedata/config/creatures/m_stalker.ltx
  pwsh tools/encoding/enc.ps1 read gamedata/scripts/xr_logic.script -Lines 40
  pwsh tools/encoding/enc.ps1 grep "function .*actor" gamedata/scripts -Max 20
  pwsh tools/encoding/enc.ps1 convert gamedata/config -Write -Backup
  pwsh tools/encoding/enc.ps1 restore gamedata/config/creatures/m_stalker.ltx `
      -Reference ..\..\..\ORIG\config\creatures\m_stalker.ltx -Write -Backup
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Command = 'help',
    [Parameter(Position = 1)][string]$Target = '',
    [Parameter(Position = 2)][string]$Pattern = '',

    [string]$RepoRoot = '',
    [string[]]$Extensions = @(),
    [switch]$Recurse,
    [switch]$Json,
    [int]$Lines = 0,
    [int]$Context = 2,
    [int]$Max = 200,
    [string]$OutFile = '',
    [string]$FromPath = '',
    [string]$Exclude = '',
    [ValidateSet('auto', 'utf8', 'utf8bom', 'cp1251')][string]$Encoding = 'auto',
    [ValidateSet('auto', 'utf8', 'cp1251')][string]$To = 'auto',
    [switch]$Write,
    [switch]$Force,
    [switch]$Backup,
    [switch]$StripBom,
    [switch]$Bom,
    [switch]$AllText,
    [switch]$IncludeQuestionMarks,
    [string]$Reference = ''
)

$ErrorActionPreference = 'Stop'
try { [Text.Encoding]::RegisterProvider([Text.CodePagesEncodingProvider]::Instance) } catch { }
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:Utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$script:Cp1251 = [Text.Encoding]::GetEncoding(1251)
$script:Cp1252 = [Text.Encoding]::GetEncoding(1252)
$script:AllTextFlag = $AllText.IsPresent
$script:ExcludePattern = $Exclude
$script:CopySuffix = -join ([char]0x043A, [char]0x043E, [char]0x043F, [char]0x0438, [char]0x044F)
$script:BinaryExtensions = @(
    '.pdf', '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tga', '.dds', '.ico',
    '.exe', '.dll', '.lib', '.obj', '.pdb', '.ilk', '.exp', '.res', '.so',
    '.a', '.o', '.class', '.jar', '.zip', '.rar', '.7z', '.gz', '.tar',
    '.pak', '.bin', '.woff', '.woff2', '.ttf', '.otf', '.mp3', '.ogg', '.wav'
)
$script:DefaultExtensions = @(
    '.script', '.ltx', '.xml', '.txt', '.ini', '.cfg', '.md', '.json',
    '.yaml', '.yml', '.lua', '.csv', '.def', '.h', '.ps', '.vs', '.s'
)
$script:Utf8BomBytes = [byte[]](0xEF, 0xBB, 0xBF)

if (-not $RepoRoot) {
    # Locate the repository root by walking up until a gamedata directory is found.
    # This keeps the script usable from OLR/encoding or any future location.
    $candidate = $PSScriptRoot
    while ($candidate) {
        if (Test-Path -LiteralPath (Join-Path $candidate 'gamedata')) { $RepoRoot = $candidate; break }
        $parent = Split-Path -Path $candidate -Parent
        if (-not $parent -or $parent -eq $candidate) { break }
        $candidate = $parent
    }
    if (-not $RepoRoot) { $RepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')) }
}
$RepoRoot = [IO.Path]::GetFullPath($RepoRoot)

function Write-Utf8([string]$Text) {
    $script:Utf8NoBom.GetString($script:Utf8NoBom.GetBytes($Text))
}

function Get-NormPath([string]$Path) {
    [IO.Path]::GetFullPath($Path).Replace('\', '/')
}

function Get-RelPath([string]$FullPath) {
    $p = Get-NormPath $FullPath
    $r = (Get-NormPath $RepoRoot).TrimEnd('/')
    if ($p.StartsWith($r + '/', [StringComparison]::OrdinalIgnoreCase)) {
        return $p.Substring($r.Length + 1)
    }
    return $p
}

function Get-PolicyEncoding([string]$FullPath) {
    $rel = (Get-RelPath $FullPath).ToLowerInvariant()
    if ($rel -match '^gamedata/shaders/') { return 'utf8' }
    if ($rel -match '^gamedata/config/text/eng/') { return 'utf8' }
    if ($rel -match '^gamedata/') { return 'cp1251' }
    return 'utf8'
}

function Get-TargetEncodingObject([string]$Name) {
    switch ($Name) {
        'utf8' { return New-Object System.Text.UTF8Encoding($false) }
        'utf8bom' { return New-Object System.Text.UTF8Encoding($true) }
        'cp1251' { return $script:Cp1251 }
        default { throw "Unknown encoding: $Name" }
    }
}

function Get-MojibakeCount([string]$Text) {
    # Build patterns from code points so this script stays pure ASCII and is
    # parsed identically by Windows PowerShell 5.1 and PowerShell 7.
    # Only unambiguous Latin-1/Windows-1252 mojibake markers are counted;
    # Cyrillic look-alike sequences produce false positives in normal Russian.
    $latin = '[' + [char]0x00D0 + [char]0x00D1 + [char]0x00C3 + [char]0x00C2 + ']'
    $seq = @(
        ([string][char]0x00E2 + [char]0x20AC),
        ([string][char]0x0420 + [char]0x040E),
        ([string][char]0x0421 + [char]0x201A),
        ([string][char]0x0421 + [char]0x0402)
    ) | ForEach-Object { [regex]::Escape($_) }
    $n = ([regex]::Matches($Text, $latin)).Count
    $n += ([regex]::Matches($Text, ($seq -join '|'))).Count
    return $n
}

function Get-FileInfo([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    $policy = Get-PolicyEncoding $full
    $bytes = [IO.File]::ReadAllBytes($full)
    $enc = ''
    $text = ''
    $hasNul = $false
    $limit = [Math]::Min($bytes.Length, 8192)
    for ($i = 0; $i -lt $limit; $i++) {
        if ($bytes[$i] -eq 0) { $hasNul = $true; break }
    }

    if ($bytes.Length -eq 0) {
        $enc = 'empty'
    }
    elseif ($hasNul) {
        $enc = 'binary'
    }
    elseif ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $enc = 'utf8-bom'
        $text = $script:Utf8NoBom.GetString($bytes, 3, $bytes.Length - 3)
    }
    elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        $enc = 'utf16le'
        $text = [Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
    }
    elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        $enc = 'utf16be'
        $text = [Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2)
    }
    else {
        $hasHigh = $false
        for ($i = 0; $i -lt $bytes.Length; $i++) { if ($bytes[$i] -ge 0x80) { $hasHigh = $true; break } }
        try {
            $text = $script:Utf8Strict.GetString($bytes)
            if ($hasHigh) { $enc = 'utf8' } else { $enc = 'ascii' }
        }
        catch {
            $cpText = $script:Cp1251.GetString($bytes)
            # Russian text contains multi-letter Cyrillic words. A lone accented
            # Latin-1 character decoded as CP1251 becomes one Cyrillic letter,
            # so require at least one 2+ letter sequence before choosing CP1251.
            $cyrWords = ([regex]::Matches($cpText, '[\u0400-\u04FF]{2,}')).Count
            if ($cyrWords -gt 0) {
                $enc = 'cp1251'
                $text = $cpText
            }
            elseif ($policy -eq 'cp1251') {
                # Gamedata is CP1251 by policy; ambiguous punctuation such as
                # byte 0xB9 means № in CP1251 and ¹ in CP1252.
                $enc = 'cp1251'
                $text = $cpText
            }
            else {
                $enc = 'cp1252'
                $text = $script:Cp1252.GetString($bytes)
            }
        }
    }

    if ($enc -in @('binary', 'empty')) {
        return [pscustomobject]@{
            Path = $full; RelPath = (Get-RelPath $full); Bytes = $bytes.Length
            Encoding = $enc; Target = (Get-PolicyEncoding $full); Action = 'skip'
            Lost = 0; QuestionRuns = 0; Mojibake = 0; Cyrillic = 0; Text = ''
        }
    }

    $lost = ([regex]::Matches($text, [string][char]0xFFFD)).Count
    $qm = ([regex]::Matches($text, '\?{3,}')).Count
    $qCount = ([regex]::Matches($text, '\?')).Count
    $moji = Get-MojibakeCount $text
    $cyr = ([regex]::Matches($text, '[\u0400-\u04FF]')).Count
    $suspect = ($qm -gt 0 -and $cyr -gt 0)
    $target = $policy

    $action = 'ok'
    if ($lost -gt 0) { $action = 'damaged' }
    elseif ($moji -gt 0) { $action = 'mojibake' }
    elseif ($suspect) { $action = 'review' }
    elseif ($enc -eq 'utf8-bom' -and $target -eq 'utf8') { $action = 'strip-bom' }
    elseif ($enc -ne 'ascii' -and $enc -ne $target) { $action = "convert-to-$target" }

    [pscustomobject]@{
        Path = $full; RelPath = (Get-RelPath $full); Bytes = $bytes.Length
        Encoding = $enc; Target = $target; Action = $action
        Lost = $lost; QuestionRuns = $qm; QuestionMarks = $qCount
        Mojibake = $moji; Cyrillic = $cyr; Text = $text
    }
}

function Get-TextFiles([string]$Path, [string[]]$Exts, [bool]$DoRecurse) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "Path not found: $Path" }
    $item = Get-Item -LiteralPath $Path
    if (-not $item.PSIsContainer) { return @($item) }
    if ($Exts.Count -eq 0) { $Exts = $script:DefaultExtensions }
    $rootFull = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    $files = Get-ChildItem -LiteralPath $Path -File -Recurse:$DoRecurse -ErrorAction SilentlyContinue |
        Where-Object {
            $full = $_.FullName
            $rel = $full.Substring($rootFull.Length).TrimStart('\', '/')
            $full -notmatch '\\\.git\\|\\node_modules\\' -and
            -not ($script:ExcludePattern -and $full -match $script:ExcludePattern) -and
            $rel -notmatch '^(bin|obj|\.vs|ipch)(\\|/|$)' -and
            $_.Name -notlike '*.bak' -and
            $_.Name -notmatch [regex]::Escape($script:CopySuffix) -and
            $script:BinaryExtensions -notcontains $_.Extension.ToLowerInvariant() -and
            ($script:AllTextFlag -or $Exts -contains $_.Extension.ToLowerInvariant())
        }
    if ($script:AllTextFlag) {
        $files = @($files | Where-Object { $_.Length -le 5242880 })
    }
    return @($files)
}

function Get-Newline([string]$Text) {
    if ($Text -match "`r`n") { return "`r`n" }
    return "`n"
}

function Write-Atomic([string]$Path, [byte[]]$Bytes) {
    $dir = [IO.Path]::GetDirectoryName($Path)
    $tmp = Join-Path $dir ('.enc-tmp-' + [guid]::NewGuid().ToString('N'))
    [IO.File]::WriteAllBytes($tmp, $Bytes)
    Move-Item -LiteralPath $tmp -Destination $Path -Force
}

function Save-Backup([string]$Path) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $root = Join-Path ([IO.Path]::GetTempPath()) ('olr-enc-backup\' + $stamp)
    $rel = (Get-RelPath $Path)
    if ($rel -match '^[A-Za-z]:') { $rel = $rel.Substring(0, 1) + $rel.Substring(2) }
    $rel = $rel.Replace(':', '_').Replace('/', '\').TrimStart('\')
    $dest = Join-Path $root $rel
    $dir = [IO.Path]::GetDirectoryName($dest)
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item -LiteralPath $Path -Destination $dest -Force
    return $dest
}

function Show-Help() {
    @'
enc.ps1 - encoding toolkit for OLR gamedata

Usage:
  enc.ps1 scan     [path] [-Extensions .ltx,.script] [-AllText] [-Exclude regex] [-Json] [-OutFile report.txt]
  enc.ps1 detect   <path...> [-AllText] [-Exclude regex] [-Json]
  enc.ps1 read     <path> [-Lines N] [-Pattern regex] [-Context N] [-OutFile utf8.txt]
  enc.ps1 grep     <path> <regex> [-Extensions .script,.ltx] [-Context N] [-Max N] [-Json]
  enc.ps1 write    <target> -FromPath <utf8-source> [-To auto|utf8|cp1251] [-Backup] [-Force]
  enc.ps1 fix-xml  <path> [-Write] [-Backup]
  enc.ps1 convert  <path> [-To auto|utf8|cp1251] [-Write] [-Backup] [-Bom| -StripBom] [-AllText] [-Force] [-Json]
  enc.ps1 restore  <file> -Reference <file> [-Write] [-Backup] [-IncludeQuestionMarks] [-Json]

Policy: gamedata/shaders/** -> UTF-8; other gamedata text -> CP1251; rest -> UTF-8.
Dry-run is the default for convert and restore. -Write applies changes.
'@
}

function Invoke-Detect {
    $files = Get-TextFiles $Target $Extensions $true
    $rows = @()
    foreach ($f in $files) { $rows += Get-FileInfo $f.FullName }
    if ($Json) {
        $rows | Select-Object RelPath, Encoding, Target, Action, Lost, QuestionRuns, Mojibake, Cyrillic, Bytes |
            ConvertTo-Json -Depth 4
        return
    }
    $rows | Sort-Object RelPath | ForEach-Object {
        '{0,-12} {1,-10} {2,-14} lost={3,-5} q={4,-3} moji={5,-4} cyr={6,-6} {7}' -f `
            $_.Encoding, $_.Target, $_.Action, $_.Lost, $_.QuestionRuns, $_.Mojibake, $_.Cyrillic, $_.RelPath
    }
}

function Invoke-Scan {
    $path = $Target
    if (-not $path) { $path = Join-Path $RepoRoot 'gamedata' }
    $files = Get-TextFiles $path $Extensions $true
    $rows = @()
    foreach ($f in $files) { $rows += Get-FileInfo $f.FullName }
    $result = [pscustomobject]@{
        Root = (Get-NormPath $path)
        TotalFiles = $rows.Count
        ByEncoding = @($rows | Group-Object Encoding | Sort-Object Count -Descending | ForEach-Object { [pscustomobject]@{ Encoding = $_.Name; Count = $_.Count } })
        ByExtension = @($rows | Where-Object { $_.RelPath.LastIndexOf('.') -gt 0 } | Group-Object { $_.RelPath.Substring($_.RelPath.LastIndexOf('.')) } | Sort-Object Name | ForEach-Object {
            [pscustomobject]@{ Extension = $_.Name; Total = $_.Count; Utf8 = @($_.Group | Where-Object Encoding -match 'utf8').Count; Cp1251 = @($_.Group | Where-Object Encoding -eq 'cp1251').Count; Ascii = @($_.Group | Where-Object Encoding -eq 'ascii').Count; Damaged = @($_.Group | Where-Object Lost -gt 0).Count }
        })
        Actions = @($rows | Group-Object Action | Sort-Object Count -Descending | ForEach-Object { [pscustomobject]@{ Action = $_.Name; Count = $_.Count } })
        Damaged = @($rows | Where-Object { $_.Lost -gt 0 } | Sort-Object Lost -Descending | Select-Object -First 50 | ForEach-Object { [pscustomobject]@{ File = $_.RelPath; Encoding = $_.Encoding; Lost = $_.Lost; QuestionRuns = $_.QuestionRuns } })
        PolicyMismatch = @($rows | Where-Object { $_.Action -like 'convert-to-*' -or $_.Action -eq 'strip-bom' } | Select-Object -First 200 | ForEach-Object { [pscustomobject]@{ File = $_.RelPath; Encoding = $_.Encoding; Target = $_.Target; Action = $_.Action } })
        Review = @($rows | Where-Object { $_.Action -eq 'review' -or $_.Action -eq 'mojibake' } | Select-Object -First 200 | ForEach-Object { [pscustomobject]@{ File = $_.RelPath; Action = $_.Action; Mojibake = $_.Mojibake; QuestionRuns = $_.QuestionRuns } })
    }

    $text = @()
    $text += "Encoding scan: $($result.Root)"
    $text += "Total text files: $($result.TotalFiles)"
    $text += ''
    $text += 'By encoding:'
    foreach ($g in $result.ByEncoding) { $text += ('  {0,-10} {1,6}' -f $g.Encoding, $g.Count) }
    $text += ''
    $text += 'By extension:'
    foreach ($g in $result.ByExtension) { $text += ('  {0,-8} total={1,-5} utf8={2,-5} cp1251={3,-5} ascii={4,-5} damaged={5}' -f $g.Extension, $g.Total, $g.Utf8, $g.Cp1251, $g.Ascii, $g.Damaged) }
    $text += ''
    $text += 'Actions:'
    foreach ($g in $result.Actions) { $text += ('  {0,-20} {1}' -f $g.Action, $g.Count) }
    $text += ''
    $text += 'Damaged files (U+FFFD lost text):'
    if ($result.Damaged.Count -eq 0) { $text += '  none' }
    foreach ($d in $result.Damaged) { $text += ('  {0,6} lost  {1,-9} {2}' -f $d.Lost, $d.Encoding, $d.File) }
    $text += ''
    $text += 'Policy mismatches (convert):'
    if ($result.PolicyMismatch.Count -eq 0) { $text += '  none' }
    foreach ($m in $result.PolicyMismatch) { $text += ('  {0,-10} -> {1,-8} {2}' -f $m.Encoding, $m.Target, $m.File) }
    $text += ''
    $text += 'Needs review (mojibake or ???):'
    if ($result.Review.Count -eq 0) { $text += '  none' }
    foreach ($r in $result.Review) { $text += ('  {0,-10} {1,-9} {2}' -f $r.Action, $r.Encoding, $r.File) }

    if ($OutFile) {
        [IO.File]::WriteAllText([IO.Path]::GetFullPath($OutFile), ($text -join "`r`n"), $script:Utf8NoBom)
    }
    if ($Json) { $result | ConvertTo-Json -Depth 6 } else { $text }
}

function Invoke-Read {
    if (-not $Target) { throw 'read: path is required' }
    $files = Get-TextFiles $Target $Extensions $true
    $multi = $files.Count -gt 1
    foreach ($f in $files) {
        $info = Get-FileInfo $f.FullName
        if ($info.Encoding -in @('binary', 'empty')) { continue }
        $fileLines = $info.Text -split "\r?\n"
        $selected = @()
        if ($Pattern) {
            for ($i = 0; $i -lt $fileLines.Count; $i++) {
                if ($fileLines[$i] -match $Pattern) {
                    $start = [Math]::Max(0, $i - $Context)
                    $end = [Math]::Min($fileLines.Count - 1, $i + $Context)
                    for ($j = $start; $j -le $end; $j++) { $selected += [pscustomobject]@{ Index = $j; Text = $fileLines[$j] } }
                }
            }
            $selected = @($selected | Sort-Object Index -Unique)
        }
        else {
            $count = $fileLines.Count
            if ($Lines -gt 0) { $count = [Math]::Min($Lines, $fileLines.Count) }
            for ($i = 0; $i -lt $count; $i++) { $selected += [pscustomobject]@{ Index = $i; Text = $fileLines[$i] } }
        }
        $out = @()
        foreach ($row in $selected) {
            if ($multi) { $out += ('{0}:{1}: {2}' -f $info.RelPath, ($row.Index + 1), $row.Text) }
            else { $out += ('{0}: {1}' -f ($row.Index + 1), $row.Text) }
        }
        if ($OutFile) {
            $body = ($selected | ForEach-Object { $_.Text }) -join "`r`n"
            [IO.File]::WriteAllText([IO.Path]::GetFullPath($OutFile), $body, $script:Utf8NoBom)
        }
        else {
            $out
        }
    }
}

function Invoke-Grep {
    if (-not $Target -or -not $Pattern) { throw 'grep: path and pattern are required' }
    $files = Get-TextFiles $Target $Extensions $true
    $total = 0
    $rows = @()
    foreach ($f in $files) {
        $info = Get-FileInfo $f.FullName
        if ($info.Encoding -in @('binary', 'empty')) { continue }
        $fileLines = $info.Text -split "\r?\n"
        for ($i = 0; $i -lt $fileLines.Count; $i++) {
            if ($fileLines[$i] -match $Pattern) {
                $rows += [pscustomobject]@{ File = $info.RelPath; Line = ($i + 1); Text = $fileLines[$i] }
                $total++
                if ($total -ge $Max) { break }
            }
        }
        if ($total -ge $Max) { break }
    }
    if ($Json) { $rows | ConvertTo-Json -Depth 3; return }
    foreach ($r in $rows) { '{0}:{1}: {2}' -f $r.File, $r.Line, $r.Text }
    if ($total -ge $Max) { "--- truncated at $Max matches ---" }
}

function Update-XmlDeclaration([string]$Text, [string]$Path, [string]$Target) {
    if ([IO.Path]::GetExtension($Path).ToLowerInvariant() -ne '.xml') { return $Text }
    $label = if ($Target -eq 'utf8' -or $Target -eq 'utf8bom') { 'UTF-8' } else { 'windows-1251' }
    $pattern = '(?i)(<\?xml[^>]*encoding\s*=\s*["''])([^"'']+)(["''])'
    if ($Text -match $pattern) {
        return [regex]::Replace($Text, $pattern, ('${1}' + $label + '${3}'), 1)
    }
    return $Text
}

function Invoke-FixXml {
    if (-not $Target) { throw 'fix-xml: path is required' }
    $files = Get-TextFiles $Target $Extensions $true | Where-Object { $_.Extension.ToLowerInvariant() -eq '.xml' }
    $changed = 0
    foreach ($f in $files) {
        $info = Get-FileInfo $f.FullName
        if ($info.Encoding -in @('binary', 'empty')) { continue }
        $policy = Get-PolicyEncoding $f.FullName
        $declTarget = if ($info.Encoding -eq 'ascii') { $policy } else { $info.Encoding }
        $normalized = Update-XmlDeclaration $info.Text $f.FullName $declTarget
        if ($normalized -eq $info.Text) { continue }
        $encObj = if ($info.Encoding -eq 'ascii') { [Text.Encoding]::ASCII } else { Get-TargetEncodingObject $info.Encoding }
        $bytes = $encObj.GetBytes($normalized)
        $back = $encObj.GetString($bytes)
        if ($back -ne $normalized) { "LOSSY: $($info.RelPath)"; continue }
        $changed++
        "FIX XML: $($info.RelPath) -> $declTarget"
        if ($Write) {
            if ($Backup) { $null = Save-Backup $f.FullName }
            Write-Atomic $f.FullName $bytes
        }
    }
    "Summary: fixed=$changed mode=$(if ($Write) { 'write' } else { 'dry-run' })"
}

function Invoke-WriteFile {
    if (-not $Target -or -not $FromPath) { throw 'write: target path and -FromPath are required' }
    if (-not (Test-Path -LiteralPath $FromPath)) { throw "write: source not found: $FromPath" }
    $srcBytes = [IO.File]::ReadAllBytes([IO.Path]::GetFullPath($FromPath))
    $offset = 0
    if ($srcBytes.Length -ge 3 -and $srcBytes[0] -eq 0xEF -and $srcBytes[1] -eq 0xBB -and $srcBytes[2] -eq 0xBF) { $offset = 3 }
    try { $text = $script:Utf8Strict.GetString($srcBytes, $offset, $srcBytes.Length - $offset) }
    catch { throw "write: -FromPath must be valid UTF-8: $FromPath" }

    $dest = if ($To -eq 'auto') { Get-PolicyEncoding $Target } else { $To }
    $text = Update-XmlDeclaration $text $Target $dest
    $encObj = Get-TargetEncodingObject $dest
    $bytes = $encObj.GetBytes($text)
    if ($Bom -and $dest -eq 'utf8') {
        $withBom = New-Object byte[] ($bytes.Length + 3)
        $withBom[0] = 0xEF; $withBom[1] = 0xBB; $withBom[2] = 0xBF
        [Array]::Copy($bytes, 0, $withBom, 3, $bytes.Length)
        $bytes = $withBom
    }
    $back = $encObj.GetString($bytes)
    if ($Bom -and $dest -eq 'utf8') { $back = $back.TrimStart([char]0xFEFF) }
    if ($back -ne $text -and -not $Force) {
        throw "write: target encoding $dest cannot represent the text without loss (use -Force to override)"
    }
    if ($Backup -and (Test-Path -LiteralPath $Target)) { $null = Save-Backup $Target }
    $fullTarget = [IO.Path]::GetFullPath($Target)
    $dir = [IO.Path]::GetDirectoryName($fullTarget)
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Write-Atomic $fullTarget $bytes
    "WROTE: $(Get-RelPath $fullTarget) [$dest] bytes=$($bytes.Length)"
}

function Invoke-Convert {
    if (-not $Target) { throw 'convert: path is required' }
    $files = Get-TextFiles $Target $Extensions $true
    $changed = 0; $skipped = 0; $lossy = 0
    foreach ($f in $files) {
        $info = Get-FileInfo $f.FullName
        if ($info.Encoding -in @('binary', 'empty')) { $skipped++; continue }
        $dest = if ($To -eq 'auto') { $info.Target } else { $To }
        $hasBom = $info.Encoding -eq 'utf8-bom'
        $srcIsTarget = $info.Encoding -eq $dest -or
            ($info.Encoding -eq 'ascii' -and ($dest -eq 'cp1251' -or $dest -eq 'utf8')) -or
            ($hasBom -and $dest -eq 'utf8')
        if ($srcIsTarget -and -not ($StripBom -and $dest -eq 'utf8' -and $hasBom)) { $skipped++; continue }

        $encObj = Get-TargetEncodingObject $dest
        $normalized = Update-XmlDeclaration $info.Text $f.FullName $dest
        try { $bytes = $encObj.GetBytes($normalized) }
        catch { "LOSSY (encode error): $($info.RelPath)"; $lossy++; continue }
        if ($Bom -and $dest -eq 'utf8') {
            $withBom = New-Object byte[] ($bytes.Length + 3)
            $withBom[0] = 0xEF; $withBom[1] = 0xBB; $withBom[2] = 0xBF
            [Array]::Copy($bytes, 0, $withBom, 3, $bytes.Length)
            $bytes = $withBom
        }
        $back = $encObj.GetString($bytes)
        if ($Bom -and $dest -eq 'utf8') { $back = $back.TrimStart([char]0xFEFF) }
        if ($back -ne $normalized) {
            $lossy++
            "LOSSY: $($info.RelPath) [$($info.Encoding) -> $dest] - contains characters that cannot round-trip"
            continue
        }
        $changed++
        "CONVERT: $($info.RelPath) [$($info.Encoding) -> $dest]"
        if ($Write) {
            if ($Backup) { $null = Save-Backup $f.FullName }
            Write-Atomic $f.FullName $bytes
        }
    }
    "Summary: converted=$changed skipped=$skipped lossy=$lossy mode=$(if ($Write) { 'write' } else { 'dry-run' })"
}

# --- restore: recover U+FFFD-damaged LTX text from a reference file ----------

function Get-NormalizedCode([string]$Line) {
    $code = $Line
    $idx = $code.IndexOf(';')
    if ($idx -ge 0) { $code = $code.Substring(0, $idx) }
    return ($code -replace '\s+', ' ').Trim()
}

function Get-LineKey([string]$Line) {
    $code = $Line
    $idx = $code.IndexOf(';')
    if ($idx -ge 0) { $code = $code.Substring(0, $idx) }
    if ($code -match '^\s*([^=]+?)\s*=') { return $Matches[1].Trim().ToLowerInvariant() }
    return ($code -replace '\s+', ' ').Trim().ToLowerInvariant()
}

function Get-SectionName([string]$Line) {
    if ($Line -match '^\s*\[([^\]]+)\]') { return $Matches[1].Trim() }
    return $null
}

function Get-DamageRegex([string]$Line) {
    $pattern = [string][char]0xFFFD + '+'
    if ($IncludeQuestionMarks) { $pattern = '(?:' + $pattern + '|\?{2,})' }
    $parts = [regex]::Split($Line, $pattern)
    $escaped = @($parts | ForEach-Object { [regex]::Escape($_) })
    return '^' + ($escaped -join '.*') + '$'
}

function Invoke-Restore {
    if (-not $Target -or -not $Reference) { throw 'restore: -Target and -Reference are required' }
    $cur = Get-FileInfo $Target
    $ref = Get-FileInfo $Reference
    if ($cur.Encoding -in @('binary', 'empty')) { throw "restore: unsupported source encoding $($cur.Encoding)" }
    if ($ref.Encoding -in @('binary', 'empty')) { throw "restore: unsupported reference encoding $($ref.Encoding)" }

    $nl = Get-Newline $cur.Text
    $endsNl = $cur.Text.EndsWith("`n")
    $curLines = $cur.Text -split "\r?\n"
    $refLines = $ref.Text -split "\r?\n"

    # Reference index: section -> code key -> list of comments / lines
    $refIndex = @{}
    $refGlobal = @{}
    $refComments = @()
    $refSectionComments = @{}
    $section = ''
    foreach ($line in $refLines) {
        $s = Get-SectionName $line
        if ($s) { $section = $s; continue }
        $key = "$section|" + (Get-LineKey $line)
        if (-not $refIndex.ContainsKey($key)) { $refIndex[$key] = @() }
        $refIndex[$key] += [pscustomobject]@{ Line = $line; Section = $section; Key = (Get-LineKey $line) }
        $lk = Get-LineKey $line
        if ($lk) {
            if (-not $refGlobal.ContainsKey($lk)) { $refGlobal[$lk] = @() }
            $refGlobal[$lk] += $line
        }
        if ($line.TrimStart().StartsWith(';')) {
            $refComments += $line
            if (-not $refSectionComments.ContainsKey($section)) { $refSectionComments[$section] = @() }
            $refSectionComments[$section] += $line
        }
    }

    $curComments = @()
    $curSectionComments = @{}
    $section = ''
    for ($i = 0; $i -lt $curLines.Count; $i++) {
        $s = Get-SectionName $curLines[$i]
        if ($s) { $section = $s; continue }
        if ($curLines[$i].TrimStart().StartsWith(';')) {
            $curComments += [pscustomobject]@{ Index = $i; Text = $curLines[$i] }
            if (-not $curSectionComments.ContainsKey($section)) { $curSectionComments[$section] = @() }
            $curSectionComments[$section] += [pscustomobject]@{ Index = $i; Text = $curLines[$i] }
        }
    }
    $commentMap = @{}
    foreach ($sec in $curSectionComments.Keys) {
        if ($refSectionComments.ContainsKey($sec) -and $refSectionComments[$sec].Count -eq $curSectionComments[$sec].Count) {
            for ($k = 0; $k -lt $curSectionComments[$sec].Count; $k++) {
                $commentMap[$curSectionComments[$sec][$k].Index] = $refSectionComments[$sec][$k]
            }
        }
    }
    if ($curLines.Count -eq $refLines.Count -and $refComments.Count -eq $curComments.Count) {
        for ($k = 0; $k -lt $curComments.Count; $k++) {
            if (-not $commentMap.ContainsKey($curComments[$k].Index)) {
                $commentMap[$curComments[$k].Index] = $refComments[$k]
            }
        }
    }

    $out = New-Object System.Collections.Generic.List[string]
    $section = ''
    $changed = 0; $recovered = 0; $remaining = 0; $unresolved = @()
    for ($i = 0; $i -lt $curLines.Count; $i++) {
        $line = $curLines[$i]
        $s = Get-SectionName $line
        if ($s) { $section = $s; $out.Add($line); continue }
        $hasLost = $line.IndexOf([char]0xFFFD) -ge 0
        $hasQuestionDamage = $line -match '\?{3,}'
        if (-not $hasLost -and -not ($IncludeQuestionMarks -and $hasQuestionDamage)) { $out.Add($line); continue }

        $key = "$section|" + (Get-LineKey $line)
        $candidates = @()
        if ($refIndex.ContainsKey($key)) { $candidates = @($refIndex[$key]) }
        if ($candidates.Count -gt 1) {
            $codeNorm = Get-NormalizedCode $line
            $exact = @($candidates | Where-Object { (Get-NormalizedCode $_.Line) -eq $codeNorm })
            if ($exact.Count -eq 1) { $candidates = $exact }
        }

        $newLine = $null
        if ($hasLost -and $line.TrimStart().StartsWith(';') -and $commentMap.ContainsKey($i)) {
            $mapped = $commentMap[$i]
            if ($mapped -and $mapped.IndexOf([char]0xFFFD) -lt 0) { $newLine = $mapped }
        }
        if (-not $newLine -and $candidates.Count -eq 1) {
            $refLine = $candidates[0].Line
            if ($line.IndexOf(';') -ge 0) {
                $curCode = $line.Substring(0, $line.IndexOf(';'))
                $refSemi = $refLine.IndexOf(';')
                if ($refSemi -ge 0) {
                    $refComment = $refLine.Substring($refSemi)
                    if ($refComment.IndexOf([char]0xFFFD) -lt 0) { $newLine = $curCode.TrimEnd() + ' ' + $refComment.TrimStart() }
                }
            }
            elseif ($refLine.IndexOf([char]0xFFFD) -lt 0) {
                $newLine = $refLine
            }
        }
        if (-not $newLine) {
            # Fallback 1: same key in another section, but only when the reference
            # comment is unambiguous across all occurrences.
            $lk = Get-LineKey $line
            if ($lk -and $refGlobal.ContainsKey($lk) -and $line.IndexOf(';') -ge 0) {
                $comments = @($refGlobal[$lk] | ForEach-Object {
                    $semi = $_.IndexOf(';')
                    if ($semi -ge 0) { $_.Substring($semi).Trim() } else { '' }
                } | Where-Object { $_ -and $_.IndexOf([char]0xFFFD) -lt 0 } | Select-Object -Unique)
                if ($comments.Count -eq 1) {
                    $newLine = $line.Substring(0, $line.IndexOf(';')).TrimEnd() + ' ' + $comments[0]
                }
            }
        }
        if (-not $newLine) {
            # Fallback 2: unique line in the whole reference matching the damaged skeleton.
            $rx = Get-DamageRegex $line
            $matches = @($refLines | Where-Object { $_ -match $rx })
            if ($matches.Count -eq 1 -and $matches[0].IndexOf([char]0xFFFD) -lt 0) { $newLine = $matches[0] }
        }

        if ($newLine) {
            $lost = ([regex]::Matches($line, [string][char]0xFFFD)).Count
            $recovered += $lost
            $changed++
            $out.Add($newLine)
        }
        else {
            $remaining += ([regex]::Matches($line, [string][char]0xFFFD)).Count
            $unresolved += ('{0}: {1}' -f ($i + 1), $line)
            $out.Add($line)
        }
    }

    $newText = ($out -join $nl)
    if ($endsNl) { $newText += $nl }
    $encName = if ($cur.Encoding -eq 'utf8-bom') { 'utf8bom' } else { $cur.Encoding }
    $encObj = Get-TargetEncodingObject $encName
    $bytes = $encObj.GetBytes($newText)
    $roundTrip = $encObj.GetString($bytes)
    $safe = ($roundTrip -eq $newText)

    "Restore: $(Get-RelPath $Target) <- $(Get-RelPath $Reference)"
    "Lines changed: $changed; lost characters recovered: $recovered; still lost: $remaining; round-trip: $(if ($safe) { 'ok' } else { 'LOSSY' })"
    if ($unresolved.Count -gt 0) {
        "Unresolved damaged lines (first 20):"
        $unresolved | Select-Object -First 20 | ForEach-Object { "  $_" }
    }
    if ($Json) {
        [pscustomobject]@{ Changed = $changed; Recovered = $recovered; Remaining = $remaining; RoundTrip = $safe; Unresolved = $unresolved.Count } | ConvertTo-Json
    }
    if ($Write) {
        if (-not $safe -and -not $Force) { throw 'restore: result would not round-trip; refusing to write (use -Force to override)' }
        if ($Backup) { $null = Save-Backup $cur.Path }
        Write-Atomic $cur.Path $bytes
        "Written: $($cur.Path)"
    }
}

switch ($Command.ToLowerInvariant()) {
    'help' { Show-Help }
    'scan' { Invoke-Scan }
    'detect' {
        if (-not $Target) { throw 'detect: path is required' }
        Invoke-Detect
    }
    'read' { Invoke-Read }
    'grep' { Invoke-Grep }
    'write' { Invoke-WriteFile }
    'fix-xml' { Invoke-FixXml }
    'convert' { Invoke-Convert }
    'restore' { Invoke-Restore }
    default { Show-Help; exit 1 }
}
