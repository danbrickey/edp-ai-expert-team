# EDP Documentation Export Script
# Purpose: Export docs folder for transfer to work environment
# Author: Dan Brickey
# Last Updated: 2025-10-16

param(
    [string]$ExportPath = ".\exports",
    [switch]$IncludeAIResources = $false,
    [switch]$GenerateChangelog = $true
)

# Script configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$ExportName = "edp-docs-export_$Timestamp"
$ExportFullPath = Join-Path $ExportPath $ExportName

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EDP Documentation Export Utility" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create export directory
Write-Host "Creating export directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $ExportFullPath | Out-Null
Write-Host "  Export location: $ExportFullPath" -ForegroundColor Green
Write-Host ""

# Export core documentation files
Write-Host "Exporting core documentation..." -ForegroundColor Yellow

# Copy README.md
Write-Host "  + README.md" -ForegroundColor Gray
Copy-Item -Path (Join-Path $RepoRoot "README.md") -Destination $ExportFullPath -Force

# Copy CLAUDE.md
Write-Host "  + CLAUDE.md" -ForegroundColor Gray
Copy-Item -Path (Join-Path $RepoRoot "CLAUDE.md") -Destination $ExportFullPath -Force

# Create docs directory structure
$DocsDestination = Join-Path $ExportFullPath "docs"
New-Item -ItemType Directory -Force -Path $DocsDestination | Out-Null

# Copy work-relevant docs folders only (exclude personal folders)
Write-Host "  + docs/architecture/" -ForegroundColor Gray
Copy-Item -Path (Join-Path $RepoRoot "docs\architecture") -Destination (Join-Path $DocsDestination "architecture") -Recurse -Force

Write-Host "  + docs/engineering-knowledge-base/" -ForegroundColor Gray
Copy-Item -Path (Join-Path $RepoRoot "docs\engineering-knowledge-base") -Destination (Join-Path $DocsDestination "engineering-knowledge-base") -Recurse -Force

Write-Host "  + docs/glossaries/" -ForegroundColor Gray
Copy-Item -Path (Join-Path $RepoRoot "docs\glossaries") -Destination (Join-Path $DocsDestination "glossaries") -Recurse -Force

# Copy root docs files
Write-Host "  + docs/DOCUMENTATION_INDEX.md" -ForegroundColor Gray
Copy-Item -Path (Join-Path $RepoRoot "docs\DOCUMENTATION_INDEX.md") -Destination $DocsDestination -Force

Write-Host "  + docs/TAXONOMY.md" -ForegroundColor Gray
Copy-Item -Path (Join-Path $RepoRoot "docs\TAXONOMY.md") -Destination $DocsDestination -Force

Write-Host "  + docs/CONFLUENCE_LANDING_PAGE.md" -ForegroundColor Gray
Copy-Item -Path (Join-Path $RepoRoot "docs\CONFLUENCE_LANDING_PAGE.md") -Destination $DocsDestination -Force

Write-Host "  (Excluded personal folders: career, goals, personal, philosophy, reports, sources, work_tracking)" -ForegroundColor DarkGray

# Optionally copy ai-resources folder
if ($IncludeAIResources) {
    Write-Host "  + ai-resources/ (entire folder)" -ForegroundColor Gray
    $AISource = Join-Path $RepoRoot "ai-resources"
    $AIDestination = Join-Path $ExportFullPath "ai-resources"
    Copy-Item -Path $AISource -Destination $AIDestination -Recurse -Force
}

Write-Host ""

