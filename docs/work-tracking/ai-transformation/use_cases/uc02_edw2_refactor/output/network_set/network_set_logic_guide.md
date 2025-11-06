---
title: "Network Set Logic Guide"
document_type: "logic_guide"
industry_vertical: "Healthcare Payer"
business_domain: ["provider", "membership", "product"]
edp_layer: "business_vault"
technical_topics: ["network-management", "effectivity-satellite", "data-vault-2.0", "temporal-joins", "provider-networks"]
audience: ["executive-leadership", "management-product", "business-analyst", "engineering"]
status: "draft"
last_updated: "2025-11-05"
version: "1.0"
author: "Dan Brickey"
description: "Comprehensive logic guide for network set dimension and temporal member/provider network assignment tracking"
related_docs:
  - "docs/work-tracking/ai-transformation/use_cases/uc02_edw2_refactor/output/network_set/network_set_business_rules.md"
  - "docs/architecture/edp_platform_architecture.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
model_name: "bv_s_network_set, bv_s_member_network_set_business, bv_sprovider_network_set_business"
legacy_source: "EDW2 dimNetworkSet stored procedures"
source_code_type: "dbt"
---

# Network Set – Logic Guide

## Executive Summary

The Network Set logic ensures accurate provider network assignments for members and providers across all plan periods. This capability directly supports claims processing accuracy, contract compliance, and network adequacy reporting. By tracking network relationships temporally, the system enables precise in-network versus out-of-network determinations for any date, protecting the organization from improper claims payments and member grievances. The logic processes network definitions from multiple source systems, creates time-accurate member-to-network assignments based on eligibility and plan relationships, and maintains complete historical provider network participation records supporting approximately 2 million claims per month.

### Key Terms

**Temporal Effectivity**: The practice of maintaining non-overlapping date ranges that track exactly when specific network assignments or relationships were valid, enabling point-in-time queries for any historical date.

**Network Set Prefix**: A short alphanumeric code (e.g., 'BCI', 'ABC') that identifies a grouping of provider networks used to define which providers members can access under specific benefit plans.

## Management Overview

**Purpose and Scope**
- Provides three interconnected capabilities: master network set definitions, temporal member network assignments, and temporal provider network participation tracking
- Consolidates network data from legacy FACETS systems and BCI Master Data Management (MDM) system into a single source of truth
- Supports claims adjudication, provider directory accuracy, benefit eligibility determination, and regulatory compliance reporting

**Operational Impact**
- Enables claims processing systems to determine network status for approximately 2 million monthly claims
- Supports provider directory tools that display current network participation to members and service representatives
- Feeds network adequacy reporting required for state and federal regulatory compliance
- Eliminates manual lookups by maintaining automated temporal tracking of all network changes

**Historical Context and Cutoffs**
- Network Set dimension excludes networks terminated before January 1, 2016 to reduce data volume while retaining operationally relevant history
- Member network assignments track eligibility terminating on or after January 1, 2017
- Provider network participation establishes baseline as of January 1, 2003 with synthetic records for providers joining after that date

**Data Refresh and Currency**
- Updates incrementally with each data warehouse refresh (typically daily)
- Current record indicators enable instant filtering for active-as-of-today relationships
- Historical versions maintained for audit, compliance, and retrospective analysis

**Cross-System Dependencies**
- Requires synchronized data from eligibility systems, plan configuration, and provider contracting systems
- Downstream impacts include claims adjudication, provider directories, benefit determination, financial reporting, and compliance reporting
- Failures or delays in upstream systems directly impact network assignment accuracy

**Data Quality Controls**
- Deduplication logic ensures single record per network set
- Temporal join validation prevents invalid date range combinations
- Gap removal eliminates periods where no valid network assignment exists
- Recursive date consolidation merges adjacent periods with identical attributes to prevent unnecessary fragmentation

**Known Limitations**
- Member network assignments limited to medical product category only (excludes dental, vision)
- Recursive consolidation capped at 99 levels to prevent infinite loops
- MDM integration partial; flag tracks which networks have been validated through governance process

## Analyst Detail

### Key Business Rules

**Network Set Historical Cutoff**: When `network_set_term_dt >= '01/01/2016'`, include the network set in the dimension, except when `network_set_prefix is null`. This excludes obsolete historical networks that are no longer operationally relevant while maintaining sufficient history for current analysis needs.

