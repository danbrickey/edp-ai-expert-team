# EDP Data Domains - Target Implementation Context

## Project Overview

This target folder contains the implementation code for migrating WhereScape stored procedures to dbt models on Snowflake, following Data Vault 2.0 methodology. The primary dbt project is **edp-data-domains** with specific use case implementations organized separately.

## Project Structure

### Main dbt Project: `edp-data-domains/`
- **Purpose**: Core Data Vault 2.0 implementation for Enterprise Data Platform
- **Architecture**: Medallion pattern with Raw ’ Integration ’ Curation ’ Consumption layers
- **Platform**: Snowflake on AWS using dbt Cloud and automate_dv package

#### Layer Organization:
- **`models/integration/dv_staging/`** - Source staging and renaming for Data Vault
- **`models/integration/dv_raw_vault/`** - Hubs, Links, Satellites, and Current Views
- **`models/curation/biz_vault/`** - Business Vault with calculations and business rules
- **`models/curation/edw3/`** - Existing 3NF models being refactored
- **`models/consumption/`** - Information marts and dimensional models
- **`models/common/`** - Shared macros and reference tables

### Use Case Projects:
- **`uc01_dv_refactor/`** - Data Vault refactoring from existing 3NF models
- **`uc02_edw2_refactor/`** - Legacy EDW2 system migration

## Platform Architecture Context

### Core Infrastructure
- **Cloud Platform**: AWS
- **Data Warehouse**: Snowflake
- **Transformation Tool**: dbt Cloud
- **Data Vault Package**: automate_dv (automateDV)
- **Visualization**: Tableau Cloud
- **Data Quality**: Anomalo
- **Data Governance**: Alation

### Source Systems
- **Legacy FACETS** (`legacy_facets`) - Historical claims and member data
- **Gemstone FACETS** (`gemstone_facets`) - Current operational system
- **VALENZ** (`valenz`) - Additional data source

### Data Vault Naming Conventions
- **Hubs**: `h_<entity>` (e.g., `h_member`, `h_provider`)
- **Links**: `l_<entity1>_<entity2>` (e.g., `l_member_provider`)
- **Satellites**: `s_<entity>_<source>` (e.g., `s_member_legacy_facets`)
- **Current Views**: `current_<entity>` (single-source, latest records)
- **Business Vault**: `bv_h_<entity>_<purpose>`, `bv_s_<entity>_business`

## Legacy Data Dictionary Reference

The `legacy_data_dictionary.csv` contains metadata from legacy systems including:
- **Source Schema/Table/Column**: Original system structure
- **Descriptions**: Business context for tables and columns
- **Data Types**: Original SQL Server data types
- **Coverage**: Includes BPA (Business Process Application) tables and core entities

## Key Implementation Guidelines

### Data Vault Standards
- Use `load_datetime`, `source`, `{entity}_hk`, `{entity}_hashdiff` columns
- Implement Current Views with single-source filtering by default
- Support composite business keys and derived expressions
- Follow automate_dv macro conventions for hub/link/satellite generation

### Development Workflow
1. **Analysis Phase**: Document source analysis in `../analysis/`
2. **Staging**: Create `stg_<entity>_<source>_rename` and `stg_<entity>_<source>` models
3. **Raw Vault**: Generate hubs, links, and satellites using automate_dv
4. **Current Views**: Create business-friendly interfaces to Raw Vault
5. **Business Vault**: Implement calculations and business rules in Curation layer
6. **Information Marts**: Build dimensional models in Consumption layer

### Environment Configuration
- **Incremental Loading**: Hourly with 24-hour overlap for late data
- **Documentation**: Enabled for relation and column levels
- **Testing**: Environment-appropriate test severity levels

## Related Context Files

- **`edp_platform_architecture.md`** - Detailed platform and naming conventions
- **`legacy_data_dictionary.csv`** - Source system metadata and business context
- **Main Project CLAUDE.md**: `../../../CLAUDE.md` - EDP AI Expert Team context
- **Architecture Baseline**: `../../../ai-resources/context-documents/edp-architecture-baseline.md`

## Quick References

**When working on Data Vault models:**
1. Follow naming conventions in `edp_platform_architecture.md`
2. Reference legacy dictionary for business context
3. Use automate_dv macros for consistent implementation
4. Create Current Views for business user access
5. Implement incremental loading with proper lookback windows

**For new entity modeling:**
1. Identify business keys from legacy data dictionary
2. Design hub first, then supporting links and satellites
3. Consider source system variations in satellite design
4. Plan Current View column mapping and conflict resolution