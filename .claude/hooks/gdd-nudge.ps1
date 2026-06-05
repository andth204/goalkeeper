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

# Skip questions / explanations: GDD nudges REQUESTS to build, not questions
# about the codebase. A trailing '?' or a question-word lead = not a build task.
if ($ascii.TrimEnd().EndsWith('?')) { exit 0 }
if ($ascii -match '^(what|how|why|which|where|when|who|explain|tai sao|vi sao|the nao|nhu the nao|co phai|giai thich)\b') { exit 0 }

# Feature / multi-step intent keywords, diacritic-free (VN + EN).
$kw = @(
    'them tinh nang', 'tinh nang moi', 'them chuc nang', 'chuc nang moi',
    'cai thien', 'cai tien', 'toi uu', 'nang cap',
    'refactor', 'implement', 'build feature', 'add feature', 'xay dung'
)
foreach ($k in $kw) {
    if ($ascii.Contains($k)) {
        Write-Output "[GDD] This looks like multi-step work. Consider /spec-to-goal before coding (see CLAUDE.md > activation threshold). Skip if it's a small edit."
        break
    }
}
exit 0