**Member Eligibility Filtering**: When `eligibility_ind = 'Y'` AND `product_category_bk = 'M'` AND `elig_term_dt >= '01/01/2017'`, include the member eligibility record, except when `edp_record_status <> 'Y'`. This ensures only active medical eligibility records with recent termination dates are processed.

**Temporal Plan-to-Eligibility Join**: When `plan_eff_dt <= elig_term_dt` AND `plan_term_dt >= elig_eff_dt`, include the plan-member relationship. This ensures the plan coverage period overlaps with the member's eligibility period, preventing invalid network assignments.

**Temporal Network-to-Plan Join**: When `network_set_eff_dt <= plan_term_dt` AND `network_set_term_dt >= plan_eff_dt` AND `network_set_eff_dt <= elig_term_dt` AND `network_set_term_dt >= elig_eff_dt`, assign the network set to the member. This triple-temporal join ensures network assignments only exist when all three date ranges (eligibility, plan, network) overlap.

**Network Name Source Resolution**: When `source = 'legacy_facets'`, use `current_network.network_name`, except when source is not legacy_facets then use `current_product_component.component_prefix_description` where `component_type_bk = 'NWST'`. This handles different naming conventions across source systems.

**Provider Overlapping Date Adjustment**: When `provider_network_eff_dt = lag(provider_network_eff_dt)` for the same provider-network-prefix combination, then shift the later record's effective date to `dateadd(day, 1, lag(provider_network_term_dt))`, except when it's the first record. This resolves overlapping date ranges in source data.

**Provider Pre-2003 Baseline**: When `min(provider_network_eff_dt) > '2003-01-01'` for a provider-network-prefix combination, then create synthetic record with `provider_network_eff_dt = '2003-01-01'` AND `provider_network_term_dt = dateadd(day, -1, min(provider_network_eff_dt))`. This establishes that the provider was not in the network before their first recorded participation.

**Contiguous Date Range Consolidation**: When `dateadd(day, -1, next_start_date) = current_end_date` AND `member_bk = member_bk` AND `network_set_prefix = network_set_prefix` AND `network_id = network_id`, then merge the adjacent date ranges by extending `end_date` to `max(end_date)` across all contiguous periods. This eliminates unnecessary fragmentation in temporal records.

### Data Flow & Transformations

The Network Set logic implements a three-stage transformation pipeline that processes network definitions, member assignments, and provider participation through distinct layers of the enterprise data platform.

**Stage 1: Network Set Dimension Creation** begins by unioning two sources: raw vault network sets joined with network names and product components, plus MDM provider networks with standardized attributes. The transformation applies deduplication using `row_number()` partitioned by `network_set` and `network_id`, prioritizing records by source system descending. For legacy FACETS records, network names come from the network master table; for other sources, names derive from product component descriptions.

```sql
-- Example: Network set union and name resolution
select
    case
       when lower(nwst.source) = 'legacy_facets'
          then nwnw.network_name
       else pdpx.component_prefix_description
    end network_name,
    nwst.network_set_prefix network_set,
    'N' mdm_captured
from {{ ref('current_network_set') }} nwst
join {{ ref('current_network') }} nwnw
    on nwnw.network_bk = nwst.network_id
where nwst.network_set_term_dt >= '01/01/2016'
union all
select facets_network_set as network_set,
    'Y' as mdm_captured
from {{ ref('r_provider_network_mdm') }}
```

**Stage 2: Member Network Assignment** employs a sophisticated temporal effectivity algorithm spanning nine CTEs. First, it filters active medical eligibility and joins to group plan assignments using temporal overlap conditions. Then it collects all potential boundary dates (effective dates, termination dates, day-after-termination, day-before-effective) from eligibility, plan, and network set tables. The logic pairs each from_date with the nearest thru_date using `row_number()` ordered by date difference, creating discrete non-overlapping date ranges. For each range, it identifies which network assignment is valid by checking if the range's start date falls within all three temporal windows (eligibility, plan, network), using `network_set_seq_no` to prioritize when multiple networks qualify. Finally, a recursive CTE consolidates adjacent date ranges with identical attributes.

```sql
-- Example: Temporal date range pairing
select from_date, thru_date,
    row_number() over (
        partition by source, member_bk, from_date
        order by datediff(day, from_date, thru_date) asc
    ) rownum
from from_dates
inner join thru_dates using (source, member_bk)
where datediff(day, from_date, thru_date) >= 0
```

