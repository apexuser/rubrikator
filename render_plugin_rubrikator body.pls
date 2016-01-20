create or replace package body render_plugin_rubrikator as

function get_cell_html(p_value in varchar2, p_url in varchar2) return varchar2 is
  cell_html varchar2(4000);
  cell_text varchar2(4000);
begin
  if p_url is not null then
     cell_text := '<a href="' || p_url || '">' || p_value || '<a>';
     else
     cell_text := p_value;
  end if;
  cell_html := '<td width="20"></td><td>' || cell_text || '</td>';
  return cell_html;
end;

function render(
  p_region              in apex_plugin.t_region,
  p_plugin              in apex_plugin.t_plugin,
  p_is_printer_friendly in boolean) return apex_plugin.t_region_render_result is

  type string_list is table of varchar2(4000) index by binary_integer;
  
  cells            string_list;
  query_result     apex_plugin_util.t_column_value_list;
  table_html       varchar2(4000) := '<table>';
  col_count        number;
  row_count        number;
  current_rubric   varchar2(100) := ' ';
  cell_idx         number;
begin
  col_count := nvl(to_number(p_region.attribute_01), 1);
  query_result := apex_plugin_util.get_data (
      p_sql_statement      => p_region.source,
      p_min_columns        => 1,
      p_max_columns        => 20,
      p_component_name     => p_region.name,
      p_search_type        => null,
      p_search_column_name => null,
      p_search_string      => null);

  for i in query_result(1).first .. query_result(1).last loop
    if current_rubric <> query_result(1)(i) or i = query_result(1).last then
       if i = query_result(1).last then
          cells(cells.count + 1) := get_cell_html(query_result(2)(i), query_result(3)(i));
       end if;
       
       if cells.count > 0 then
          table_html := table_html || '<tr><td colspan="' || (col_count * 2) || '"><b>' || current_rubric || '<b></td></tr>';
          row_count := ceil(cells.count / col_count);
          
          for r in 1 .. row_count loop
            table_html := table_html || '<tr>';
            for c in 1 .. col_count loop
              cell_idx := r + (c - 1) * row_count;
              if cell_idx <= cells.count then
                 table_html := table_html || cells(cell_idx);
              end if;
            end loop;
            table_html := table_html || '</tr>';
          end loop;
          
          cells.delete;
       end if;      
       current_rubric := query_result(1)(i);
    end if;
    cells(cells.count + 1) := get_cell_html(query_result(2)(i), query_result(3)(i));
  end loop;

  table_html := table_html || '</table>';
  htp.p(table_html);
  
  return null;
  exception
  when others then return null;
end;

procedure prepare_demo is
begin
  execute immediate 
     'create table continent (
         continent_id number primary key, 
         continent_name varchar2(100))';
  execute immediate 
     'create table country (
         country_id number primary key, 
         country_name varchar2(100), 
         continent_id number references continent (continent_id),
         url varchar2(4000))';
  execute immediate q'[insert into continent(continent_id, continent_name) values (1, 'Europe')]';
  execute immediate q'[insert into continent(continent_id, continent_name) values (2, 'Asia')]';
  execute immediate q'[insert into continent(continent_id, continent_name) values (3, 'North America')]';
  execute immediate q'[insert into continent(continent_id, continent_name) values (4, 'South America')]';
  execute immediate q'[insert into continent(continent_id, continent_name) values (5, 'Australia')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (1, 'France', 1, 'https://ru.wikipedia.org/wiki/%D0%A4%D1%80%D0%B0%D0%BD%D1%86%D0%B8%D1%8F')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (2, 'Greece', 1, 'https://ru.wikipedia.org/wiki/%D0%93%D1%80%D0%B5%D1%86%D0%B8%D1%8F')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (3, 'Norway', 1, 'https://ru.wikipedia.org/wiki/%D0%9D%D0%BE%D1%80%D0%B2%D0%B5%D0%B3%D0%B8%D1%8F')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (4, 'Spain', 1, 'https://ru.wikipedia.org/wiki/%D0%98%D1%81%D0%BF%D0%B0%D0%BD%D0%B8%D1%8F')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (5, 'China', 2, 'https://ru.wikipedia.org/wiki/%D0%9A%D0%B8%D1%82%D0%B0%D0%B9%D1%81%D0%BA%D0%B0%D1%8F_%D0%9D%D0%B0%D1%80%D0%BE%D0%B4%D0%BD%D0%B0%D1%8F_%D0%A0%D0%B5%D1%81%D0%BF%D1%83%D0%B1%D0%BB%D0%B8%D0%BA%D0%B0')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (6, 'India', 2, 'https://ru.wikipedia.org/wiki/%D0%98%D0%BD%D0%B4%D0%B8%D1%8F')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (7, 'Japan', 2, 'https://ru.wikipedia.org/wiki/%D0%AF%D0%BF%D0%BE%D0%BD%D0%B8%D1%8F')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (8, 'USA', 3, 'https://ru.wikipedia.org/wiki/%D0%A1%D0%BE%D0%B5%D0%B4%D0%B8%D0%BD%D1%91%D0%BD%D0%BD%D1%8B%D0%B5_%D0%A8%D1%82%D0%B0%D1%82%D1%8B_%D0%90%D0%BC%D0%B5%D1%80%D0%B8%D0%BA%D0%B8')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (9, 'Canada', 3, 'https://ru.wikipedia.org/wiki/%D0%9A%D0%B0%D0%BD%D0%B0%D0%B4%D0%B0')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (10, 'Mexico', 3, 'https://ru.wikipedia.org/wiki/%D0%9C%D0%B5%D0%BA%D1%81%D0%B8%D0%BA%D0%B0')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (11, 'Brasil', 4, 'https://ru.wikipedia.org/wiki/%D0%91%D1%80%D0%B0%D0%B7%D0%B8%D0%BB%D0%B8%D1%8F')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (12, 'Uruguay', 4, 'https://ru.wikipedia.org/wiki/%D0%A3%D1%80%D1%83%D0%B3%D0%B2%D0%B0%D0%B9')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (13, 'Chile', 4, 'https://ru.wikipedia.org/wiki/%D0%A7%D0%B8%D0%BB%D0%B8')]';
  execute immediate q'[insert into country (country_id, country_name, continent_id, url) values (14, 'Australia', 5, 'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D1%81%D1%82%D1%80%D0%B0%D0%BB%D0%B8%D1%8F')]';

  execute immediate 'create view by_continent as
      select continent_name rubric, country_name value, url link
        from continent ct,
             country cr
       where ct.continent_id = cr.continent_id
       order by rubric, upper(value)';

  execute immediate 'create view by_alphabet as
      select upper(substr(country_name, 1, 1)) rubric, country_name value, url link
        from country cr
       order by rubric, upper(value)';
end;

procedure drop_demo is
begin
  execute immediate 'drop table country';
  execute immediate 'drop table continent';
  execute immediate 'drop view by_continent';
  execute immediate 'drop view by_alphabet';
end;

end render_plugin_rubrikator;