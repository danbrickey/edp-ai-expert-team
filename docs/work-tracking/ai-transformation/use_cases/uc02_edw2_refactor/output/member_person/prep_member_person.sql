{{
    config(
        materialized='view',
        tags=['prep', 'member_person', 'business_rules']
    )
}}

with member_source as (
    select
        member_bk,
        person_bk,
        subscriber_bk,
        member_suffix,
        member_first_name,
        member_last_name,
        member_sex,
        member_birth_dt,
        member_ssn,
        source as member_source,
        edp_record_source,
        edp_start_dt
    from {{ ref('current_member') }}
),

person_source as (
    select
        person_bk,
        person_id,
        source,
        person_id_type
    from {{ ref('current_person') }}
    where person_id_type = 'EXRM'
),

subscriber_source as (
    select
        subscriber_bk,
        group_bk,
        subscriber_identifier,
        source as subscriber_source
    from {{ ref('current_subscriber') }}
    where subscriber_identifier not like 'PROXY%'
),

group_source as (
    select
        group_bk,
        group_id,
        source as group_source
    from {{ ref('current_group') }}
),

member_person_prepared as (
    select
        p.person_id,
        m.member_bk,
        m.person_bk,
        s.group_bk,
        m.subscriber_bk,
        m.member_suffix,
        m.member_first_name,
        m.member_last_name,
        m.member_sex,
        m.member_birth_dt,
        m.member_ssn,
        g.group_id,
        s.subscriber_identifier,
        coalesce(p.source, m.member_source) as source,
        m.member_source,
        m.edp_record_source,
        m.edp_start_dt as load_datetime,
        m.edp_start_dt as effective_from
    from member_source m
    left join person_source p
        on m.person_bk = p.person_bk
        and m.member_source = p.source
    inner join subscriber_source s
        on m.subscriber_bk = s.subscriber_bk
        and m.member_source = s.subscriber_source
    inner join group_source g
        on s.group_bk = g.group_bk
        and m.member_source = g.group_source
)

select * from member_person_prepared