**Stage 3: Provider Network Participation** first handles overlapping effective dates in source data by adjusting later records to start the day after the prior record's termination. Window functions track prior and next dates to determine participation status ('Active' when no subsequent record exists, 'InActive' otherwise). The logic enriches provider-network relationships with network names, types, and prefix descriptions, applying special handling for the 'BCI' prefix. It calculates effectivity satellite dates using `1900-01-01` as the start date for the earliest record and `2999-12-31` as the end date for the latest record, with historical records receiving calculated end dates based on the next record's start date.

```sql
-- Example: Provider network date range calculation
select provider_bk, network_bk,
    case
        when provider_network_eff_dt = min_provider_network_eff_dt
            then cast('1900-01-01' as date)
        else cast(provider_network_eff_dt as date)
    end dss_start_date,
    case
        when provider_network_eff_dt = max_provider_network_eff_dt
            then cast('2999-12-31' as date)
        else cast(lead(provider_network_eff_dt, 1) over (...) as date) - 1
    end dss_end_date
```

### Validation & Quality Checks

**Network Set Uniqueness Check**: Verify all combinations of `network_set` and `network_id` appear exactly once in the dimension. Query: `SELECT network_set, network_id, COUNT(*) FROM bv_s_network_set GROUP BY network_set, network_id HAVING COUNT(*) > 1` should return zero rows.

**Member Network Temporal Integrity**: Verify no overlapping date ranges exist for the same member and network combination. Query: `SELECT a.member_bk FROM bv_s_member_network_set_business a JOIN bv_s_member_network_set_business b ON a.member_bk = b.member_bk WHERE a.dss_end_date >= b.dss_start_date AND a.dss_start_date <= b.dss_end_date AND a.dss_start_date <> b.dss_start_date` should return zero rows.

**Provider Network Gap Detection**: Verify all provider-network-prefix combinations have contiguous date ranges with no gaps. Query: `SELECT a.provider_bk FROM prep_provider_network_set_business a JOIN prep_provider_network_set_business b ON a.provider_bk = b.provider_bk AND a.network_id = b.network_id WHERE dateadd(day, 1, a.end_date) < b.start_date` should identify any gaps in coverage.

**Referential Integrity Check**: Verify all `hk_member` values in member network set exist in `h_member` hub. Query: `SELECT COUNT(*) FROM bv_s_member_network_set_business a LEFT JOIN h_member b ON a.hk_member = b.member_hk WHERE b.member_hk IS NULL` should return zero.

**Current Record Indicator Validation**: Verify `is_current = '1'` only when today's date falls between `dss_start_date` and `dss_end_date`. Query: `SELECT COUNT(*) FROM bv_s_member_network_set_business WHERE is_current = '1' AND (current_date < dss_start_date OR current_date > dss_end_date)` should return zero.

### Example Scenario

**Scenario**: Member M12345 enrolls in a group plan with network set 'ABC' effective January 1, 2024. On March 1, 2024, the employer switches to network set 'XYZ' while the member remains enrolled. On June 30, 2024, the member's eligibility terminates.

**Input Data**:
- `current_member_eligibility`: member_bk='M12345', elig_eff_dt='2024-01-01', elig_term_dt='2024-06-30'
- `current_group_plan_eligibility`: plan_eff_dt='2024-01-01', plan_term_dt='2024-02-29', network_set_prefix='ABC'
- `current_group_plan_eligibility`: plan_eff_dt='2024-03-01', plan_term_dt='9999-12-31', network_set_prefix='XYZ'
- `current_network_set`: network_set_prefix='ABC', network_set_eff_dt='2020-01-01', network_set_term_dt='9999-12-31', network_id='100'
- `current_network_set`: network_set_prefix='XYZ', network_set_eff_dt='2023-06-01', network_set_term_dt='9999-12-31', network_id='200'

**Transformation Logic**: The temporal join algorithm collects boundary dates: 2024-01-01 (elig_eff), 2024-02-29 (plan_term for ABC), 2024-03-01 (plan_eff for XYZ), 2024-06-30 (elig_term). It creates discrete ranges and assigns networks where all three temporal windows overlap. The ABC network qualifies from 2024-01-01 through 2024-02-29. The XYZ network qualifies from 2024-03-01 through 2024-06-30.

