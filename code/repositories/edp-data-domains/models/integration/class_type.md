# Example Code Refactor - class entity

{{
    config(
        unique_key=''class_ik'',
        merge_exclude_columns = [''create_dtm'']
    )
}}

{% set schemas = ["legacy_bcifacets_hist","gemstone_facets_hist"] %}

{% for schema in schemas %}
    {%- if schema in ["legacy_bcifacets_hist"] -%}
        {%- set source_system = var(''legacy_source_system'') -%}
        {%- set ref_file = "stg_legacy_bcifacets_hist__dbo_cmc_cscs_class" -%}
    {%- else -%}
        {%- set source_system = var(''gemstone_source_system'') -%}
        {%- set ref_file = "stg_gemstone_facets_hist__dbo_cmc_cscs_class" -%}
    {%- endif -%}

    select
        {{ dbt_utils.generate_surrogate_key([''1'',"''" ~ source_system ~ "''",''src.grgr_ck'',''src.cscs_id'']) }}  as class_ik,
        1 as tenant_id,
        ''{{source_system}}'' as source_system,
        cast(src.grgr_ck as varchar) as employer_group_bk,
        src.cscs_id as class_bk,
        src.cscs_desc as class_desc,
        src.edp_start_dt,
        src.edp_end_dt,
        src.edp_record_status,
        lower(src.edp_record_source) as edp_record_source,
        getdate() as create_dtm,
        getdate() as update_dtm
    from {{ ref( ''enterprise_data_platform'',ref_file ) }} src
    {% if is_incremental() %}
        -- this filter will only be applied on an incremental run
        where src.edp_start_dt >= (select dateadd(dd,-3,coalesce(max(edp_start_dt), ''1900-01-01'')) from {{ this }})
    {% endif %}
    {% if not loop.last %}
        union all
    {% endif %}
{% endfor %}
```