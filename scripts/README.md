# Export Scripts Documentation

This folder contains utility scripts for exporting EDP documentation to work environments.

## Export Documentation Script

**File:** `export-docs-for-work.ps1`

### Purpose
Exports the EDP documentation folder structure as a timestamped zip file that can be emailed to your work account and imported into GitLab, SharePoint, or network shares.

### Features
- ✅ Creates timestamped export with all documentation
- ✅ Generates changelog of recent changes
- ✅ Includes detailed import instructions
- ✅ Creates ready-to-email zip archive
- ✅ Optional inclusion of AI resources
- ✅ Git integration for change tracking

### Basic Usage

Open PowerShell in the repository root and run:

```powershell
.\scripts\export-docs-for-work.ps1
```

This will:
1. Create an export folder with timestamp
2. Copy README.md, CLAUDE.md, and entire docs/ folder
3. Generate EXPORT_CHANGELOG.md with recent git commits
4. Create IMPORT_INSTRUCTIONS.txt
5. Compress everything into a zip file
6. Save to `.\exports\` directory

### Advanced Usage

**Include AI Resources:**
```powershell
.\scripts\export-docs-for-work.ps1 -IncludeAIResources
```

**Custom export location:**
```powershell
.\scripts\export-docs-for-work.ps1 -ExportPath "C:\Temp\exports"
```

**Skip changelog generation:**
```powershell
.\scripts\export-docs-for-work.ps1 -GenerateChangelog:$false
```

**Combine multiple options:**
```powershell
.\scripts\export-docs-for-work.ps1 -IncludeAIResources -ExportPath "C:\Temp\exports"
```

### Output Structure

The script creates:
```
exports/
└── edp-docs-export_2025-10-16_143022/
    ├── README.md
    ├── CLAUDE.md
    ├── EXPORT_CHANGELOG.md
    ├── IMPORT_INSTRUCTIONS.txt
    ├── docs/
    │   ├── DOCUMENTATION_INDEX.md
    │   ├── TAXONOMY.md
    │   ├── CONFLUENCE_LANDING_PAGE.md
    │   ├── architecture/
    │   └── engineering-knowledge-base/
    └── ai-resources/ (if -IncludeAIResources used)

# Plus compressed archive:
exports/edp-docs-export_2025-10-16_143022.zip
```

### Workflow

**At Home (with AI access):**
1. Work on documentation with AI assistance
2. Commit changes to GitHub
3. Run export script
4. Email generated zip to work account

**At Work:**
1. Extract zip file
2. Review EXPORT_CHANGELOG.md
3. Follow import instructions to push to GitLab
4. Create Confluence landing page
5. Share with team

### Parameters Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ExportPath` | string | `.\exports` | Where to save the export |
| `-IncludeAIResources` | switch | `false` | Include ai-resources folder |
| `-GenerateChangelog` | switch | `true` | Generate changelog from git |

### What Gets Exported

**Always Included:**
- README.md (repository overview)
- CLAUDE.md (project context)
- docs/ folder (work-relevant documentation only):
  - docs/architecture/ (architecture docs and patterns)
  - docs/engineering-knowledge-base/ (implementation guides)
  - docs/glossaries/ (business and technical glossaries)
  - docs/DOCUMENTATION_INDEX.md (master navigation)
  - docs/TAXONOMY.md (controlled vocabulary)
  - docs/CONFLUENCE_LANDING_PAGE.md (Confluence template)
- EXPORT_CHANGELOG.md (generated)
- IMPORT_INSTRUCTIONS.txt (generated)

**Excluded (Personal Content):**
- docs/career/ (personal career planning)
- docs/goals/ (personal goals)
- docs/personal/ (personal notes)
- docs/philosophy/ (personal philosophy)
- docs/reports/ (personal reports)
- docs/sources/ (personal source materials)
- docs/work_tracking/ (personal work tracking)

**Optional (with `-IncludeAIResources`):**
- ai-resources/prompts/ (AI prompt templates)
- ai-resources/context-documents/ (project context)
- ai-resources/tools/ (utility scripts)

### Compliance

The export script is designed to only export documentation that:
- ✅ Contains no PHI/PII
- ✅ Uses sanitized/fictional examples
- ✅ Is safe for distribution within the organization

The generated changelog reminds you to verify compliance before broad distribution.

### Troubleshooting

**"Cannot be loaded because running scripts is disabled on this system"**

Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Git commands fail**

The script will work without git, but won't include commit history in the changelog. Install git or ignore the warning.

**Zip creation fails**

Ensure you have write permissions to the export directory and sufficient disk space.

### Examples

**Standard weekly export:**
```powershell
.\scripts\export-docs-for-work.ps1
```

**Full export including AI prompts:**
```powershell
.\scripts\export-docs-for-work.ps1 -IncludeAIResources
```

**Quick export to desktop:**
```powershell
.\scripts\export-docs-for-work.ps1 -ExportPath "$env:USERPROFILE\Desktop\exports"
```

### File Locations

After running the script:
- **Uncompressed export:** `.\exports\edp-docs-export_[timestamp]\`
- **Zip archive:** `.\exports\edp-docs-export_[timestamp].zip` ← Email this
- **Exports folder:** `.\exports\` (all historical exports preserved)

### Tips

1. **Regular Exports**: Run weekly or after significant documentation updates
2. **Email Size**: Exports are typically 1-5 MB compressed
3. **Preserve Exports**: Keep local copies as backup snapshots
4. **GitLab First**: Import to GitLab before Confluence for best experience
5. **Update URLs**: Remember to update GitLab URLs in Confluence template

---

**Version:** 1.0.0
**Last Updated:** 2025-10-16
**Maintained By:** Dan Brickey