**Output Data**:
- `bv_s_member_network_set_business`: member_bk='M12345', network_set_prefix='ABC', network_id='100', dss_start_date='2024-01-01', dss_end_date='2024-02-29', is_current='0'
- `bv_s_member_network_set_business`: member_bk='M12345', network_set_prefix='XYZ', network_id='200', dss_start_date='2024-03-01', dss_end_date='2024-06-30', is_current='1' (if today falls in this range)

## Engineering Reference

### Technical Architecture

The Network Set implementation follows a layered Data Vault 2.0 architecture within the Enterprise Data Platform:

**Integration Layer (Raw Vault)**:
- Source tables: `current_network_set`, `current_network`, `current_member_eligibility`, `current_group_plan_eligibility`, `current_provider_network_relational`, `current_product_component`, `current_user_defined_code_translations`
- Reference data: `r_provider_network_mdm`
- Hubs: `h_member`, `h_provider`

**Business Vault Layer (Computed Satellites)**:
- `bv_s_network_set`: Network set dimension satellite
- `bv_s_member_network_set_business`: Member network assignment effectivity satellite
- `bv_sprovider_network_set_business`: Provider network participation effectivity satellite

**Curation Layer (Dimensional Model)**:
- `dim_network_set`: Dimensional table for downstream consumption

**Pipeline DAG**:
1. `prep_network_set.sql` → `stg_network_set.sql` → `bv_s_network_set.sql`
2. `prep_member_network_set_business.sql` → `stg_member_network_set_business.sql` → `bv_s_member_network_set_business.sql`
3. `prep_provider_network_set_business.sql` → `stg_provider_network_set_business.sql` → `bv_sprovider_network_set_business.sql`

**Materialization Strategy**:
- Prep models: Materialized as views for lightweight transformation
- Staging models: Views generating hash keys using automate_dv macros
- Business vault models: Incremental tables using automate_dv satellite macro with merge strategy

### Critical Implementation Details

**Incremental Logic**: Business vault satellites use the automate_dv `sat()` macro with default incremental merge strategy. The macro compares `src_hashdiff` values to detect changes, inserting new records only when hashdiff differs from the latest record for each primary key.

**Join Strategy**:
- Network Set: Simple inner joins with 1:1 cardinality between network_set and network (one network per network set prefix)
- Member Network: Complex many-to-many resolved through temporal filtering and sequence number prioritization (one eligibility can have multiple plans, one plan can have multiple network sets)
- Provider Network: 1:many relationship between provider and networks (one provider participates in multiple networks over time)

**Filters**: Critical WHERE clauses include `edp_record_status = 'Y'` (excludes soft-deleted records), date cutoffs for historical data reduction, and null exclusions for data quality.

**Aggregations**: Member network logic uses recursive CTE with `max(end_date)` grouped by `start_date` to collapse contiguous date ranges. Provider network uses `max(provider_network_term_dt)` grouped by effective date to handle duplicate termination dates.

**Change Tracking**: Effectivity satellites track changes using `dss_start_date` and `dss_end_date` columns following Type 2 SCD pattern. Current records use high dates (9999-12-31 or 2999-12-31) for open-ended validity. Hash diff columns detect attribute changes.

**Performance Considerations**:
- Partitioning by source and member_bk in window functions reduces memory footprint
- Row number deduplication limits result sets early in CTEs
- Recursive CTE has hard limit of 99 iterations to prevent runaway queries
- Views for prep layers enable Snowflake query pruning

### Code Examples

**Complex Temporal Join Logic**:
```sql
-- Purpose: Create temporal overlap between eligibility, plan, and network set
-- Critical: All three date ranges must overlap for valid network assignment

select
    current_member.member_bk,
    current_network_set.network_set_prefix,
    membernetworksetlookup_nondv_01.elig_eff_dt,
    membernetworksetlookup_nondv_01.elig_term_dt,
    current_group_plan_eligibility.plan_eff_dt,
    current_group_plan_eligibility.plan_term_dt,
    current_network_set.network_set_eff_dt,
    current_network_set.network_set_term_dt
from {{ ref('current_member') }} current_member
inner join membernetworksetlookup_nondv_01
    on membernetworksetlookup_nondv_01.member_bk = current_member.member_bk
inner join {{ ref('current_group_plan_eligibility') }} current_group_plan_eligibility
    on current_group_plan_eligibility.group_bk = membernetworksetlookup_nondv_01.group_bk
    -- Temporal join: plan overlaps eligibility
    and (current_group_plan_eligibility.plan_eff_dt <= membernetworksetlookup_nondv_01.elig_term_dt)
    and (current_group_plan_eligibility.plan_term_dt >= membernetworksetlookup_nondv_01.elig_eff_dt)
inner join {{ ref('current_network_set') }} current_network_set
    on current_network_set.network_set_prefix = current_group_plan_eligibility.network_set_prefix
    -- Temporal join: network set overlaps plan
    and (current_network_set.network_set_eff_dt <= current_group_plan_eligibility.plan_term_dt)
    and (current_network_set.network_set_term_dt >= current_group_plan_eligibility.plan_eff_dt)
    -- Temporal join: network set overlaps eligibility
    and (current_network_set.network_set_eff_dt <= membernetworksetlookup_nondv_01.elig_term_dt)
    and (current_network_set.network_set_term_dt >= membernetworksetlookup_nondv_01.elig_eff_dt)
```

