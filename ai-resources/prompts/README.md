---
title: "AI Prompts Library - Master Catalog"
author: "Dan Brickey"
last_updated: "2025-10-16"
version: "2.0.0"
category: "prompts-index"
tags: ["prompts", "AI-templates", "code-generation", "documentation", "architecture", "career"]
status: "current"
contents: ["architecture", "documentation", "meta", "career", "workflows", "specialized"]
usage: "Centralized library of reusable prompt templates for consistent AI assistance across all domains"
---

# AI Prompts Library - Master Catalog

Welcome to the centralized AI prompts library for the EDP AI Expert Team project. All general-purpose and reusable prompts are organized here by category for easy discovery and maintenance.

## 📂 Directory Structure

```
ai-resources/prompts/
├── architecture/          ← Architecture & technical design prompts
├── documentation/         ← Documentation generation & management prompts
├── meta/                  ← Prompt engineering & meta-prompts
├── career/                ← Career development & analysis prompts
├── workflows/             ← Multi-step workflow prompts
└── specialized/           ← Domain-specific utility prompts
```

---

## 🏗️ Architecture Prompts

**Location**: [architecture/](architecture/)

Expert prompts for data architecture, technical design, and diagramming:

- **[data_architect.md](architecture/data_architect.md)** - Data architecture expert for Data Vault 2.0, dimensional modeling, and Snowflake platform design.
- **[drawio-diagram-specialist.md](architecture/drawio-diagram-specialist.md)** - Specialist for creating and editing Draw.io diagrams for architecture documentation.

---

## 📝 Documentation Prompts

**Location**: [documentation/](documentation/)

Prompts for generating and managing various types of documentation:

- **[architecture_documentation_architect.md](architecture/architecture_documentation_architect.md)** - Architecture documentation assistant with business rules integration. Interviews for missing details, processes braindumps, organizes documentation with multi-audience layering.
- **[project_documentation_expert.md](documentation/project_documentation_expert.md)** - Expert for creating comprehensive project documentation with proper structure and formatting.
- **[business_rule_documenter.md](documentation/business_rule_documenter.md)** - Specialist for documenting business rules and domain logic in accessible formats.
- **[meeting_notes_summarizer.md](documentation/meeting_notes_summarizer.md)** - Assistant for summarizing meeting notes into actionable items and key decisions.

---

## 🧠 Meta / Prompt Engineering

**Location**: [meta/](meta/)

Tools for creating and improving prompts themselves:

- **[meta-prompt-engineer.md](meta/meta-prompt-engineer.md)** - Meta-prompt engineering expert using systematic evaluation methodology. Creates high-quality prompts with self-evaluation and iterative refinement.
- **[data_vault_refactor_prompt_generator.md](meta/data_vault_refactor_prompt_generator.md)** - Generator for creating Data Vault refactoring prompts for specific tables/entities.

---

## 💼 Career Development Prompts

**Location**: [career/](career/)

Prompts for career planning, analysis, and development:

### Career Planning & Analysis
- **[career-analyzer.md](career/career-analyzer.md)** - Analyze career paths, create development plans, and identify skill gaps.
- **[career-cv-interviewer.md](career/career-cv-interviewer.md)** - Interview assistant for building comprehensive CV/resume content.

### AI Career Path Role Prompts
**Location**: [career/ai_career_paths/](career/ai_career_paths/)

Specialized role-specific prompts for exploring AI career paths:

#### Technical Roles
- [ai_prompt_engineer.md](career/ai_career_paths/ai_prompt_engineer.md)
- [ml_engineer.md](career/ai_career_paths/ml_engineer.md)
- [deep_learning_engineer.md](career/ai_career_paths/deep_learning_engineer.md)
- [ai_research_scientist.md](career/ai_career_paths/ai_research_scientist.md)
- [nlp_engineer.md](career/ai_career_paths/nlp_engineer.md)
- [computer_vision_engineer.md](career/ai_career_paths/computer_vision_engineer.md)

#### Business & Strategy Roles
- [ai_product_manager.md](career/ai_career_paths/ai_product_manager.md)
- [ai_strategist.md](career/ai_career_paths/ai_strategist.md)
- [ai_customer_success_manager.md](career/ai_career_paths/ai_customer_success_manager.md)

