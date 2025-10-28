{{
    config(
        materialized='view',
        tags=['staging', 'member_person', 'business_vault']
    )
}}

{% set yaml_metadata %}
source_model: 'prep_member_person'
hashed_columns:
  member_person_hk:
    - member_bk
  member_person_hashdiff:
    is_hashdiff: true
    columns:
      - person_id
      - person_bk
      - group_bk
      - subscriber_bk
      - member_suffix
      - member_first_name
      - member_last_name
      - member_sex
      - member_birth_dt
      - member_ssn
      - group_id
      - subscriber_identifier
      - source
      - member_source
derived_columns:
  source: "source"
  record_source: "edp_record_source"
  load_datetime: "load_datetime"
  effective_from: "effective_from"
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    hashed_columns=metadata_dict['hashed_columns'],
    derived_columns=metadata_dict['derived_columns']
) }}