**Recursive Date Consolidation**:
```sql
-- Purpose: Merge adjacent date ranges with identical attributes into contiguous periods
-- Critical: Prevents fragmentation; recursion limit prevents infinite loops

with date_contig as (
    -- Anchor: Find ranges with no immediately preceding range
    select source, member_bk, network_set_prefix, network_id,
        start_date, end_date, 1 as current_level
    from membernetworksetlookup_nondv_09 a
    left join membernetworksetlookup_nondv_09 b
        on a.source = b.source
        and a.member_bk = b.member_bk
        and a.network_id = b.network_id
        and a.network_set_prefix = b.network_set_prefix
        and dateadd(day, -1, a.start_date) = b.end_date
    where b.source is null

    union all

    -- Recursive: Chain forward through adjacent ranges
    select a.source, a.member_bk, a.network_set_prefix, a.network_id,
        a.start_date, b.end_date, a.current_level + 1 as current_level
    from date_contig a
    inner join membernetworksetlookup_nondv_09 b
        on a.source = b.source
        and a.member_bk = b.member_bk
        and a.network_id = b.network_id
        and a.network_set_prefix = b.network_set_prefix
        and dateadd(day, -1, b.start_date) = a.end_date
    where a.current_level < 99
)
select source, member_bk, network_set_prefix, network_id,
    start_date, max(end_date) as dss_end_date
from date_contig
group by source, member_bk, network_set_prefix, network_id, start_date
```

**Provider Overlapping Date Resolution**:
```sql
-- Purpose: Handle source data with identical effective dates for same provider-network-prefix
-- Critical: Shifts later records to prevent overlaps; maintains temporal integrity

select provider_bk, network_bk, provider_network_prefix_bk,
    case
        when provider_network_eff_dt = lag(provider_network_eff_dt, 1, null)
             over (partition by source, provider_bk, network_bk, provider_network_prefix_bk
                   order by provider_network_eff_dt, provider_network_term_dt)
        then dateadd(day, 1,
                 lag(provider_network_term_dt, 1, null)
                 over (partition by source, provider_bk, network_bk, provider_network_prefix_bk
                       order by provider_network_eff_dt, provider_network_term_dt)
             )
        else provider_network_eff_dt
    end as provider_network_eff_dt,
    provider_network_term_dt
from {{ ref('current_provider_network_relational') }}
where provider_network_eff_dt <> provider_network_term_dt
    and edp_record_status = 'Y'
```

### Common Issues & Troubleshooting

**Issue**: Duplicate member_bk-network_set-network_id combinations with overlapping date ranges
**Cause**: Recursive CTE consolidation failed to merge adjacent date ranges due to attribute mismatch (e.g., different group_id or subscriber_id for same network assignment)
**Resolution**: Add diagnostic query to identify which attribute varies: `SELECT member_bk, network_set_prefix, network_id, start_date, end_date, group_id, subscriber_id FROM prep_member_network_set_business WHERE member_bk = '<member>' ORDER BY start_date`. If group_id or subscriber_id differs, check if member switched employer groups mid-period.
**Prevention**: Review business requirements; determine if different group_id should create separate date ranges or if attributes should be standardized

**Issue**: Member network set query timeout exceeding 10 minutes
**Cause**: Cartesian product explosion in from_dates/thru_dates cross join when member has many eligibility, plan, and network set combinations
**Resolution**: Add diagnostic query to check combination volume: `SELECT member_bk, COUNT(*) as combo_count FROM membernetworksetlookup_nondv_02 GROUP BY member_bk ORDER BY combo_count DESC LIMIT 10`. For members with >1000 combinations, add temporal pre-filtering in CTE 02 to reduce cross join size. Consider increasing Snowflake warehouse size temporarily.
**Prevention**: Monitor CTE row counts in query profile; alert when membernetworksetlookup_nondv_02 exceeds 100k rows per member

