# EMAIL TRANSFER PLAN - EDP Documentation Export

**Export Date:** 2025-10-17
**Total Files:** 29 files
**Transfer Method:** Individual file email attachments

## Strategy Overview
Email files in logical batches to avoid overwhelming email size limits and maintain organization. Recreate folder structure on work machine as you receive each batch.

---

## BATCH 1: Root Setup Files (4 files)
**Priority:** CRITICAL - Do this first!
**Purpose:** Setup instructions and project context

Email these 4 files together:

```
README.md
CLAUDE.md
IMPORT_INSTRUCTIONS.txt
EXPORT_CHANGELOG.md
```

**On work machine after receiving Batch 1:**
```bash
# Create root directory
mkdir edp-architecture-docs
cd edp-architecture-docs

# Save the 4 files here
# Then create folder structure:
mkdir docs
mkdir docs\architecture
mkdir docs\architecture\braindumps
mkdir docs\architecture\diagrams
mkdir docs\architecture\patterns
mkdir docs\engineering-knowledge-base
mkdir docs\glossaries
```

---

## BATCH 2: Documentation Navigation (3 files)
**Priority:** HIGH
**Purpose:** Master indexes and taxonomy

```
docs\DOCUMENTATION_INDEX.md
docs\TAXONOMY.md
docs\CONFLUENCE_LANDING_PAGE.md
```

**On work machine after receiving Batch 2:**
```bash
# Save these 3 files to the docs\ folder
```

---

## BATCH 3: Core Architecture Docs (4 files)
**Priority:** HIGH
**Purpose:** Main architecture specifications

```
docs\architecture\edp_platform_architecture.md
docs\architecture\edp-layer-architecture-detailed.md
docs\architecture\edp-data-ingestion-architecture.md
docs\architecture\edp-near-realtime-architecture.md
```

**On work machine after receiving Batch 3:**
```bash
# Save these 4 files to docs\architecture\
```

---

## BATCH 4: Specialized Architecture (2 files)
**Priority:** MEDIUM

```
docs\architecture\edp-master-data-management-strategy.md
docs\architecture\README.md
```

**On work machine after receiving Batch 4:**
```bash
# Save these 2 files to docs\architecture\
```

---

## BATCH 5: Architecture Patterns (1 file)
**Priority:** MEDIUM

```
docs\architecture\patterns\multi-tenancy-architecture.md
```

**On work machine after receiving Batch 5:**
```bash
# Save to docs\architecture\patterns\
```

---

## BATCH 6: Architecture Diagrams (3 SVG files)
**Priority:** MEDIUM
**Note:** SVG files may be flagged - if blocked, skip and recreate later

```
docs\architecture\diagrams\EDP Data and Code Migration - Current State.svg
docs\architecture\diagrams\EDP Data and Code Migration - Occupy Northstar.svg
docs\architecture\diagrams\EDP Database Overview.svg
```

**On work machine after receiving Batch 6:**
```bash
# Save to docs\architecture\diagrams\
```

**If SVG files are blocked:**
- Skip this batch
- Recreate diagrams in Confluence or draw.io at work
- Or try renaming .svg to .txt before emailing, then rename back

---

## BATCH 7: Braindumps (4 files)
**Priority:** LOW (reference material)

```
docs\architecture\braindumps\README.md
docs\architecture\braindumps\2025_09_30_braindump.md
docs\architecture\braindumps\2025_10_01_braindump.md
docs\architecture\braindumps\2025_10_16_braindump.md
```

**On work machine after receiving Batch 7:**
```bash
# Save to docs\architecture\braindumps\
```

---

## BATCH 8: Engineering Knowledge Base (4 files)
**Priority:** HIGH

```
docs\engineering-knowledge-base\README.md
docs\engineering-knowledge-base\data-vault-2.0-guide.md
docs\engineering-knowledge-base\environment-database-configuration.md
docs\engineering-knowledge-base\technology-stack-reference.md
```

**On work machine after receiving Batch 8:**
```bash
# Save to docs\engineering-knowledge-base\
```

---

## BATCH 9: Glossaries - Part 1 (3 files)
**Priority:** MEDIUM

```
docs\glossaries\aws-terminology.md
docs\glossaries\snowflake-terminology.md
docs\glossaries\sql-server-terminology.md
```

**On work machine after receiving Batch 9:**
```bash
# Save to docs\glossaries\
```

---

## BATCH 10: Glossaries - Part 2 (3 files)
**Priority:** MEDIUM

