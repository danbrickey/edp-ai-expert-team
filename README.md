# EDP Architecture Documentation Repository

Official architecture documentation for the Enterprise Data Platform (EDP) project at Blue Cross of Idaho.

## 📖 Start Here

**New to the documentation?** → [Documentation Index](docs/DOCUMENTATION_INDEX.md)

The Documentation Index provides AI-navigable access to all architecture, business rules, and implementation guides organized by intent, document type, business domain, and EDP layer.

**Looking for specific information?** → [Taxonomy Guide](docs/TAXONOMY.md)

The Taxonomy provides controlled vocabulary for searching and classifying documentation.

## 🗂️ Repository Structure

```
docs/
├── DOCUMENTATION_INDEX.md          # Master navigation index (START HERE)
├── TAXONOMY.md                     # Controlled vocabulary for classification
├── architecture/                   # Architecture documentation
│   ├── edp_platform_architecture.md
│   ├── edp-layer-architecture-detailed.md
│   ├── patterns/                   # Reusable architecture patterns
│   │   └── multi-tenancy-architecture.md
│   ├── rules/                      # Business domain knowledge
│   │   ├── broker/                 # Broker domain rules
│   │   ├── claims/                 # Claims domain rules
│   │   ├── financial/              # Financial domain rules
│   │   ├── membership/             # Membership domain rules
│   │   ├── product/                # Product domain rules
│   │   └── provider/               # Provider domain rules
│   └── braindumps/                 # Working notes and raw captures
└── engineering-knowledge-base/     # Implementation guides
    ├── data-vault-2.0-guide.md
    └── environment-database-configuration.md

ai-resources/                       # AI Tools & Context
├── tools/                          # Streamlit apps & utilities
├── examples/                       # Reference implementations
├── context-documents/              # Project context & requirements
└── prompts/                        # Reusable AI prompt templates
```

## 🔍 Finding Information

### Quick Navigation by Intent

**"I need to understand the overall EDP architecture..."**
- Start with [EDP Platform Architecture](docs/architecture/edp_platform_architecture.md) (Executive Summary section)

**"I need technical details about a specific layer..."**
- See [Layer Architecture Detailed](docs/architecture/edp-layer-architecture-detailed.md)

**"I need to understand business rules for a domain..."**
- Browse [Business Rules by Domain](docs/architecture/rules/)

**"I need implementation guidance..."**
- Check [Engineering Knowledge Base](docs/engineering-knowledge-base/)

**"I need to find all documentation about [topic]..."**
- Use the [Documentation Index](docs/DOCUMENTATION_INDEX.md) organized by type, domain, and layer

### By Business Domain

- **[Broker Rules](docs/architecture/rules/broker/)** - Producer/broker information, hierarchies, commissions, appointments
- **[Claims Rules](docs/architecture/rules/claims/)** - Claims processing, adjudication rules, payment rules
- **[Financial Rules](docs/architecture/rules/financial/)** - Premium billing, payment processing, accounting rules
- **[Membership Rules](docs/architecture/rules/membership/)** - Enrollment, eligibility rules, coverage determination
- **[Product Rules](docs/architecture/rules/product/)** - Plan designs, benefit structures, coverage rules
- **[Provider Rules](docs/architecture/rules/provider/)** - Provider networks, credentialing, fee schedules, reimbursement

### Key Architecture Documents

- **[EDP Platform Architecture](docs/architecture/edp_platform_architecture.md)** - High-level platform overview, AWS + Snowflake integration, medallion architecture
- **[Layer Architecture Detailed](docs/architecture/edp-layer-architecture-detailed.md)** - Detailed specifications for Raw, Integration, Curation, and Consumption layers
- **[Data Vault 2.0 Guide](docs/engineering-knowledge-base/data-vault-2.0-guide.md)** - Comprehensive Data Vault 2.0 implementation guide
- **[Multi-Tenancy Pattern](docs/architecture/patterns/multi-tenancy-architecture.md)** - Multi-tenant security pattern for data isolation

### By EDP Architecture Layer

- **Raw Layer** - Source system data landing (minimal transformation)
- **Integration Layer** - Data Vault 2.0 raw vault (historized, integrated)
- **Curation Layer** - Business vault and dimensional models (business-friendly)
- **Consumption Layer** - Purpose-built data products and analytics
- **Cross-Layer** - Patterns and standards applying across all layers

See [Documentation Index](docs/DOCUMENTATION_INDEX.md) for complete layer-specific documentation.

## 📋 Documentation Standards

All documentation follows these principles:

### Multi-Audience Layering
Documents are structured with progressive disclosure:
1. **Executive Summary** - Business context and value (2-3 min read)
2. **Analytical Overview** - Functional capabilities and requirements (5-7 min read)
3. **Technical Architecture** - Detailed technical design (15-30 min read)
4. **Implementation Specifications** - Code patterns and deployment details (reference)