**Issue**: Provider network participation shows gaps in date ranges
**Cause**: Source data missing records for continuous participation periods, or overlapping date adjustment logic created gaps
**Resolution**: Query source table for provider-network-prefix: `SELECT * FROM current_provider_network_relational WHERE provider_bk = '<provider>' AND network_bk = '<network>' ORDER BY provider_network_eff_dt`. Check if gaps exist in source or were introduced by transformation. If source has gaps, they're valid. If transformation introduced gaps, review overlapping date adjustment logic.
**Prevention**: Add data quality test in source layer to flag providers with unexpected gaps longer than 30 days

**Issue**: Network set dimension missing records expected from MDM
**Cause**: MDM records filtered out by deduplication logic (row_num > 1) due to matching non-MDM record with higher priority source
**Resolution**: Check deduplication: `SELECT network_set, network_id, source, row_number() over (partition by network_set, network_id order by source desc) as row_num FROM v_networkset_union WHERE network_set = '<prefix>' AND network_id = '<id>'`. If MDM record has row_num > 1, a raw vault record took precedence. Review if `order by source desc` prioritization is correct for business requirements.
**Prevention**: Add reconciliation report comparing MDM record count to final dimension record count, alerting when MDM records are excluded

**Issue**: is_current flag incorrect for member network assignments
**Cause**: System timestamp used in `case when getdate() between dss_start_date and dss_end_date` evaluates during model build time, not query time
**Resolution**: is_current is calculated at materialization time and stored. For real-time current status, downstream queries should recalculate: `WHERE current_date between dss_start_date and dss_end_date`. Update documentation to clarify is_current represents "current as of last warehouse refresh."
**Prevention**: Consider removing is_current from stored models and calculating dynamically in consumption layer views

**Issue**: Recursive CTE hits 99-level limit and truncates date consolidation
**Cause**: Member has unusually long chain of adjacent single-day date ranges (99+ contiguous days each with different attribute that later becomes identical)
**Resolution**: Identify affected member: `SELECT member_bk, COUNT(*) as range_count FROM (SELECT member_bk, network_set_prefix, network_id, start_date FROM date_contig WHERE current_level = 99) GROUP BY member_bk`. Investigate why single-day ranges exist. May need to adjust upstream logic to prevent daily fragmentation.
**Prevention**: Add monitoring for members approaching 80+ recursion levels; investigate fragmentation causes proactively

### Testing & Validation

**Unit Test Scenarios**:

1. **Single Continuous Period**: Member with one eligibility period, one plan, one network set; expect single output record with date range matching eligibility dates
   - Input: member_bk='TEST001', elig 2024-01-01 to 2024-12-31, plan 2024-01-01 to 2024-12-31, network set ABC 2020-01-01 to 9999-12-31
   - Expected: One record with dss_start_date='2024-01-01', dss_end_date='2024-12-31', network_set_prefix='ABC'

2. **Plan Change Mid-Period**: Member switches plans and networks mid-eligibility period; expect two records with no gaps or overlaps
   - Input: member_bk='TEST002', elig 2024-01-01 to 2024-12-31, plan ABC 2024-01-01 to 2024-06-30, plan XYZ 2024-07-01 to 2024-12-31
   - Expected: Two records: ABC 2024-01-01 to 2024-06-30, XYZ 2024-07-01 to 2024-12-31

3. **Network Set Date Range Subset**: Network set effective dates fall within eligibility period; expect output limited to network set dates
   - Input: member_bk='TEST003', elig 2024-01-01 to 2024-12-31, plan 2024-01-01 to 2024-12-31, network set 2024-03-01 to 2024-09-30
   - Expected: One record with dss_start_date='2024-03-01', dss_end_date='2024-09-30'

4. **Provider Overlapping Dates**: Provider has two records with identical effective date; expect second record shifted to day after first termination
   - Input: provider_bk='PROV001', network_bk='NET100', eff_dt 2024-01-01 term_dt 2024-06-30, eff_dt 2024-01-01 term_dt 2024-12-31
   - Expected: Two ranges: 2024-01-01 to 2024-06-30, 2024-07-01 to 2024-12-31

