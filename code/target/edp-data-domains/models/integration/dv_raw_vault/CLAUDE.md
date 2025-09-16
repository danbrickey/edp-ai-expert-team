# Raw Vault - Integration Layer Context

## Purpose
The Raw Vault implements Data Vault 2.0 methodology in the Integration layer, storing all source data in hub-and-spoke architecture with full historization and auditability. This layer provides the foundation for all downstream data transformations.

## Raw Vault Architecture

### Entity Structure
- **`hubs/`** - Business entities with unique business keys
- **`links/`** - Relationships between business entities
- **`sat/`** - Descriptive attributes and historical changes
- **`current_views/`** - Business-friendly interfaces to Raw Vault data

## Naming Conventions

### Core Entities
- **Hubs**: `h_<entity>` (e.g., `h_member`, `h_provider`, `h_claim`)
- **Links**: `l_<entity1>_<entity2>` (e.g., `l_member_provider`, `l_claim_procedure`)
- **Satellites**: `s_<entity>_<source>` (e.g., `s_member_legacy_facets`, `s_provider_gemstone_facets`)
- **Reference Tables**: `r_<entity>` (e.g., `r_date_spine`)

### Supporting Objects
- **Staging Rename**: `stg_<entity>_<source>_rename`
- **Data Vault Staging**: `stg_<entity>_<source>`
- **Current Views**: `current_<entity>` (e.g., `current_member`, `current_provider`)

## Source System Integration

### Source System Codes
- **`legacy_facets`** - Legacy FACETS system (historical data)
- **`gemstone_facets`** - Gemstone FACETS system (current operational)
- **`valenz`** - VALENZ system (additional data source)

### Business Key Strategy
Based on legacy data dictionary analysis, implement composite business keys for:
- **Members**: Combine member ID with source system to prevent key collisions
- **Providers**: Use provider NPI where available, fall back to source-specific IDs
- **Claims**: Combine claim number with source system for uniqueness
- **Procedures**: Use standard procedure codes (CPT, HCPCS) with modifiers

## Standard automate_dv Columns

### Required Columns
- **`load_datetime`** - Load Date Time Stamp (audit trail)
- **`source`** - Record Source (data lineage)
- **`{entity}_hk`** - Hub Hash Key (unique identifier)
- **`{entity}_hashdiff`** - Hash Difference (change detection)

### Implementation Pattern
```sql
-- Example Hub
{{ automate_dv.hub(
    src_pk='member_hk',
    src_nk='member_business_key',
    src_ldts='load_datetime',
    src_source='source',
    source_model='stg_member_legacy_facets'
) }}

-- Example Satellite
{{ automate_dv.sat(
    src_pk='member_hk',
    src_hashdiff='member_hashdiff',
    src_payload=['first_name', 'last_name', 'date_of_birth'],
    src_eff='effective_from',
    src_ldts='load_datetime',
    src_source='source',
    source_model='stg_member_legacy_facets'
) }}
```

## Healthcare Domain Entities

### Core Member Hub (`h_member`)
**Business Key Strategy**: `member_id || '|' || source_system`
**Key Satellites**:
- `s_member_legacy_facets` - Historical member demographics
- `s_member_gemstone_facets` - Current member information
- `s_member_eligibility` - Coverage and benefit information

### Core Provider Hub (`h_provider`)
**Business Key Strategy**: `provider_npi` OR `provider_id || '|' || source_system`
**Key Satellites**:
- `s_provider_legacy_facets` - Provider demographics and contracts
- `s_provider_gemstone_facets` - Current provider information
- `s_provider_credentials` - Licensing and certification data

### Core Claim Hub (`h_claim`)
**Business Key Strategy**: `claim_number || '|' || source_system`
**Key Satellites**:
- `s_claim_header` - Basic claim information
- `s_claim_financial` - Payment and adjustment details
- `s_claim_clinical` - Medical coding and diagnosis

### Key Links
- **`l_member_provider`** - Member-provider relationships (PCP assignments, referrals)
- **`l_claim_member`** - Claims associated with members
- **`l_claim_provider`** - Claims associated with providers
- **`l_claim_procedure`** - Procedures performed on claims

## Legacy Data Dictionary Integration

### BPA System Context
The legacy data dictionary reveals Business Process Application (BPA) tables containing:
- **Rule Groups** (`bpa_brgr_rul_grp_r`): Configure business process rules
- **Service Categories** (`bpa_dpsc_svc_cat_a`): Healthcare service classification
- **Data States** (`bpa_dsas_data_state`): Entity lifecycle tracking
- **Conditions** (`bpa_dscr_cond_r`): Business condition definitions

### Business Key Derivation
Reference `legacy_data_dictionary.csv` for:
- **Primary Keys**: Original table key structures
- **Business Identifiers**: Member IDs, provider IDs, claim numbers
- **Relationship Keys**: Foreign key patterns between entities
- **Effective Dating**: Temporal validity patterns

## Current Views Implementation

### Design Principles
- **Single-Source Default**: Each current view shows latest data from one source system
- **No Cross-Source Combination**: Avoid merging conflicting data without explicit business rules
- **Hub-Based**: Join from hub to get all satellite attributes for current state
- **Latest Record**: Filter satellites to most recent `load_datetime` per business key

### Current View Template
```sql
-- current_member example
select
    h.member_hk,
    h.member_business_key,
    h.load_datetime as hub_load_datetime,
    s.first_name,
    s.last_name,
    s.date_of_birth,
    s.load_datetime as sat_load_datetime
from {{ ref('h_member') }} h
left join {{ ref('s_member_legacy_facets') }} s
    on h.member_hk = s.member_hk
    and s.load_datetime = (
        select max(load_datetime)
        from {{ ref('s_member_legacy_facets') }} s2
        where s2.member_hk = h.member_hk
    )
```

## Incremental Loading Strategy

### Configuration
- **Load Unit**: Hourly (`hh`)
- **Load Offset**: -24 hours (overlap for late-arriving data)
- **Change Detection**: Use `hashdiff` columns for efficient incremental processing

### Implementation
```sql
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='member_hk'
) }}
```

## Data Quality and Testing

### Hub Testing
- Business key uniqueness within load batch
- Hash key consistency and collision detection
- Source system coverage validation

### Satellite Testing
- Hash difference change detection accuracy
- Temporal consistency (no future effective dates)
- Referential integrity to parent hubs/links

### Link Testing
- Valid relationships between existing hub entities
- Business rule compliance for relationship types
- Temporal relationship consistency

## Reference Files
- **Platform Architecture**: `../../../edp_platform_architecture.md` - Detailed naming conventions
- **Legacy Dictionary**: `../../../legacy_data_dictionary.csv` - Source system context
- **Business Vault**: `../../curation/biz_vault/` - Downstream business logic layer