{{
    config(
        materialized='view',
        tags=['lookup', 'member_person', 'crosswalk']
    )
}}

with latest_member_person as (
    select
        *,
        row_number() over (
            partition by member_person_hk
            order by effective_from desc, load_datetime desc
        ) as row_num
    from {{ ref('bv_s_member_person') }}
)

select
    {{ dbt_utils.generate_surrogate_key([
        'source',
        'member_bk'
    ]) }} as member_person_lookup_key,
    source,
    member_bk,
    person_bk,
    group_bk,
    subscriber_bk,
    group_id,
    subscriber_identifier,
    coalesce(member_suffix, '') as member_suffix,
    person_id,
    load_datetime as last_updated_datetime,
    record_source
from latest_member_person
where row_num = 1