5. **Provider Pre-2003 Baseline**: Provider first joins network in 2010; expect synthetic record from 2003-01-01 to day before first join
   - Input: provider_bk='PROV002', first participation 2010-05-15
   - Expected: Synthetic record 2003-01-01 to 2010-05-14, actual record 2010-05-15 onward

**Data Quality Checks**:

```sql
-- Row count validation: Member network records should not drastically decrease
SELECT COUNT(*) as record_count,
    COUNT(DISTINCT member_bk) as member_count,
    COUNT(DISTINCT network_set_prefix) as network_count
FROM bv_s_member_network_set_business
-- Alert if record_count drops >10% from previous run

-- Null check: Critical business keys should never be null
SELECT COUNT(*) as null_count
FROM bv_s_member_network_set_business
WHERE member_bk IS NULL
   OR network_set_prefix IS NULL
   OR network_id IS NULL
   OR dss_start_date IS NULL
   OR dss_end_date IS NULL
-- Expect: 0

-- Referential integrity: All hash keys must exist in parent hubs
SELECT COUNT(*) as orphan_count
FROM bv_s_member_network_set_business a
LEFT JOIN h_member b ON a.hk_member = b.member_hk
WHERE b.member_hk IS NULL
-- Expect: 0

-- Temporal overlap check: No overlapping date ranges for same member-network
SELECT a.member_bk, a.network_set_prefix, a.network_id,
    a.dss_start_date, a.dss_end_date,
    b.dss_start_date, b.dss_end_date
FROM bv_s_member_network_set_business a
JOIN bv_s_member_network_set_business b
    ON a.member_bk = b.member_bk
    AND a.network_set_prefix = b.network_set_prefix
    AND a.network_id = b.network_id
    AND a.dss_start_date < b.dss_start_date
    AND a.dss_end_date >= b.dss_start_date
-- Expect: 0 rows

-- Current flag validation: is_current='1' only when today is in range
SELECT COUNT(*) as invalid_current_flag
FROM bv_s_member_network_set_business
WHERE is_current = '1'
  AND (current_date < dss_start_date OR current_date > dss_end_date)
-- Expect: 0
```

**Regression Tests**:

When modifying temporal join logic, validate:
- Total record count remains within 5% of baseline
- Distinct member_bk count unchanged
- No new null values introduced in required fields
- Maximum date range length per member-network remains reasonable (<10 years)
- Recursive CTE completion time remains under 2 minutes for largest member

When modifying deduplication logic, validate:
- Network set dimension record count change aligns with MDM prioritization intent
- No network_set-network_id duplicates introduced
- MDM captured flag distribution matches expectations

### Dependencies & Risks

**Upstream Dependencies**:
- `current_member_eligibility`: Daily refresh from eligibility system; SLA 6am CT
- `current_network_set`: Daily refresh from plan configuration system; SLA 5am CT
- `current_provider_network_relational`: Daily refresh from provider contracting; SLA 7am CT
- `h_member`, `h_provider`: Raw vault hubs; must complete before business vault
- `r_provider_network_mdm`: Weekly refresh from BCI MDM; SLA Monday 8am CT

**Downstream Impacts**:
- Claims adjudication system queries member network set for in-network determination; failures cause claims to pend
- Provider directory application queries provider network set for current participation; failures cause directory inaccuracy
- Network adequacy reporting consumes all three artifacts; failures block regulatory submissions
- Financial reporting uses network assignments for cost analysis; failures impact monthly close

**Data Quality Risks**:
- Source systems may have overlapping date ranges requiring resolution logic; if resolution logic fails, duplicates propagate to business vault
- Recursive CTE consolidation may hit 99-level limit for members with fragmented date ranges; affected members retain fragmented ranges
- MDM integration incomplete; some networks may be captured in MDM while others remain in raw vault creating inconsistent governance
- Historical cutoff dates (2016 for networks, 2017 for members) may exclude records needed for long-running claims or appeals

**Performance Risks**:
- Member network temporal join can produce cartesian product for members with 10+ plan changes; queries may timeout on X-Small warehouse
- Recursive CTE can consume excessive memory for members with 50+ adjacent date ranges; requires Large or X-Large warehouse
- Provider network overlapping date resolution requires multiple window function passes; may timeout with >1M provider-network combinations
- View materialization for prep layers eliminates incremental loading opportunity; full refresh required on every run affecting SLA
