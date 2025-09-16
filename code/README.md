# EDP WhereScape to dbt Migration - Code Organization

## Structure Overview

This folder organizes code and artifacts for migrating from WhereScape stored procedures (SQL Server) to dbt models (Snowflake).

### 📁 Folder Purposes

#### `analysis/` - Discovery and Analysis Work
- **`source_analysis/`** - WhereScape stored procedure analysis and documentation
- **`business_rules/`** - Extracted business logic and transformation rules
- **`data_lineage/`** - Source-to-target data flow mappings
- **`gap_analysis/`** - Identified missing functionality or implementation challenges

#### `legacy/` - Source System Artifacts
- **`wherescape_exports/`** - Exported stored procedures and job definitions
- **`schema_definitions/`** - SQL Server schema documentation and DDL
- **`sample_data/`** - Representative data samples for testing
- **`use_case_1/`** - Legacy code for first use case
- **`use_case_2/`** - Legacy code for second use case

#### `target/` - dbt Implementation
- **`dbt_project/`** - Main dbt project following medallion architecture
  - `models/staging/` - Raw data cleaning and standardization
  - `models/integration/` - Business logic and Data Vault patterns
  - `models/data_mart/` - Final consumption layer
  - `macros/` - Reusable transformation logic
  - `tests/` - Data quality and business rule tests
  - `docs/` - dbt documentation and descriptions
- **`use_case_1/`** - Specific dbt implementations for first use case
- **`use_case_2/`** - Specific dbt implementations for second use case

#### `migration/` - Transition Support
- **`mapping_docs/`** - Detailed transformation specifications
- **`validation_queries/`** - Data comparison and validation scripts
- **`migration_scripts/`** - One-time data movement and setup scripts
- **`testing_framework/`** - Automated validation and regression testing

#### `examples/` - Reference Materials
- **`context_docs/`** - Business context and requirements documentation
- **`sample_transforms/`** - Example dbt patterns and implementations
- **`best_practices/`** - Coding standards and architectural guidelines

## Usage Guidelines

1. **Start with `analysis/`** - Document current state before building target state
2. **Populate `legacy/`** - Preserve original artifacts for reference and validation
3. **Develop in `target/`** - Build new dbt models following established patterns
4. **Use `migration/`** - Support the transition with validation and testing
5. **Reference `examples/`** - Leverage proven patterns and context

## Next Steps

1. Place existing context documents in `examples/context_docs/`
2. Export WhereScape artifacts to `legacy/wherescape_exports/`
3. Begin source analysis in `analysis/source_analysis/`
4. Establish dbt project structure in `target/dbt_project/`