{{
    config(
        materialized='table',
        tags=['lookup', 'member_person', 'crosswalk']
    )
}}

{#
    Lookup Table: Member Person to Constituent ID Crosswalk

    Purpose: Provides mapping from member identifiers to external person ID

    Grain: One row per unique member (current records only)

    Lookup Keys:
    - Primary: source + member_bk
    - Alternate: source + group_id + subscriber_identifier + member_suffix

    Source: bv_s_member_person (business vault computed satellite)

    Legacy Equivalent: v_FacetsMemberUMI_current
#}

with member_person_current as (
    select
        -- Source Information
        source,

        -- Natural Keys
        member_bk,
        person_bk,

        -- Business Keys for alternate lookup
        group_id,
        subscriber_identifier,
        coalesce(member_suffix, '') as member_suffix,

        -- Target: External Constituent ID
        person_id,

        -- Related Entity Keys
        group_bk,
        subscriber_bk,

        -- Metadata
        load_datetime,
        record_source

    from {{ ref('bv_s_member_person') }}
    where effective_from = (
        select max(effective_from)
        from {{ ref('bv_s_member_person') }} inner_sat
        where inner_sat.member_person_hk = {{ ref('bv_s_member_person') }}.member_person_hk
    )
)

select
    -- Generate surrogate key for lookup table
    {{ dbt_utils.generate_surrogate_key([
        'source',
        'member_bk'
    ]) }} as member_person_lookup_key,

    -- Primary Lookup Keys
    source,
    member_bk,

    -- Alternate Lookup Keys
    group_id,
    subscriber_identifier,
    member_suffix,

    -- Target Value: Constituent ID
    person_id,

    -- Additional Context Keys
    person_bk,
    group_bk,
    subscriber_bk,

    -- Metadata
    load_datetime as last_updated_datetime,
    record_source

from member_person_current
