{{
    config(
        materialized='incremental',
        unique_key='member_person_hk',
        tags=['business_vault', 'satellite', 'member_person']
    )
}}

{% set yaml_metadata %}
src_pk: 'member_person_hk'
src_hashdiff: 'member_person_hashdiff'
src_payload:
  - person_id
  - member_bk
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
src_eff: 'effective_from'
src_ldts: 'load_datetime'
src_source: 'record_source'
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(
    src_pk=metadata_dict['src_pk'],
    src_hashdiff=metadata_dict['src_hashdiff'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model='stg_member_person'
) }}
