<#
.SYNOPSIS
    Cleans Git repository history by removing specific commits that modify internal/beta ZIP files only.

.DESCRIPTION
    This script is designed to clean up the history of a Git repository by identifying and removing commits
    that modify specific ZIP files (-Intern, -Internal, -Beta) across all branches.
    These commits are often the result of frequently updated binary assets (e.g., ZIP files), which can
    unnecessarily bloat the repository history and size.

    The script performs the following steps:
      1. Scans all commits in the repository that touch specific files.
      2. Filters commits that modify *only* those files.
      3. Uses git-filter-repo to rewrite history and remove those commits.
      4. Prints instructions to force-push the updated history to GitHub.

    This operation is **destructive** and rewrites the repository history. It should be used only when:
      - You understand the risks of history rewriting.
      - You have a backup.
      - You plan to force-push and coordinate with other collaborators.

.PARAMETER WhatIf
    Shows what commits would be removed without actually making any changes.

.PARAMETER RemoveFiles
    Second pass: removes the target ZIP files from all commits in history.
    Run this after the main commit removal pass.

.REQUIREMENTS
    - PowerShell
    - Git
    - git-filter-repo (https://github.com/newren/git-filter-repo)

.NOTES
    - Use this script responsibly; it will change the commit history of your repository.
    - All collaborators must re-clone or reset their local repositories after you force-push the changes.
#>

param(
    [switch]$WhatIf,
    [int]$RetentionDays = 60,
    [switch]$OnlyInternal = $false
)

# Variables - patterns for files to target
$filePatterns = @(
    "dist*/*-Intern.zip",
    "dist*/*-Internal.zip",
    "dist*/*-Beta.zip"
)
if ($OnlyInternal) {
    $filePatterns = @(
        "dist*/*-Intern.zip",
        "dist*/*-Internal.zip"
    )
}

# Validate path
if (-Not (Test-Path ".git")) {
    Write-Error "This is not a Git repository."
    exit 1
}

$cutoffDate = (Get-Date).AddDays(-$RetentionDays)
$cutoffUnix = [int][double]::Parse((Get-Date $cutoffDate -UFormat %s))

# Remove files from history using a commit callback with date check
Write-Host "Removing target ZIP files from commits older than $cutoffDate..."

if ($WhatIf) {
    Write-Host "`nWhatIf: Would remove files matching these patterns from commits older than 60 days:"
    $filePatterns | ForEach-Object { Write-Host "  $_" }
    exit 0
}

# Use commit callback to filter files only from old commits
$pythonScript = @"
import fnmatch

file_patterns = [
$(($filePatterns | ForEach-Object { "    b'$_'," }) -join "`n")
]
cutoff_timestamp = $cutoffUnix

def matches_pattern(filename):
    for pattern in file_patterns:
        if fnmatch.fnmatch(filename, pattern):
            return True
    return False

commit_timestamp = int(commit.committer_date.split()[0])
if commit_timestamp < cutoff_timestamp:
    commit.file_changes = [fc for fc in commit.file_changes if not matches_pattern(fc.filename)]
"@

git filter-repo --commit-callback "$pythonScript"

Write-Host "`nFiles removed. To force-push updated history to GitHub:"
Write-Host "git push origin --force --all"
Write-Host "git push origin --force --tags"
exit 0