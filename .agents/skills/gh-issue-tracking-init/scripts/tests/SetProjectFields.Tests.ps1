#!/usr/bin/env pwsh
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Tests for the $PSBoundParameters.ContainsKey(...) fix in
    set-project-fields.ps1 (the spurious "Field 'Phase' not found" warning).

    When a caller invokes set-project-fields.ps1 without -Phase, the script
    should not add a Phase entry to its single-select collection and should
    emit NO warning — prior to this fix, unbound [string] parameters defaulted
    to "" and the $null -ne guard erroneously passed.

    Run:  Invoke-Pester -Path .agents/skills/gh-issue-tracking-init/scripts/tests/SetProjectFields.Tests.ps1
#>

$ghitDir = Split-Path -Parent $PSScriptRoot
$scriptFile = Join-Path $ghitDir 'set-project-fields.ps1'

Describe 'set-project-fields.ps1 single-select parameter guards' {

    # Shared baseline arguments used by every test invocation + the helper that
    # invokes set-project-fields.ps1 under -DryRun and captures the merged
    # stdout+warning stream.
    BeforeAll {
        $script:ScriptFile = $scriptFile

        $script:BaseParams = @{
            Owner         = 'test-owner'
            ProjectNumber = 3
            Repo          = 'test-owner/test-repo'
            IssueNumber   = 42
        }

        function Invoke-SetProjectFieldsDryRun {
            param([hashtable]$Params)

            $argList = @()
            foreach ($k in $Params.Keys) {
                $v = $Params[$k]
                if ($v -is [switch]) {
                    if ($v) { $argList += "-$k" }
                    continue
                }
                $argList += "-$k"
                if ($null -ne $v) { $argList += $v }
            }

            # Build an outer command string that invokes set-project-fields.ps1
            # with every argument explicit. We capture the merged 3>&1 stream
            # via [powershell]::Create() so warnings surface as WarningRecord
            # objects in $ps.Streams.Warning.
            $escapedScript = ($script:ScriptFile -replace "'", "''")
            $escapedArgSegments = @()
            foreach ($a in $argList) {
                if ($a -eq '') { $escapedArgSegments += "''" }
                elseif ($a -match ' ') { $escapedArgSegments += "'$($a -replace "'", "''")'" }
                else { $escapedArgSegments += $a }
            }
            $cmd = "& '$escapedScript' $($escapedArgSegments -join ' ') 3>&1"
            Write-Verbose "[TRACE] cmd = $cmd"

            $ps = [powershell]::Create()
            $null = $ps.AddScript($cmd)
            $raw = @($ps.Invoke())

            $merged = [System.Collections.Generic.List[object]]::new()
            foreach ($w    in @($ps.Streams.Warning)) { $merged.Add($w) }
            foreach ($line in $raw)                   { $merged.Add($line) }
            $ps.Dispose()

            return , $merged
        }
    }

    Context 'when none of Level/Priority/Phase/Status are passed' {

        It 'emits no Field-not-found warning under -DryRun' {
            $p = $script:BaseParams.Clone()
            $p['DryRun'] = [switch]$true
            $all = Invoke-SetProjectFieldsDryRun -Params $p

            $warnings = @($all | Where-Object { $_ -is [System.Management.Automation.WarningRecord] })
            $warnings | Should -HaveCount 0 -Because "no single-select fields supplied; nothing should warn (Phase/Priority/Status/Level bug fix)."
        }

        It 'completes successfully without throwing' {
            $p = $script:BaseParams.Clone()
            $p['DryRun'] = [switch]$true
            { Invoke-SetProjectFieldsDryRun -Params $p } | Should -Not -Throw
        }
    }

    Context 'when only Level is passed' {

        It 'emits no Phase / Priority / Status warnings' {
            $p = $script:BaseParams.Clone()
            $p['Level']  = 'story'
            $p['DryRun'] = [switch]$true
            $all = Invoke-SetProjectFieldsDryRun -Params $p

            $warnings = @($all | Where-Object { $_ -is [System.Management.Automation.WarningRecord] })
            $warnings | Should -HaveCount 0 -Because "only Level was supplied; Phase/Priority/Status must not appear in the plan."
        }
    }

    Context 'when an empty-string Phase value is passed explicitly' {

        It 'does not throw — empty string is an intentional caller value' {
            # The $PSBoundParameters.ContainsKey(...) guard only filters
            # unbound params. Explicitly passing -Phase '' still passes the
            # guard by design — the bug was the implicit default when omitted.
            $p = $script:BaseParams.Clone()
            $p['Phase']  = ''
            $p['DryRun'] = [switch]$true
            { Invoke-SetProjectFieldsDryRun -Params $p } | Should -Not -Throw
        }
    }
}
