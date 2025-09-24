mmnn# Enterprise Data Platform (EDP) Data Domain Architecture Context

## Overview

This document describes the architecture, tools, environments, and conventions for the Enterprise Data Platform (EDP) Data Domain project, designed for Data Vault 2.0 implementation using dbt and Snowflake. The EDP vision is to make it a hub for all the enterprise data needs. Both analytical and operational use cases that do not need to run directly in the source systems will be served here, and as the EDP is built out, the existing on prem services and processes will move to the EDP when dependecies are in place.

## Platform Architecture

### Core Infrastructure

- **Cloud Platform**: `AWS`
- **Data Warehouse**: `Snowflake`
- **Data Architecture**: `Data Vault 2.0` (transitioning from 3NF)
- **Transformation Tool**: `dbt Cloud`
- **Data Vault Package**: `automateDV`
- **Visualization Tool**: `Tableau Cloud`
- **Data Quality Tool**: `Anomalo`
- **Data Governance and Catalog Tool**: `Alation`

### Data Layer Architecture

```
Raw Layer → Integration Layer → Curation Layer → Consumption Layer
```

#### Layer Descriptions

- **Raw Layer**: Equivalent to a Bronze medallion layer. Raw CDC (Change Data Capture) data from source systems, snowflake shares, or ingested files.
- **Integration Layer**: Data in modular, reusable, integrated format. Some light cleansing to conform datatypes and creation of record identification keys that maintain uniqueness acrosss all sources (protection againsy key collisions). Typically source id + source PK. Raw Data Vault with Hubs, Links, and Satellites following Data Vault 2.0 methodology. We are beginning the process of refactoring our existing 3NF data model in this layer. Also contains Current Views with all satellite columns.
- **Curation Layer**: Fit for purpose data shapes. Business Vault following Data Vault 2.0 methodology, Dimensional Models, flattened datasets for ML and extracts, Small, purpose-built 3NF models to support operations application use cases (e.g. Customer Service)
- **Consumption Layer**: Common access layer with fit for use data. Data Vault Information Mart, Constrained data sets for specific sets of use cases. Targeted data marts with specialized transformations that should not be conformed across the enterprise (e.g. CMS EDGE Server data extracts, which have very particular CMS rules).

## Data Vault Naming Conventions

### Entity Prefixes and Suffixes

#### Raw Vault (Integration Layer) Naming Conventions

- **Staging Rename Tables**: `stg_<entity>_<source>_rename` (e.g. `stg_product_gemstone_facets_rename`)
- **Data Vault Staging Tables**: `stg_<entity>_<source>` (e.g. `stg_product_gemstone_facets`)
- **Hubs**: `h_<entity>` (e.g. `h_product`)
- **Links**: `l_<entity1>_<entity2>` (e.g. `l_class_group`)
- **Satellites**: `s_<entity>_<source>` (e.g. `s_product_gemstone_facets`)
- **Reference Tables**: `r__<entity>` (e.g. `r_date_spine`)
- **Current Views**: `current_<entity>`

#### Business Vault (Curation Layer) Naming Conventions

- **Business Vault Hubs**: `bv_h_<entity>_<purpose>`
- **Bridge Tables**: `bridge_<entity>_<purpose>`
- **Point-In-Time (PIT) Tables**: `pit_<entity>_<purpose>`
- **Business Vault Satellites - Calculations**: `bv_s_<entity>_calculations`
- **Business Vault Satellites - Business Rules**: `bv_s_<entity>_business_rules`
- **Business Vault Satellites - Mixed Logic**: `bv_s_<entity>_business`
- **Business Vault Reference Tables**: `bv_r_<entity>`

- **When splitting data by rate of change**: `*_hroc`, `*_mroc`, `*_lroc` (for high, medium, and low rates of change respectively)

#### Information Mart (Consumption Layer)

- **Dimensions**: `dim_<entity>` (e.g. `dim_product`)
- **Fact Tables**: `fact_<entity> (e.g. `fact_member_coverage`)
- **Bridge Tables**: `bridge_<entity>_<purpose>` (e.g. `bridge_medical_claim_procedure`)

### Source System Suffixes

Use full source_system value as suffix:

- `legacy_facets` - Legacy FACETS system
- `gemstone_facets` - Gemstone FACETS system
- `valenz` - VALENZ system

## Source Systems

### Primary Systems

1. **Legacy FACETS** (`legacy_facets`)

2. **Gemstone FACETS** (`gemstone_facets`)

## Data Vault Configuration Standards

### Standard automate_dv Columns

- **Load Date**: `load_datetime` - Load Date Time Stamp
- **Record Source**: `source` - Record Source
- **Hash Key**: `{entity}_hk` - Hub hash key (e.g. member_hk, member_provider_hk)
- **Hash Diff**: `{entity}_hashdiff` - Hash Difference for change detection (e.g. subscriber_hashdiff)

### Business Key Handling

- Support for simple and composite business keys
- Derived business key expressions using SQL functions
- Proper hashing using automate_dv macros

### Satellite Types Supported

- **Standard Satellites**: Basic attribute storage
- **Effectivity Satellites**: Time-based effective periods
- **Multi-Active Satellites**: Multiple active records per business key

### Current View Requirements

- Include all satellite columns
- Handle column name mapping and data type consistency
- Implement conflict resolution for overlapping columns
- **Default Behavior**: Use same key as hub/link including source_system
- Filter to most recent business key record from satellite for each source
- **Do not combine records from multiple sources** unless explicitly specified
- Base on hub or link table
- LEFT JOIN to satellites for current records only
- Handle null values and missing data appropriately

## Configuration Variables

### Incremental Loading

- **Load Unit**: `hh` (hourly)
- **Load Offset**: `-24` hours (overlap for late-arriving data)

### Documentation Requirements

- Relation-level documentation enabled
- Column-level documentation enabled
- Persist documentation in curation and consumption layers

---

## Usage Notes for Other Projects

When referencing this architecture in other chats or projects:

1. **Data Vault Implementation**: Follow automate_dv package conventions
2. **Naming**: Always use the specified prefixes and source system suffixes
3. **Current Views**: Default to single-source views unless multi-source is explicitly required
4. **Environment Handling**: Use the database naming patterns for proper environment separation
5. **Schema Organization**: Follow the established domain-based schema structure
6. **Testing**: Apply appropriate test severity based on environment type

This architecture is intented to support a scalable, auditable data platform with clear lineage for the transition from 3NF to Data Vault 2.0.