```
docs\glossaries\dbt-cloud-terminology.md
docs\glossaries\data-vault-2.0-terminology.md
docs\glossaries\healthcare-payer-terminology.md
```

**On work machine after receiving Batch 10:**
```bash
# Save to docs\glossaries\
```

---

## After All Files Transferred

### Verify Structure
```bash
cd edp-architecture-docs
tree /F > structure-verification.txt
```

Compare against this expected structure:
```
edp-architecture-docs/
├── README.md
├── CLAUDE.md
├── IMPORT_INSTRUCTIONS.txt
├── EXPORT_CHANGELOG.md
└── docs/
    ├── DOCUMENTATION_INDEX.md
    ├── TAXONOMY.md
    ├── CONFLUENCE_LANDING_PAGE.md
    ├── architecture/
    │   ├── README.md
    │   ├── edp_platform_architecture.md
    │   ├── edp-layer-architecture-detailed.md
    │   ├── edp-data-ingestion-architecture.md
    │   ├── edp-near-realtime-architecture.md
    │   ├── edp-master-data-management-strategy.md
    │   ├── braindumps/
    │   │   ├── README.md
    │   │   ├── 2025_09_30_braindump.md
    │   │   ├── 2025_10_01_braindump.md
    │   │   └── 2025_10_16_braindump.md
    │   ├── diagrams/
    │   │   ├── EDP Data and Code Migration - Current State.svg
    │   │   ├── EDP Data and Code Migration - Occupy Northstar.svg
    │   │   └── EDP Database Overview.svg
    │   └── patterns/
    │       └── multi-tenancy-architecture.md
    ├── engineering-knowledge-base/
    │   ├── README.md
    │   ├── data-vault-2.0-guide.md
    │   ├── environment-database-configuration.md
    │   └── technology-stack-reference.md
    └── glossaries/
        ├── aws-terminology.md
        ├── snowflake-terminology.md
        ├── sql-server-terminology.md
        ├── dbt-cloud-terminology.md
        ├── data-vault-2.0-terminology.md
        └── healthcare-payer-terminology.md
```

### Initialize Git Repository
```bash
cd edp-architecture-docs
git init
git branch -M main
git add .
git commit -m "Initial import of EDP architecture documentation

- Architecture specifications and patterns
- Engineering knowledge base
- Business glossaries
- Documentation index and taxonomy
- Confluence landing page template

Transferred via email: 2025-10-17"
```

### Push to GitLab
```bash
# Replace with your actual BCI GitLab URL
git remote add origin https://gitlab.bcidaho.com/edp/architecture-docs.git
git push -u origin main
```

---

## PHASE 2: GitLab Pages Documentation Portal

**When to do this:** After initial GitLab repository is set up and team confirms interest

**Why:** Business Data Councils and executives need a polished, navigable documentation site that's easy for non-technical audiences to browse.

### Recommended Stack for GitLab Pages

**Option A: MkDocs Material (Recommended)**
- **Best for:** Technical documentation with beautiful UI
- **Pros:**
  - Gorgeous out-of-the-box theme
  - Great search functionality
  - Mobile-responsive
  - Supports glossaries, tabs, admonitions
  - Easy navigation with automatic sidebar
- **Cons:** Requires Python (but GitLab CI handles this)
- **Example:** https://squidfunk.github.io/mkdocs-material/

**Option B: Docusaurus**
- **Best for:** If you want React-based customization
- **Pros:** Very modern, highly customizable
- **Cons:** More complex setup
- **Example:** https://docusaurus.io/

**Option C: Just the Docs (Jekyll)**
- **Best for:** Simplest setup
- **Pros:** Minimal dependencies, GitLab Pages native support
- **Cons:** Less polished than MkDocs Material

**Recommendation: MkDocs Material** - Perfect balance of ease and polish for your use case.

### Implementation Roadmap

**Step 1: Local Test (1-2 hours)**
```bash
# Install MkDocs Material locally
pip install mkdocs-material

# Create mkdocs.yml configuration
# Run local preview
mkdocs serve

# Browse at http://localhost:8000
```

**Step 2: Organize Content (2-3 hours)**
- Your docs are already well-organized!
- Just need to create `mkdocs.yml` config file
- Add a `docs/index.md` landing page
- Existing docs stay as-is (minimal restructuring needed)

**Step 3: GitLab CI/CD Pipeline (1 hour)**
- Create `.gitlab-ci.yml` to auto-build on commits
- Deploys to GitLab Pages automatically
- Available at `https://yourgitlab.com/edp/architecture-docs`