# Generate changelog if requested
if ($GenerateChangelog) {
    Write-Host "Generating changelog..." -ForegroundColor Yellow

    $ChangelogPath = Join-Path $ExportFullPath "EXPORT_CHANGELOG.md"

    # Get git changes since last export (if git is available)
    $GitChanges = ""
    try {
        Push-Location $RepoRoot
        $LastWeekCommits = git log --since="7 days ago" --pretty=format:"%h - %s (%an, %ar)" --no-merges 2>&1
        if ($LASTEXITCODE -eq 0 -and $LastWeekCommits) {
            $GitChanges = $LastWeekCommits
        }
        Pop-Location
    } catch {
        $GitChanges = "Git history not available"
    }

    # Count files
    $TotalFiles = (Get-ChildItem -Path $ExportFullPath -Recurse -File).Count
    $DocFiles = (Get-ChildItem -Path (Join-Path $ExportFullPath "docs") -Recurse -File -Filter "*.md").Count

    $ChangelogContent = @"
# EDP Documentation Export Changelog

**Export Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Export Name:** $ExportName
**Exported By:** $env:USERNAME

---

## Export Contents

### Files Exported
- ✅ README.md - Repository overview and navigation
- ✅ CLAUDE.md - Project context for AI assistants
- ✅ docs/ - Work-relevant documentation only
  - ✅ docs/architecture/ - Architecture documentation and patterns
  - ✅ docs/engineering-knowledge-base/ - Implementation guides
  - ✅ docs/glossaries/ - Business and technical glossaries
  - ✅ docs/DOCUMENTATION_INDEX.md - Master navigation index
  - ✅ docs/TAXONOMY.md - Controlled vocabulary
  - ✅ docs/CONFLUENCE_LANDING_PAGE.md - Confluence template
  - ⏭️ Personal folders excluded (career, goals, personal, philosophy, reports, sources, work_tracking)
- $DocFiles markdown documentation files
$(if ($IncludeAIResources) { "- ✅ ai-resources/ - AI tools and prompts" } else { "- ⏭️ ai-resources/ - Excluded from export (use -IncludeAIResources to include)" })

**Total files exported:** $TotalFiles

---

## Recent Changes (Last 7 Days)

$(if ($GitChanges -and $GitChanges -ne "Git history not available") {
@"
``````
$GitChanges
``````
"@
} else {
"No recent commits or git history not available."
})

---

## Import Instructions for Work Environment

### Option 1: Import to GitLab

1. **Create new repository** in GitLab:
   - Repository name: ``edp-architecture-docs``
   - Visibility: Internal or Private (as appropriate)
   - Initialize with README: No (we're providing one)

2. **Extract this export** to a working directory on your work machine

3. **Initialize and push to GitLab**:
   ``````bash
   cd path/to/extracted/export
   git init
   git add .
   git commit -m "Initial import of EDP architecture documentation"
   git remote add origin https://gitlab.yourcompany.com/edp/architecture-docs.git
   git push -u origin main
   ``````

4. **Set up branch protection** on the ``main`` branch (recommended)

5. **Create Confluence landing page** using the template in ``docs/CONFLUENCE_LANDING_PAGE.md``

### Option 2: Import to SharePoint

1. **Create new document library** in SharePoint:
   - Library name: "EDP Architecture Documentation"
   - Enable versioning for change tracking

2. **Upload files**:
   - Upload all contents of this export folder
   - Maintain folder structure

3. **Pin key documents** for easy access:
   - docs/DOCUMENTATION_INDEX.md
   - docs/architecture/edp_platform_architecture.md

### Option 3: Network Share

1. **Create folder structure** on network share:
   ``\\\\shareserver\\EDP\\Architecture-Documentation\\``

2. **Copy all files** maintaining folder structure

3. **Set permissions** appropriately for team access

---

## Post-Import Tasks

After importing to your work environment:

- [ ] Update GitLab URLs in CONFLUENCE_LANDING_PAGE.md to match your actual GitLab instance
- [ ] Create Confluence landing page and publish
- [ ] Share documentation location with EDP team
- [ ] Set up appropriate access controls
- [ ] Consider setting up CI/CD for documentation validation (optional)

---

## Compliance Verification

Before sharing broadly, verify:

- [ ] No PHI/PII in any documentation files
- [ ] No actual member/patient names or identifiers
- [ ] No real provider names, NPIs, or addresses
- [ ] All examples use sanitized/fictional data
- [ ] No sensitive credentials or connection strings

All documentation has been designed to be PHI/PII free, but verification before broad distribution is recommended.

---

## Next Export

To export updated documentation in the future:

1. Run this script again from your personal repository
2. Email the generated zip file to your work account
3. Extract and update your work GitLab repository with changes

For questions about this export, contact Dan Brickey.
"@

    $ChangelogContent | Out-File -FilePath $ChangelogPath -Encoding UTF8
    Write-Host "  ✅ Changelog created: EXPORT_CHANGELOG.md" -ForegroundColor Green
    Write-Host ""
}

# Create import instructions file
Write-Host "Creating import instructions..." -ForegroundColor Yellow
$InstructionsPath = Join-Path $ExportFullPath "IMPORT_INSTRUCTIONS.txt"
$InstructionsContent = @"
EDP DOCUMENTATION EXPORT - IMPORT INSTRUCTIONS
===============================================

Export Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Export Name: $ExportName

CONTENTS:
---------
✓ README.md                   - Repository overview
✓ CLAUDE.md                   - Project context
✓ docs/                       - Work-relevant documentation only
  ✓ docs/architecture/        - Architecture docs and patterns
  ✓ docs/engineering-knowledge-base/ - Implementation guides
  ✓ docs/glossaries/          - Business and technical glossaries
  ✓ docs/DOCUMENTATION_INDEX.md - Master navigation
  ✓ docs/TAXONOMY.md          - Controlled vocabulary
  ✓ docs/CONFLUENCE_LANDING_PAGE.md - Confluence template
  ⏭ Personal folders excluded
✓ EXPORT_CHANGELOG.md         - Detailed export information
✓ IMPORT_INSTRUCTIONS.txt     - This file
$(if ($IncludeAIResources) { "✓ ai-resources/              - AI tools and prompts" } else { "" })

RECOMMENDED APPROACH:
--------------------
1. Import to GitLab repository for version control
2. Create Confluence landing page that links to GitLab
3. Share Confluence page with team for discoverability

QUICK START:
-----------
1. Extract this entire folder on your work machine
2. Review EXPORT_CHANGELOG.md for recent changes
3. Follow detailed import instructions in EXPORT_CHANGELOG.md
4. Use docs/CONFLUENCE_LANDING_PAGE.md as template for Confluence

GITLAB QUICK SETUP:
------------------
cd path/to/this/export
git init
git add .
git commit -m "Initial import of EDP architecture documentation"
git remote add origin https://gitlab.yourcompany.com/edp/architecture-docs.git
git push -u origin main

Then create Confluence page using docs/CONFLUENCE_LANDING_PAGE.md template.

IMPORTANT:
---------
• Update GitLab URLs in CONFLUENCE_LANDING_PAGE.md to match your instance
• Verify no PHI/PII before broad distribution (designed to be clean)
• Set appropriate access controls in GitLab

For questions: Contact Dan Brickey
"@

$InstructionsContent | Out-File -FilePath $InstructionsPath -Encoding UTF8
Write-Host "  ✅ Import instructions created" -ForegroundColor Green
Write-Host ""

# Create compressed archive
Write-Host "Creating zip archive..." -ForegroundColor Yellow
$ZipPath = "$ExportFullPath.zip"
Compress-Archive -Path $ExportFullPath -DestinationPath $ZipPath -Force
$ZipSizeMB = [math]::Round((Get-Item $ZipPath).Length / 1MB, 2)
Write-Host "  ✅ Archive created: $ExportName.zip ($ZipSizeMB MB)" -ForegroundColor Green
Write-Host ""

# Display summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Export Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Export Details:" -ForegroundColor White
Write-Host "  Location:     $ZipPath" -ForegroundColor Gray
Write-Host "  Size:         $ZipSizeMB MB" -ForegroundColor Gray
Write-Host "  Files:        $(Get-ChildItem -Path $ExportFullPath -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "  1. Email $ExportName.zip to your work account" -ForegroundColor Gray
Write-Host "  2. Extract the archive on your work machine" -ForegroundColor Gray
Write-Host "  3. Review EXPORT_CHANGELOG.md for recent changes" -ForegroundColor Gray
Write-Host "  4. Follow import instructions for GitLab setup" -ForegroundColor Gray
Write-Host "  5. Create Confluence landing page using provided template" -ForegroundColor Gray
Write-Host ""
Write-Host "The uncompressed export folder has been preserved at:" -ForegroundColor Yellow
Write-Host "  $ExportFullPath" -ForegroundColor Gray
Write-Host ""

# Optionally open the export folder
$OpenFolder = Read-Host "Open export folder now? (y/n)"
if ($OpenFolder -eq 'y' -or $OpenFolder -eq 'Y') {
    Invoke-Item $ExportPath
}
