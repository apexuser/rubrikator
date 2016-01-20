create or replace package render_plugin_rubrikator as

function render(
  p_region              in apex_plugin.t_region,
  p_plugin              in apex_plugin.t_plugin,
  p_is_printer_friendly in boolean) return apex_plugin.t_region_render_result;
  
procedure prepare_demo;

procedure drop_demo;

end render_plugin_rubrikator;