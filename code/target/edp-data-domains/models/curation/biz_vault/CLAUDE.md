# Business Vault - Curation Layer Context

## Purpose
The Business Vault layer implements calculated fields, business rules, and derived insights on top of the Raw Vault foundation. This follows Data Vault 2.0 methodology for the curation layer in our medallion architecture.

## Business Vault Implementation Standards

### Naming Conventions
- **Business Hubs**: `bv_h_<entity>_<purpose>`
- **Business Satellites - Calculations**: `bv_s_<entity>_calculations`
- **Business Satellites - Business Rules**: `bv_s_<entity>_business_rules`
- **Business Satellites - Mixed Logic**: `bv_s_<entity>_business`
- **Bridge Tables**: `bridge_<entity>_<purpose>`
- **Point-In-Time Tables**: `pit_<entity>_<purpose>`
- **Reference Tables**: `bv_r_<entity>`

### Rate of Change Suffixes
When splitting data by rate of change, append:
- `*_hroc` - High rate of change (frequent updates)
- `*_mroc` - Medium rate of change (moderate updates)
- `*_lroc` - Low rate of change (infrequent updates)

## Business Logic Categories

### 1. Calculations (`bv_s_<entity>_calculations`)
- **Financial Calculations**: Premium computations, claim reserves, actuarial calculations
- **Derived Metrics**: Member tenure, provider performance scores, utilization rates
- **Aggregations**: Rolling totals, year-to-date amounts, trend calculations
- **Business KPIs**: Quality measures, risk scores, efficiency metrics

### 2. Business Rules (`bv_s_<entity>_business_rules`)
- **Compliance Rules**: HIPAA requirements, regulatory compliance flags
- **Eligibility Logic**: Coverage determination, benefit calculations
- **Validation Rules**: Data quality checks, business constraint validation
- **Classification Logic**: Risk categories, member segments, provider tiers

### 3. Cross-Entity Relationships (`bridge_<entity>_<purpose>`)
- **Complex Associations**: Many-to-many relationships requiring business logic
- **Temporal Relationships**: Time-based associations with effective periods
- **Hierarchical Structures**: Organizational hierarchies, product families
- **Network Analysis**: Provider networks, referral patterns

## Data Sources and Context

### Legacy System Integration
Reference the `legacy_data_dictionary.csv` for business context:
- **BPA Tables**: Business Process Application rules and configurations
- **Entity Descriptions**: Original business purpose and usage
- **Column Meanings**: Business definitions and calculation logic
- **Data Relationships**: Cross-table dependencies and joins

### Key Business Entities from Legacy Data
Based on legacy dictionary analysis:
- **Rule Groups** (`bpa_brgr_rul_grp_r`): Business process rules and configurations
- **Service Categories** (`bpa_dpsc_svc_cat_a`): Healthcare service classification
- **Data States** (`bpa_dsas_data_state`): Entity lifecycle and status tracking
- **Conditions** (`bpa_dscr_cond_r`): Business conditions and qualifiers

## Implementation Guidelines

### Business Vault Satellite Design
```sql
-- Example: Business calculations satellite
{{ automate_dv.sat(
    src_pk='member_hk',
    src_hashdiff='member_business_hashdiff',
    src_payload=[...],
    src_eff='effective_datetime',
    src_ldts='load_datetime',
    src_source='business_vault',
    source_model='stg_member_business_calculations'
) }}
```

### Point-In-Time Table Pattern
- **Purpose**: Snapshot business state at specific points in time
- **Use Cases**: Member eligibility at claim date, provider status at service date
- **Implementation**: Join Raw Vault data with business effective dates

### Business Rule Documentation
For each Business Vault object, document:
1. **Business Purpose**: Why this calculation/rule exists
2. **Source Logic**: Which Raw Vault entities provide input
3. **Calculation Method**: Specific formulas and business rules
4. **Validation Rules**: Expected ranges, constraints, quality checks
5. **Refresh Frequency**: How often business logic should recalculate

## Healthcare-Specific Business Logic

### Member-Related Business Vault
- **Member Tenure Calculations**: Coverage duration, gaps in coverage
- **Risk Scoring**: Health risk assessments, predictive modeling
- **Eligibility Rules**: Coverage determination logic, benefit calculations
- **Utilization Metrics**: Healthcare usage patterns, cost trends

### Provider-Related Business Vault
- **Network Status**: In-network vs out-of-network determination
- **Performance Metrics**: Quality scores, efficiency measures
- **Credentialing Status**: License validation, specialty certification
- **Payment Calculations**: Fee schedules, reimbursement rates

### Claims-Related Business Vault
- **Claim Processing Rules**: Adjudication logic, approval workflows
- **Medical Necessity**: Coverage determination, prior authorization
- **Fraud Detection**: Anomaly detection, suspicious pattern identification
- **Cost Management**: Cost sharing calculations, benefit limits

## Development Workflow

1. **Identify Business Need**: What business question needs answering?
2. **Map Raw Vault Sources**: Which hubs/links/satellites provide data?
3. **Define Business Logic**: Document calculations and rules clearly
4. **Create Business Vault Models**: Implement using automate_dv patterns
5. **Test Business Rules**: Validate calculations against known scenarios
6. **Document for Consumption**: Prepare for Information Mart layer

## Reference Files
- **Platform Architecture**: `../../../edp_platform_architecture.md` - Technical standards
- **Legacy Dictionary**: `../../../legacy_data_dictionary.csv` - Business context
- **Raw Vault Models**: `../integration/dv_raw_vault/` - Source data structures