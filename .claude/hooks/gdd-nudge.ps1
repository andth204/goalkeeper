# GDD nudge -- UserPromptSubmit hook.
# Reads the prompt JSON on stdin. If it looks like a multi-step/feature request,
# prints a ONE-LINE reminder to consider /spec-to-goal first. Otherwise prints
# nothing (zero token cost). Never blocks: always exit 0.
# NOTE: kept pure ASCII -- Windows PowerShell 5.1 mis-parses non-BOM UTF-8 files.
# Vietnamese is matched diacritic-insensitively by folding the prompt to ASCII.
$ErrorActionPreference = 'SilentlyContinue'
try {
    # Read stdin as UTF-8 explicitly. PowerShell 5.1 otherwise decodes the pipe
    # with the OEM codepage, which corrupts the Vietnamese in the prompt.
    $reader = New-Object System.IO.StreamReader([Console]::OpenStandardInput(), [Text.Encoding]::UTF8)
    $raw = $reader.ReadToEnd()
    $reader.Close()
    if (-not $raw) { exit 0 }
    $obj = $raw | ConvertFrom-Json
    $p = "$($obj.prompt)"
} catch { exit 0 }

if (-not $p) { exit 0 }
$pl = $p.ToLower().Trim()

# Skip slash commands and anything already in the GDD flow.
if ($pl.StartsWith('/')) { exit 0 }
if ($pl -match 'spec-to-goal|goal-implement|goal-status') { exit 0 }

# Fold diacritics to ASCII so Vietnamese matches regardless of accents.
$ascii = $pl
try {
    $norm = $pl.Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $norm.ToCharArray()) {
        $cat = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($c)
        if ($cat -ne [Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($c) }
    }
    $ascii = $sb.ToString()
} catch { $ascii = $pl }

# Feature / multi-step intent keywords, diacritic-free (VN + EN).
$kw = @(
    'them tinh nang', 'tinh nang moi', 'them chuc nang', 'chuc nang moi',
    'cai thien', 'cai tien', 'toi uu', 'nang cap',
    'refactor', 'implement', 'build feature', 'add feature', 'xay dung'
)
foreach ($k in $kw) {
    if ($ascii.Contains($k)) {
        Write-Output "[GDD] Yeu cau co ve da-buoc. Can nhac /spec-to-goal truoc khi code (xem CLAUDE.md - nguong kich hoat). Bo qua neu la sua nho."
        break
    }
}
exit 0