**Step 4: Polish (2-4 hours)**
- Add logo
- Configure navigation menu
- Set up search
- Test on mobile

**Total Time Investment:** 6-10 hours spread over a week or two

### What You'll Get

A beautiful documentation portal with:
- **Homepage** with quick links to key sections
- **Search bar** - find any term across all docs
- **Navigation sidebar** - organized by category
- **Breadcrumbs** - always know where you are
- **Dark/light mode toggle**
- **Glossary integration** - your 6 glossaries become searchable reference
- **Mobile-friendly** - executives can read on tablets/phones
- **Version history** - git commit log visible in footer

### Business Value

**For Data Councils:**
- Clean reading experience on glossaries (snowflake-terminology.md, etc.)
- Easy to share specific doc links in meetings
- Search makes it self-service

**For Executives:**
- Professional appearance builds confidence
- No GitLab login required (if you set public access)
- Can browse architecture on iPad during meetings

**For You:**
- Same markdown files, just rendered beautifully
- Auto-deploys when you commit
- Easy to maintain (just edit markdown in GitLab)

### Sample `mkdocs.yml` Structure

```yaml
site_name: EDP Architecture Documentation
site_url: https://gitlab.bcidaho.com/edp/architecture-docs
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - search.suggest
    - search.highlight
  palette:
    - scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode

nav:
  - Home: index.md
  - Architecture:
      - Platform Overview: architecture/edp_platform_architecture.md
      - Layer Architecture: architecture/edp-layer-architecture-detailed.md
      - Data Ingestion: architecture/edp-data-ingestion-architecture.md
      - Near Real-Time: architecture/edp-near-realtime-architecture.md
      - Master Data Mgmt: architecture/edp-master-data-management-strategy.md
      - Patterns:
          - Multi-Tenancy: architecture/patterns/multi-tenancy-architecture.md
  - Engineering:
      - Data Vault 2.0: engineering-knowledge-base/data-vault-2.0-guide.md
      - Environment Config: engineering-knowledge-base/environment-database-configuration.md
      - Tech Stack: engineering-knowledge-base/technology-stack-reference.md
  - Glossaries:
      - AWS: glossaries/aws-terminology.md
      - Snowflake: glossaries/snowflake-terminology.md
      - SQL Server: glossaries/sql-server-terminology.md
      - dbt Cloud: glossaries/dbt-cloud-terminology.md
      - Data Vault: glossaries/data-vault-2.0-terminology.md
      - Healthcare Payer: glossaries/healthcare-payer-terminology.md
  - Reference:
      - Documentation Index: DOCUMENTATION_INDEX.md
      - Taxonomy: TAXONOMY.md

plugins:
  - search
  - tags

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences
  - pymdownx.tabbed
  - tables
  - toc:
      permalink: true
```

### When to Trigger Phase 2

**Green lights:**
- GitLab repo is stable and being used
- You get questions like "where's the glossary again?"
- Leadership asks to share docs with external partners
- Data Council wants bookmarkable links to specific sections
- You have a few hours to invest in polish

**Can wait if:**
- Team is happy with raw GitLab markdown view
- Only engineers are accessing docs
- Confluence integration is sufficient
- Other priorities are more urgent

---

## Email Subject Line Template

Use consistent subject lines for easy filtering:

```
EDP Docs Export - Batch [N]: [Description]
```

Examples:
- `EDP Docs Export - Batch 1: Root Setup Files`
- `EDP Docs Export - Batch 2: Documentation Navigation`
- `EDP Docs Export - Batch 3: Core Architecture Docs`

---

## Troubleshooting

### If any file is blocked by email:
1. Try renaming extension to `.txt` before sending
2. Rename back to original extension after receiving
3. Example: `CLAUDE.md` → `CLAUDE.md.txt` → `CLAUDE.md`

### If you get overwhelmed:
**Minimum viable set** (do these first):
- Batch 1: Root Setup Files
- Batch 2: Documentation Navigation
- Batch 3: Core Architecture Docs
- Batch 8: Engineering Knowledge Base

You can add the rest later.

### If email size limits are hit:
Split larger batches in half or send files individually.

---

## Pro Tips

1. **Email to yourself first** - Send Batch 1 from personal email to work email as a test
2. **Check spam folder** - First email might get flagged
3. **Save incrementally** - Don't wait for all batches, start setting up GitLab after Batch 1
4. **Use work Outlook rules** - Create a rule to auto-label these emails for easy finding
5. **Keep this plan** - Email this file to yourself in Batch 1 for reference at work

---

**Good luck! This is tedious but reliable.**
