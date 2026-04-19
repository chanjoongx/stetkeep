# stetkeep Safety Net — PreToolUse hook (PowerShell version for Windows)
#
# Installed via .claude/settings.json:
#   {
#     "hooks": {
#       "PreToolUse": [{
#         "matcher": "Edit|Write|Bash",
#         "hooks": [{ "type": "command", "command": "pwsh $CLAUDE_PROJECT_DIR/.claude/hooks/safety-net.ps1" }]
#       }]
#     }
#   }

$ErrorActionPreference = "Stop"

$Stdin = [Console]::In.ReadToEnd()
$Payload = $Stdin | ConvertFrom-Json

$ToolName = $Payload.tool_name
$FilePath = if ($Payload.tool_input.file_path) { $Payload.tool_input.file_path } else { $Payload.tool_input.path }
$BashCmd = $Payload.tool_input.command
$ProjectDir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }

function Send-Decision {
    param([string]$Decision, [string]$Reason)
    $out = @{
        hookSpecificOutput = @{
            hookEventName = "PreToolUse"
            permissionDecision = $Decision
            permissionDecisionReason = $Reason
        }
    } | ConvertTo-Json -Compress
    Write-Output $out
    exit 0
}

# Destructive or write-via-Bash in protected zones
# Catches `rm -rf legacy/` and `cat > legacy/foo.ts` (Bash-based bypass of subagent Write restrictions).
if ($ToolName -eq "Bash" -and $BashCmd) {
    # Destructive
    if ($BashCmd -match "(rm -rf|rm -fr|git clean -fd)") {
        if ($BashCmd -match "(legacy/|generated/|vendor/|\.craftignore|\.perfignore)") {
            Send-Decision "deny" "Destructive command targets a protected zone. Safety Net refusal."
        }
        Send-Decision "ask" "Destructive command detected. Confirm intent."
    }
    # Write-via-Bash bypass: `>`, `>>` redirect to protected path
    if ($BashCmd -match '>\s*["'']?(legacy|generated|vendor|node_modules|dist|build|\.next)/') {
        Send-Decision "deny" "Bash redirection targets a protected zone. Use Edit/Write tool (which is gated)."
    }
    # `tee` bypass
    if ($BashCmd -match 'tee\s+["'']?(legacy|generated|vendor)/') {
        Send-Decision "deny" "Bash tee targets a protected zone. Safety Net refusal."
    }
    exit 0
}

# Only gate Edit / Write
if ($ToolName -ne "Edit" -and $ToolName -ne "Write") { exit 0 }
if (-not $FilePath) { exit 0 }

$RelPath = $FilePath -replace [regex]::Escape($ProjectDir + "/"), ""
$RelPath = $RelPath -replace [regex]::Escape($ProjectDir + "\"), ""

# Protected path prefixes
$Protected = @("legacy/", "generated/", "vendor/", "node_modules/", "dist/", "build/", ".next/")
foreach ($proto in $Protected) {
    if ($RelPath.StartsWith($proto) -or $RelPath.StartsWith($proto.Replace("/", "\"))) {
        Send-Decision "ask" "Editing $proto path ($RelPath). Mandatory-ask Safety Net trigger."
    }
}

# .craftignore / .perfignore
foreach ($ignoreFile in @(".craftignore", ".perfignore")) {
    $ignorePath = Join-Path $ProjectDir $ignoreFile
    if (Test-Path $ignorePath) {
        $patterns = Get-Content $ignorePath | Where-Object { $_ -and -not $_.StartsWith("#") }
        foreach ($pattern in $patterns) {
            $regex = $pattern -replace '\.', '\.' -replace '\*\*', '.*' -replace '\*', '[^/]*'
            if ($RelPath -match "^$regex$") {
                Send-Decision "deny" "$RelPath matches $ignoreFile pattern '$pattern'. Safety Net refusal."
            }
        }
    }
}

# Markers in existing file
# Real markers always carry reason= / baseline= / date= (per CRAFT.md / PERF.md spec).
# Bare prose mentions like "use @perf-optimized markers" do not match.
if (Test-Path $FilePath) {
    $first20 = Get-Content $FilePath -TotalCount 20 -ErrorAction SilentlyContinue
    $joined = $first20 -join "`n"
    if ($joined -match '@(craft|perf)-[a-z-]+\s+(reason|baseline|date)=') {
        $marker = [regex]::Match($joined, '@(craft|perf)-[a-z-]+').Value
        Send-Decision "deny" "$RelPath has a $marker marker. Safety Net refusal."
    }
}

# Default: allow
exit 0