### Metadata and Discoverability
Every document includes:
- **Frontmatter** - Classification using controlled vocabulary from [TAXONOMY.md](docs/TAXONOMY.md)
- **Cross-references** - Related documents and business rules
- **Audience tags** - Target readers (executives, analysts, architects, engineers)
- **Status tags** - Document lifecycle (draft, active, deprecated)

### Business Rules Documentation
Domain-specific business rules are separated from technical architecture:
- Located in `docs/architecture/rules/[domain]/`
- Include business context, rule definitions, examples, and technical implementation guidance
- Link to related architecture documentation

## 🔐 Compliance and Data Protection

**CRITICAL:** This documentation repository must remain **free of PHI/PII**.

- ✅ All examples use sanitized/fictional data
- ✅ No actual member/patient names or identifiers
- ✅ No real provider names, NPIs, or facility addresses
- ✅ No medical record numbers, claim numbers, or SSNs
- ✅ Dates use relative references or year-only
- ✅ Contact information uses generic references

If you discover any PHI/PII in documentation, immediately report it to the repository maintainer.

## 📝 Contributing and Updating Documentation

### For Architecture and Business Rules Updates

1. **Create a branch** for your changes
   ```bash
   git checkout -b feature/update-claims-rules
   ```

2. **Make your updates** following documentation standards:
   - Use controlled vocabulary from [TAXONOMY.md](docs/TAXONOMY.md)
   - Include proper frontmatter metadata
   - Follow multi-audience layering for architecture docs
   - Use business rules template for domain rules

3. **Update the index**:
   - Add new documents to [DOCUMENTATION_INDEX.md](docs/DOCUMENTATION_INDEX.md)
   - Update relevant sections (by type, domain, layer)
   - Ensure cross-references are bidirectional

4. **Submit merge request** for review

5. **After approval**, changes are merged to `main` branch

### Documentation Quality Checklist

Before submitting updates, verify:
- [ ] Proper frontmatter with taxonomy tags
- [ ] Multi-audience content layers (if architecture doc)
- [ ] Business context provided (if business rules doc)
- [ ] Cross-references to related documentation
- [ ] Added to DOCUMENTATION_INDEX.md
- [ ] **Free of PHI/PII** - all examples sanitized
- [ ] Clear, concise writing appropriate to audience

## 🤖 AI-Assisted Documentation

This documentation structure is optimized for AI-powered navigation and assistance:

- **TAXONOMY.md** provides controlled vocabulary for semantic search
- **DOCUMENTATION_INDEX.md** offers intent-based navigation
- **Frontmatter metadata** enables precise filtering and discovery
- **Cross-references** create a knowledge graph of related concepts

AI tools can use these resources to quickly locate relevant documentation when answering questions or performing tasks.

## 🏗️ EDP Architecture Context

### Platform Overview
The Enterprise Data Platform (EDP) is a modern cloud-based data platform built on:
- **AWS** - Cloud infrastructure
- **Snowflake** - Cloud data warehouse
- **dbt** - Data transformation and modeling
- **Data Vault 2.0** - Integration layer modeling methodology
- **Dimensional Modeling** - Consumption layer analytics patterns

### Medallion Architecture Layers
1. **Raw** - Source system landing zone
2. **Integration** - Data Vault 2.0 historized hub-link-satellite models
3. **Curation** - Business vault computations and dimensional models
4. **Consumption** - Analytics-ready data products

### Business Domains
- Broker, Claims, Financial, Membership, Network, Product, Provider, Regulatory, Utilization

See [EDP Platform Architecture](docs/architecture/edp_platform_architecture.md) for comprehensive overview.

## 👥 Team and Contacts

**EDP Data & Solution Architect:** Dan Brickey

**Key Stakeholders:**
- **CIO:** David Yoo
- **Director of Data and Analytics:** Ram Garimella
- **EDP Program Manager:** Linsey Smith
- **Enterprise Architects:** Sani Messenger, Dom Desimini, Rich Tallon

**EDP Delivery Teams:**
- Admin Team (Snowflake config, RBAC) - PO: Sam Schrader
- Ingestion Team - Manager: Kelly Good Clark
- OneView Team - PO: Jesse Ahern
- Extracts Team - PO: Carl Morse
- HDS Team (On-prem DW) - Manager: Rob Hopper

See [CLAUDE.md](CLAUDE.md) for complete team structure and project context.

## 📚 Additional Resources

- **[CLAUDE.md](CLAUDE.md)** - Project context for AI assistants (team structure, repository overview)
- **[Architecture Prompts](ai-resources/prompts/documentation/)** - AI assistant prompts for documentation work
- **[Data Vault 2.0 Guide](docs/engineering-knowledge-base/data-vault-2.0-guide.md)** - Complete implementation reference
- **[EDP Work Plan](ai-resources/context-documents/edp-work-plan-breakdown.md)** - Functional area breakdown

---

**Version:** 2.0.0
**Last Updated:** 2025-10-16
**Maintained By:** Dan Brickey, EDP Data & Solution Architect
