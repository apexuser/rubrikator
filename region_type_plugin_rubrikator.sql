set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.2.00.07'
,p_default_workspace_id=>1670552497385579
,p_default_application_id=>800
,p_default_owner=>'DXDY'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/region_type/rubrikator
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(3939820971282966)
,p_plugin_type=>'REGION TYPE'
,p_name=>'RUBRIKATOR'
,p_display_name=>'Rubrikator'
,p_supported_ui_types=>'DESKTOP'
,p_render_function=>'render_plugin_rubrikator.render'
,p_standard_attributes=>'SOURCE_SQL:SOURCE_REQUIRED'
,p_sql_min_column_count=>1
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(3940674100916952)
,p_plugin_id=>wwv_flow_api.id(3939820971282966)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Columns count'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
