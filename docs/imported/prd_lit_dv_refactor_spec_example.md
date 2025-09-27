# Example Code Refactor - class entity

## Input Model

Please follow the project guidelines and generate the refactored spec for the subscriber_address entity

### Expected Output Summary

- Data Dictionary source_table Name
  - cmc_sbad_addr

I expect that the Raw Vault artifacts generated will include:

- Rename Views (1 per source)
  - stg_subscriber_address_legacy_facets_rename.sql
  - stg_subscriber_address_gemstone_facets_rename.sql
- Staging Views (1 per source)
  - stg_subscriber_address_legacy_facets.sql
  - stg_subscriber_address_gemstone_facets.sql
- Hub
  - h_address_type.sql
    - business Keys: address_type_hk (from source column: sbad_type)
- Link
  - l_subscriber_address.sql
    - business Keys: subscriber_hk (from source column: sbsb_ck), address_type_hk (from source column: sbad_type)
- Standard Satellites (1 per source)
  - s_subscriber_address_legacy_facets.sql
  - s_subscriber_address_gemstone_facets.sql
- Current View
  - current_subscriber_address.sql

### Data Dictionary

- Use this information to map source view references in the prior model code back to the source solumns, and rename columns in the rename views:

```csv
source_schema,source_table, source_column, table_description, column_description, column_data_type
dbo,cmc_sbad_addr,sbsb_ck,Subscriber/Member Address/ Phone/Fax,Subscriber Contrived Key,int
dbo,cmc_sbad_addr,sbad_type,Subscriber/Member Address/ Phone/Fax,Subscriber Address Type,char
dbo,cmc_sbad_addr,grgr_ck,Subscriber/Member Address/ Phone/Fax,Group Contrived Key,int
dbo,cmc_sbad_addr,sbad_addr1,Subscriber/Member Address/ Phone/Fax,Subscriber Address Line 1,char
dbo,cmc_sbad_addr,sbad_addr2,Subscriber/Member Address/ Phone/Fax,Subscriber Address Line 2,char
dbo,cmc_sbad_addr,sbad_addr3,Subscriber/Member Address/ Phone/Fax,Subscriber Address Line 3,char
dbo,cmc_sbad_addr,sbad_city,Subscriber/Member Address/ Phone/Fax,City,char
dbo,cmc_sbad_addr,sbad_state,Subscriber/Member Address/ Phone/Fax,State,char
dbo,cmc_sbad_addr,sbad_zip,Subscriber/Member Address/ Phone/Fax,Zip Code,char
dbo,cmc_sbad_addr,sbad_county,Subscriber/Member Address/ Phone/Fax,County,char
dbo,cmc_sbad_addr,sbad_ctry_cd,Subscriber/Member Address/ Phone/Fax,Country,char
dbo,cmc_sbad_addr,sbad_phone,Subscriber/Member Address/ Phone/Fax,Subscriber Phone Number,char
dbo,cmc_sbad_addr,sbad_phone_ext,Subscriber/Member Address/ Phone/Fax,Phone Extension,char
dbo,cmc_sbad_addr,sbad_fax,Subscriber/Member Address/ Phone/Fax,Subscriber Fax Number,char
dbo,cmc_sbad_addr,sbad_fax_ext,Subscriber/Member Address/ Phone/Fax,Fax Extension,char
dbo,cmc_sbad_addr,sbad_email,Subscriber/Member Address/ Phone/Fax,Email,char
dbo,cmc_sbad_addr,sbad_city_xlow,Subscriber/Member Address/ Phone/Fax,City search case insensitive,char
dbo,cmc_sbad_addr,sbad_lock_token,Subscriber/Member Address/ Phone/Fax,Lock Token,smallint
dbo,cmc_sbad_addr,atxr_source_id,Subscriber/Member Address/ Phone/Fax,Attachment Source Id,datetime
dbo,cmc_sbad_addr,sys_last_upd_dtm,Subscriber/Member Address/ Phone/Fax,Last Update Datetime,datetime
dbo,cmc_sbad_addr,sys_usus_id,Subscriber/Member Address/ Phone/Fax,Last Update User ID,varchar
dbo,cmc_sbad_addr,sys_dbuser_id,Subscriber/Member Address/ Phone/Fax,Last Update DBMS User ID,varchar

```

### Prior dbt Model Code

