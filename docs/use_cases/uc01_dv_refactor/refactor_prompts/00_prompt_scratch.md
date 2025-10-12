

@ai-resources\prompts\data_vault_refactor_prompt_generator.md
Create a prompt from this info:
[sources] = legacy_facets, gemstone_facets
[entity_name] = product_prefix
[source_schema].[source_table] = dbo.cmc_pdpx_desc
[hub_name] = h_product_prefix
[hub_key] = product_prefix_hk [pdbc_pfx from source]
[link_name] = l_product_prefix_product_component_type
[link_keys]:
  - product_prefix_lk = product_prefix_hk (pdbc_pfx)
  - product_component_type_hk (pdbc_type) 
[satellites]:
  - s_product_prefix_product_component_type_gemstone_facets
  - s_product_prefix_product_component_type_legacy_facets
  - standard sats with all renamed columns from cmc_pdpx_desc 
  - attached to [link_name] l_product_prefix_product_component_type
  - include system columns
[data_dictionary_info] = @docs/sources/facets/dbo_cmc_pdpx_desc.csv 
[current_view] = current_product_prefix

src_eff: [source_column] from source
src_start_date: [source_column] from source  
src_end_date: [source_column] from source 

@docs\use_cases\uc01_dv_refactor\dv_refactor_project_context.md use this prompt info: @docs\use_cases\uc01_dv_refactor\refactor_prompts\product_prefix_refactor_prompt.md