#### Governance & Compliance Roles
- [ai_ethics_officer.md](career/ai_career_paths/ai_ethics_officer.md)
- [ai_governance_specialist.md](career/ai_career_paths/ai_governance_specialist.md)
- [ai_compliance_manager.md](career/ai_career_paths/ai_compliance_manager.md)

#### Specialized Roles
- [ai_coach.md](career/ai_career_paths/ai_coach.md)
- [ai_content_creator.md](career/ai_career_paths/ai_content_creator.md)
- [ai_change_management_specialist.md](career/ai_career_paths/ai_change_management_specialist.md)
- [conversational_ai_ux_designer.md](career/ai_career_paths/conversational_ai_ux_designer.md)
- [data_annotator_ai_trainer.md](career/ai_career_paths/data_annotator_ai_trainer.md)

---

## 🔄 Workflows

**Location**: [workflows/](workflows/)

Multi-step workflow prompts for complex tasks:

### Slide Deck Workflow
**Location**: [workflows/slide_deck_workflow/](workflows/slide_deck_workflow/)

Four-step workflow for creating enterprise slide decks:
- [01_corporate_style_extractor.md](workflows/slide_deck_workflow/01_corporate_style_extractor.md) - Extract corporate style from existing presentations
- [02_corporate_style_applicator.md](workflows/slide_deck_workflow/02_corporate_style_applicator.md) - Apply extracted style to new content
- [03_enterprise_deck_architect.md](workflows/slide_deck_workflow/03_enterprise_deck_architect.md) - Architect comprehensive slide deck structure
- [04_deck_assemply_and_validation.md](workflows/slide_deck_workflow/04_deck_assemply_and_validation.md) - Assemble and validate final deck

---

## 🎯 Specialized Prompts

**Location**: [specialized/](specialized/)

Domain-specific utility prompts:

- **[ai_tutor.md](specialized/ai_tutor.md)** - AI tutor for personalized learning and skill development.

---

## 📍 Project-Specific Prompts (Kept in Context)

Some prompts are kept with their specific use cases for archival purposes:

### Data Vault Refactor Prompts (UC01)
**Location**: `docs/work_tracking/ai_transformation/use_cases/uc01_dv_refactor/refactor_prompts/`

See [PROMPTS.md](../../docs/work_tracking/ai_transformation/use_cases/uc01_dv_refactor/PROMPTS.md) for UC01-specific refactor prompts.

---

## 🚀 Usage Guidelines

### Using Prompts in Claude Code

Reference prompts using the @-mention syntax:
```
@ai-resources/prompts/architecture/architecture_documentation_architect.md review my architecture documentation for gaps
```

### Creating New Prompts

1. Use [@meta/meta-prompt-engineer.md](meta/meta-prompt-engineer.md) to create high-quality prompts with systematic evaluation
2. Place general-purpose prompts in the appropriate category folder
3. Place project-specific prompts with their use case documentation
4. Update this README catalog when adding new prompts

### Prompt Maintenance

- **Versioning**: Update version numbers in frontmatter when making significant changes
- **Documentation**: Keep this README updated with new prompts
- **Archival**: When use cases complete, archive project-specific prompts with the use case folder
- **Centralization**: Keep general-purpose prompts here; avoid duplication across the repository

---

## 📊 Quick Reference

| Category | Count | Use Case |
|----------|-------|----------|
| Architecture | 3 | Technical design, Data Vault, diagrams |
| Documentation | 3 | Project docs, business rules, meeting notes |
| Meta | 3 | Prompt engineering, refactor generators |
| Career | 17 | Career planning, AI role exploration |
| Workflows | 4 | Multi-step processes (slide decks) |
| Specialized | 1 | Domain utilities (tutoring) |
| **Total** | **31** | Centralized general-purpose prompts |

---

## 🔗 Related Resources

- **Context Documents**: [ai-resources/context-documents/](../context-documents/)
- **Architecture Documentation**: [docs/architecture/](../../docs/architecture/)
- **Project Instructions**: [CLAUDE.md](../../CLAUDE.md)

---

*Last Updated: 2025-10-16 by Dan Brickey*
*Migration v2.0.0: Reorganized into categorized structure with context references*