```sql
{{
    config(
        unique_key='subscriber_address_ik',
        merge_exclude_columns = ['create_dtm']
    )
}}

{% set schemas = ["legacy_bcifacets_hist","gemstone_facets_hist"]%}
{% for schema in schemas %}
    {%- if schema in ["legacy_bcifacets_hist"] -%}
        {%- set source_system = var('legacy_source_system') -%}
        {%- set ref_file = "stg_legacy_bcifacets_hist__dbo_cmc_sbad_addr" -%}
    {%- else -%}
        {%- set source_system = var('gemstone_source_system') -%}
        {%- set ref_file = "stg_gemstone_facets_hist__dbo_cmc_sbad_addr" -%}
    {%- endif -%}

    select
        {{ dbt_utils.generate_surrogate_key(['1',"'" ~ source_system ~ "'",'src.sbsb_ck','src.sbad_type','1900-01-01']) }} as subscriber_address_ik,
        1 as tenant_id,
        '{{source_system}}' as source_system,
        {{ dbt_utils.generate_surrogate_key(['1',"'" ~ source_system ~ "'",'src.sbsb_ck']) }} as subscriber_ik,
        {{ dbt_utils.generate_surrogate_key(['1',"'" ~ source_system ~ "'",'src.sbad_type']) }} as subscriber_address_type_ik,
        src.sbad_type as subscriber_address_type_bk,
        cast('1900-01-01' as datetime) as subscriber_address_eff_dt,
        cast('2199-12-31' as datetime) as subscriber_address_term_dt,
        cast(src.sbsb_ck as varchar) as subscriber_bk,
        cast(src.grgr_ck as varchar) as group_bk,
        {{string_clean_lenient('src.sbad_addr1')}} as subscriber_address1,
        {{string_clean_lenient('src.sbad_addr2')}} as subscriber_address2,
        {{string_clean_lenient('src.sbad_addr3')}} as subscriber_address3,
        {{string_clean_lenient('src.sbad_city')}} as subscriber_city,
        {{string_clean_lenient('src.sbad_state')}} as subscriber_state,
        {{string_clean_lenient('src.sbad_zip')}} as subscriber_zip,
        {{string_clean_lenient('src.sbad_county')}} as subscriber_county,
        {{string_clean_lenient('src.sbad_ctry_cd')}} as subscriber_country_code,
        {{string_clean_numeric('src.sbad_phone')}} as subscriber_phone,
        src.sbad_phone_ext as subscriber_phone_ext,
        src.sbad_email as subscriber_email,
        src.edp_start_dt,
        src.edp_end_dt,
        src.edp_record_status as edp_record_status,
        lower(src.edp_record_source) as edp_record_source,
        getdate() as create_dtm,
        getdate() as update_dtm
    from {{ ref( 'enterprise_data_platform',ref_file ) }} src
    {% if is_incremental() %}
        -- this filter will only be applied on an incremental run
        where src.edp_start_dt >= (select dateadd(dd,-3,coalesce(max(edp_start_dt), '1900-01-01')) from {{ this }})
    {% endif %}
    {% if not loop.last %}
        union all
    {% endif %}
{% endfor %}
```

## Output Requirements

# Artifact Summary for subscriber_address

- **Source Table**: cmc_sbad_addr
- **Rename Views (1 per source)**
  - stg_subscriber_address_legacy_facets_rename
  - stg_subscriber_address_gemstone_facets_rename
- **Staging Views (1 per source)**
  - stg_subscriber_address_legacy_facets
  - stg_subscriber_address_gemstone_facets
- **Hub**
  - h_address_type
- **Link**
  - l_subscriber_address
- **Satellites (1 per source)**
  - s_subscriber_address_legacy_facets
  - s_subscriber_address_gemstone_facets
- **Current View**
  - current_subscriber_address

---

# Artifact Specifications for subscriber_address

1. Specification for Renamed Views

```sql
    '{{ var('*_source_system') }}' as source,
    '1' as tenant_id,
    sbsb_ck as subscriber_bk,
    sbad_type as address_type_bk,
    grgr_ck as group_bk,
    sbad_addr1 as address_line_1,
    sbad_addr2 as address_line_2,
    sbad_addr3 as address_line_3,
    sbad_city as city,
    sbad_state as state,
    sbad_zip as zip_code,
    sbad_county as county,
    sbad_ctry_cd as country_code,
    sbad_phone as phone_number,
    sbad_phone_ext as phone_extension,
    sbad_fax as fax_number,
    sbad_fax_ext as fax_extension,
    sbad_email as email_address,
    sbad_city_xlow as city_search,
    sbad_lock_token as lock_token,
    atxr_source_id as attachment_source_id,
    sys_last_upd_dtm as last_update_datetime,
    sys_usus_id as last_update_user_id,
    sys_dbuser_id as last_update_db_user_id,
    edp_start_dt,
    edp_end_dt,
    edp_record_status,
    edp_record_source,
    cdc_operation
```

2. Specification for Staging Views

```yml
derived_columns:
  source: "source"
  load_datetime: "edp_start_dt"
  effective_from: "edp_start_dt"
  subscriber_bk: "cast(subscriber_bk as varchar)"
  group_bk: "cast(group_bk as varchar)"
hashed_columns:
  subscriber_address_hk:
    - "source"
    - "subscriber_bk"
    - "address_type_bk"
  subscriber_hk:
    - "source"
    - "subscriber_bk"
  address_type_hk:
    - "source"
    - "address_type_bk"
  subscriber_address_hashdiff:
  is_hashdiff: true
  columns:
    - "tenant_id"
    - "address_line_1"
    - "address_line_2"
    - "address_line_3"
    - "city"
    - "state"
    - "zip_code"
    - "county"
    - "country_code"
    - "phone_number"
    - "phone_extension"
    - "fax_number"
    - "fax_extension"
    - "email_address"
    - "city_search"
    - "lock_token"
    - "attachment_source_id"
    - "last_update_datetime"
    - "last_update_user_id"
    - "last_update_db_user_id"
```
