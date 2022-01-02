CREATE OR REPLACE package body APPS.cux_fnd_web_sec as    

　function encrypt(key in varchar2, value in varchar2) return varchar2     as language java 　　　　 name'oracle.apps.fnd.security.WebSessionManagerProc.encrypt(java.lang.String,java.lang.String) return java.lang.String';

   function decrypt(key in varchar2, value in varchar2) return varchar2     as language java name'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(java.lang.String,java.lang.String) return java.lang.String';

end; 

1.查看当前系统定义了那些值是中文的段值。
SELECT *
FROM   fnd_flex_value_sets ffvs
WHERE  ffvs.flex_value_set_name LIKE 'CUX%'
AND    EXISTS (SELECT 1
        FROM   fnd_flex_values_vl ffv
        WHERE  ffvs.flex_value_set_id = ffv.flex_value_set_id
        AND    (ascii(substr(ffv.flex_value, 1, 1)) < 0 OR ascii(substr(ffv.flex_value, 1, 1)) > 127)
        AND    ffv.enabled_flag = 'Y');

--CREATE OR REPLACE package APPS.cux_fnd_web_sec authid current_user as
 --加密函数
   -- function encrypt(key in varchar2, value in varchar2) return varchar2;

   --解密函数
  --  function decrypt(key in varchar2, value in varchar2) return varchar2;
--end;

--取得APPS密文
明文：APPS                                                                                                 
---------------
select  c.id_flex_name,
       a.id_flex_structure_name,
       b.form_left_prompt,
       c.application_table_name,
       b.application_column_name,
       b.flex_value_set_id
   from  fnd_id_flex_structures_vl a,
       fnd_id_flex_segments_vl   b,
       fnd_id_flexs              c
  where  a.id_flex_structure_name    ='CN 法定信息'   -- 用你自己要查的代替，就是Form窗口的标题
    and  a.application_id  =  b.application_id
    and  a.id_flex_code  =  b.id_flex_code
    and  a.id_flex_num  =  b.id_flex_num
    and  a.application_id  =  c.application_id
    and  a.id_flex_code  =  c.id_flex_code; 
    
    -- 根据上面FLEX_VALUE_SET_ID查弹性域的数据
select   *  
   from  fnd_flex_values_vl t 
  where  t.flex_value_set_id  =   1005982 ;  --  FLEX_VALUE_SET_ID


-------菜单----
SELECT res.RESPONSIBILITY_NAME 职责名称,
       menu.MENU_NAME 菜单编码,
       menu.USER_MENU_NAME 菜单名称,
       func.FUNCTION_NAME 功能编码,
       func.USER_FUNCTION_NAME 菜单名称,
       sub_menu.PROMPT 
  FROM FND_RESPONSIBILITY_VL res,
       fnd_menus_vl          menu,
       FND_MENU_ENTRIES_VL   sub_menu,
       FND_FORM_FUNCTIONS_VL func
 WHERE res.MENU_ID = sub_menu.MENU_ID
   AND menu.MENU_ID = sub_menu.MENU_ID
   AND sub_menu.FUNCTION_ID = func.FUNCTION_ID
   AND res.RESPONSIBILITY_NAME LIKE '345中钢设计院_PJ_项目超级用%'
   AND sub_menu.SUB_MENU_ID IS NULL
   AND sub_menu.FUNCTION_ID IS NOT NULL
   AND sub_menu.PROMPT IS NOT NULL
UNION ALL
SELECT res.RESPONSIBILITY_NAME,
       menu.MENU_NAME,
       menu.USER_MENU_NAME,
       func.FUNCTION_NAME,
       func.USER_FUNCTION_NAME,
       sub_menu1.PROMPT
  FROM FND_RESPONSIBILITY_VL res,
       fnd_menus_vl          menu,
       FND_MENU_ENTRIES_VL   sub_menu,
       FND_MENU_ENTRIES_VL   sub_menu1,
       FND_FORM_FUNCTIONS_VL func
 WHERE res.MENU_ID = sub_menu.MENU_ID
   AND sub_menu.MENU_ID = menu.MENU_ID
   AND sub_menu.SUB_MENU_ID = sub_menu1.MENU_ID
   AND sub_menu1.FUNCTION_ID = func.FUNCTION_ID
   AND res.RESPONSIBILITY_NAME LIKE '345中钢设计院_PJ_项目超级用%'
   AND sub_menu.SUB_MENU_ID IS NOT NULL
   AND sub_menu.FUNCTION_ID IS NULL
   AND sub_menu1.PROMPT IS NOT NULL
 ----end------
 =====菜单复制脚本
 DECLARE
  l_error_flag        VARCHAR2(1);
  l_menu_rowid        VARCHAR2(100);
  l_menu_entity_rowid VARCHAR2(100);
  l_menu_id           NUMBER;
  l_cnt               NUMBER := 0;
  c_new_menu_code    CONSTANT VARCHAR2(50) := 'CUX_MDM_MENU_SYS_GROUP'; ----新的菜单简称
  c_new_menu_name    CONSTANT VARCHAR2(100) := 'CUX_MDM菜单_运维_集团'; --用户菜单名
  c_copied_menu_code CONSTANT VARCHAR2(50) := 'CUX_MDM_MENU_SYS'; --被复制的菜单名

  CURSOR csr_menu_entity IS
    SELECT DISTINCT fme.entry_sequence,
                    fme.sub_menu_id,
                    fme.function_id,
                    fme.grant_flag,
                    fmet.prompt,
                    fmet.description
      FROM fnd_menu_entries    fme,
           fnd_menu_entries_tl fmet,
           fnd_menus           fm
     WHERE fme.menu_id = fm.menu_id
       AND fmet.menu_id = fm.menu_id
       AND fmet.entry_sequence = fme.entry_sequence
       AND fm.menu_name = c_copied_menu_code;

BEGIN
  SELECT fnd_menus_s.nextval
    INTO l_menu_id
    FROM dual;
  l_error_flag := 'N';

  fnd_menus_pkg.insert_row(x_rowid             => l_menu_rowid,
                           x_menu_id           => l_menu_id,
                           x_menu_name         => c_new_menu_code,
                           x_user_menu_name    => c_new_menu_name,
                           x_menu_type         => NULL,
                           x_description       => NULL,
                           x_creation_date     => SYSDATE,
                           x_created_by        => fnd_global.user_id,
                           x_last_update_date  => SYSDATE,
                           x_last_updated_by   => fnd_global.user_id,
                           x_last_update_login => fnd_global.login_id);
  IF l_menu_rowid IS NULL THEN
    dbms_output.put_line('error:' || SQLERRM);
    l_error_flag := 'Y';
  ELSE
    FOR l_menu_entity_rec IN csr_menu_entity LOOP
    
      fnd_menu_entries_pkg.insert_row(x_rowid             => l_menu_entity_rowid,
                                      x_menu_id           => l_menu_id,
                                      x_entry_sequence    => l_menu_entity_rec.entry_sequence,
                                      x_sub_menu_id       => l_menu_entity_rec.sub_menu_id,
                                      x_function_id       => l_menu_entity_rec.function_id,
                                      x_grant_flag        => l_menu_entity_rec.grant_flag,
                                      x_prompt            => l_menu_entity_rec.prompt,
                                      x_description       => l_menu_entity_rec.description,
                                      x_creation_date     => SYSDATE,
                                      x_created_by        => fnd_global.user_id,
                                      x_last_update_date  => SYSDATE,
                                      x_last_updated_by   => fnd_global.user_id,
                                      x_last_update_login => fnd_global.login_id);
    
      IF l_menu_rowid IS NULL THEN
        dbms_output.put_line('error:' || SQLERRM);
        l_error_flag := 'Y';
      ELSE
        l_cnt := l_cnt + 1;
      END IF;
    END LOOP;
  END IF;

  IF l_error_flag = 'N' AND l_cnt > 0 THEN
    dbms_output.put_line('提交编译请求：' || fnd_menu_entries_pkg.submit_compile);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLCODE || ',' || SQLERRM);
END;
-------------------------
 SELECT t.user_concurrent_program_name 报表名称,
       e.execution_file_name 可执行文件,
       t.concurrent_program_name 简称,
       e.executable_name 可执行简称,
       e.user_executable_name 可执行名称,
       e.application_name 应用产品,
       decode(t.execution_method_code,
              'P',
              'Oracle Reports',
              'I',
              'PL/SQL 存储过程',
              'B',
              '请求集阶段函数',
              'M',
              '多语言功能',
              'K',
              'Java 并发程序',
              'J',
              'Java 存储过程',
              'S',
              '立即',
              'H',
              '主机',
              'A',
              '派生') 执行方法,
       e.description 可执行说明,
       e.execution_file_path 执行文件路径
  FROM fnd_concurrent_programs_vl t,
       fnd_executables_form_v     e
 WHERE t.executable_id = e.executable_id
   AND t.application_id IN (20004, 20003)
   AND t.user_concurrent_program_name LIKE '%入库%';
   
   
   
 ===end===
 
-- 具体某一数据
select   *
   from  fnd_flex_values_vl t
  where  t.flex_value_set_id  =   1005982
    and  t.flex_value  =   ' 72061'
 
2.查询当前系统程序包中引用内容
SELECT *
FROM   all_source t
WHERE  t.type = 'PACKAGE BODY'
AND    t.name LIKE 'XX%'
AND    t.owner LIKE 'XX%'
AND    t.text LIKE '%per_org_structure_versions%';
3.查询当前EBS的版本
SELECT * FROM fnd_product_groups;
4.查看单取EBS数据库版本
SELECT * FROM   v$version;
5.查看所选表的字段信息
SELECT * FROM   all_tab_columns
WHERE  table_name = 'PO_HEADERS_ALL';
6.查找当前应用服务器的网址
SELECT fnd_profile.value('APPS_WEB_AGENT') FROM   dual;
7.查看表或者视图被某个对象引用
SELECT * FROM all_dependencies dep WHERE dep.referenced_name = 'MTL_SAFETY_STOCKS';
8.查看当前最耗时的进程
SELECT * FROM   v$session_longops;
10.查看系统配置文件状态
SELECT fp.level_id
      ,fp.level_value
      ,fp.profile_option_value
FROM   fnd_profile_options_vl    fpo
      ,fnd_profile_option_values fp
WHERE  fpo.application_id = fp.application_id
AND    fpo.profile_option_id = fp.profile_option_id
AND    fpo.user_profile_option_name = 'FND: Debug Log Enabled';


11.查看当前系统的应用模块
SELECT fnd_application.application_short_name
      ,fnd_application.application_id
      ,fnd_product_installations.status
FROM   fnd_application
      ,fnd_product_installations
WHERE  fnd_application.application_id = fnd_product_installations.application_id;

12.利用应用简称或应用名称查找应用模块详细信息
SELECT fapp.application_short_name
      ,fapptl.application_name
      ,fapp.*
FROM   fnd_application    fapp
      ,fnd_application_tl fapptl
WHERE  fapptl.application_name = 'Purchasing' -- fapp.application_short_name='XXSAT'
AND    fapp.application_id = fapptl.application_id
AND    fapptl.language = 'US'
13.查看当前EBS系统注册的用户

SELECT *
FROM   fnd_user
WHERE  user_name = upper('sysadmin');
14.查询消息的定义
SELECT fa.application_short_name
,      fm.language_code
,      fm.message_name
,      fm.message_text
,      fm.type
FROM   fnd_new_messages fm
,      fnd_application  fa
WHERE  fm.message_name = 'FWK_TBX_T_PAGE_GENERAL'
AND    fm.application_id = fa.application_id
AND    fa.application_short_name = 'AK'
15.查看EBS系统当前的语言配置
SELECT userenv('language')
FROM   dual;
16.查看所有配置文件的名字
SELECT *
FROM   fnd_profile_options_tl t
WHERE  t.profile_option_name = 'AFLOG_ENABLED';
17.查看配置文件的sql
SELECT t.user_profile_option_name "Profile Option"
       ,decode(a.level_id
             ,10001
             ,'Site'
             ,10002
             ,'Application'
             ,10003
             ,'Responsibility'
             ,10004
             ,'User') "Level"
       ,decode(a.level_id
             ,10001
             ,'Site'
             ,10002
             ,b.application_short_name
             ,10003
             ,c.responsibility_key
             ,10004
             ,d.user_name) "Level Value"
       ,a.profile_option_value "Profile Value"
FROM   fnd_profile_option_values a
      ,fnd_application           b
      ,fnd_responsibility        c
      ,fnd_user                  d
      ,fnd_profile_options       e
      ,fnd_profile_options_tl    t
WHERE  a.profile_option_id = e.profile_option_id
AND    e.profile_option_name = 'RCV_TP_MODE'
AND    a.level_value = b.application_id(+)
AND    a.level_value = c.responsibility_id(+)
AND    a.level_value = d.user_id(+)
AND    t.profile_option_name = e.profile_option_name
AND    t.language = 'US'
ORDER  BY e.profile_option_name
         ,a.level_id DESC;

16.数字转换为时间
SELECT to_char(trunc(46583 / 3600)) || ':' || to_char(trunc(MOD(46583, 3600) / 60)) || ':' ||
       to_char(trunc(MOD(MOD(46583, 3600), 60)))
FROM   dual;
17.获得当前会话编号
SELECT userenv('SESSIONID')
FROM   dual;

18.查看定义的并发程序挂在那个职责
SELECT responsibility_name
      ,frg.request_group_name
      ,fcpv.concurrent_program_name
      ,fcpv.user_concurrent_program_name
      ,fcpv.description
FROM   fnd_request_groups         frg
      ,fnd_request_group_units    frgu
      ,fnd_concurrent_programs_vl fcpv
      ,fnd_responsibility_vl      frv
WHERE  frgu.request_unit_type = 'P'
AND    frgu.request_group_id = frg.request_group_id
AND    frgu.request_unit_id = fcpv.concurrent_program_id
AND    frv.request_group_id(+) = frg.request_group_id
AND    fcpv.user_concurrent_program_name = < 并发程序全称，例： 'CUX:接收入库单' >
ORDER  BY responsibility_name
19.查看所查内容被那些包引用
SELECT *  FROM   all_source t
WHERE  t.text LIKE '%IBY_DISBURSEMENT_COMP_PUB%';
20.查看当前EBS数据库对应字符集
SELECT * FROM   nls_database_parameters;
22.查找功能所属职责
SELECT fffv.function_name
      ,fm.menu_name
      ,fr.responsibility_key
FROM   fnd_form_functions_vl fffv
      ,fnd_menu_entries_vl   fmev
      ,fnd_menus             fm
      ,fnd_responsibility    fr
WHERE  fffv.function_id = fmev.function_id
AND    fmev.menu_id = fm.menu_id
AND    fmev.menu_id = fr.menu_id(+)
AND    fffv.function_name = '&function_name';
 
23.查看配置文件配置
SELECT pro.profile_option_name
      ,pro.user_profile_option_name
      ,lev.level_type TYPE
      ,lev.level_code
      ,lev.level_name
      ,prv.profile_option_value
FROM   apps.fnd_profile_options_vl pro
      ,applsys.fnd_profile_option_values prv
      ,(SELECT 10001 level_id
              ,'Site' level_type
              ,0 level_value
              ,'Site' level_code
              ,'Site' level_name
        FROM   dual
        UNION ALL
        SELECT 10002 level_id
              ,'App' level_type
              ,app.application_id level_value
              ,app.application_short_name level_code
              ,app.application_name level_name
        FROM   apps.fnd_application_vl app
        UNION ALL
        SELECT 10003 level_id
              ,'Resp' level_type
              ,resp.responsibility_id level_value
              ,resp.responsibility_key level_code
              ,resp.responsibility_name level_name
        FROM   apps.fnd_responsibility_vl resp
        UNION ALL
        SELECT 10004 level_id
              ,'User' level_type
              ,usr.user_id level_value
              ,usr.user_name level_code
              ,usr.user_name level_name
        FROM   applsys.fnd_user usr) lev
WHERE  pro.profile_option_id = prv.profile_option_id(+)
AND    prv.level_id = lev.level_id(+)
AND    prv.level_value = lev.level_value(+)
AND    pro.user_profile_option_name LIKE 'CUX%' --Profile名称
ORDER  BY pro.profile_option_name
         ,lev.level_type
         ,lev.level_name;



24.查看Oracle Patch版本
SELECT dd.patch_name
      ,pp.creation_date
      ,pp.driver_file_name
      ,lang.language
FROM   ad_patch_drivers      pp
      ,ad_applied_patches    dd
      ,ad_patch_driver_langs lang
WHERE  pp.applied_patch_id = dd.applied_patch_id
AND    lang.patch_driver_id = pp.patch_driver_id
AND    lang.language = userenv('LANG')
ORDER  BY pp.creation_date;

25.根据描述性弹性域的标题查找描述性弹性域表和列
SELECT fnd_dfv.title
      ,fnd_dfv.descriptive_flexfield_name
      ,fnd_dfv.application_table_name
      ,fnd_dfu.application_column_name
      ,fnd_dfu.form_left_prompt
      ,fnd_dfu.form_above_prompt
FROM   fnd_descriptive_flexs_vl    fnd_dfv
      ,fnd_descr_flex_col_usage_vl fnd_dfu
WHERE  fnd_dfv.title = '物料' --如：物料
AND    fnd_dfu.descriptive_flexfield_name = fnd_dfv.descriptive_flexfield_name;


 
26.查看当前环境登录的用户


SELECT u.user_name
      ,app.application_short_name
      ,fat.application_name
      ,fr.responsibility_key
      ,frt.responsibility_name
      ,fff.function_name
      ,fft.user_function_name
      ,icx.function_type
      ,icx.first_connect
      ,icx.last_connect
FROM   icx_sessions          icx
      ,fnd_user              u
      ,fnd_application       app
      ,fnd_application_tl    fat
      ,fnd_responsibility    fr
      ,fnd_responsibility_tl frt
      ,fnd_form_functions    fff
      ,fnd_form_functions_tl fft
WHERE  1 = 1
AND    u.user_id = icx.user_id
AND    icx.responsibility_application_id = app.application_id
AND    fat.application_id = icx.responsibility_application_id
AND    fat.language = 'ZHS'
AND    fr.application_id = icx.responsibility_application_id
AND    fr.responsibility_id = icx.responsibility_id
AND    frt.language = 'ZHS'
AND    frt.application_id = icx.responsibility_application_id
AND    frt.responsibility_id = icx.responsibility_id
AND    fff.function_id = icx.function_id
AND    fft.function_id = icx.function_id
AND    icx.disabled_flag != 'Y'
AND    icx.pseudo_flag = 'N'
AND    (icx.last_connect + decode(fnd_profile.value('ICX_SESSION_TIMEOUT')
                                 ,NULL
                                 ,icx.limit_time
                                 ,0
                                 ,icx.limit_time
                                 ,fnd_profile.value('ICX_SESSION_TIMEOUT') / 60) / 24) > SYSDATE
AND    icx.counter < icx.limit_connects;


 
27.查看当前系统所有存在个性化的功能

SELECT DISTINCT fun.user_function_name
               ,fun.function_name
FROM   fnd_form_custom_rules fcr
      ,fnd_form_functions_vl fun
WHERE  fun.function_name = fcr.function_name
ORDER  BY fun.function_name;
28.查看当前请求挂在那些请求组中
SELECT rg.request_group_name
      ,fcp.concurrent_program_name
      ,fcp.user_concurrent_program_name
      ,rg.application_id
      ,rg.request_group_id
FROM   fnd_request_groups         rg
      ,fnd_request_group_units    rgu
      ,fnd_concurrent_programs_vl fcp
WHERE  rg.request_group_id = rgu.request_group_id
AND    rgu.request_unit_id = fcp.concurrent_program_id
AND    fcp.user_concurrent_program_name = 'CUX:库存帐龄表';


 
29.查看配置文件的配置情况


SELECT t.user_profile_option_name us_name
      ,l.user_profile_option_name zhs_name
      ,decode(v.level_id
             ,10001
             ,'地点层'
             ,10002
             ,'应用层'
             ,10003
             ,'职责层'
             ,10004
             ,'用户层'
             ,10005
             ,'服务器层'
             ,10006
             ,'组织层'
             ,'其它') level_name
      ,decode(v.level_id
             ,10002
             ,(SELECT application_name
              FROM   apps.fnd_application_vl
              WHERE  application_id = v.level_value)
             ,10003
             ,(SELECT responsibility_name
              FROM   apps.fnd_responsibility_vl
              WHERE  responsibility_id = v.level_value
              AND    application_id = v.level_value_application_id)
             ,10004
             ,(SELECT user_name
              FROM   apps.fnd_user
              WHERE  user_id = v.level_value)
             ,10005
             ,(SELECT node_name
              FROM   apps.fnd_nodes
              WHERE  node_id = v.level_value)
             ,10006
             ,(SELECT NAME
              FROM   apps.hr_operating_units
              WHERE  organization_id = v.level_value)
             ,v.level_value) level_value
      ,v.profile_option_value
      ,u.user_name
      ,v.last_update_date
FROM   apps.fnd_profile_options_vl    t
      ,apps.fnd_profile_options_tl    l
      ,apps.fnd_profile_option_values v
      ,apps.fnd_user                  u
WHERE  t.application_id = v.application_id
AND    t.profile_option_id = v.profile_option_id
AND    t.profile_option_name = l.profile_option_name
AND    l.language = 'ZHS'
AND    u.user_id = v.last_updated_by
AND    t.start_date_active <= SYSDATE
AND    nvl(t.end_date_active
          ,SYSDATE) >= SYSDATE
AND    user_id NOT IN (-1
                      ,0
                      ,1
                      ,2
                      ,3
                      ,4
                      ,5
                      ,6
                      ,7)
AND    l.user_profile_option_name = 'MO：安全性配置文件'
ORDER  BY t.user_profile_option_name;


 
30.报表trace定位
SELECT 'Request id: ' || request_id
      ,'Trace id: ' || oracle_process_id
      ,'Trace Flag: ' || req.enable_trace
      ,'Trace Name: ' || dest.value || '/' || lower(dbnm.value) || '_ora_' || oracle_process_id || '.trc'
      ,'Prog. Name: ' || prog.user_concurrent_program_name
      ,'File Name: ' || execname.execution_file_name || execname.subroutine_name
      ,'Status : ' || decode(phase_code
                            ,'R'
                            ,'Running') || '-' || decode(status_code
                                                        ,'R'
                                                        ,'Normal')
      ,'SID Serial: ' || ses.sid || ',' || ses.serial#
      ,'Module : ' || ses.module
FROM   fnd_concurrent_requests    req
      ,v$session                  ses
      ,v$process                  proc
      ,v$parameter                dest
      ,v$parameter                dbnm
      ,fnd_concurrent_programs_vl prog
      ,fnd_executables            execname
WHERE  req.request_id = &request_id
AND    req.oracle_process_id = proc.spid(+)
AND    proc.addr = ses.paddr(+)
AND    dest.name = 'user_dump_dest'
AND    dbnm.name = 'db_name'
AND    req.concurrent_program_id = prog.concurrent_program_id
AND    req.program_application_id = prog.application_id
AND    prog.application_id = execname.application_id
AND    prog.executable_id = execname.executable_id;


 
31.停止正在运行的请求

SELECT fcr.rowid
      ,fcr.*
FROM   fnd_concurrent_requests fcr
WHERE  1 = 1
AND    fcr.phase_code IN ( /*'P',*/'R')
AND    fcr.request_id = 558746; --phase_code,status_code = C
32.查看当前EBS环境的服务节点部署情况
SELECT NAME,
       server_type
FROM   fnd_app_servers,
       fnd_nodes
WHERE  fnd_app_servers.node_id = fnd_nodes.node_id
AND    server_type IN ('APPS'
                      ,'DB');
清除正在运行的并发程序
select * from v$session c where c.MODULE ='CUX_AP_DEALINGS_ACCOUNT';
alter system kill session 'sid,serial#';
CUX_AP_DEALINGS_ACCOUNT是包名称

select gmicuom.uom_conversion(物料ID,NULL,数量,'吨','件',null) from dual;
用在OPM的ic_item_mst_b  吨转成件
这个函数单位参数为汉字。
select inv_convert.inv_um_convert(物料ID,小数位数,数量,'TUN','EA',null,null) from dual;
用在OA 的mtl_system_items_b吨转成件

这个函数单位参数为英文。

清除被锁定的报表（PL/SQL包）

select * from v$ACCESS va where va.OBJECT='cux_ic_inout_pkg'-- cux_ic_inout_pkg是包名

在PL/SQL工具菜单里选TOOLS下的SESSION下找到上面的SQL语句查出的SID对应的数据，在数据上点右键选”KILLED”就可以了。


1.编辑信息：取上一个值集所选的数据。（值集关联）

WHERE BANK_ACCOUNT_ID = :$FLEX$.CE_BANK_ACCOUNT_NUM_NAME
--
SELECT l.session_id      sid
      ,s.serial#
      ,l.locked_mode     锁模式
      ,l.oracle_username 登录用户
      ,l.os_user_name    登录机器用户名
      ,s.machine         机器名
      ,s.terminal        终端用户名
      ,o.object_name     被锁对象名
      ,s.logon_time      登录数据库时间
FROM   v$locked_object l
      ,all_objects     o
      ,v$session       s
WHERE  l.object_id = o.object_id
AND    l.session_id = s.sid
ORDER  BY SID ,s.serial#;

 ALTER SYSTEM KILL SESSION '7261,15433';-- 分别取 3.0 SID SERIAL

FTP连接命令
sftp -P 22 appltest@10.60.137.155
##伊利
/u04/test/inst/apps/TEST_erptest/logs/appl/conc/out
kaifa2018!


-----学习--ebs 系统基础表----
CALL fnd_global.APPS_INITIALIZE(1318,50583,401)
CALL fnd_global.APPS_INITIALIZE(,user_id => ,resp_id => ,resp_appl_id => '');
user_id  用户ID
resp_id 职责ID 
resp_appl_id 应用ID
SELECT user_id,user_name FROM  FND_USER /*EBS等用户信息*/
SELECT * FROM fnd_responsibility_tl  frt WHERE frt.LANGUAGE ='ZHS'  USERENV('LANGUAGE')
SELECT * FROM FND_RESPONSIBILITY /*获取职责ID*/
SELECT * FROM FND_APPLICATION  /*获取应用ID*/
SELECT * FROM fnd_application_tl /**/
SELECT * FROM V$SESSION SE WHERE SE.SID='5573674'
SELECT * FROM FND_APP_SERVERS/*存储 服务 数据库服务器信息和应用服务器信息*/
SELECT * FROM FND_DATABASE_INSTANCES/*存储数据库实例信息*/
SELECT * FROM FND_DATABASES /*数据库服务器信息存储表*/
SELECT * from FND_ATTACHED_DOCUMENTS/*文档和应用之间关系*/
SELECT * FROM zsFND_DOCUMENTS/*文档信息*/
SELECT * FROM FND_LANGUAGES
SELECT * from FND_TERRITORIES/*区域信息表*/
SELECT * from  FND_CONCURRENT_PROCESSES /*存储并发程序管理*/
SELECT * FROM FND_CONCURRENT_PROCESSORS/*并发程序管理子程序*/
/*并发程序表*/
SELECT * FROM fnd_concurrent_programs fcp WHERE fcp.CONCURRENT_PROGRAM_NAME LIKE 'CUX%'
/*多个语言配置信息表*/
SELECT * FROM fnd_concurrent_programs_tl fcpl WHERE fcpl.USER_CONCURRENT_PROGRAM_NAME LIKE 'CUX%'
/*每个并发管理器（并发队列）的信息，包括客户自己定义的并发管理器。*/
SELECT * FROM  fnd_concurrent_queues fcq WHERE 1=1
/*.每个并发管理器可以同时处理并发程序的个数*/
SELECT * from FND_CONCURRENT_QUEUE_SIZE fcq WHERE fcq.CONCURRENT_QUEUE_ID='5'
/*并发请求产生的文件，比如pdf的，rtf的，excel的等等。*/
SELECT * FROM  FND_CONC_REQ_OUTPUTS
/*可执行文件信息*/
SELECT * from FND_EXECUTABLES
/*弹性描述信息*/
SELECT * from  FND_DESCRIPTIVE_FLEXS 
/*存储键和描述性flexfield段的有效值。*/
SELECT * FROM fnd_flex_values
/*弹性域值集*/
SELECT * FROM fnd_flex_value_sets

SELECT fvv.flex_value_id
      ,fvv.flex_value
      ,fvv.flex_value_meaning
      ,fvv.description
      ,fvs.flex_value_set_name
FROM   fnd_flex_value_sets fvs
      ,fnd_flex_values_vl  fvv
WHERE  fvs.flex_value_set_id = fvv.flex_value_set_id
AND    fvs.flex_value_set_name = 'INCLUDE'
 
/*fnd lookups*/
SELECT * FROM fnd_lookups
SELECT * FROM  fnd_lookup_values_vl


FND_CONCURRENT_PROGRAMS

SELECT * from FND_CONCURRENT_QUEUES
---并发程序研究

select request_id, controlling_manager,  phase_code
from fnd_concurrent_requests  
where phase_code='R';

select  fcr.REQUEST_ID,fcr.CONTROLLING_MANAGER,fcr.PHASE_CODE
from fnd_concurrent_requests  fcr
where phase_code='R';

# 根据 request id 找到 对应的<controlling_manager>
select request_id, controlling_manager,  phase_code
from fnd_concurrent_requests  
where request_id  ='746020'

状态（STATUS_CODE）：
已取消 D
已禁用 U
错误 E
无管理程序 M
正常 R
暂挂 H
暂停 W
重新开始 B
已计划 I
准备 Q
挂起 S
已终止 X
终止 T
等待中 A
警告 G
I应该是Inactive 
另外 四个阶段(PHASE_CODE)：
已完成 C
无效 I
等待 P
运行中 R
select OS_PROCESS_ID, ORACLE_PROCESS_ID
from fnd_concurrent_processes
where CONCURRENT_PROCESS_ID IS NULL


-----------------------------------

SELECT USERENV('SESSIONID') FROM DUAL;
SELECT * FROM v$session se WHERE se.SID='5575832'


-----SQL 


RACLE EBS常用表查询语句

1.  OU、库存组织
SELECT hou.organization_id ou_org_id,           --org_id  

       hou.name ou_name,                        --ou 名称   

       ood.organization_id org_org_id,          -- 库存组织 id  

       ood.organization_code org_org_code,      -- 库存组织代码    

       msi.secondary_inventory_name,            -- 子库存名称   

       msi.description                          -- 子库存描述   

  FROM hr_organization_information   hoi,        -- 组织分类表   

        hr_operating_units           hou,        --ou 视图     

        org_organization_definitions ood,        -- 库存组织定义视图   

        mtl_secondary_inventories    msi         -- 子库存信息表   

  WHERE hoi.org_information1 = 'OPERATING_UNIT'  

   AND hoi.organization_id  = hou.organization_id  

   AND ood.operating_unit   = hoi.organization_id  

   AND ood.organization_id  = msi.organization_id

-- 获取系统 ID

call fnd_global.APPS_INITIALIZE( 1318 , 50583 , 401 )

select fnd_profile.VALUE( 'ORG_ID' ) FROM DUAL

select * from hr_operating_units hou where hou.organization_id= 204

2.  用户、责任及 HR
-- 系统责任定义 VIEW(FROM FND_RESPONSIBILITY_TL, FND_RESPONSIBILITY)

SELECT APPLICATION_ID,

       RESPONSIBILITY_ID,

       RESPONSIBILITY_KEY,

       END_DATE,

       RESPONSIBILITY_NAME,

       DESCRIPTION

  FROM FND_RESPONSIBILITY_VL;

-- 用户责任关系

SELECT USER_ID, RESPONSIBILITY_ID FROM FND_USER_RESP_GROUPS;

-- 用户表

SELECT USER_ID, USER_NAME, EMPLOYEE_ID, PERSON_PARTY_ID, END_DATE

  FROM FND_USER;

-- 人员表 VIEW

SELECT PERSON_ID,

       START_DATE,

       DATE_OF_BIRTH,

       EMPLOYEE_NUMBER,

       NATIONAL_IDENTIFIER,

       SEX,

       FULL_NAME

  FROM per_people_f;

-- 综合查询

SELECT USER_NAME, FULL_NAME, RESPONSIBILITY_NAME, CC.DESCRIPTION

  FROM FND_USER              AA,

       FND_USER_RESP_GROUPS  BB,

       FND_RESPONSIBILITY_VL CC,

       per_people_f          DD

  WHERE AA.USER_ID = BB.USER_ID

   AND BB.RESPONSIBILITY_ID = CC.RESPONSIBILITY_ID

   AND AA.EMPLOYEE_ID = DD.PERSON_ID

   AND RESPONSIBILITY_NAME like '% 供应处 %'

  ORDER BY USER_NAME;

-- 综合查询

-- 人员状况基本信息表

SELECT PAF.PERSON_ID 系统 ID,

       PAF.FULL_NAME 姓名 ,

       PAF.DATE_OF_BIRTH 出生日期 ,

       PAF.REGION_OF_BIRTH 出生地区 ,

       PAF.NATIONAL_IDENTIFIER 身份证号 ,

       PAF.ATTRIBUTE1 招工来源 ,

       PAF.ATTRIBUTE3 员工类型 ,

       PAF.ATTRIBUTE11 集团合同号 ,

       PAF.original_date_of_hire 参加工作日期 ,

       PAF.PER_INFORMATION17 省份 ,

       DECODE (PAF.SEX, 'M' , ' 男 ' , 'F' , ' 女 ' , 'NULL' ) 性别 , --decode 适合和同一值做比较有多种结果，不适合和多种值比较有多种结果

       CASE PAF.SEX

            WHEN 'M' THEN ' 男 '

            WHEN 'F' THEN ' 女 '

            ELSE 'NULL'

            END   性别 1,     --case 用法一

       CASE WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1960' THEN '50 年代 '

            WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1970' THEN '60 年代 '

            WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1980' THEN '70 年代 '

            WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1990' THEN '80 年代 '

            WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '2000' THEN '90 年代 '

            ELSE '21 世纪 ' --case 用法二

       END 出生年代

FROM PER_ALL_PEOPLE_F PAF

 

3.  供应商 VENDOR
-- 供应商主表数据：

SELECT ass.vendor_id                  vendor_id,

       ass.party_id                   party_id,

       ass.segment1                   vendor_code,

       ass.vendor_name                vendor_name,

       ass.vendor_name                vendor_short_name,

       ass.vendor_type_lookup_code    vendor_type,

       flv.meaning                    vendor_type_meaning,

       hp.tax_reference               tax_registered_name,

       ass.payment_method_lookup_code payment_method,

       att.name                       term_name,

       att.enabled_flag               enabled_flag,

       att.end_date_active            end_date_active,

       ass.creation_date              creation_date,

       ass.created_by                 created_by,

       ass.last_update_date           last_update_date,

       ass.last_updated_by            last_updated_by,

       ass.last_update_login          last_update_login

  FROM ap_suppliers      ass,

       fnd_lookup_values flv,

       hz_parties        hp,

       ap_terms_tl       att

  WHERE ass.vendor_type_lookup_code = flv.lookup_code(+)

   AND flv.lookup_type(+) = 'VENDOR TYPE'

   AND flv.language(+) = userenv ( 'LANG' )

   AND ass.party_id = hp.party_id

   AND att.language = userenv ( 'LANG' )

   AND ass.terms_id = att.term_id(+)

-- 供应商银行信息

SELECT ass.vendor_id         vendor_id,

       ass.party_id          party_id,

       bank.party_id         bank_id,

        bank.party_name       bank_name,

       branch.party_id       branch_id,

       branch.party_name     bank_branch_name,

       ieba.bank_account_num bank_account_num

  FROM ap_suppliers          ass,

       hz_parties            hp,

       iby_account_owners    iao,

       iby_ext_bank_accounts ieba,

       hz_parties            bank,

       hz_parties            branch

  WHERE ass.party_id = hp.party_id

   AND hp.party_id = iao.account_owner_party_id(+)

   AND iao.ext_bank_account_id = ieba.ext_bank_account_id(+)

   AND ieba.bank_id = bank.party_id(+)

   AND ieba.branch_id = branch.party_id(+)

  ORDER BY ieba.creation_date;

-- 供应商开户行地址信息

SELECT hps.party_id      party_id,

       hps.party_site_id party_site_id,

        hl.location_id    location_id,

       hl.country        country,

       hl.province       province,

       hl.city           city,

       hl.address1       address1,

       hl.address2       address2,

       hl.address3       address3,

       hl.address4       address4

  FROM hz_party_sites hps, hz_locations hl

  WHERE hps.location_id = hl.location_id

  ORDER BY hps.creation_date

-- 供应商联系人信息

SELECT hr.subject_id subject_id,

       hr.object_id object_id,

       hr.party_id party_id,

       hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||

       hp.person_first_name contact_person,

       hcpp.phone_area_code phone_area_code,

       hcpp.phone_number phone_number,

       hcpp.phone_extension phone_extension,

       hcpf.phone_area_code fax_phone_area_code,

       hcpf.phone_number fax_phone_number,

       hcpe.email_address email_address

  FROM hz_relationships  hr,

       hz_contact_points hcpp,

       hz_contact_points hcpf,

       hz_contact_points hcpe,

       hz_parties        hp

  WHERE hr.object_id = hp.party_id

   AND hcpp.owner_table_id(+) = hr.party_id

   AND hcpf.owner_table_id(+) = hr.party_id

   AND hcpe.owner_table_id(+) = hr.party_id

   AND hr.object_type = 'PERSON'

   AND hr.relationship_code(+) = 'CONTACT'

   AND hcpp.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpf.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpe.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpp.contact_point_type(+) = 'PHONE'

   AND hcpp.phone_line_type(+) = 'GEN'

   AND hcpf.contact_point_type(+) = 'PHONE'

   AND hcpf.phone_line_type(+) = 'FAX'

   AND hcpe.contact_point_type(+) = 'EMAIL'

   AND hcpe.phone_line_type IS NULL

  ORDER BY hr.creation_date;

-- 供应商地址主信息

SELECT assa.vendor_site_id       vendor_site_id,

       assa.vendor_id            vendor_id,

       assa.vendor_site_code     vendor_code,

       assa.vendor_site_code     address_short_name,

       assa.address_line1        address_line1,

       assa.address_line2        address_line2,

       assa.address_line3        address_line3,

       assa.address_line4        address_line4,

       assa.org_id               org_id,

       assa.country              country,

       assa.province             province,

       assa.city                 city,

       assa.county               county,

       assa.zip                  zip,

       assa.pay_site_flag        pay_site_flag,

       assa.purchasing_site_flag purchasing_site_flag,

       assa.inactive_date        inactive_date,

       assa.creation_date        creation_date,

       assa.created_by           created_by,

       assa.last_update_date     last_update_date,

       assa.last_updated_by      last_updated_by,

       assa.last_update_login    last_update_login

  FROM ap_suppliers ass, ap_supplier_sites_all assa

  WHERE assa.vendor_id = ass.vendor_id;

-- 供应商地址联系人信息： phone 、 fax 和 Email

SELECT hcpp.phone_area_code phone_area_code,

       hcpp.phone_number    phone_number,

       hcpp.phone_extension phone_extension,

       hcpf.phone_area_code fax_phone_area_code,

       hcpf.phone_number    fax_phone_number,

       hcpe.email_address   email_address

  FROM ap_supplier_sites_all assa,

       hz_contact_points     hcpp,

       hz_contact_points     hcpf,

       hz_contact_points     hcpe,

       hz_party_sites        hps

  WHERE assa.party_site_id = hps.party_site_id

   AND hcpp.owner_table_id(+) = assa.party_site_id

   AND hcpf.owner_table_id(+) = assa.party_site_id

   AND hcpe.owner_table_id(+) = assa.party_site_id

   AND hcpp.owner_table_name(+) = 'HZ_PARTY_SITES'

   AND hcpf.owner_table_name(+) = 'HZ_PARTY_SITES'

   AND hcpe.owner_table_name(+) = 'HZ_PARTY_SITES'

   AND hcpp.contact_point_type(+) = 'PHONE'

   AND hcpp.phone_line_type(+) = 'GEN'

   AND hcpf.contact_point_type(+) = 'PHONE'

   AND hcpf.phone_line_type(+) = 'FAX'

   AND hcpe.contact_point_type(+) = 'EMAIL'

   AND hcpe.phone_line_type IS NULL ;

-- 供应商地址收件人信息

SELECT assa.party_site_id

FROM ap_supplier_sites_all assa

-- 根据 party_site_id 得到供应商地址的收件人名称   

SELECT hps.addressee FROM hz_party_sites hps;

-- 供应商银行帐户分配层次关系

SELECT * FROM iby_pmt_instr_uses_all;

-- 供应商银行帐户分配层次关系明细 ( 不包括供应商层的分配信息 ):

SELECT * FROM iby_external_payees_all;

 

4.  客户 CUSTOMER
--SQL 查询

-- 客户账户表    以许继 1063 电网客户为例 -->>PARTY_ID = 21302

SELECT * FROM hz_cust_accounts AA WHERE AA.CUST_ACCOUNT_ID = 1063 ;

 

-- 客户名称及地址全局信息表 -->> PARTY_NUMBER = 19316

SELECT * FROM hz_parties AA WHERE AA.PARTY_ID = 21302 ;

 

-- 客户地点账户主文件

SELECT * FROM hz_cust_acct_sites_all WHERE CUST_ACCOUNT_ID = 1063 ;

 

-- 客户地点 ( 关联 hz_cust_acct_sites_all)

SELECT * FROM HZ_PARTY_SITES WHERE PARTY_ID = 21302 ;

 

-- 地点地址名称 ( 关联 hz_cust_acct_sites_all)

SELECT AA.ADDRESS1, AA.ADDRESS_KEY

  FROM HZ_LOCATIONS AA, HZ_PARTY_SITES BB

  WHERE AA.LOCATION_ID = BB.LOCATION_ID

   AND BB.PARTY_ID = 21302 ;

 

-- 客户地点业务目的 ( 关联 hz_cust_acct_sites_all 用 CUST_ACCT_SITE_ID)

SELECT * FROM HZ_CUST_SITE_USES_ALL;

 

-- 客户地点详细信息表，以供应处 OU 的身份 ORG_ID = 119

SELECT AA.PARTY_SITE_ID            客户组织地点 ID,

       AA.PARTY_ID                 客户组织 ID,

       AA.LOCATION_ID              地点 ID,

       AA.PARTY_SITE_NUMBER        地点编号 ,

       AA.IDENTIFYING_ADDRESS_FLAG 地址标示 ,

       AA.STATUS                   有效否 ,

       AA.PARTY_SITE_NAME,

       BB.ORG_ID                   业务实体 ,

       BB.bill_to_flag             收单标示 ,

       BB.ship_to_flag              收货标示 ,

       CC.ADDRESS1                 地点名称 ,

       DD.SITE_USE_ID,

       DD.SITE_USE_CODE,

       DD.PRIMARY_FLAG,

       DD.STATUS,

       DD.LOCATION                 业务目的 ,

DD.BILL_TO_SITE_USE_ID      收单地 ID,

       DD.TAX_CODE

  FROM hz_party_sites         AA,

       hz_cust_acct_sites_all BB,

       hz_locations           CC,

       HZ_CUST_SITE_USES_ALL  DD

  WHERE AA.PARTY_SITE_ID = BB.PARTY_SITE_ID

   AND BB.CUST_ACCOUNT_ID = 1063

   AND BB.ORG_ID = 119

   AND AA.STATUS = 'A'

   AND AA.LOCATION_ID = CC.LOCATION_ID

   AND BB.CUST_ACCT_SITE_ID(+) = DD.CUST_ACCT_SITE_ID

   AND DD.STATUS <> 'I' ;

 

--************* 综合查询 ************--

-- 客户主数据

SELECT hca.cust_account_id     customer_id,

       hp.party_number         customer_number,

       hp.party_name           customer_name,

       hp.party_name           customer_short_name,

       hca.customer_type       customer_type,

       alt.meaning             customer_type_meaning,

       hca.customer_class_code customer_class,

       alc.meaning             customer_class_meaning,

       hp.tax_reference        tax_registered_name,

       rt.name                 term_name,

       hca.creation_date       creation_date,

       hca.created_by          created_by,

       hca.last_update_date     last_update_date,

       hca.last_updated_by     last_updated_by,

       hca.last_update_login   last_update_login

  FROM hz_parties           hp,

       hz_cust_accounts     hca,

       ar_lookups           alt,

       ar_lookups           alc,

       hz_customer_profiles hcp,

       ra_terms             rt

  WHERE hp.party_id = hca.party_id

   AND hca.customer_type = alt.lookup_code(+)

   AND alt.lookup_type = 'CUSTOMER_TYPE'

   AND hca.customer_class_code = alc.lookup_code(+)

   AND alc.lookup_type(+) = 'CUSTOMER CLASS'

   AND hca.cust_account_id = hcp.cust_account_id(+)

   AND hcp.standard_terms = rt.term_id(+)

 

-- 客户收款方法 SQL

SELECT arm.name receipt_method_name

FROM hz_cust_accounts        hca,

     ra_cust_receipt_methods rcrm,

     ar_receipt_methods      arm

WHERE hca.cust_account_id = rcrm.customer_id

      AND rcrm.receipt_method_id = arm.receipt_method_id

ORDER BY rcrm.creation_date;

-- 客户账户层银行账户信息 SQL

SELECT hca.cust_account_id   cust_account_id,

       hp.party_id           party_id,

       bank.party_id         bank_id,

       bank.party_name       bank_name,

       branch.party_id       branch_id,

       branch.party_name     bank_branch_name,

       ieba.bank_account_num bank_account_num

FROM hz_cust_accounts      hca,

       hz_parties            hp,

       iby_account_owners    iao,

       iby_ext_bank_accounts ieba,

       hz_parties            bank,

       hz_parties            branch

WHERE hca.party_id = hp.party_id

   AND hp.party_id = iao.account_owner_party_id(+)

   AND iao.ext_bank_account_id = ieba.ext_bank_account_id(+)

   AND ieba.bank_id = bank.party_id(+)

   AND ieba.branch_id = branch.party_id(+)

  ORDER BY ieba.creation_date;

-- 客户开户行地址信息 SQL

SELECT hl.country || '-' || hl.province || '-' || hl.city || '-' ||

       hl.address1 || '-' || hl.address2 || '-' || hl.address3 || '-' ||

       hl.address4 bank_address

FROM hz_party_sites hps, hz_locations hl

WHERE hps.location_id = hl.location_id

ORDER BY hps.creation_date;

-- 客户账户层联系人信息：联系人、电话、手机和 Email SQL

SELECT hr.party_id party_id,

       hcar.cust_account_id cust_account_id,

       hcar.cust_acct_site_id cust_acct_site_id,

       hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||

       hp.person_first_name contact_person,

       hcpp.phone_area_code phone_area_code,

       hcpp.phone_number phone_number,

       hcpp.phone_extension phone_extension,

       hcpm.phone_area_code mobile_phone_area_code,

       hcpm.phone_number mobile_phone_number,

       hcpe.email_address email_address

  FROM hz_relationships      hr,

       hz_cust_account_roles hcar,

       hz_org_contacts       hoc,

       hz_contact_points     hcpp,

       hz_contact_points     hcpm,

       hz_contact_points     hcpe,

       hz_parties            hp,

       hz_cust_accounts      hca

  WHERE hr.object_id = hp.party_id

   AND hr.party_id = hcar.party_id

   AND hr.relationship_id = hoc.party_relationship_id(+)

   AND hcpp.owner_table_id(+) = hr.party_id

   AND hcpm.owner_table_id(+) = hr.party_id

   AND hcpe.owner_table_id(+) = hr.party_id

   AND hr.object_type = 'PERSON'

   AND hr.relationship_code(+) = 'CONTACT'

   AND hcpp.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpm.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpe.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpp.contact_point_type(+) = 'PHONE'

   AND hcpp.phone_line_type(+) = 'GEN'

   AND hcpm.contact_point_type(+) = 'PHONE'

   AND hcpm.phone_line_type(+) = 'MOBILE'

   AND hcpe.contact_point_type(+) = 'EMAIL'

   AND hcpe.phone_line_type IS NULL

   AND hr.subject_id = hca.party_id

   AND hcar.cust_acct_site_id IS NULL

  ORDER BY hr.creation_date;

-- 客户地址

SELECT hcasa.cust_acct_site_id customer_site_id,

       hcasa.cust_account_id   customer_id,

       hps.party_site_number   customer_site_code,

       hps.party_site_name     customer_site_name,

       hl.address1             address_line1,

       hl.address2             address_line2,

       hl.address3             address_line3,

       hl.address4             address_line4,

       hcasa.org_id             org_id,

       hl.country              country,

       hl.province             province,

       hl.city                 city,

       hl.county               county,

       hl.postal_code          zip,

       hcasa.bill_to_flag      bill_to_flag,

       hcasa.ship_to_flag      ship_to_flag,

       hca.creation_date       creation_date,

       hca.created_by          created_by,

       hca.last_update_date    last_update_date,

       hca.last_updated_by     last_updated_by,

       hca.last_update_login   last_update_login

  FROM hz_cust_accounts       hca,

       hz_cust_acct_sites_all hcasa,

       hz_party_sites         hps,

       hz_locations           hl

  WHERE hca.cust_account_id = hcasa.cust_account_id

   AND hcasa.party_site_id = hps.party_site_id

   AND hps.location_id = hl.location_id;

 

-- 客户账户层地址 contact person 信息 :phone,mobile,email

SELECT hr.party_id party_id,

       hcar.cust_account_id cust_account_id,

       hcar.cust_acct_site_id cust_acct_site_id,

       hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||

       hp.person_first_name contact_person,

       hcpp.phone_area_code phone_area_code,

       hcpp.phone_number phone_number,

       hcpp.phone_extension phone_extension,

       hcpm.phone_area_code mobile_phone_area_code,

       hcpm.phone_number mobile_phone_number,

       hcpe.email_address email_address

  FROM hz_relationships      hr,

       hz_cust_account_roles hcar,

       hz_org_contacts       hoc,

       hz_contact_points     hcpp,

       hz_contact_points     hcpm,

       hz_contact_points     hcpe,

       hz_parties            hp,

       hz_cust_accounts      hca

  WHERE hr.object_id = hp.party_id

   AND hr.party_id = hcar.party_id

   AND hr.relationship_id = hoc.party_relationship_id(+)

   AND hcpp.owner_table_id(+) = hr.party_id

   AND hcpm.owner_table_id(+) = hr.party_id

   AND hcpe.owner_table_id(+) = hr.party_id

   AND hr.object_type = 'PERSON'

   AND hr.relationship_code(+) = 'CONTACT'

   AND hcpp.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpm.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpe.owner_table_name(+) = 'HZ_PARTIES'

   AND hcpp.contact_point_type(+) = 'PHONE'

   AND hcpp.phone_line_type(+) = 'GEN'

   AND hcpm.contact_point_type(+) = 'PHONE'

   AND hcpm.phone_line_type(+) = 'MOBILE'

   AND hcpe.contact_point_type(+) = 'EMAIL'

   AND hcpe.phone_line_type IS NULL

   AND hr.subject_id = hca.party_id

   AND hca.cust_account_id = hcar.cust_account_id

  ORDER BY hr.creation_date;

 

-- 客户账户地点地址

SELECT hp.party_id,

       hca.cust_account_id,

        hcasa.cust_acct_site_id,

       hcasa.bill_to_flag,

       hcasa.ship_to_flag,

       hcsua.site_use_id,

       hcasa.party_site_id,

       hcsua.site_use_code,

       hcsua.primary_flag,

       hcsua.location,

       hcsua.org_id

  FROM hz_parties             hp,

       hz_cust_accounts       hca,

       hz_party_sites         hps,

       hz_cust_acct_sites_all hcasa,

       hz_cust_site_uses_all  hcsua

  WHERE hp.party_id = hca.party_id

   AND hca.cust_account_id = hcasa.cust_account_id

   AND hcasa.party_site_id = hps.party_site_id

   AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id

-- 客户主配置文件

SELECT * FROM hz_cust_profile_classes;

SELECT * FROM hz_customer_profiles;

SELECT * FROM hz_cust_prof_class_amts;

SELECT * FROM hz_cust_profile_amts;

 

5.  订单 OE
--

select * from oe_order_headers_all 销售头

select * from oe_order_lines_all 销售行

select * from wsh_new_deliveries 发送

select * from wsh_delivery_details

select * from wsh_delivery_assignments

-- 综合查询 1- 未结销售订单

SELECT H.ORDER_NUMBER      销售订单 ,

       h.cust_po_number    客户 PO,

       cust.account_number 客户编码 ,

       hp.party_name       客户名称 ,

       ship_use.location   收货地 ,

       bill_use.location   收单地 ,

       h.ordered_date       订单日期 ,

       H.ATTRIBUTE1         合同号 ,

       h.attribute2         屏号 ,

       h.attribute3         来源编码 ,

       l.line_number        行号 ,

       l.ordered_item       物料 ,

       msi.description      物料说明 ,

       l.order_quantity_uom 订购单位 ,

       l.ordered_quantity   订购数量 ,

       l.cancelled_quantity 取消数量 ,

       l.shipped_quantity   发运数量 ,

       l.schedule_ship_date 计划发运日期 ,

       l.booked_flag        登记标记 ,

       ol.MEANING           工作流状态 ,

       l.cancelled_flag     取消标记

  FROM OE_ORDER_HEADERS_ALL  H,

       OE_ORDER_LINES_ALL    L,

       HZ_CUST_ACCOUNTS      CUST,

       hz_parties            hp,

       hz_cust_site_uses_all ship_use,

       hz_cust_site_uses_all bill_use,

       mtl_system_items_b    msi,

       oe_lookups            ol

  WHERE 1 = 1

   AND H.HEADER_ID = L.HEADER_ID

   AND H.SOLD_TO_ORG_ID = CUST.CUST_ACCOUNT_ID

   and cust.party_id = hp.party_id

   and h.ship_to_org_id = ship_use.site_use_id

   and h.invoice_to_org_id = bill_use.site_use_id

   and l.flow_status_code not in ( 'CLOSED' , 'CANCELLED' )

   and l.inventory_item_id = msi.inventory_item_id

   and msi.organization_id = 141

   and l.flow_status_code = ol.LOOKUP_CODE

   and ol.LOOKUP_TYPE = 'LINE_FLOW_STATUS'

   AND CUST.ACCOUNT_NUMBER IN ( '91010072' , '91010067' , '91010036' )

  order by party_name ，收货地，销售订单 ;

6.  采购申请 PR
-- 申请单头 （以电网组织 ORG_ID=112 内部申请 =14140002781 为例

SELECT PRH.REQUISITION_HEADER_ID  申请单头 ID,

       PRH.PREPARER_ID,

       PRH.Org_Id                 OU_ID,

       PRH.SEGMENT1               申请单编号 ,

       PRH.Creation_Date          创建日期 ,

       PRH.Created_By             编制人 ID,

       FU.USER_NAME               用户名称 ,

       PP.FULL_NAME               用户姓名 ,

       PRH.Approved_Date          批准日期 ,

       PRH.Description            说明 ,

       PRH.Authorization_Status   状态 ,

       PRH.Type_Lookup_Code       类型 ,

       PRH.Transferred_To_Oe_Flag 传递标示

  FROM PO_REQUISITION_HEADERS_ALL PRH, FND_USER FU, per_people_f PP

  WHERE PRH.CREATED_BY = FU.USER_ID

   AND FU.EMPLOYEE_ID = PP.PERSON_ID

   AND PRH.ORG_ID = 112

   AND PRH.SEGMENT1 = '14140002781' ;

-->> 内部申请 =14140002781  申请单头 ID = 3379   

-- 申请单行明细

SELECT PRL.REQUISITION_HEADER_ID       申请单 ID,

       PRL.REQUISITION_LINE_ID         行 ID,

       PRL.LINE_NUM                    行号 ,

       PRL.CATEGORY_ID                 分类 ID,

       PRL.ITEM_ID                      物料 ID,

       ITEM.SEGMENT1                   物料编码 ,

       PRL.ITEM_DESCRIPTION            物料说明 ,

       PRL.Quantity                    需求数 ,

       PRL.Quantity_Delivered          送货数 ,

       PRL.Quantity_Cancelled          取消数 ,

       PRL.Unit_Meas_Lookup_Code       单位 ,

       PRL.Unit_Price                  参考价 ,

       PRL.Need_By_Date                需求日期 ,

       PRL.Source_Type_Code            来源类型 ,

       PRL.Org_Id                      OU_ID,

       PRL.Source_Organization_Id      对方组织 ID,

       PRL.Destination_Organization_Id 本方组织 ID

  from PO_REQUISITION_LINES_ALL PRL,MTL_SYSTEM_ITEMS ITEM

  WHERE PRL.ORG_ID = 112

   AND PRL.ITEM_ID = ITEM.INVENTORY_ITEM_ID

   AND PRL.Destination_Organization_Id = ITEM.ORGANIZATION_ID

   AND PRL.REQUISITION_HEADER_ID = 3379 ;

-- 申请单头 ( 加对方订单编号 )

SELECT PRH.REQUISITION_HEADER_ID  申请单头 ID,

       PRH.PREPARER_ID,

       PRH.Org_Id                 OU_ID,

       PRH.SEGMENT1               申请单编号 ,

       PRH.Creation_Date          创建日期 ,

       PRH.Created_By              编制人 ID,

       FU.USER_NAME               用户名称 ,

       PP.FULL_NAME               用户姓名 ,

       PRH.Approved_Date          批准日期 ,

       PRH.Description            说明 ,

       PRH.Authorization_Status   状态 ,

       PRH.Type_Lookup_Code       类型 ,

       PRH.Transferred_To_Oe_Flag 传递标示 ,

       OEH.ORDER_NUMBER 对方 CO 编号

  FROM PO_REQUISITION_HEADERS_ALL PRH, FND_USER FU, per_people_f PP,OE_ORDER_HEADERS_ALL OEH

  WHERE PRH.CREATED_BY = FU.USER_ID

   AND FU.EMPLOYEE_ID = PP.PERSON_ID

   AND PRH.REQUISITION_HEADER_ID = OEH.SOURCE_DOCUMENT_ID(+)

   AND PRH.ORG_ID = 112

   AND PRH.SEGMENT1 = '14140002781' ;

--( 销售订单记录有对方 OU_ID, 申请单关键字 SOURCE_DOCUMENT_ID 申请单号 SOURCE_DOCEMENT_REF)

 

******************* 综合查询类 *******************

-- 申请单头综合查询 （进限制只能查询 -- 电网组织 ORG_ID=112)

SELECT PRH.REQUISITION_HEADER_ID       申请单头 ID,

       PRH.Org_Id                      组织 ID,

       PRH.SEGMENT1                    申请单编号 ,

       PRH.Creation_Date               创建日期 ,

       PRH.Created_By                  编制人 ID,

       FU.USER_NAME                    用户名称 ,

       PP.FULL_NAME                    用户姓名 ,

       PRH.Approved_Date               批准日期 ,

       PRH.Description                 说明 ,

       PRH.Authorization_Status        状态 ,

       PRH.Type_Lookup_Code            类型 ,

       PRH.Transferred_To_Oe_Flag      传递标示 ,

       PRL.REQUISITION_LINE_ID         行 ID,

       PRL.LINE_NUM                    行号 ,

       PRL.CATEGORY_ID                 分类 ID,

       PRL.ITEM_ID                     物料 ID,

       ITEM.SEGMENT1                   物料编码 ,

       PRL.ITEM_DESCRIPTION            物料说明 ,

       PRL.Quantity                    需求数 ,

       PRL.Quantity_Delivered          送货数 ,

       PRL.Quantity_Cancelled          取消数 ,

       PRL.Unit_Meas_Lookup_Code       单位 ,

       PRL.Unit_Price                   参考价 ,

       PRL.Need_By_Date                需求日期 ,

       PRL.Source_Type_Code            来源类型 ,

       PRL.Source_Organization_Id      对方组织 ID,

       PRL.Destination_Organization_Id 本方组织 ID

  FROM PO_REQUISITION_HEADERS_ALL PRH,

       FND_USER                    FU,

       per_people_f               PP,

       PO_REQUISITION_LINES_ALL   PRL,

       MTL_SYSTEM_ITEMS           ITEM

  WHERE PRH.CREATED_BY = FU.USER_ID

   AND FU.EMPLOYEE_ID = PP.PERSON_ID

   AND PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID

   AND PRH.Org_Id = PRL.ORG_ID

   AND PRL.ITEM_ID = ITEM.INVENTORY_ITEM_ID

   AND PRL.Destination_Organization_Id = ITEM.ORGANIZATION_ID

   AND PRH.ORG_ID = 112 ;

 

-- 若需创建视图只需在 SELECT 语句前加上

  CREATE OR REPLACE VIEW CUX_INV_PR112 AS

7.  采购订单 PO
-- 采购单头信息   TYPE_LOOKUP_CODE='STANDARD' （以供应处 OU  ORG_ID=119  采购单 ='' 为例）

-- 类型说明 TYPE_LOOKUP_CODE='STANDARD' 为采购单    TYPE_LOOKUP_CODE='BLANKET' 为采购协议

SELECT POH.ORG_ID               OU_ID,

       POH.PO_HEADER_ID         采购单头 ID,

       POH.TYPE_LOOKUP_CODE     类型 ,

        POH.AUTHORIZATION_STATUS 状态 ,

       POH.VENDOR_ID            供应商 ID,

       VENDOR.VENDOR_NAME       供应商名 ,

       POH.VENDOR_SITE_ID       供应商地址 ID,

       POH.VENDOR_CONTACT_ID    供应商联系人 ID,

       POH.SHIP_TO_LOCATION_ID  本方收货地 ID,

       POH.BILL_TO_LOCATION_ID  本方收单地 ID,

       POH.CREATION_DATE        创建日期 ,

       POH.APPROVED_FLAG        审批 YN,

       POH.APPROVED_DATE        审批日期 ,

       POH.COMMENTS             采购单说明 ,

       POH.TERMS_ID             条款 ID,

       POH.AGENT_ID             采购员 ID,

       AGT_PP.LAST_NAME         采购员 ,                 

       POH.CREATED_BY           创建者 ID,

       FU.USER_NAME             创建用户 ,

       PP.FULL_NAME             用户姓名

  FROM PO_HEADERS_ALL POH, FND_USER FU, per_people_f PP,PER_ALL_PEOPLE_F AGT_PP,ap_suppliers VENDOR

  WHERE POH.CREATED_BY = FU.USER_ID

   AND FU.EMPLOYEE_ID = PP.PERSON_ID

   AND POH.AGENT_ID = AGT_PP.PERSON_ID

   AND POH.VENDOR_ID=VENDOR.VENDOR_ID

   AND POH.ORG_ID = 119

   AND POH.TYPE_LOOKUP_CODE = 'STANDARD'

   AND POH.SEGMENT1 = '14730005436' ;

  /*

  FND_USER FU, per_people_f PP  用户相关表

  po_agents_name_v 采购员视图 ---->   PO_AGENTS.AGENT_ID = PER_ALL_PEOPLE_F.PERSON_ID 采购员相关表

  ap_suppliers 供应商主表

  */
-->> POH.SEGMENT1 = '14730005436'  PO_HEADER_ID = 10068

-- 采购单行信息

SELECT POL.ORG_ID                OU_ID,

       POL.PO_HEADER_ID          采购单头 ID,

       POL.PO_LINE_ID            行 ID,

       POL.LINE_NUM              行号 ,

       POL.ITEM_ID               物料 ID,

       ITEM.SEGMENT1             物料编码 ,

       POL.ITEM_DESCRIPTION      物料说明 ,

       POL.UNIT_MEAS_LOOKUP_CODE 单位 ,

       POL.UNIT_PRICE            单价 ,

       PO_LCT.QUANTITY           订购数 ,

       PO_LCT.QUANTITY_RECEIVED  验收数 ,

       PO_LCT.QUANTITY_ACCEPTED  接收数 ,

       PO_LCT.QUANTITY_REJECTED  拒绝数 ,

       PO_LCT.QUANTITY_CANCELLED 取消数 ,

       PO_LCT.QUANTITY_BILLED    到票数 ,

       PO_LCT.PROMISED_DATE      承诺日期 ,

       PO_LCT.NEED_BY_DATE       需求日期

  FROM PO_LINES_ALL          POL,

       Po_Line_Locations_all PO_LCT,

       MTL_SYSTEM_ITEMS      ITEM

  WHERE POL.ORG_ID = PO_LCT.ORG_ID

   AND POL.PO_LINE_ID = PO_LCT.PO_LINE_ID

   AND POL.ITEM_ID = ITEM.INVENTORY_ITEM_ID

   AND ITEM.ORGANIZATION_ID = 142

   AND POL.Org_Id = 119

   AND POL.PO_HEADER_ID = 10068 ;

-- 说明： Po_Line_Locations_all 系 “ 发运表 ”

 

-- 综合查询 1 ，所分配给供应处组织的物料，存在采购协议，但缺失采购员或缺失仓库；

select MSIF.Segment1         物料编码 ,

          MSIF.Description      物料描述 ,

          MSIF.LONG_DESCRIPTION 物料详细描述 ,

       --MSIF.primary_unit_of_measure 计量单位 ,

       PRF.LAST_NAME          采购员 ,

       MISD.subinventory_code 默认接收库存 ,

       PLA.unit_price         未税价 ,

        round (PLA.unit_price * ( 1 + ZRB.percentage_rate / 100 ), 2 )        含税价 ,

       PV.VENDOR_NAME         供应商名称

  from apps.PO_HEADERS_ALL        PHA,

       apps.PO_LINES_ALL          PLA,

       apps.MTL_SYSTEM_ITEMS_FVL  MSIF,

       apps.MTL_ITEM_SUB_DEFAULTS MISD,

       apps.PER_PEOPLE_F          PRF,

       apps.PO_VENDORS            PV,

       apps.PO_VENDOR_SITES_ALL   PVSA,

       apps.ZX_RATES_B            ZRB

  where PHA.Type_Lookup_Code = 'BLANKET' and PHA.Org_Id = 119 and

       PHA.PO_HEADER_ID = PLA.Po_Header_Id and

       PHA.Global_Agreement_Flag = 'Y' and PHA.Approved_Flag in ( 'Y' , 'R' ) and

       NVL (PHA.end_Date, sysdate ) >= sysdate and

       NVL (PLA.Expiration_Date, sysdate ) >= sysdate and

       PLA.Cancel_Flag = 'N' and PLA.Item_Id = MSIF.INVENTORY_ITEM_ID and

       MSIF.ORGANIZATION_ID = 142 and

       MSIF.INVENTORY_ITEM_ID = MISD.INVENTORY_ITEM_ID(+) and

       MISD.ORGANIZATION_ID(+) = 142 and MISD.default_type(+) = 2 and

       MSIF.BUYER_ID = PRF.PERSON_ID(+) and

       PRF.EFFECTIVE_END_DATE(+) = to_date( '4712-12-31' , 'YYYY-MM-DD' ) and

       PHA.VENDOR_ID = PV.VENDOR_ID and

       PHA.Vendor_Site_Id = PVSA.VENDOR_SITE_ID and

       PVSA.VAT_CODE = ZRB.tax_rate_code and

       (MISD.subinventory_code is null or PRF.LAST_NAME is null )

 

-- 采购其他相关表

select * from po_distributions_all  分配

select * from po_releases_all

select * from rcv_shipment_headers 采购接收头

select * from rcv_shipment_lines 采购接收行

select * from rcv_transactions 接收事务处理

select * from po_agents

select * from po_vendors

select * from po_vendor_sites_all

8.  库存 INV
-- 物料主表

select MSI.ORGANIZATION_ID            组织 ID,

       MSI.INVENTORY_ITEM_ID          物料 ID,

       MSI.SEGMENT1                   物料编码 ,

       MSI.DESCRIPTION                物料说明 ,

       MSI.ITEM_TYPE                  项目类型 ,

       MSI.PLANNING_MAKE_BUY_CODE     制造或购买 ,

       MSI.PRIMARY_UNIT_OF_MEASURE    基本度量单位 ,

       MSI.BOM_ENABLED_FLAG           BOM 标志 ,

       MSI.INVENTORY_ASSET_FLAG       库存资产否 ,

       MSI.BUYER_ID                    采购员 ID,

       MSI.PURCHASING_ENABLED_FLAG    可采购否 ,

       MSI.PURCHASING_ITEM_FLAG       采购项目 ,

       MSI.UNIT_OF_ISSUE              单位 ,

       MSI.INVENTORY_ITEM_FLAG        是否为库存 ,

       MSI.LOT_CONTROL_CODE           是否批量 ,

       MSI.RESERVABLE_TYPE            是否要预留 ,

       MSI.STOCK_ENABLED_FLAG         能否库存 ,

       MSI.FIXED_DAYS_SUPPLY          固定提前期 ,

       MSI.FIXED_LOT_MULTIPLIER       固定批量大小 ,

       MSI.INVENTORY_PLANNING_CODE    库存计划方法 ,

       MSI.MAXIMUM_ORDER_QUANTITY     最大定单数 ,

       MSI.MINIMUM_ORDER_QUANTITY     最小定单数 ,

       MSI.FULL_LEAD_TIME             固定提前期 ,

       MSI.PLANNER_CODE               计划员码 ,

       MISD.SUBINVENTORY_CODE         接收子仓库 ,

       MSI.SOURCE_SUBINVENTORY        来源子仓库 ,

       MSI.WIP_SUPPLY_SUBINVENTORY    供应子仓库 ,

       MSI.ATTRIBUTE12                老编码 ,

       MSI.INVENTORY_ITEM_STATUS_CODE 物料状态 ,

       MSS.SAFETY_STOCK_QUANTITY      安全库存量   

  from mtl_system_items MSI, MTL_ITEM_SUB_DEFAULTS MISD,mtl_safety_stocks MSS

  where MSI.ORGANIZATION_ID = MISD.ORGANIZATION_ID(+)

   and MSI.INVENTORY_ITEM_ID = MISD.INVENTORY_ITEM_ID(+)

   and MSI.ORGANIZATION_ID = MSS.ORGANIZATION_ID(+)

   and MSI.INVENTORY_ITEM_ID = MSS.INVENTORY_ITEM_ID(+)

   and MSI.ORGANIZATION_ID = 1155

   and MSI.SEGMENT1 = '18020200012'

-- 物料库存数量

SELECT MOQ.ORGANIZATION_ID,

       MOQ.INVENTORY_ITEM_ID,

       MOQ.SUBINVENTORY_CODE,

       SUM (MOQ.TRANSACTION_QUANTITY) QTY

  FROM mtl_onhand_quantities MOQ

  WHERE MOQ.INVENTORY_ITEM_ID = 12781

   AND MOQ.ORGANIZATION_ID = 1155

  GROUP BY MOQ.ORGANIZATION_ID, MOQ.INVENTORY_ITEM_ID, MOQ.SUBINVENTORY_CODE;

-- 移动平均成本

SELECT CST.INVENTORY_ITEM_ID       ITEM_ID,

       CST.ORGANIZATION_ID         ORG_ID,

       CST.COST_TYPE_ID            成本类型 ,

       CST.ITEM_COST               单位成本 ,

       CST.MATERIAL_COST           材料成本 ,

       CST.MATERIAL_OVERHEAD_COST  间接费 ,

       CST.Resource_Cost           人工费 ,

       CST.OUTSIDE_PROCESSING_COST 外协费 ,

       CST.OVERHEAD_COST           制造费

  FROM CST_ITEM_COSTS CST

  WHERE CST.COST_TYPE_ID = 2

    AND CST.INVENTORY_ITEM_ID = 12781

   AND CST.ORGANIZATION_ID = 1155 ;

-- 综合查询 - 库存数量及成本
SELECT MSI.ORGANIZATION_ID        组织 ID,

       MSI.INVENTORY_ITEM_ID      物料 ID,

       MSI.SEGMENT1               物料编码 ,

       MSI.DESCRIPTION            物料说明 ,

       MSI.PLANNING_MAKE_BUY_CODE M1P2,

       MOQV.SUBINVENTORY_CODE     子库存 ,

       MOQV.QTY                   当前库存量 ,

       CST.ITEM_COST               单位成本 ,

       CST.MATERIAL_COST           材料成本 ,

       CST.MATERIAL_OVERHEAD_COST  间接费 ,

       CST.Resource_Cost           人工费 ,

       CST.OUTSIDE_PROCESSING_COST 外协费 ,

       CST.OVERHEAD_COST           制造费

  FROM MTL_SYSTEM_ITEMS MSI,

       CST_ITEM_COSTS CST,

       ( SELECT MOQ.ORGANIZATION_ID,

               MOQ.INVENTORY_ITEM_ID,

               MOQ.SUBINVENTORY_CODE,

               SUM (MOQ.TRANSACTION_QUANTITY) QTY

          FROM mtl_onhand_quantities MOQ

         WHERE MOQ.ORGANIZATION_ID = 1155

         GROUP BY MOQ.ORGANIZATION_ID,

                  MOQ.INVENTORY_ITEM_ID,

                   MOQ.SUBINVENTORY_CODE) MOQV

  WHERE MSI.ORGANIZATION_ID = CST.ORGANIZATION_ID(+)

   AND MSI.INVENTORY_ITEM_ID = CST.INVENTORY_ITEM_ID(+)

   AND MSI.ORGANIZATION_ID = MOQV.ORGANIZATION_ID(+)

   AND MSI.INVENTORY_ITEM_ID = MOQV.INVENTORY_ITEM_ID(+)

   AND CST.COST_TYPE_ID = 2

   AND MSI.ORGANIZATION_ID = 1155

   AND MSI.SEGMENT1 = '18020200012'

-- 子库存列表

SELECT * FROM mtl_secondary_inventories;

-- 货位列表  

SELECT ORGANIZATION_ID       组织代码 ,

       INVENTORY_LOCATION_ID 货位内码 ,

       SUBINVENTORY_CODE      子库名称 ,

       SEGMENT1              货位编码

  FROM mtl_item_locations;

-- 计划员表   

SELECT PLANNER_CODE    计划员代码 ,

       ORGANIZATION_ID 组织代码 ,

       DESCRIPTION      计划员描述 ,

       MP.EMPLOYEE_ID  员工 ID,

       DISABLE_DATE    失效日期

  FROM mtl_planners MP;

-- 科目设置等参数

select * from MTL_PARAMETERS MP

 

9.  物料清单 BOM
--BOM 主表 bom_bill_of_materials

select AA.BILL_SEQUENCE_ID 清单序号 ,

          AA.ASSEMBLY_ITEM_ID 装配件内码 ,

          AA.ORGANIZATION_ID  组织代码 ,

         BB.SEGMENT1         物料编码 ,

          BB.DESCRIPTION      物料说明 ,

          AA.ASSEMBLY_TYPE    装配类别

  from bom_bill_of_materials AA ， mtl_system_items BB

  where AA.ASSEMBLY_ITEM_ID = BB.INVENTORY_ITEM_ID

   and AA.ORGANIZATION_ID = BB.ORGANIZATION_ID;

--BOM 明细表 bom_inventory_components

select BILL_SEQUENCE_ID      清单序号 ,

       COMPONENT_SEQUENCE_ID 构件序号 ,

       ITEM_NUM              项目序列 ,

       OPERATION_SEQ_NUM     操作序列号 ,

       COMPONENT_ITEM_ID     子物料内码 ,

       COMPONENT_QUANTITY    构件数量 ,

       DISABLE_DATE          失效日期 ,

       supply_subinventory   供应子库存 ,

       BOM_ITEM_TYPE

  from bom_inventory_components;

 

--BOM 明细综合查询 ( 组织 限定供应处 142 装配件 = '5XJ061988')

SELECT VBOM.BID                   清单序号 ,

       VBOM.F_ITEMID              装配件内码 ,

       BB.SEGMENT1                物料编码 ,

       BB.DESCRIPTION             物料说明 ,

       VBOM.OGT_ID                组织内码 ,

       VBOM.CID                   操作 ID,

       VBOM.ITEM_NUM              物料序号 ,

       VBOM.OPID                  工序 ,

       VBOM.C_ITEMID              子物料内码 ,

       CC.SEGMENT1                物料编码 ,

       CC.DESCRIPTION              物料说明 ,

       VBOM.QTY                   构件数量 ,

       CC.PRIMARY_UOM_CODE        子计量单位码 ,

       CC.PRIMARY_UNIT_OF_MEASURE 子计量单位名 ,

       VBOM.WHSE                  供应子仓库

  FROM ( select AA.BILL_SEQUENCE_ID      BID,

               BB.ASSEMBLY_ITEM_ID       F_ITEMID,

               BB.ORGANIZATION_ID       OGT_ID,

               AA.COMPONENT_SEQUENCE_ID CID,

               AA.ITEM_NUM              ITEM_NUM,

               AA.OPERATION_SEQ_NUM     OPID,

               AA.COMPONENT_ITEM_ID     C_ITEMID,

               AA.COMPONENT_QUANTITY    QTY,

               AA.supply_subinventory   WHSE

          from bom_inventory_components AA, bom_bill_of_materials BB

         where AA.BILL_SEQUENCE_ID = BB.BILL_SEQUENCE_ID) VBOM,

       mtl_system_items BB,

        mtl_system_items CC

  WHERE VBOM.F_ITEMID = BB.INVENTORY_ITEM_ID

   and VBOM.OGT_ID = BB.ORGANIZATION_ID

   and VBOM.C_ITEMID = CC.INVENTORY_ITEM_ID

   and VBOM.OGT_ID = CC.ORGANIZATION_ID

   and VBOM.OGT_ID = 142

   and BB.SEGMENT1 = '5XJ061988'

  ORDER BY VBOM.ITEM_NUM;
-- 单层 BOM 成本查询 ( 需系统提交请求计算后 )

select inventory_item_id, organization_id, item_cost, program_update_date

  from bom.cst_item_costs

  where inventory_item_id = 23760

   and organization_id = 142 ;


select inventory_item_id, organization_id, item_cost, program_update_date

  from cst_item_cost_details

  where inventory_item_id = 23760

   and organization_id = 142 ;

 

10. 作业任务 WIP
  说明： 查询作业任务头以及作业任务工序和 BOM 情况

-- 作业任务头信息表

-- （以直流 OU_ID=117 ； ORGANIZATION_ID=1155; 及任务 WIP_ENTITY_NAME='XJ39562'; 装配件编码 SEGMENT1 = '07D9202.92742' 为例）

SELECT AA.WIP_ENTITY_ID   任务令 ID,

       AA.ORGANIZATION_ID 组织 ID,

       AA.WIP_ENTITY_NAME 任务名称 ,

       AA.ENTITY_TYPE     任务类型 ,

       AA.CREATION_DATE   创建日期 ,

       AA.CREATED_BY      创建者 ID,

       AA.DESCRIPTION     说明 ,

       AA.PRIMARY_ITEM_ID 装配件 ID,

       BB.SEGMENT1        物料编码 ,

       BB.DESCRIPTION     物料说明

  FROM wip_entities AA, mtl_system_items BB

  WHERE AA.PRIMARY_ITEM_ID = BB.INVENTORY_ITEM_ID

   and AA.ORGANIZATION_ID = BB.ORGANIZATION_ID

   and AA.ORGANIZATION_ID = 1155

   and AA.WIP_ENTITY_NAME = 'XJ39562' ;

--=> WIP_ENTITY_ID = 48825
-- 离散作业任务详细主信息表

-- 用途 1 ）作业任务下达及完成情况查询

-- 说明 1 ）此表包括 wip_entities 表大部分信息 2) 重复作业任务表为 wip_repetitive_items, wip_repetitive_schedules

select AA.WIP_ENTITY_ID                 任务令 ID,

       BB.WIP_ENTITY_NAME               任务名称 ,

       AA.ORGANIZATION_ID               组织 ID,

       AA.SOURCE_LINE_ID                行 ID,

       AA.STATUS_TYPE                   状态 TYPE,

       AA.PRIMARY_ITEM_ID               装配件 ID,

       CC.SEGMENT1                      物料编码 ,

       CC.DESCRIPTION                   物料说明 ,

       AA.FIRM_PLANNED_FLAG,

       AA.JOB_TYPE                      作业类型 ,

       AA.WIP_SUPPLY_TYPE               供应 TYPE,

       AA.CLASS_CODE                    任务类别 ,

       AA.SCHEDULED_START_DATE           起始时间 ,

       AA.DATE_RELEASED                 下达时间 ,

       AA.SCHEDULED_COMPLETION_DATE     完工时间 ,

       AA.DATE_COMPLETED                完工时间 ,

       AA.DATE_CLOSED                   关门时间 ,

       AA.START_QUANTITY                计划数 ,

       AA.QUANTITY_COMPLETED            完工数 ,

       AA.QUANTITY_SCRAPPED             报废数 ,

       AA.NET_QUANTITY                  MRP 净值 ,

       AA.COMPLETION_SUBINVENTORY       接收子库 ,

       AA.COMPLETION_LOCATOR_ID         货位

  from wip_discrete_jobs AA, wip.wip_entities BB, mtl_system_items CC

  where AA.WIP_ENTITY_ID = BB.WIP_ENTITY_ID

   and AA.PRIMARY_ITEM_ID = CC.INVENTORY_ITEM_ID

   and AA.ORGANIZATION_ID = CC.ORGANIZATION_ID

   and AA.organization_id = 1155

   and BB.WIP_ENTITY_NAME = 'XJ39562' ;

/*

1 ）任务状态 TYPE 值说明：

   STATUS_TYPE =1 未发放的 - 收费不允许

   STATUS_TYPE =3 发入 - 收费允许

   STATUS_TYPE =4 完成 - 允许收费

   STATUS_TYPE =5 完成 - 不允许收费

   STATUS_TYPE =6 暂挂 - 不允许收费

   STATUS_TYPE =7 已取消 - 不允许收费

   STATUS_TYPE =8 等待物料单加载

   STATUS_TYPE =9 失败的物料单加载

   STATUS_TYPE =10 等待路线加载

   STATUS_TYPE =11 失败的路线加载

   STATUS_TYPE =12 关闭 - 不可收费

   STATUS_TYPE =13 等待 - 成批加载

   STATUS_TYPE =14 等待关闭

   STATUS_TYPE =15 关闭失败

2 ）供应类型 TYPE 值说明：            

   WIP_SUPPLY_TYPE =1 推式

   WIP_SUPPLY_TYPE =2 装配拉式

   WIP_SUPPLY_TYPE =3 操作拉式

   WIP_SUPPLY_TYPE =4 大量

   WIP_SUPPLY_TYPE =5 供应商

   WIP_SUPPLY_TYPE =6 虚拟

   WIP_SUPPLY_TYPE =7 以帐单为基础

*/

-- 离散作业任务工序状况表

select AA.ORGANIZATION_ID            组织 ID,

       AA.WIP_ENTITY_ID              任务令 ID,

       BB.WIP_ENTITY_NAME            任务名称 ,

       AA.OPERATION_SEQ_NUM          工序号 ,

       AA.DESCRIPTION                工序描述 ,

       AA.DEPARTMENT_ID              部门 ID,

       AA.SCHEDULED_QUANTITY         计划数量 ,

       AA.QUANTITY_IN_QUEUE          排队数量 ,

       AA.QUANTITY_RUNNING           运行数量 ,

       AA.QUANTITY_WAITING_TO_MOVE    待移动数量 ,

       AA.QUANTITY_REJECTED          故障品数量 ,

       AA.QUANTITY_SCRAPPED          报废品数量 ,

       AA.QUANTITY_COMPLETED         完工数量 ,

       AA.FIRST_UNIT_START_DATE      最早一个单位上线时间 ,

       AA.FIRST_UNIT_COMPLETION_DATE 最早一个单位完成时间 ,

       AA.LAST_UNIT_START_DATE       最后一个单位上线时间 ,

       AA.LAST_UNIT_COMPLETION_DATE  最后一个单位完工时间 ,

       AA.PREVIOUS_OPERATION_SEQ_NUM 前一工序序号 ,

       AA.NEXT_OPERATION_SEQ_NUM     下一工序序号 ,

       AA.COUNT_POINT_TYPE           是否自动计费 ,

       AA.BACKFLUSH_FLAG             倒冲否 ,

       AA.MINIMUM_TRANSFER_QUANTITY  最小传送数量 ,

       AA.DATE_LAST_MOVED            最后移动时间

  from wip_operations AA,wip_entities BB

  where AA.WIP_ENTITY_ID = BB.WIP_ENTITY_ID

  and   BB.WIP_ENTITY_NAME = 'XJ39562' ;

-- 离散作业任务子查询 ——— 工单工序状况查询（不单独使用）

select WDJ.ORGANIZATION_ID,

       WDJ.WIP_ENTITY_ID,

       COUNT ( 1 ) COUNT_OPER,

       max ( decode (wo.quantity_completed, 1 , wo.operation_seq_num, 10 )) OPER

  from WIP_DISCRETE_JOBS WDJ, WIP_OPERATIONS WO

  where 1 = 1

   AND WDJ.WIP_ENTITY_ID = WO.WIP_ENTITY_ID

   AND WDJ.wip_entity_id = '48825'

   group by WDJ.ORGANIZATION_ID,WDJ.WIP_ENTITY_ID;

 -- 离散作业任务 BOM ( 无材料费 )

SELECT WOP.ORGANIZATION_ID       组织 ID,

       WOP.WIP_ENTITY_ID         任务令 ID,

       BB.WIP_ENTITY_NAME       装配件名称 ,

       BB.PRIMARY_ITEM_ID       装配件 ID,

       CC.SEGMENT1              装配件物料编码 ,

       CC.DESCRIPTION           装配件说明 ,

       WOP.OPERATION_SEQ_NUM     工序号 ,

       WOP.DEPARTMENT_ID         部门 ID,

       WOP.WIP_SUPPLY_TYPE       供应类型 ,

       WOP.DATE_REQUIRED         要求日期 ,

       WOP.INVENTORY_ITEM_ID     子物料 ID,

       DD.SEGMENT1              子物料编码 ,

       DD.DESCRIPTION           子物料说明 ,

       WOP.QUANTITY_PER_ASSEMBLY 单位需量 ,

       WOP.REQUIRED_QUANTITY     总需求量 ,

       WOP.QUANTITY_ISSUED       已发放量 ,

       WOP.COMMENTS              注释 ,

        WOP.SUPPLY_SUBINVENTORY   供应子库

  FROM wip_requirement_operations WOP,

      wip_entities BB,

      mtl_system_items CC,

      mtl_system_items DD

  WHERE WOP.WIP_ENTITY_ID = BB.WIP_ENTITY_ID

   and BB.PRIMARY_ITEM_ID = CC.INVENTORY_ITEM_ID

   and BB.ORGANIZATION_ID = CC.ORGANIZATION_ID

   and WOP.INVENTORY_ITEM_ID = DD.INVENTORY_ITEM_ID

   and WOP.ORGANIZATION_ID = DD.ORGANIZATION_ID

   and WOP.ORGANIZATION_ID = 1155

   and BB.WIP_ENTITY_NAME = 'XJ39562' ;

 

-- 作业任务已发放材料处理记录清单 0101 （最详细） （内码为 48825 为例）

-- 用途 1 ）查询工单发料详细明细，包括发料类型、时间、用户等

select MTL.TRANSACTION_ID 交易 ID,

       MTL.INVENTORY_ITEM_ID 项目 ID,

       CC.SEGMENT1 物料编码 ,

       CC.DESCRIPTION 物料说明 ,

       MTL.ORGANIZATION_ID 组织 ID,

       MTL.SUBINVENTORY_CODE 子库名称 ,

       MTL.TRANSACTION_TYPE_ID 交易类型 ID,

       BB.TRANSACTION_TYPE_NAME 交易类型名称 ,

       MTL.TRANSACTION_QUANTITY 交易数量 ,

       MTL.TRANSACTION_UOM 单位 ,

       MTL.TRANSACTION_DATE 交易日期 ,

       MTL.TRANSACTION_REFERENCE 交易参考 ,

       MTL.TRANSACTION_SOURCE_ID 参考源 ID,

       FF.WIP_ENTITY_NAME 任务名称 ,

       MTL.DEPARTMENT_ID 部门 ID,

       MTL.OPERATION_SEQ_NUM 工序号 ,

       ROUND (MTL.PRIOR_COST, 2 ) 原来成本 ,

       ROUND (MTL.NEW_COST, 2 ) 新成本 ,

       MTL.TRANSACTION_QUANTITY * ROUND (MTL.PRIOR_COST, 2 ) 交易金额 ,

       DD.USER_NAME 用户名称 ,

       EE.FULL_NAME 用户姓名

  from mtl_material_transactions MTL,

       mtl_transaction_types     BB,

       mtl_system_items          CC,

       FND_USER                  DD,

       per_people_f              EE,

       wip_entities              FF

  where MTL.TRANSACTION_TYPE_ID = BB.TRANSACTION_TYPE_ID

   and MTL.CREATED_BY = DD.USER_ID

   and MTL.INVENTORY_ITEM_ID = CC.INVENTORY_ITEM_ID

   and MTL.ORGANIZATION_ID = CC.ORGANIZATION_ID

   and DD.EMPLOYEE_ID = EE.PERSON_ID

   and MTL.TRANSACTION_SOURCE_ID = FF.WIP_ENTITY_ID

   and MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )

   and MTL.ORGANIZATION_ID = 1155

   and MTL.TRANSACTION_SOURCE_ID = 48825 ;

-- 按工单的材料费汇总（不单独使用）

select MTL.ORGANIZATION_ID,

       MTL.TRANSACTION_SOURCE_ID WIP_ENTITY_ID,

       ABS ( round ( SUM (MTL.TRANSACTION_QUANTITY * MTL.PRIOR_COST), 2 )) AMT

  from mtl_material_transactions MTL

  where MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )

   and MTL.ORGANIZATION_ID = 1155

   and MTL.TRANSACTION_SOURCE_ID = 48825

  group by MTL.ORGANIZATION_ID, MTL.TRANSACTION_SOURCE_ID;

  

-- 离散作业任务子查询 01——— 材料消耗状况及材料费综合查询  

-- 用途   1 ）查询发料状况   2 ）查询材料费物料小计

SELECT WOP.ORGANIZATION_ID       组织 ID,

       WOP.WIP_ENTITY_ID         任务令 ID,

       BB.WIP_ENTITY_NAME        装配件名称 ,

       BB.PRIMARY_ITEM_ID        装配件 ID,

       CC.SEGMENT1               装配件物料编码 ,

       CC.DESCRIPTION            装配件说明 ,

       WOP.OPERATION_SEQ_NUM     工序号 ,

       WOP.DEPARTMENT_ID         部门 ID,

       WOP.WIP_SUPPLY_TYPE       供应类型 ,

       WOP.DATE_REQUIRED         要求日期 ,

        WOP.INVENTORY_ITEM_ID     子物料 ID,

       DD.SEGMENT1               子物料编码 ,

       DD.DESCRIPTION            子物料说明 ,

       WOP.QUANTITY_PER_ASSEMBLY 单位需量 ,

       WOP.REQUIRED_QUANTITY     总需求量 ,

       WOP.QUANTITY_ISSUED       已发放量 ,

       CST.AMT                    已发生材料费 ,

       WOP.COMMENTS              注释 ,

       WOP.SUPPLY_SUBINVENTORY   供应子库

  FROM wip_requirement_operations WOP,

       wip_entities BB,

       mtl_system_items CC,

       mtl_system_items DD,

       ( select MTL.ORGANIZATION_ID orgID,

               MTL.TRANSACTION_SOURCE_ID wipID,

               MTL.OPERATION_SEQ_NUM oprID,

               MTL.INVENTORY_ITEM_ID itemID,

               sum (MTL.TRANSACTION_QUANTITY * ROUND (MTL.actual_cost, 2 )) amt

          from mtl_material_transactions MTL

         where MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )

           and MTL.ORGANIZATION_ID = 1155

           and MTL.TRANSACTION_SOURCE_ID = 48825

         group by MTL.ORGANIZATION_ID,

                  MTL.TRANSACTION_SOURCE_ID,

                  MTL.OPERATION_SEQ_NUM,

                  MTL.INVENTORY_ITEM_ID) CST

  WHERE WOP.WIP_ENTITY_ID = BB.WIP_ENTITY_ID

   and BB.PRIMARY_ITEM_ID = CC.INVENTORY_ITEM_ID

   and BB.ORGANIZATION_ID = CC.ORGANIZATION_ID

   and WOP.INVENTORY_ITEM_ID = DD.INVENTORY_ITEM_ID

   and WOP.ORGANIZATION_ID = DD.ORGANIZATION_ID

   and WOP.ORGANIZATION_ID = CST.orgID

   and WOP.WIP_ENTITY_ID = CST.wipID

   and WOP.OPERATION_SEQ_NUM = CST.oprID

   and WOP.INVENTORY_ITEM_ID = CST.itemID

   and WOP.ORGANIZATION_ID = 1155

   and BB.WIP_ENTITY_NAME = 'XJ39562' ;

                     

-- 离散作业任务子查询 0201——— 作业资源报工明细表

SELECT WTA.ORGANIZATION_ID   组织代码 ,

       WTA.TRANSACTION_ID    交易代码 ,

       WTA.REFERENCE_ACCOUNT 参考科目 ,

       WTA.TRANSACTION_DATE  报工日期 ,

       WTA.WIP_ENTITY_ID     任务令内码 ,

       WTA.ACCOUNTING_LINE_TYPE   会计栏类型 ,

       WTA.BASE_TRANSACTION_VALUE 费用额 ,

       WTA.CONTRA_SET_ID          反方集代码 ,

       WTA.PRIMARY_QUANTITY       基本数量 ,

       WTA.RATE_OR_AMOUNT         率或金额 ,

       WTA.BASIS_TYPE             基本类型 ,

       WTA.RESOURCE_ID            资源代码 ,

       WTA.COST_ELEMENT_ID        成本要素 ID,

       WTA.ACCOUNTING_LINE_TYPE   成本类型 ID,

       WTA.OVERHEAD_BASIS_FACTOR  费用因子 ,

       WTA.BASIS_RESOURCE_ID      基本资源 ID,

       WTA.CREATED_BY              录入人 ID,

       DD.USER_NAME               用户名称 ,

       EE.FULL_NAME               用户姓名

  FROM wip_transaction_accounts WTA, FND_USER DD, per_people_f EE

  WHERE WTA.CREATED_BY = DD.USER_ID

   and DD.EMPLOYEE_ID = EE.PERSON_ID

   and WTA.BASE_TRANSACTION_VALUE <> 0

   and WTA.ORGANIZATION_ID = 1155

   and WTA.WIP_ENTITY_ID = 48839 ;

-- 成本类型 ID ACCOUNTING_LINE_TYPE

SELECT * FROM MFG_LOOKUPS ML

WHERE ML.LOOKUP_TYPE LIKE 'CST_ACCOUNTING_LINE_TYPE'

ORDER BY ML.LOOKUP_CODE;

-- 成本要素 ID COST_ELEMENT_ID

--( 待补充 --------------------------------------------------------------------------?)

-- 统计人工费与制造费 ( 不单独应用 )

SELECT ORGANIZATION_ID, WIP_ENTITY_ID, SUM (HR_FEE) HR_FEE, SUM (MD_FEE) MD_FEE

  FROM ( Select WTA.ORGANIZATION_ID,

               WTA.WIP_ENTITY_ID,

                decode (COST_ELEMENT_ID, 3 , WTA.BASE_TRANSACTION_VALUE, 0 ) HR_FEE,

               decode (COST_ELEMENT_ID, 5 , WTA.BASE_TRANSACTION_VALUE, 0 ) MD_FEE

          from WIP_TRANSACTION_ACCOUNTS WTA

         where WTA.ACCOUNTING_LINE_TYPE = 7

           and WTA.BASE_TRANSACTION_VALUE <> 0 ) WTA_COST

  WHERE WTA_COST.ORGANIZATION_ID = 1155

   AND WTA_COST.WIP_ENTITY_ID = '48839'

  GROUP BY WTA_COST.ORGANIZATION_ID,WTA_COST.WIP_ENTITY_ID;

 

-- 工单进度及费用信息综合查询 ( 未下达及下达零发料和报工的看不到 )

select WE.WIP_ENTITY_NAME            任务名称 ,

       MSI.SEGMENT1                  物料 ,

       MSI.DESCRIPTION               物料描述 ,

       MSI.PRIMARY_UNIT_OF_MEASURE   单位 ,

       WDJ.SCHEDULED_START_DATE      计划开始时间 ,

       WDJ.SCHEDULED_COMPLETION_DATE 计划完成时间 ,

       WDJ.START_QUANTITY            工单数量 ,

       WDJ.QUANTITY_COMPLETED        完成数量 ,

       WDJ.DATE_RELEASED             实际开始时间 ,

       WDJ.DATE_COMPLETED            时间完成时间 ,

       WDJ.DESCRIPTION               工单备注 ,

       PP.SEGMENT1                   项目号 ,

       PP.DESCRIPTION                项目描述 ,

       PT.TASK_NUMBER                任务号 ,

       PT.DESCRIPTION                任务描述 ,

       WO.COUNT_OPER                 工序数 ,

       WO1.OPERATION_SEQ_NUM         当前工序 ,

       WO1.DESCRIPTION               当前工序描述 ,

       MTA.MT_FEE                    材料费 ,

       WCT.HR_FEE                    人工费 ,

       WCT.MD_FEE                    制造费 ,

       WE.WIP_ENTITY_ID,

       WE.ORGANIZATION_ID,

       WDJ.PRIMARY_ITEM_ID,

       WDJ.PROJECT_ID,

       WDJ.TASK_ID

  from WIP_ENTITIES WE,

       WIP_OPERATIONS WO1,

       WIP_DISCRETE_JOBS WDJ,

       MTL_SYSTEM_ITEMS_B MSI,

       PA_PROJECTS_ALL PP,

       PA_TASKS PT,

       ( select WDJ.ORGANIZATION_ID,

               WDJ.WIP_ENTITY_ID,

               COUNT ( 1 ) COUNT_OPER,

               max ( decode (wo.quantity_completed, 1 , wo.operation_seq_num, 10 )) OPER

          from WIP_DISCRETE_JOBS WDJ, WIP_OPERATIONS WO

         where WDJ.WIP_ENTITY_ID = WO.WIP_ENTITY_ID

         group by WDJ.ORGANIZATION_ID, WDJ.WIP_ENTITY_ID) WO, -- 工序进度

       ( select MTL.ORGANIZATION_ID,

               MTL.TRANSACTION_SOURCE_ID WIP_ENTITY_ID,

               ABS ( SUM (MTL.TRANSACTION_QUANTITY * MTL.actual_cost)) MT_FEE

          from mtl_material_transactions MTL

         where MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )

         group by MTL.ORGANIZATION_ID, MTL.TRANSACTION_SOURCE_ID) MTA, -- 材料费    

       ( select WTA_COST.ORGANIZATION_ID,

               WTA_COST.WIP_ENTITY_ID,

               SUM (WTA_COST.HR_FEE1) HR_FEE,

                SUM (WTA_COST.MD_FEE1) MD_FEE

          from ( select WTA.ORGANIZATION_ID,

                       WTA.WIP_ENTITY_ID,

                       decode (COST_ELEMENT_ID,

                              3 ,

                              WTA.BASE_TRANSACTION_VALUE,

                              0 ) HR_FEE1,

                       decode (COST_ELEMENT_ID,

                              5 ,

                              WTA.BASE_TRANSACTION_VALUE,

                              0 ) MD_FEE1

                  from WIP_TRANSACTION_ACCOUNTS WTA

                 where WTA.ACCOUNTING_LINE_TYPE = 7

                   and WTA.BASE_TRANSACTION_VALUE <> 0 ) WTA_COST

         group by WTA_COST.ORGANIZATION_ID, WTA_COST.WIP_ENTITY_ID) WCT -- 人工与制造

  WHERE 1 = 1

   AND WE.ORGANIZATION_ID = WDJ.ORGANIZATION_ID

   AND WE.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID

   AND WDJ.ORGANIZATION_ID = MSI.ORGANIZATION_ID

   AND WDJ.PRIMARY_ITEM_ID = MSI.INVENTORY_ITEM_ID

   AND WE.WIP_ENTITY_ID = WO.WIP_ENTITY_ID

   AND WO1.WIP_ENTITY_ID = WO.WIP_ENTITY_ID

   AND WO.OPER = WO1.OPERATION_SEQ_NUM

   AND WE.ORGANIZATION_ID = MTA.ORGANIZATION_ID

   AND WE.WIP_ENTITY_ID = MTA.WIP_ENTITY_ID(+)

   AND WE.ORGANIZATION_ID = WCT.ORGANIZATION_ID

   AND WE.WIP_ENTITY_ID = WCT.WIP_ENTITY_ID(+)

   AND WDJ.PROJECT_ID = PP.PROJECT_ID(+)

   AND WDJ.TASK_ID = PT.TASK_ID(+)

   and we.organization_id = 1155

   and we.wip_entity_id = '48825' ;

  

  -- 工单进度及费用信息综合查询 ( 不论是否下达和发料都能看到 )

SELECT WDJ.WIP_ENTITY_ID           任务令 ID,

       WE.WIP_ENTITY_NAME  
       
       
  <=====================================>    
 

===profile====
select FPT.USER_PROFILE_OPTION_NAME 配置文件名,FPO.PROFILE_OPTION_VALUE 配置文件值
  from FND_PROFILE_OPTION_VALUES fpo,
       FND_PROFILE_OPTIONS       fro,
       fnd_user                  fu,
       FND_PROFILE_OPTIONS_TL    FPT
 where fpo.level_VALUE = FU.USER_ID --1730;
   AND fro.profile_option_id = FPO.PROFILE_OPTION_ID
   AND FPT.PROFILE_OPTION_NAME = FRO.PROFILE_OPTION_NAME
   --AND FU.USER_NAME = upper('username')
   AND FPT.LANGUAGE = 'ZHS'
 /* 存储每个 attributes 数类型  */
 SELECT * from WF_ITEM_ATTRIBUTES WHERE  item_type='MPAYMENT' AND NAME ='NTF_FROM_ROLE'      
   wf_item_attribute_values，保存工作流实例的attribute最新值
   wf_item_activity_statuses，保存工作流实例的各个activity的状态，比如完成否，返回值
   wf_notifications，保存工作流实例的notifications消息，基本是按顺序的，可以看发给谁了
   wf_roles，角色视图，工作流引用角色的依据，有mail地址等信息
   wf_user_roles，用户和角色关系视图，工作流可以根据它进行“群发”   
       

SELECT responsibility_name
      ,frg.request_group_name
      ,fcpv.concurrent_program_name
      ,fcpv.user_concurrent_program_name
      ,fcpv.description
FROM   fnd_request_groups         frg
      ,fnd_request_group_units    frgu
      ,fnd_concurrent_programs_vl fcpv
      ,fnd_responsibility_vl      frv
WHERE  frgu.request_unit_type = 'P'
AND    frgu.request_group_id = frg.request_group_id
AND    frgu.request_unit_id = fcpv.concurrent_program_id
AND    frv.request_group_id(+) = frg.request_group_id
AND    fcpv.user_concurrent_program_name ='H-应收/合同负债增减明细表接口'
ORDER  BY responsibility_name
---------------
 SELECT t.user_concurrent_program_name 报表名称,
       e.execution_file_name 可执行文件,
       t.concurrent_program_name 简称,
       e.executable_name 可执行简称,
       e.user_executable_name 可执行名称,
       e.application_name 应用产品,
       decode(t.execution_method_code,
              'P',
              'Oracle Reports',
              'I',
              'PL/SQL 存储过程',
              'B',
              '请求集阶段函数',
              'M',
              '多语言功能',
              'K',
              'Java 并发程序',
              'J',
              'Java 存储过程',
              'S',
              '立即',
              'H',
              '主机',
              'A',
              '派生') 执行方法,
       e.description 可执行说明,
       e.execution_file_path 执行文件路径
  FROM fnd_concurrent_programs_vl t,
       fnd_executables_form_v     e
 WHERE t.executable_id = e.executable_id
  -- AND t.application_id IN (20004, 20003)
  AND e.EXECUTABLE_NAME LIKE 'CUXARBALANCE_INT%'

  select  
        mmt.transaction_id,---事务处理头id,
        mmt.organization_id,---事务处理库存组织，
        mmt.transaction_quantity,----事务处理头数量，
        mmt.transaction_cost，---事务处理头成本，
        mmt.inventory_item_id,---事务处理头物料id
        mtt.transaction_type_name, --事物处理类型
        mmt.transaction_id,--事务处理标识
        mmt.subinventory_code,--子库存
        inv_project.get_locator(mmt.locator_id,mmt.organization_id) locator, --货位
        msi.segment1,
        msi.description,
        mmt.transaction_date, --事务处理头日期
        mta.reference_account,  --事务处理分配行ccid
        mta.transaction_source_id,---事务处理分类来源id
        mta.transaction_source_type_id,--事务处理分配来源类型id
        mta.accounting_line_type,  ---事务处理分配行id
        mta.base_transaction_value,--事务处理值
        gcc.code_combination_id,  ----gl账户ccid
        gcc.segment1,           ----gl账户段1
        gcc.segment2,           ----gl账户段2
        gcc.segment3,           ----gl账户段3
        gcc.segment4,           ----gl账户段4
        gcc.segment5,           ----gl账户段5
        gcc.segment6,           ----gl账户段6
        gcc.segment7,           ----gl账户段7
        gcc.segment8,          ----gl账户段8
        gcc.segment9,           ----gl账户段9
        gcc.segment10,          ----gl账户段10
        xte.transaction_number,  ----sla事件编号
        xah.ae_header_id,        ----sla分录头表
        xal.ae_header_id,        ----sla分录行表
        xal.code_combination_id  ---xla的分录行表
  from inv.mtl_material_transactions mmt, ---事务处理头表
       inv. mtl_system_items_b      msi, ----物料主数据表
       inv.mtl_transaction_accounts  mta,  ----事务处理分配表
       gl.gl_code_combinations  gcc,       ----gl账户表
       xla.xla_transaction_entities  xte,   ---会计事件表
       xla.xla_ae_headers            xah,  ----sla头表
       xla.xla_ae_lines              xal,    ---sla行表
       mtl_transaction_types mtt             --事务处理类型表  
 where 1=1 
   and   mtt.transaction_type_id = mmt.transaction_type_id 
   and   mmt.transaction_id=mta.transaction_id   --通过事务处理头表id关联事务处理行表的id
   and   mmt.inventory_item_id=msi.inventory_item_id--通过事务处理头表物料id关联主数据物料id
   and   mmt.organization_id =msi.organization_id    --限制事务处理头表和物料表的库存组织相同
   and   mta.reference_account=gcc.code_combination_id  ---通过分配表的账户ccid和gl账户ccid相同进行关联
   and   mta.transaction_id=xte.transaction_number      --通过分配表的事务处理id关联会计事件表id
   and   mmt.transaction_id=xte.transaction_number      ---通过头表的事务处理id关联会计事件表id
   and   xal.code_combination_id=gcc.code_combination_id  ---通过sla行表的ccid和gl账户表的ccid关联
   and   xte.application_id in('707')                     ---限制会计事件表为707-成本的应用产品
   and   xte.entity_id =xah.entity_id                     --通过xte事件id关联sla的头表的事件id
   and   xah.ae_header_id=xal.ae_header_id                --通过sla头表的header id 关联到sla行表
   --and   mmt.organization_id in ('81')                      ---限制事务处理库存组织
   --and   mmt.transaction_date >=to_date('2018-12-25','YYYY-MM-DD')  ---限制事务处理起始时间
   --and   mmt.transaction_date <=to_date('2018-12-26','YYYY-MM-DD')   -----限制事务处理起始时间
   and mmt.transaction_id = 83207;

   select  
        mmt.transaction_id,---事务处理头id,
        mmt.organization_id,---事务处理库存组织，
        mmt.transaction_quantity,----事务处理头数量，
        mmt.transaction_cost，---事务处理头成本，
        mmt.inventory_item_id,---事务处理头物料id
        mtt.transaction_type_name, --事物处理类型
        mmt.transaction_id,--事务处理标识
        mmt.subinventory_code,--子库存
        inv_project.get_locator(mmt.locator_id,mmt.organization_id) locator, --货位
        msi.segment1,
        msi.description,
        mmt.transaction_date, --事务处理头日期
        mta.reference_account,  --事务处理分配行ccid
        mta.transaction_source_id,---事务处理分类来源id
        mta.transaction_source_type_id,--事务处理分配来源类型id
        mta.accounting_line_type,  ---事务处理分配行id
        mta.base_transaction_value,--事务处理值
        gcc.code_combination_id,  ----gl账户ccid
        gcc.segment1,           ----gl账户段1
        gcc.segment2,           ----gl账户段2
        gcc.segment3,           ----gl账户段3
        gcc.segment4,           ----gl账户段4
        gcc.segment5,           ----gl账户段5
        gcc.segment6,           ----gl账户段6
        gcc.segment7,           ----gl账户段7
        gcc.segment8,          ----gl账户段8
        gcc.segment9,           ----gl账户段9
        gcc.segment10,          ----gl账户段10
        xte.transaction_number,  ----sla事件编号
        xah.ae_header_id,        ----sla分录头表
        xal.ae_header_id,        ----sla分录行表
        xal.code_combination_id  ---xla的分录行表
  from inv.mtl_material_transactions mmt, ---事务处理头表
       inv. mtl_system_items_b      msi, ----物料主数据表
       inv.mtl_transaction_accounts  mta,  ----事务处理分配表
       gl.gl_code_combinations  gcc,       ----gl账户表
       xla.xla_transaction_entities  xte,   ---会计事件表
       xla.xla_ae_headers            xah,  ----sla头表
       xla.xla_ae_lines              xal,    ---sla行表
       mtl_transaction_types mtt             --事务处理类型表  
 where 1=1 
   and   mtt.transaction_type_id = mmt.transaction_type_id 
   and   mmt.transaction_id=mta.transaction_id   --通过事务处理头表id关联事务处理行表的id
   and   mmt.inventory_item_id=msi.inventory_item_id--通过事务处理头表物料id关联主数据物料id
   and   mmt.organization_id =msi.organization_id    --限制事务处理头表和物料表的库存组织相同
   and   mta.reference_account=gcc.code_combination_id  ---通过分配表的账户ccid和gl账户ccid相同进行关联
   and   mta.transaction_id=xte.transaction_number      --通过分配表的事务处理id关联会计事件表id
   and   mmt.transaction_id=xte.transaction_number      ---通过头表的事务处理id关联会计事件表id
   and   xal.code_combination_id=gcc.code_combination_id  ---通过sla行表的ccid和gl账户表的ccid关联
   and   xte.application_id in('707')                     ---限制会计事件表为707-成本的应用产品
   and   xte.entity_id =xah.entity_id                     --通过xte事件id关联sla的头表的事件id
   and   xah.ae_header_id=xal.ae_header_id                --通过sla头表的header id 关联到sla行表
   --and   mmt.organization_id in ('81')                      ---限制事务处理库存组织
   --and   mmt.transaction_date >=to_date('2018-12-25','YYYY-MM-DD')  ---限制事务处理起始时间
   --and   mmt.transaction_date <=to_date('2018-12-26','YYYY-MM-DD')   -----限制事务处理起始时间
   and mmt.transaction_id = 83207;
 ----
 
 select OOD.ORGANIZATION_ID 组织id,
         OOD.ORGANIZATION_CODE 组织代码,
         OOD.ORGANIZATION_NAME 组织名称,
         MSIB.SEGMENT1 物料,
         MSIB.DESCRIPTION 物料名称,
         MTT.TRANSACTION_TYPE_ID 类型ID,
         MTT.TRANSACTION_TYPE_NAME 类型名称,
         MTST.TRANSACTION_SOURCE_TYPE_ID 来源ID,
         MTST.TRANSACTION_SOURCE_TYPE_NAME 来源名称,
         mmt.transaction_id 事务ID,
         MMT.TRANSACTION_DATE 日期,
         MMT.TRANSACTION_UOM 单位,
         MMT.TRANSACTION_QUANTITY 数量,
         msi.secondary_inventory_name 子库,
         msi.description 子库名称
 from 
mtl_system_items_b msib,
mtl_material_transactions mmt,
org_organization_definitions ood,
mtl_txn_source_types mtst,
mtl_transaction_types mtt,
mtl_secondary_inventories msi
where mmt.organization_id=ood.ORGANIZATION_ID
and mmt.organization_id=msib.organization_id
and mmt.inventory_item_id=msib.inventory_item_id
and mmt.transaction_type_id=mtt.transaction_type_id
and mmt.transaction_source_type_id=mtst.transaction_source_type_id
--and mmt.transaction_date>=to_date('2018-03-01 00:00:00','YYYY-MM-DD HH24:MI:SS')
and mmt.transaction_date<=to_date('2018-03-01 00:00:00','YYYY-MM-DD HH24:MI:SS')
AND ood.ORGANIZATION_CODE='NY7'
and mmt.organization_id=msi.organization_id(+)
and mmt.subinventory_code=msi.secondary_inventory_name(+)
and mmt.transaction_type_id!='10008';
 
事务处理类型（transaction_type_id）：
select transaction_type_id,
        transaction_type_name
from   mtl_transaction_types
order  by 1;


事务处理来源（transaction_source_type_id）
select lookup_code,meaning
from   mfg_lookups
where  lookup_type ='MTL_DISPOSITION'
order  by 1;

CV_TRANSACTIONS_INTERFACE 中的
事务处理类型（TRANSACTION_TYPE）

select lookup_code,DESCRIPTION Meaning
from   po_lookup_codes
where  lookup_type = 'RCV TRANSACTION TYPE'
order  by 1;


库存事务处理接口表（MTL_TRANSACTIONS_INTERFACE）的说明：
要想物料事务处理管理器能处理库存接口中的数据，则必须保证如下标志的信息：
    PROCESS_FLAG      = 'Y'
    LOCK_FLAG         = 'N' or NULL
    TRANSACTION_MODE  = 3
    ERROR_CODE        = NULL
    ERROR_EXPLANATION = NULL
并且当接口中的数据发生错误，也必须把这些标志修改为如上的状态，
数据才会被处理
同理MTL_MATERIAL_TRANSACTIONS_TEMP也是如此

事务处理活动（transaction_action_id）
FA有用的脚本

/*-------------------------------------------------------------------------------------------*/
/*新增，报废---------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------*/
--1 保存FA的基本描述信息，如资产标签，所属类别等
select fab.asset_id                 --自定义资产编号
       ,fab.asset_number            --用户定义的资产标签
       ,fab.current_units           --资产数量
       ,fab.asset_type              -- 资产类型：资产，在建，费用
       ,fab.tag_number
       ,fab.asset_category_id       --资产所属类别
       ,fab.parent_asset_id         --是否是一项资产的部分
       ,fab.owned_leased            --标识资产是自有的还是租赁的
       ,fab.in_use_flag             --标识资产是否已经使用
       ,fab.new_used                --标识资产是否新的还是已经使用过
       ,fab.unit_adjustment_flag    --该资产是否有数量上的调整
       ,fab.attribute_category_code --资产类别描述
       ,fab.inventorial             --是否是可见的资产，区别于无形资产，长期待摊费用
       ,fab.*
from   fa.FA_ADDITIONS_B fab
where  fab.asset_number = 'S1O010207-208'

--2 记录FA重新分类，资本化，数量调整，部分报废等动作是的信息
select fah.asset_id
       ,fah.category_id --标识资产的所属类别
       ,fah.asset_type  --标识资产的种类：资产，在建，费用
       ,fah.units       --资产的数量
       ,fah.date_effective --这条记录的生效日期
       ,fah.date_ineffective --这条记录的失效日期
       ,fah.transaction_header_id_in --这条记录是由哪个Transaction产生的，来自FA_TRANSACTION_HEADERS这个Table
       ,fah.transaction_header_id_out --这条记录是由哪个Transaction废弃的，来自FA_TRANSACTION_HEADERS这个Table
from fa.fa_asset_history fah

--3 保存资产的类别信息
select fcb.category_id   --唯一标识一种资产类别
       ,fcb.enabled_flag --该类别是否继续被使用
       ,fcb.owned_leased --资产是自己拥有还是租借的
       ,fcb.segment1     --资产类别描述
       ,fcb.capitalize_flag --如果为资本化的资产，默认为YES
       ,fcb.start_date_active --该资产类别开始使用日期
       ,fcb.end_date_active --该资产类别停止使用的日期
       ,fcb.inventorial     --该资产是否是实物资产     
from   fa.fa_categories_b fcb

--4 记录FA折旧所需要的信息，如成本，折旧方法，使用年限，残值等
select fb.book_type_code --账本名称
       ,fb.asset_id
       ,fb.date_placed_in_service --资产开始投入使用的日期
       ,fb.date_effective         --此条记录的输入日期
       ,fb.deprn_start_date       --资产开始计提折旧的日期
       ,fb.deprn_method_code      --计提折旧的种类
       ,fb.life_in_months         --资产的使用寿命
       ,fb.rate_adjustment_factor --资产成本调整时，资产剩余年限和使用年限的比率
       ,fb.adjusted_cost          --当资产的成本未被调整过，金额等于资产成本（Cost栏位的数额）- 资产残值(salvage_value栏位的数值)  
                                  --当成本有变动时，其金额＝变动后的Cost - Salvage value残值 -以提折旧
       ,fb.cost                   --当前资产的成本
       ,fb.original_cost          --资产最初的成本
       ,fb.salvage_value          --资产的残值
       ,fb.prorate_convention_code
       ,fb.prorate_date           
       ,fb.cost_change_flag       --标识成本是否调整过，如果为YES，系统会重新计算折旧
       ,fb.adjustment_required_status --产生该条记录的Transaction是否会影响折旧费用的计提，不会显示为NONE
       ,fb.capitalize_flag            --标识该资产是否资本化，区别租借和其它资产
       ,fb.retirement_pending_flag    --资产是否报废
       ,fb.depreciate_flag            --资产是否正在计提折旧
       ,fb.date_ineffective           --该条记录作废的时间
       ,fb.transaction_header_id_in   --存储产生该条记录的Transaction
       ,fb.transaction_header_id_out  --存储使该记录作废的Transaction
       ,fb.retirement_id              --如果该资产已经报废或者正在报废中，该栏位显示向对应的报废Transaction的Id，来自Fa_Retirements
       ,fb.recoverable_cost           --= cost-salvage cost                              
from   fa.fa_books  fb
WHERE asset_id=10031

--5 纪录所有对FA进行操作的信息，如操作类型，操作时间等
select fth.book_type_code             --账本名称
       ,fth.asset_id                  --资产Id
       ,fth.transaction_type_code     --transaction的类型
       ,fth.transaction_date_entered  --Transaction的发生的日期
       ,fth.date_effective            --该记录生效的日期
       ,fth.transaction_name          --Transaction的描述
       ,fth.invoice_transaction_id    --Transaction的Id
from   fa.fa_transaction_headers fth

--6 记录FA购买，付款等信息，根据此信息，我们可以查到资产明细的来源，包括各种费用，每条Line包含一笔支出
select fai.asset_id 
       ,fai.invoice_number        --发票号码
       ,fai.payables_batch_name  --该发票所在的批次的名称
       ,fai.payables_code_combination_id --会计科目代码
       ,fai.feeder_system_name           --该发票数据的来源
       ,fai.create_batch_date
       ,fai.create_batch_id
       ,fai.post_batch_id
       ,fai.invoice_date
       ,fai.invoice_id
       ,fai.ap_distribution_line_number
       ,fai.payables_units
       ,fai.split_merged_code
       ,fai.description                  --发票中对资产的描述
       ,fai.parent_mass_addition_id
       ,fai.merged_code                  --标识该发票金额是否并入一项已存在的资产中
       ,fai.split_code                   --标识该发票金额是否分为几项独立的资产
       ,fai.project_id 
       ,fai.po_number                  --
from   fa.fa_asset_invoices  fai where fai.invoice_number is not null and fai.
where  fai.asset_id =6335 and fai.parent_mass_addition_id is null

--7 记录FA_asset_invoice每条Line的类型
select fit.invoice_transaction_id        
       ,fit.book_type_code
       ,fit.transaction_type
       ,fit.date_effective
from   fa.fa_invoice_transactions fit

--8 记录FA每次折旧的信息，包含：折旧月份，每次折旧金额，累计折旧，资产原值金额等
select fdd.book_type_code         --账本名称
       ,fdd.asset_id              --资产Id
       ,fdd.period_counter        --折旧计提所属期间，即属于哪个月份的折旧
       ,fdd.distribution_id       
       ,fdd.deprn_source_code     --标识记录是因计提折旧产生的，还是新增资产产生的，新增资产是产生的记录折旧为0
       ,fdd.deprn_run_date        --折旧计提的时间
       ,fdd.deprn_amount          --当月折旧
       ,fdd.ytd_deprn             --当年计提折旧
       ,fdd.deprn_reserve         --累计折旧       
       ,fdd.addition_cost_to_clear--新增改资产时的成本
       ,fdd.cost                  --资产的成本
       ,fdd.deprn_adjustment_amount--折旧调整时的金额
       ,fdd.deprn_expense_je_line_num
       ,fdd.reval_reserve_je_line_num
       ,fdd.je_header_id
       ,fdd.reval_reserve 
from   fa.fa_deprn_detail fdd
WHERE asset_id=10031

--9 记录FA每次折旧信息，包含：累计折旧等信息
select fds.book_type_code
       ,fds.asset_id
       ,fds.deprn_run_date        --折旧计提的日期
       ,fds.deprn_amount          --当月折旧金额
       ,fds.ytd_deprn             --当年折旧金额
       ,fds.deprn_reserve         --累计折旧金额
       ,fds.deprn_source_code     --标记该计提是因为计提折旧产生的，还是由于新增资产产生的
       ,fds.adjusted_cost         --资产可提折旧的总成本，每月折旧＝adjusted_cost/总月数
       ,fds.bonus_rate            
       ,fds.period_counter        --折旧所属的期间
       ,fds.reval_amortization
       ,fds.reval_amortization_basis
       ,fds.prior_fy_expense
from   fa.fa_deprn_summary  fds
WHERE asset_id=10031

--10 记录Transfer transaction information。
--是连接fa_books,fa_distribution_history,fa_transaction_headers三个Table的纽带
select ftd.transfer_header_id
       ,ftd.distribution_id
       ,ftd.book_header_id
from    fa.fa_transfer_details ftd

--11 记录Fa的管理人，存放地，所属会计科目等信息，当以上信息发生变动时，新增一条Line
select  fdh.distribution_id    --标识该记录的id
        ,fdh.asset_id
        ,fdh.units_assigned    --资产分配数量
        ,fdh.date_effective    --该条记录生效的日期
        ,fdh.code_combination_id --该条折旧所属的会计科目
        ,fdh.location_id         --资产的位置
        ,fdh.transaction_header_id_in --该条记录由哪个Transaction产生
        ,fdh.date_ineffective         --该条记录作废的时间        
        ,fdh.assigned_to              --资产管理人
        ,fdh.transaction_header_id_out--该条记录因哪个Transaction作废
        ,fdh.transaction_units        --Transaction所涉及的资产数量
        ,fdh.retirement_id
from    fa.fa_distribution_history fdh
where   fdh.asset_id =10031

--12 记录资产报废信息
select fr.retirement_id            --系统标识该条记录的唯一Id
       ,fr.book_type_code          --账本名称
       ,fr.asset_id                --资产Id
       ,fr.transaction_header_id_in   --产生此条记录的Transaction的id
       ,fr.date_retired               --资产报废时间
       ,fr.date_effective             --该条记录生效时间
       ,fr.cost_retired               --资产成本
       ,fr.status                     --资产报废状态，分4种：Pending：资产报废时还没有计算损益
                                      --                     Processed：资产报废时已经计算了损益
                                      --                     reinstate：还没有恢复使用报废资产
                                      --                     deleted：  已经恢复使用报废资产
       ,fr.transaction_header_id_out  --该条记录作废的Transaction Id
       ,fr.units                      --报废资产的数量
       ,fr.cost_of_removal            --清理报废资产的费用
       ,fr.nbv_retired                --资产的账面净值，等于原值-累计折旧
       ,fr.gain_loss_amount           --资产报废时的损失或者收益金额
       ,fr.gain_loss_type_code        --报废资产时产生损失还是收益
       ,fr.retirement_type_code       --报废类型，非正常报废和出售      
from   fa.fa_retirements fr

--13 保存产生日记账分录的资产信息。当跑折旧时，会增加借贷两个会计科目的两条Line
select fam.transaction_header_id      --来自Table:Fa_transaction_headers，标识该Transaction的系统Id
       ,fam.source_type_code          --该Transaction的类型：增加，调整，cip增加，cip调整，折旧，报废，重分类，税，重估等类型
       ,fam.adjustment_type           --影响到会计科目的调整类型:在建工程成本，成本，费用，账面报废等
       ,fam.debit_credit_flag         --标识是借记会计科目还是贷记会计科目
       ,fam.code_combination_id       --会计科目
       ,fam.book_type_code            --账本名称
       ,fam.asset_id                  --资产编号
       ,fam.adjustment_amount         --调整金额
from   fa.fa_adjustments fam

--14 保存资产位置资料 Flexfield Title:Location Flexfield
select fl.location_id                 --
       ,fl.segment1                   -- --Country
       ,fl.segment2                   -- --State
       ,fl.segment3                   -- --City
       ,fl.segment4                   -- --Street
       ,fl.segment5                   -- --Building
       ,fl.segment6                   -- --Reserved
       ,fl.enabled_flag               --是否在使用 
from   fa.fa_locations fl
where  fl.location_id in (2304,2310,2299,2306)

--25 保存员工的资料，如姓名，工号等
select fe.Employee_ID
       ,fe.Employee_Number
       ,fe.Name
       ,fe.Actual_Termination_Date    --员工离职时间
from   apps.fa_employees fe

SELECT *
  FROM FA.FA_CATEGORIES_B FCB
WHERE FCB.SEGMENT1 = '249-1'
   AND FCB.SEGMENT2 = 'PII_09'
   AND FCB.SEGMENT3 = 'NO'
   AND FCB.SEGMENT4 = 'C'
   AND FCB.SEGMENT5 = '0'
249-1%PII_11%NO%C%0
fcb.category_id IN (64,21);

PS0077-289100221-0-0-HQPT8-0-0-0


SELECT * FROM fa.Fa_Categories_tl fct WHERE fct.LANGUAGE='US' 
AND fct.category_id IN (64)
AND DESCRIPTION IN ('PII OP EQ METAL LOSS - MFL 3.0','Mft-Tooling- <$50K (U)')  249-1.PII_11.NO.C.0

SELECT * FROM fa.Fa_Category_Books WHERE category_id IN (64,21);
SELECT * FROM FA.FA_CATEGORY_BOOK_DEFAULTS WHERE category_id IN (64,21);
SELECT * FROM fa.fa_

/*-------------------------------------------------------------------------------------------*/
/*折旧---------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------*/
FA_ADJUSTMENTS
FA_ASSET_HISTORY
FA_BOOK_CONTROLS
FA_BOOKS
FA_CALENDAR_PERIODS
FA_CALENDAR_TYPES
FA_CATEGORIES_B
FA_CATEGORY_BOOK_DEFAULT
FA_CATEGORY_BOOKS
FA_DEPRN_DETAIL
FA_DEPRN_PERIODS
FA_DEPRN_SUMMARY
FA_DISTRIBUTION_HISTORY
FA_RETIREMENTS
FA_TRANSACTION_HEADERS

-------------------------------------------------------
select distinct fai.po_number,pv.vendor_name,fe.Employee_Number,fe.Name,fl.segment2,fl.segment3 
       ,fab.asset_number,fab.attribute_category_code,fab.current_units
       ,fat.description
  from apps.fa_employees              fe
       ,fa.fa_locations               fl
       ,fa.FA_ADDITIONS_B             fab
       ,fa.fa_additions_tl            fat
       ,fa.fa_distribution_history    fdh
       ,fa.fa_asset_invoices          fai
       ,po.po_vendors                 pv
where  fdh.assigned_to   = fe.Employee_ID(+)
  and  fdh.location_id   = fl.location_id
  and  fdh.asset_id      = fab.asset_id
  and  fab.asset_id      = fat.asset_id
  and  fai.asset_id      = fat.asset_id
  and  fai.po_vendor_id  = pv.vendor_id
  and  fai.parent_mass_addition_id is null
-- and  fat.language      = userenv('LANG')  
  and  fl.enabled_flag   = 'Y'
  and  nvl(fdh.date_ineffective ,sysdate+1) > sysdate
  and  fdh.retirement_id is null 
  and  nvl(fe.Actual_Termination_Date,sysdate+1) > sysdate
  and fl.segment1='USA'
  and  fe.Employee_Number ='S0202010'
------------------------------------------------------------------------------------------------------------------------
--Asset's Category has asset and asset haven't finished depreciation can't modify the accounts
SELECT DISTINCT /*FCBS.BOOK_TYPE_CODE FA_BOOKS,
                FCT.DESCRIPTION,*/
                FCB.SEGMENT1 || '.' || FCB.SEGMENT2 || '.' || FCB.SEGMENT3 || '.' ||
                FCB.SEGMENT4 || '.' || FCB.SEGMENT5 CATETORY_NAME --,
/*fab.asset_number,
       fab.current_units,
       fb.life_in_months,
       MONTHS_BETWEEN(SYSDATE,fb.date_placed_in_service),
       fb.**/
  FROM FA.FA_ADDITIONS_B    FAB,
       FA.FA_CATEGORIES_B   FCB,
       FA.FA_CATEGORIES_TL  FCT,
       FA.FA_CATEGORY_BOOKS FCBS,
       FA.FA_BOOKS          FB
WHERE FAB.ASSET_CATEGORY_ID = FCB.CATEGORY_ID
   AND FCBS.CATEGORY_ID = FCB.CATEGORY_ID
   AND FCB.CATEGORY_ID = FCT.CATEGORY_ID
   AND FCT.LANGUAGE = 'US'
   AND FAB.ASSET_ID = FB.ASSET_ID
   AND FCBS.BOOK_TYPE_CODE = FB.BOOK_TYPE_CODE
   AND FB.DATE_INEFFECTIVE IS NULL
      AND  fab.asset_number = '10031'
   AND FB.LIFE_IN_MONTHS >
       MONTHS_BETWEEN(SYSDATE, FB.DATE_PLACED_IN_SERVICE)
   AND FCB.SEGMENT1 || '.' || FCB.SEGMENT2 || '.' || FCB.SEGMENT3 || '.' ||
       FCB.SEGMENT4 || '.' || FCB.SEGMENT5 IN
       ('201.LAND.NO.C.0', '205-1.BUILDINGS.NO.C.0', '225.PII_09.NO.C.0',
        '225.PII_11.NO.C.0', '235-2.MANUFACTURING.NO.U.0',
        '249-1.PII_00.NO.C.0', '249-1.PII_05.NO.C.0', '249-1.PII_09.NO.C.0',
        '249-1.PII_10.NO.C.0', '249-1.PII_11.NO.C.0', '249-1.PII_12.NO.C.0',
        '249-1.PII_13.NO.C.0', '249-1.PII_14.NO.C.0', '249-1.PII_15.NO.C.0',
        '249-1.PII_16.NO.C.0', '249-1.PII_17.NO.C.0', '249-1.PII_20.NO.C.0',
        '249-1.PII_21.NO.C.0', '249-1.PII_25.NO.C.0', '249-1.PII_30.NO.C.0',
        '249-1.PII_31.NO.C.0', '249-1.PII_32.NO.C.0', '249-1.PII_33.NO.C.0',
        '249-1.PII_34.NO.C.0', '249-1.PII_35.NO.C.0', '249-1.PII_36.NO.C.0',
        '249-1.PII_37.NO.C.0', '249-1.PII_40.NO.C.0', '249-1.PII_41.NO.C.0',
        '249-1.PII_42.NO.C.0', '249-1.PII_43.NO.C.0', '249-1.PII_45.NO.C.0',
        '249-1.PII_50.NO.C.0', '249-1.PII_51.NO.C.0', '249-1.PII_52.NO.C.0',
        '249-1.PII_55.NO.C.0', '249-1.PII_98.NO.C.0', '249-1.PII_99.NO.C.0',
        '255-1.VEHICLES.NO.C.0', '261-3.OFFICE EQUIPTMENT.NO.C.0',
        '283-3.MISC EQUIPTMENT.NO.U.0', '292-13.LEASEHOLD.NO.U.0',
        '292-14.SOFTWARE.NO.U.0')
ORDER BY FCB.SEGMENT1 || '.' || FCB.SEGMENT2 || '.' || FCB.SEGMENT3 || '.' ||
          FCB.SEGMENT4 || '.' || FCB.SEGMENT5
                     
--Asset's Category hasn't has asset can modify the accounts      
select DISTINCT fcbs.book_type_code FA_Books,
       fct.DESCRIPTION,
       fcb.segment1||'.'||fcb.segment2||'.'||fcb.segment3||'.'||fcb.segment4||'.'||fcb.segment5 catetory_name--,
      
from   fa.Fa_Categories_b fcb,
       fa.Fa_Categories_tl fct,
       fa.Fa_Category_Books fcbs      
where   fcbs.category_id = fcb.category_id
       AND fcb.category_id = fct.category_id
       AND fct.LANGUAGE='US' 
       AND NOT EXISTS (SELECT 'Y' FROM fa.FA_ADDITIONS_B fab WHERE fab.asset_category_id = fcb.category_id) 
       --AND fcb.segment1 LIKE '249%'
       ORDER BY  fcb.segment1||'.'||fcb.segment2||'.'||fcb.segment3||'.'||fcb.segment4||'.'||fcb.segment5


---------------------------------
1、oe_order_headers_all
--订单头信息表
2、oe_order_lines_all
--header_id=oe_order_headers_all.header_id
--订单行信息表
3、mtl_sales_orders
--segment1=oe_order_headers_all.order_number
--sales_order_id=mtl_material_transaction.transaction_source_id
--记录订单编号的信息表
4、wsh_delivery_details
--source_header_id=oe_order_headers_all.header_id
--source_line_id=oe_order_lines_all.line_id
--记录订单的物料的发运明细信息，该表的记录在此阶段状态为R（Ready to release）
5、wsh_delivery_assignments
--delivery_detail_id=wsh_delivery_details.delivery_detail_id
--连接wsh_delivery_details和wsh_new_deliveries的信息表
--此阶段连接wsh_delivery_details
二、发放

1、wsh_delivery_details
--该表的记录在此阶段状态为S（Released to Warehouse）
2、wsh_new_deliveries
--source_header_id=oe_order_headers_all.header_id
--记录订单的交货信息表，此阶段为OP（Delivery is Open, has not been shipped）
3、wsh_delivery_assignments
--delivery_id=wsh_new_deliveries.delivery_id
--连接wsh_delivery_details和wsh_new_deliveries的信息表
--此阶段连接wsh_new_deliveries
4、wsh_picking_batches
--order_header_id=oe_order_headers_all.header_id
--记录订单的发放的信息表
三、挑库

1、wsh_delivery_details
--该表的记录在此阶段状态为Y（Staged）。如果启用了序列号，记录会按单个序列号拆分
2、mtl_material_transactions
--transaction_source_id=mtl_sales_orders.sales_order_id
--trx_source_line_id=oe_order_lines_all.line_id
--记录“销售订单挑库”阶段物料的存放位置发生变化的信息
3、mtl_onhand_quantities
--记录物料的现有数量信息表
4、mtl_transaction_lot_numbers
--transaction_id=mtl_material_transactions.transaction_id
--lot_number=mtl_onhand_quantities.lot_number
--记录物料的存放位置发生变化的所产生的批次信息表
5、mtl_serial_numbers
--last_txn_source_id=mtl_material_transactions.transaction_source_id
--记录物料序列号的当前状态的信息表
四、交货

1、wsh_delivery_details
--该表的记录在此阶段状态为C（Shipped）
2、wsh_new_deliveries
--该表的记录在此阶段为CL（Delivery has arrived at the destination）
3、mtl_material_transactions
--记录“销售订单发放”阶段物料的存放位置发生变化的信息
--如果启用了序列号，记录会按单个序列号拆分
----一个OU多少个仓库-----
 SELECT HR_OPERATING_UNITS.ORGANIZATION_ID AS OU_ID,
       HR_OPERATING_UNITS.NAME AS OU_NAME,
       HR_OPERATING_UNITS.SHORT_CODE as OU_Short_Code,
       ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_ID AS INV_ORG_ID,
       ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_CODE AS INV_ORG_CODE,
       Org_Organization_Definitions.organization_name as Inv_Org_name
  From Org_Organization_Definitions
 INNER JOIN HR_OPERATING_UNITS
    ON HR_OPERATING_UNITS.ORGANIZATION_ID =
       ORG_ORGANIZATION_DEFINITIONS.OPERATING_UNIT
 where hr_operating_units.Name like '%230059_OU_内蒙古金海伊利乳业有限责任公司%'
 order by HR_OPERATING_UNITS.name; 


1. OU、库存组织 
SELECT hou.organization_id ou_org_id, --org_id
hou.name ou_name, --ou 名称
ood.organization_id org_org_id, -- 库存组织 id
ood.organization_code org_org_code, -- 库存组织代码
msi.secondary_inventory_name, -- 子库存名称
msi.description -- 子库存描述
FROM hr_organization_information hoi, -- 组织分类表
hr_operating_units hou, --ou 视图
org_organization_definitions ood, -- 库存组织定义视图
mtl_secondary_inventories msi -- 子库存信息表
WHERE hoi.org_information1 = 'OPERATING_UNIT'
AND hoi.organization_id = hou.organization_id
AND ood.operating_unit = hoi.organization_id
AND ood.organization_id = msi.organization_id
-- 获取系统 ID
call fnd_global.APPS_INITIALIZE( 1318 , 50583 , 401 )
select fnd_profile.VALUE( 'ORG_ID' ) FROM DUAL
select * from hr_operating_units hou where hou.organization_id= 204
2. 用户、责任及 HR
-- 系统责任定义 VIEW(FROM FND_RESPONSIBILITY_TL, FND_RESPONSIBILITY)
SELECT APPLICATION_ID,
RESPONSIBILITY_ID,
RESPONSIBILITY_KEY,
END_DATE,
RESPONSIBILITY_NAME,
DESCRIPTION
FROM FND_RESPONSIBILITY_VL;
-- 用户责任关系
SELECT USER_ID, RESPONSIBILITY_ID FROM FND_USER_RESP_GROUPS;
-- 用户表
SELECT USER_ID, USER_NAME, EMPLOYEE_ID, PERSON_PARTY_ID, END_DATE
FROM FND_USER;
-- 人员表 VIEW
SELECT PERSON_ID,
START_DATE,
DATE_OF_BIRTH,
EMPLOYEE_NUMBER,
NATIONAL_IDENTIFIER,
SEX,
FULL_NAME
FROM per_people_f;
-- 综合查询
SELECT USER_NAME, FULL_NAME, RESPONSIBILITY_NAME, CC.DESCRIPTION
FROM FND_USER AA,
FND_USER_RESP_GROUPS BB,
FND_RESPONSIBILITY_VL CC,
per_people_f DD
WHERE AA.USER_ID = BB.USER_ID
AND BB.RESPONSIBILITY_ID = CC.RESPONSIBILITY_ID
AND AA.EMPLOYEE_ID = DD.PERSON_ID
AND RESPONSIBILITY_NAME like '% 供应处 %'
ORDER BY USER_NAME;
-- 综合查询
-- 人员状况基本信息表
SELECT PAF.PERSON_ID 系统 ID,
PAF.FULL_NAME 姓名 ,
PAF.DATE_OF_BIRTH 出生日期 ,
PAF.REGION_OF_BIRTH 出生地区 ,
PAF.NATIONAL_IDENTIFIER 身份证号 ,
PAF.ATTRIBUTE1 招工来源 ,
PAF.ATTRIBUTE3 员工类型 ,
PAF.ATTRIBUTE11 集团合同号 ,
PAF.original_date_of_hire 参加工作日期 ,
PAF.PER_INFORMATION17 省份 ,
DECODE (PAF.SEX, 'M' , ' 男 ' , 'F' , ' 女 ' , 'NULL' ) 性别 , --decode 适合和同一值做比较有多种结果，不适合和多种值比较有多种结果
CASE PAF.SEX
WHEN 'M' THEN ' 男 '
WHEN 'F' THEN ' 女 '
ELSE 'NULL'
END 性别 1, --case 用法一
CASE WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1960' THEN '50 年代 '
WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1970' THEN '60 年代 '
WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1980' THEN '70 年代 '
WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1990' THEN '80 年代 '
WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '2000' THEN '90 年代 '
ELSE '21 世纪 ' --case 用法二
END 出生年代
FROM PER_ALL_PEOPLE_F PAF
 
 
 
3. 供应商 VENDOR
-- 供应商主表数据：
SELECT ass.vendor_id vendor_id,
ass.party_id party_id,
ass.segment1 vendor_code,
ass.vendor_name vendor_name,
ass.vendor_name vendor_short_name,
ass.vendor_type_lookup_code vendor_type,
flv.meaning vendor_type_meaning,
hp.tax_reference tax_registered_name,
ass.payment_method_lookup_code payment_method,
att.name term_name,
att.enabled_flag enabled_flag,
att.end_date_active end_date_active,
ass.creation_date creation_date,
ass.created_by created_by,
ass.last_update_date last_update_date,
ass.last_updated_by last_updated_by,
ass.last_update_login last_update_login
FROM ap_suppliers ass,
fnd_lookup_values flv,
hz_parties hp,
ap_terms_tl att
WHERE ass.vendor_type_lookup_code = flv.lookup_code(+)
AND flv.lookup_type(+) = 'VENDOR TYPE'
AND flv.language(+) = userenv ( 'LANG' )
AND ass.party_id = hp.party_id
AND att.language = userenv ( 'LANG' )
AND ass.terms_id = att.term_id(+)
-- 供应商银行信息
SELECT ass.vendor_id vendor_id,
ass.party_id party_id,
bank.party_id bank_id,
bank.party_name bank_name,
branch.party_id branch_id,
branch.party_name bank_branch_name,
ieba.bank_account_num bank_account_num
FROM ap_suppliers ass,
hz_parties hp,
iby_account_owners iao,
iby_ext_bank_accounts ieba,
hz_parties bank,
hz_parties branch
WHERE ass.party_id = hp.party_id
AND hp.party_id = iao.account_owner_party_id(+)
AND iao.ext_bank_account_id = ieba.ext_bank_account_id(+)
AND ieba.bank_id = bank.party_id(+)
AND ieba.branch_id = branch.party_id(+)
ORDER BY ieba.creation_date;
-- 供应商开户行地址信息
SELECT hps.party_id party_id,
hps.party_site_id party_site_id,
hl.location_id location_id,
hl.country country,
hl.province province,
hl.city city,
hl.address1 address1,
hl.address2 address2,
hl.address3 address3,
hl.address4 address4
FROM hz_party_sites hps, hz_locations hl
WHERE hps.location_id = hl.location_id
ORDER BY hps.creation_date
-- 供应商联系人信息
SELECT hr.subject_id subject_id,
hr.object_id object_id,
hr.party_id party_id,
hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
hp.person_first_name contact_person,
hcpp.phone_area_code phone_area_code,
hcpp.phone_number phone_number,
hcpp.phone_extension phone_extension,
hcpf.phone_area_code fax_phone_area_code,
hcpf.phone_number fax_phone_number,
hcpe.email_address email_address
FROM hz_relationships hr,
hz_contact_points hcpp,
hz_contact_points hcpf,
hz_contact_points hcpe,
hz_parties hp
WHERE hr.object_id = hp.party_id
AND hcpp.owner_table_id(+) = hr.party_id
AND hcpf.owner_table_id(+) = hr.party_id
AND hcpe.owner_table_id(+) = hr.party_id
AND hr.object_type = 'PERSON'
AND hr.relationship_code(+) = 'CONTACT'
AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
AND hcpf.owner_table_name(+) = 'HZ_PARTIES'
AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
AND hcpp.contact_point_type(+) = 'PHONE'
AND hcpp.phone_line_type(+) = 'GEN'
AND hcpf.contact_point_type(+) = 'PHONE'
AND hcpf.phone_line_type(+) = 'FAX'
AND hcpe.contact_point_type(+) = 'EMAIL'
AND hcpe.phone_line_type IS NULL
ORDER BY hr.creation_date;
-- 供应商地址主信息
SELECT assa.vendor_site_id vendor_site_id,
assa.vendor_id vendor_id,
assa.vendor_site_code vendor_code,
assa.vendor_site_code address_short_name,
assa.address_line1 address_line1,
assa.address_line2 address_line2,
assa.address_line3 address_line3,
assa.address_line4 address_line4,
assa.org_id org_id,
assa.country country,
assa.province province,
assa.city city,
assa.county county,
assa.zip zip,
assa.pay_site_flag pay_site_flag,
assa.purchasing_site_flag purchasing_site_flag,
assa.inactive_date inactive_date,
assa.creation_date creation_date,
assa.created_by created_by,
assa.last_update_date last_update_date,
assa.last_updated_by last_updated_by,
assa.last_update_login last_update_login
FROM ap_suppliers ass, ap_supplier_sites_all assa
WHERE assa.vendor_id = ass.vendor_id;
-- 供应商地址联系人信息： phone 、 fax 和 Email
SELECT hcpp.phone_area_code phone_area_code,
hcpp.phone_number phone_number,
hcpp.phone_extension phone_extension,
hcpf.phone_area_code fax_phone_area_code,
hcpf.phone_number fax_phone_number,
hcpe.email_address email_address
FROM ap_supplier_sites_all assa,
hz_contact_points hcpp,
hz_contact_points hcpf,
hz_contact_points hcpe,
hz_party_sites hps
WHERE assa.party_site_id = hps.party_site_id
AND hcpp.owner_table_id(+) = assa.party_site_id
AND hcpf.owner_table_id(+) = assa.party_site_id
AND hcpe.owner_table_id(+) = assa.party_site_id
AND hcpp.owner_table_name(+) = 'HZ_PARTY_SITES'
AND hcpf.owner_table_name(+) = 'HZ_PARTY_SITES'
AND hcpe.owner_table_name(+) = 'HZ_PARTY_SITES'
AND hcpp.contact_point_type(+) = 'PHONE'
AND hcpp.phone_line_type(+) = 'GEN'
AND hcpf.contact_point_type(+) = 'PHONE'
AND hcpf.phone_line_type(+) = 'FAX'
AND hcpe.contact_point_type(+) = 'EMAIL'
AND hcpe.phone_line_type IS NULL ;
-- 供应商地址收件人信息
SELECT assa.party_site_id
FROM ap_supplier_sites_all assa
-- 根据 party_site_id 得到供应商地址的收件人名称
SELECT hps.addressee FROM hz_party_sites hps;
-- 供应商银行帐户分配层次关系
SELECT * FROM iby_pmt_instr_uses_all;
-- 供应商银行帐户分配层次关系明细 ( 不包括供应商层的分配信息 ):
SELECT * FROM iby_external_payees_all;
 
4. 客户 CUSTOMER
--SQL 查询
-- 客户账户表 以许继 1063 电网客户为例 -->>PARTY_ID = 21302
SELECT * FROM hz_cust_accounts AA WHERE AA.CUST_ACCOUNT_ID = 1063 ;
 
-- 客户名称及地址全局信息表 -->> PARTY_NUMBER = 19316
SELECT * FROM hz_parties AA WHERE AA.PARTY_ID = 21302 ;
 
-- 客户地点账户主文件
SELECT * FROM hz_cust_acct_sites_all WHERE CUST_ACCOUNT_ID = 1063 ;
 
-- 客户地点 ( 关联 hz_cust_acct_sites_all)
SELECT * FROM HZ_PARTY_SITES WHERE PARTY_ID = 21302 ;
 
-- 地点地址名称 ( 关联 hz_cust_acct_sites_all)
SELECT AA.ADDRESS1, AA.ADDRESS_KEY
FROM HZ_LOCATIONS AA, HZ_PARTY_SITES BB
WHERE AA.LOCATION_ID = BB.LOCATION_ID
AND BB.PARTY_ID = 21302 ;
 
-- 客户地点业务目的 ( 关联 hz_cust_acct_sites_all 用 CUST_ACCT_SITE_ID)
SELECT * FROM HZ_CUST_SITE_USES_ALL;
 
-- 客户地点详细信息表，以供应处 OU 的身份 ORG_ID = 119
SELECT AA.PARTY_SITE_ID 客户组织地点 ID,
AA.PARTY_ID 客户组织 ID,
AA.LOCATION_ID 地点 ID,
AA.PARTY_SITE_NUMBER 地点编号 ,
AA.IDENTIFYING_ADDRESS_FLAG 地址标示 ,
AA.STATUS 有效否 ,
AA.PARTY_SITE_NAME,
BB.ORG_ID 业务实体 ,
BB.bill_to_flag 收单标示 ,
BB.ship_to_flag 收货标示 ,
CC.ADDRESS1 地点名称 ,
DD.SITE_USE_ID,
DD.SITE_USE_CODE,
DD.PRIMARY_FLAG,
DD.STATUS,
DD.LOCATION 业务目的 ,
DD.BILL_TO_SITE_USE_ID 收单地 ID,
DD.TAX_CODE
FROM hz_party_sites AA,
hz_cust_acct_sites_all BB,
hz_locations CC,
HZ_CUST_SITE_USES_ALL DD
WHERE AA.PARTY_SITE_ID = BB.PARTY_SITE_ID
AND BB.CUST_ACCOUNT_ID = 1063
AND BB.ORG_ID = 119
AND AA.STATUS = 'A'
AND AA.LOCATION_ID = CC.LOCATION_ID
AND BB.CUST_ACCT_SITE_ID(+) = DD.CUST_ACCT_SITE_ID
AND DD.STATUS <> 'I' ;
 
--************* 综合查询 ************--
-- 客户主数据
SELECT hca.cust_account_id customer_id,
hp.party_number customer_number,
hp.party_name customer_name,
hp.party_name customer_short_name,
hca.customer_type customer_type,
alt.meaning customer_type_meaning,
hca.customer_class_code customer_class,
alc.meaning customer_class_meaning,
hp.tax_reference tax_registered_name,
rt.name term_name,
hca.creation_date creation_date,
hca.created_by created_by,
hca.last_update_date last_update_date,
hca.last_updated_by last_updated_by,
hca.last_update_login last_update_login
FROM hz_parties hp,
hz_cust_accounts hca,
ar_lookups alt,
ar_lookups alc,
hz_customer_profiles hcp,
ra_terms rt
WHERE hp.party_id = hca.party_id
AND hca.customer_type = alt.lookup_code(+)
AND alt.lookup_type = 'CUSTOMER_TYPE'
AND hca.customer_class_code = alc.lookup_code(+)
AND alc.lookup_type(+) = 'CUSTOMER CLASS'
AND hca.cust_account_id = hcp.cust_account_id(+)
AND hcp.standard_terms = rt.term_id(+)
 
-- 客户收款方法 SQL
SELECT arm.name receipt_method_name
FROM hz_cust_accounts hca,
ra_cust_receipt_methods rcrm,
ar_receipt_methods arm
WHERE hca.cust_account_id = rcrm.customer_id
AND rcrm.receipt_method_id = arm.receipt_method_id
ORDER BY rcrm.creation_date;
-- 客户账户层银行账户信息 SQL
SELECT hca.cust_account_id cust_account_id,
hp.party_id party_id,
bank.party_id bank_id,
bank.party_name bank_name,
branch.party_id branch_id,
branch.party_name bank_branch_name,
ieba.bank_account_num bank_account_num
FROM hz_cust_accounts hca,
hz_parties hp,
iby_account_owners iao,
iby_ext_bank_accounts ieba,
hz_parties bank,
hz_parties branch
WHERE hca.party_id = hp.party_id
AND hp.party_id = iao.account_owner_party_id(+)
AND iao.ext_bank_account_id = ieba.ext_bank_account_id(+)
AND ieba.bank_id = bank.party_id(+)
AND ieba.branch_id = branch.party_id(+)
ORDER BY ieba.creation_date;
-- 客户开户行地址信息 SQL
SELECT hl.country || '-' || hl.province || '-' || hl.city || '-' ||
hl.address1 || '-' || hl.address2 || '-' || hl.address3 || '-' ||
hl.address4 bank_address
FROM hz_party_sites hps, hz_locations hl
WHERE hps.location_id = hl.location_id
ORDER BY hps.creation_date;
-- 客户账户层联系人信息：联系人、电话、手机和 Email SQL
SELECT hr.party_id party_id,
hcar.cust_account_id cust_account_id,
hcar.cust_acct_site_id cust_acct_site_id,
hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
hp.person_first_name contact_person,
hcpp.phone_area_code phone_area_code,
hcpp.phone_number phone_number,
hcpp.phone_extension phone_extension,
hcpm.phone_area_code mobile_phone_area_code,
hcpm.phone_number mobile_phone_number,
hcpe.email_address email_address
FROM hz_relationships hr,
hz_cust_account_roles hcar,
hz_org_contacts hoc,
hz_contact_points hcpp,
hz_contact_points hcpm,
hz_contact_points hcpe,
hz_parties hp,
hz_cust_accounts hca
WHERE hr.object_id = hp.party_id
AND hr.party_id = hcar.party_id
AND hr.relationship_id = hoc.party_relationship_id(+)
AND hcpp.owner_table_id(+) = hr.party_id
AND hcpm.owner_table_id(+) = hr.party_id
AND hcpe.owner_table_id(+) = hr.party_id
AND hr.object_type = 'PERSON'
AND hr.relationship_code(+) = 'CONTACT'
AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
AND hcpm.owner_table_name(+) = 'HZ_PARTIES'
AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
AND hcpp.contact_point_type(+) = 'PHONE'
AND hcpp.phone_line_type(+) = 'GEN'
AND hcpm.contact_point_type(+) = 'PHONE'
AND hcpm.phone_line_type(+) = 'MOBILE'
AND hcpe.contact_point_type(+) = 'EMAIL'
AND hcpe.phone_line_type IS NULL
AND hr.subject_id = hca.party_id
AND hcar.cust_acct_site_id IS NULL
ORDER BY hr.creation_date;
-- 客户地址
SELECT hcasa.cust_acct_site_id customer_site_id,
hcasa.cust_account_id customer_id,
hps.party_site_number customer_site_code,
hps.party_site_name customer_site_name,
hl.address1 address_line1,
hl.address2 address_line2,
hl.address3 address_line3,
hl.address4 address_line4,
hcasa.org_id org_id,
hl.country country,
hl.province province,
hl.city city,
hl.county county,
hl.postal_code zip,
hcasa.bill_to_flag bill_to_flag,
hcasa.ship_to_flag ship_to_flag,
hca.creation_date creation_date,
hca.created_by created_by,
hca.last_update_date last_update_date,
hca.last_updated_by last_updated_by,
hca.last_update_login last_update_login
FROM hz_cust_accounts hca,
hz_cust_acct_sites_all hcasa,
hz_party_sites hps,
hz_locations hl
WHERE hca.cust_account_id = hcasa.cust_account_id
AND hcasa.party_site_id = hps.party_site_id
AND hps.location_id = hl.location_id;
 
-- 客户账户层地址 contact person 信息 :phone,mobile,email
SELECT hr.party_id party_id,
hcar.cust_account_id cust_account_id,
hcar.cust_acct_site_id cust_acct_site_id,
hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
hp.person_first_name contact_person,
hcpp.phone_area_code phone_area_code,
hcpp.phone_number phone_number,
hcpp.phone_extension phone_extension,
hcpm.phone_area_code mobile_phone_area_code,
hcpm.phone_number mobile_phone_number,
hcpe.email_address email_address
FROM hz_relationships hr,
hz_cust_account_roles hcar,
hz_org_contacts hoc,
hz_contact_points hcpp,
hz_contact_points hcpm,
hz_contact_points hcpe,
hz_parties hp,
hz_cust_accounts hca
WHERE hr.object_id = hp.party_id
AND hr.party_id = hcar.party_id
AND hr.relationship_id = hoc.party_relationship_id(+)
AND hcpp.owner_table_id(+) = hr.party_id
AND hcpm.owner_table_id(+) = hr.party_id
AND hcpe.owner_table_id(+) = hr.party_id
AND hr.object_type = 'PERSON'
AND hr.relationship_code(+) = 'CONTACT'
AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
AND hcpm.owner_table_name(+) = 'HZ_PARTIES'
AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
AND hcpp.contact_point_type(+) = 'PHONE'
AND hcpp.phone_line_type(+) = 'GEN'
AND hcpm.contact_point_type(+) = 'PHONE'
AND hcpm.phone_line_type(+) = 'MOBILE'
AND hcpe.contact_point_type(+) = 'EMAIL'
AND hcpe.phone_line_type IS NULL
AND hr.subject_id = hca.party_id
AND hca.cust_account_id = hcar.cust_account_id
ORDER BY hr.creation_date;
 
-- 客户账户地点地址
SELECT hp.party_id,
hca.cust_account_id,
hcasa.cust_acct_site_id,
hcasa.bill_to_flag,
hcasa.ship_to_flag,
hcsua.site_use_id,
hcasa.party_site_id,
hcsua.site_use_code,
hcsua.primary_flag,
hcsua.location,
hcsua.org_id
FROM hz_parties hp,
hz_cust_accounts hca,
hz_party_sites hps,
hz_cust_acct_sites_all hcasa,
hz_cust_site_uses_all hcsua
WHERE hp.party_id = hca.party_id
AND hca.cust_account_id = hcasa.cust_account_id
AND hcasa.party_site_id = hps.party_site_id
AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
-- 客户主配置文件
SELECT * FROM hz_cust_profile_classes;
SELECT * FROM hz_customer_profiles;
SELECT * FROM hz_cust_prof_class_amts;
SELECT * FROM hz_cust_profile_amts;
 
5. 订单 OE
--
select * from oe_order_headers_all 销售头
select * from oe_order_lines_all 销售行
select * from wsh_new_deliveries 发送
select * from wsh_delivery_details
select * from wsh_delivery_assignments
-- 综合查询 1- 未结销售订单
SELECT H.ORDER_NUMBER 销售订单 ,
h.cust_po_number 客户 PO,
cust.account_number 客户编码 ,
hp.party_name 客户名称 ,
ship_use.location 收货地 ,
bill_use.location 收单地 ,
h.ordered_date 订单日期 ,
H.ATTRIBUTE1 合同号 ,
h.attribute2 屏号 ,
h.attribute3 来源编码 ,
l.line_number 行号 ,
l.ordered_item 物料 ,
msi.description 物料说明 ,
l.order_quantity_uom 订购单位 ,
l.ordered_quantity 订购数量 ,
l.cancelled_quantity 取消数量 ,
l.shipped_quantity 发运数量 ,
l.schedule_ship_date 计划发运日期 ,
l.booked_flag 登记标记 ,
ol.MEANING 工作流状态 ,
l.cancelled_flag 取消标记
FROM OE_ORDER_HEADERS_ALL H,
OE_ORDER_LINES_ALL L,
HZ_CUST_ACCOUNTS CUST,
hz_parties hp,
hz_cust_site_uses_all ship_use,
hz_cust_site_uses_all bill_use,
mtl_system_items_b msi,
oe_lookups ol
WHERE 1 = 1
AND H.HEADER_ID = L.HEADER_ID
AND H.SOLD_TO_ORG_ID = CUST.CUST_ACCOUNT_ID
and cust.party_id = hp.party_id
and h.ship_to_org_id = ship_use.site_use_id
and h.invoice_to_org_id = bill_use.site_use_id
and l.flow_status_code not in ( 'CLOSED' , 'CANCELLED' )
and l.inventory_item_id = msi.inventory_item_id
and msi.organization_id = 141
and l.flow_status_code = ol.LOOKUP_CODE
and ol.LOOKUP_TYPE = 'LINE_FLOW_STATUS'
AND CUST.ACCOUNT_NUMBER IN ( '91010072' , '91010067' , '91010036' )
order by party_name ，收货地，销售订单 ;


6. 采购申请 PR
-- 申请单头 （以电网组织 ORG_ID=112 内部申请 =14140002781 为例
SELECT PRH.REQUISITION_HEADER_ID 申请单头 ID,
PRH.PREPARER_ID,
PRH.Org_Id OU_ID,
PRH.SEGMENT1 申请单编号 ,
PRH.Creation_Date 创建日期 ,
PRH.Created_By 编制人 ID,
FU.USER_NAME 用户名称 ,
PP.FULL_NAME 用户姓名 ,
PRH.Approved_Date 批准日期 ,
PRH.Description 说明 ,
PRH.Authorization_Status 状态 ,
PRH.Type_Lookup_Code 类型 ,
PRH.Transferred_To_Oe_Flag 传递标示
FROM PO_REQUISITION_HEADERS_ALL PRH, FND_USER FU, per_people_f PP
WHERE PRH.CREATED_BY = FU.USER_ID
AND FU.EMPLOYEE_ID = PP.PERSON_ID
AND PRH.ORG_ID = 112
AND PRH.SEGMENT1 = '14140002781' ;
-->> 内部申请 =14140002781 申请单头 ID = 3379
-- 申请单行明细
SELECT PRL.REQUISITION_HEADER_ID 申请单 ID,
PRL.REQUISITION_LINE_ID 行 ID,
PRL.LINE_NUM 行号 ,
PRL.CATEGORY_ID 分类 ID,
PRL.ITEM_ID 物料 ID,
ITEM.SEGMENT1 物料编码 ,
PRL.ITEM_DESCRIPTION 物料说明 ,
PRL.Quantity 需求数 ,
PRL.Quantity_Delivered 送货数 ,
PRL.Quantity_Cancelled 取消数 ,
PRL.Unit_Meas_Lookup_Code 单位 ,
PRL.Unit_Price 参考价 ,
PRL.Need_By_Date 需求日期 ,
PRL.Source_Type_Code 来源类型 ,
PRL.Org_Id OU_ID,
PRL.Source_Organization_Id 对方组织 ID,
PRL.Destination_Organization_Id 本方组织 ID
from PO_REQUISITION_LINES_ALL PRL,MTL_SYSTEM_ITEMS ITEM
WHERE PRL.ORG_ID = 112
AND PRL.ITEM_ID = ITEM.INVENTORY_ITEM_ID
AND PRL.Destination_Organization_Id = ITEM.ORGANIZATION_ID
AND PRL.REQUISITION_HEADER_ID = 3379 ;
-- 申请单头 ( 加对方订单编号 )
SELECT PRH.REQUISITION_HEADER_ID 申请单头 ID,
PRH.PREPARER_ID,
PRH.Org_Id OU_ID,
PRH.SEGMENT1 申请单编号 ,
PRH.Creation_Date 创建日期 ,
PRH.Created_By 编制人 ID,
FU.USER_NAME 用户名称 ,
PP.FULL_NAME 用户姓名 ,
PRH.Approved_Date 批准日期 ,
PRH.Description 说明 ,
PRH.Authorization_Status 状态 ,
PRH.Type_Lookup_Code 类型 ,
PRH.Transferred_To_Oe_Flag 传递标示 ,
OEH.ORDER_NUMBER 对方 CO 编号
FROM PO_REQUISITION_HEADERS_ALL PRH, FND_USER FU, per_people_f PP,OE_ORDER_HEADERS_ALL OEH
WHERE PRH.CREATED_BY = FU.USER_ID
AND FU.EMPLOYEE_ID = PP.PERSON_ID
AND PRH.REQUISITION_HEADER_ID = OEH.SOURCE_DOCUMENT_ID(+)
AND PRH.ORG_ID = 112
AND PRH.SEGMENT1 = '14140002781' ;
--( 销售订单记录有对方 OU_ID, 申请单关键字 SOURCE_DOCUMENT_ID 申请单号 SOURCE_DOCEMENT_REF)
 
******************* 综合查询类 *******************
-- 申请单头综合查询 （进限制只能查询 -- 电网组织 ORG_ID=112)
SELECT PRH.REQUISITION_HEADER_ID 申请单头 ID,
PRH.Org_Id 组织 ID,
PRH.SEGMENT1 申请单编号 ,
PRH.Creation_Date 创建日期 ,
PRH.Created_By 编制人 ID,
FU.USER_NAME 用户名称 ,
PP.FULL_NAME 用户姓名 ,
PRH.Approved_Date 批准日期 ,
PRH.Description 说明 ,
PRH.Authorization_Status 状态 ,
PRH.Type_Lookup_Code 类型 ,
PRH.Transferred_To_Oe_Flag 传递标示 ,
PRL.REQUISITION_LINE_ID 行 ID,
PRL.LINE_NUM 行号 ,
PRL.CATEGORY_ID 分类 ID,
PRL.ITEM_ID 物料 ID,
ITEM.SEGMENT1 物料编码 ,
PRL.ITEM_DESCRIPTION 物料说明 ,
PRL.Quantity 需求数 ,
PRL.Quantity_Delivered 送货数 ,
PRL.Quantity_Cancelled 取消数 ,
PRL.Unit_Meas_Lookup_Code 单位 ,
PRL.Unit_Price 参考价 ,
PRL.Need_By_Date 需求日期 ,
PRL.Source_Type_Code 来源类型 ,
PRL.Source_Organization_Id 对方组织 ID,
PRL.Destination_Organization_Id 本方组织 ID
FROM PO_REQUISITION_HEADERS_ALL PRH,
FND_USER FU,
per_people_f PP,
PO_REQUISITION_LINES_ALL PRL,
MTL_SYSTEM_ITEMS ITEM
WHERE PRH.CREATED_BY = FU.USER_ID
AND FU.EMPLOYEE_ID = PP.PERSON_ID
AND PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
AND PRH.Org_Id = PRL.ORG_ID
AND PRL.ITEM_ID = ITEM.INVENTORY_ITEM_ID
AND PRL.Destination_Organization_Id = ITEM.ORGANIZATION_ID
AND PRH.ORG_ID = 112 ;
 
-- 若需创建视图只需在 SELECT 语句前加上
CREATE OR REPLACE VIEW CUX_INV_PR112 AS
7. 采购订单 PO
-- 采购单头信息 TYPE_LOOKUP_CODE='STANDARD' （以供应处 OU ORG_ID=119 采购单 ='' 为例）
-- 类型说明 TYPE_LOOKUP_CODE='STANDARD' 为采购单 TYPE_LOOKUP_CODE='BLANKET' 为采购协议
SELECT POH.ORG_ID OU_ID,
POH.PO_HEADER_ID 采购单头 ID,
POH.TYPE_LOOKUP_CODE 类型 ,
POH.AUTHORIZATION_STATUS 状态 ,
POH.VENDOR_ID 供应商 ID,
VENDOR.VENDOR_NAME 供应商名 ,
POH.VENDOR_SITE_ID 供应商地址 ID,
POH.VENDOR_CONTACT_ID 供应商联系人 ID,
POH.SHIP_TO_LOCATION_ID 本方收货地 ID,
POH.BILL_TO_LOCATION_ID 本方收单地 ID,
POH.CREATION_DATE 创建日期 ,
POH.APPROVED_FLAG 审批 YN,
POH.APPROVED_DATE 审批日期 ,
POH.COMMENTS 采购单说明 ,
POH.TERMS_ID 条款 ID,
POH.AGENT_ID 采购员 ID,
AGT_PP.LAST_NAME 采购员 ,
POH.CREATED_BY 创建者 ID,
FU.USER_NAME 创建用户 ,
PP.FULL_NAME 用户姓名
FROM PO_HEADERS_ALL POH, FND_USER FU, per_people_f PP,PER_ALL_PEOPLE_F AGT_PP,ap_suppliers VENDOR
WHERE POH.CREATED_BY = FU.USER_ID
AND FU.EMPLOYEE_ID = PP.PERSON_ID
AND POH.AGENT_ID = AGT_PP.PERSON_ID
AND POH.VENDOR_ID=VENDOR.VENDOR_ID
AND POH.ORG_ID = 119
AND POH.TYPE_LOOKUP_CODE = 'STANDARD'
AND POH.SEGMENT1 = '14730005436' ;
/*
FND_USER FU, per_people_f PP 用户相关表
po_agents_name_v 采购员视图 ----> PO_AGENTS.AGENT_ID = PER_ALL_PEOPLE_F.PERSON_ID 采购员相关表
ap_suppliers 供应商主表
*/
 
-->> POH.SEGMENT1 = '14730005436' PO_HEADER_ID = 10068
-- 采购单行信息
SELECT POL.ORG_ID OU_ID,
POL.PO_HEADER_ID 采购单头 ID,
POL.PO_LINE_ID 行 ID,
POL.LINE_NUM 行号 ,
POL.ITEM_ID 物料 ID,
ITEM.SEGMENT1 物料编码 ,
POL.ITEM_DESCRIPTION 物料说明 ,
POL.UNIT_MEAS_LOOKUP_CODE 单位 ,
POL.UNIT_PRICE 单价 ,
PO_LCT.QUANTITY 订购数 ,
PO_LCT.QUANTITY_RECEIVED 验收数 ,
PO_LCT.QUANTITY_ACCEPTED 接收数 ,
PO_LCT.QUANTITY_REJECTED 拒绝数 ,
PO_LCT.QUANTITY_CANCELLED 取消数 ,
PO_LCT.QUANTITY_BILLED 到票数 ,
PO_LCT.PROMISED_DATE 承诺日期 ,
PO_LCT.NEED_BY_DATE 需求日期
FROM PO_LINES_ALL POL,
Po_Line_Locations_all PO_LCT,
MTL_SYSTEM_ITEMS ITEM
WHERE POL.ORG_ID = PO_LCT.ORG_ID
AND POL.PO_LINE_ID = PO_LCT.PO_LINE_ID
AND POL.ITEM_ID = ITEM.INVENTORY_ITEM_ID
AND ITEM.ORGANIZATION_ID = 142
AND POL.Org_Id = 119
AND POL.PO_HEADER_ID = 10068 ;
-- 说明： Po_Line_Locations_all 系 “ 发运表 ”
 
-- 综合查询 1 ，所分配给供应处组织的物料，存在采购协议，但缺失采购员或缺失仓库；
select MSIF.Segment1 物料编码 ,
MSIF.Description 物料描述 ,
MSIF.LONG_DESCRIPTION 物料详细描述 ,
--MSIF.primary_unit_of_measure 计量单位 ,
PRF.LAST_NAME 采购员 ,
MISD.subinventory_code 默认接收库存 ,
PLA.unit_price 未税价 ,
round (PLA.unit_price * ( 1 + ZRB.percentage_rate / 100 ), 2 ) 含税价 ,
PV.VENDOR_NAME 供应商名称
from apps.PO_HEADERS_ALL PHA,
apps.PO_LINES_ALL PLA,
apps.MTL_SYSTEM_ITEMS_FVL MSIF,
apps.MTL_ITEM_SUB_DEFAULTS MISD,
apps.PER_PEOPLE_F PRF,
apps.PO_VENDORS PV,
apps.PO_VENDOR_SITES_ALL PVSA,
apps.ZX_RATES_B ZRB
where PHA.Type_Lookup_Code = 'BLANKET' and PHA.Org_Id = 119 and
PHA.PO_HEADER_ID = PLA.Po_Header_Id and
PHA.Global_Agreement_Flag = 'Y' and PHA.Approved_Flag in ( 'Y' , 'R' ) and
NVL (PHA.end_Date, sysdate ) >= sysdate and
NVL (PLA.Expiration_Date, sysdate ) >= sysdate and
PLA.Cancel_Flag = 'N' and PLA.Item_Id = MSIF.INVENTORY_ITEM_ID and
MSIF.ORGANIZATION_ID = 142 and
MSIF.INVENTORY_ITEM_ID = MISD.INVENTORY_ITEM_ID(+) and
MISD.ORGANIZATION_ID(+) = 142 and MISD.default_type(+) = 2 and
MSIF.BUYER_ID = PRF.PERSON_ID(+) and
PRF.EFFECTIVE_END_DATE(+) = to_date( '4712-12-31' , 'YYYY-MM-DD' ) and
PHA.VENDOR_ID = PV.VENDOR_ID and
PHA.Vendor_Site_Id = PVSA.VENDOR_SITE_ID and
PVSA.VAT_CODE = ZRB.tax_rate_code and
(MISD.subinventory_code is null or PRF.LAST_NAME is null )
 
-- 采购其他相关表
select * from po_distributions_all 分配
select * from po_releases_all
select * from rcv_shipment_headers 采购接收头
select * from rcv_shipment_lines 采购接收行
select * from rcv_transactions 接收事务处理
select * from po_agents
select * from po_vendors
select * from po_vendor_sites_all
 
8. 库存 INV
-- 物料主表
select MSI.ORGANIZATION_ID 组织 ID,
MSI.INVENTORY_ITEM_ID 物料 ID,
MSI.SEGMENT1 物料编码 ,
MSI.DESCRIPTION 物料说明 ,
MSI.ITEM_TYPE 项目类型 ,
MSI.PLANNING_MAKE_BUY_CODE 制造或购买 ,
MSI.PRIMARY_UNIT_OF_MEASURE 基本度量单位 ,
MSI.BOM_ENABLED_FLAG BOM 标志 ,
MSI.INVENTORY_ASSET_FLAG 库存资产否 ,
MSI.BUYER_ID 采购员 ID,
MSI.PURCHASING_ENABLED_FLAG 可采购否 ,
MSI.PURCHASING_ITEM_FLAG 采购项目 ,
MSI.UNIT_OF_ISSUE 单位 ,
MSI.INVENTORY_ITEM_FLAG 是否为库存 ,
MSI.LOT_CONTROL_CODE 是否批量 ,
MSI.RESERVABLE_TYPE 是否要预留 ,
MSI.STOCK_ENABLED_FLAG 能否库存 ,
MSI.FIXED_DAYS_SUPPLY 固定提前期 ,
MSI.FIXED_LOT_MULTIPLIER 固定批量大小 ,
MSI.INVENTORY_PLANNING_CODE 库存计划方法 ,
MSI.MAXIMUM_ORDER_QUANTITY 最大定单数 ,
MSI.MINIMUM_ORDER_QUANTITY 最小定单数 ,
MSI.FULL_LEAD_TIME 固定提前期 ,
MSI.PLANNER_CODE 计划员码 ,
MISD.SUBINVENTORY_CODE 接收子仓库 ,
MSI.SOURCE_SUBINVENTORY 来源子仓库 ,
MSI.WIP_SUPPLY_SUBINVENTORY 供应子仓库 ,
MSI.ATTRIBUTE12 老编码 ,
MSI.INVENTORY_ITEM_STATUS_CODE 物料状态 ,
MSS.SAFETY_STOCK_QUANTITY 安全库存量
from mtl_system_items MSI, MTL_ITEM_SUB_DEFAULTS MISD,mtl_safety_stocks MSS
where MSI.ORGANIZATION_ID = MISD.ORGANIZATION_ID(+)
and MSI.INVENTORY_ITEM_ID = MISD.INVENTORY_ITEM_ID(+)
and MSI.ORGANIZATION_ID = MSS.ORGANIZATION_ID(+)
and MSI.INVENTORY_ITEM_ID = MSS.INVENTORY_ITEM_ID(+)
and MSI.ORGANIZATION_ID = 1155
and MSI.SEGMENT1 = '18020200012'
-- 物料库存数量
SELECT MOQ.ORGANIZATION_ID,
MOQ.INVENTORY_ITEM_ID,
MOQ.SUBINVENTORY_CODE,
SUM (MOQ.TRANSACTION_QUANTITY) QTY
FROM mtl_onhand_quantities MOQ
WHERE MOQ.INVENTORY_ITEM_ID = 12781
AND MOQ.ORGANIZATION_ID = 1155
GROUP BY MOQ.ORGANIZATION_ID, MOQ.INVENTORY_ITEM_ID, MOQ.SUBINVENTORY_CODE;
-- 移动平均成本
SELECT CST.INVENTORY_ITEM_ID ITEM_ID,
CST.ORGANIZATION_ID ORG_ID,
CST.COST_TYPE_ID 成本类型 ,
CST.ITEM_COST 单位成本 ,
CST.MATERIAL_COST 材料成本 ,
CST.MATERIAL_OVERHEAD_COST 间接费 ,
CST.Resource_Cost 人工费 ,
CST.OUTSIDE_PROCESSING_COST 外协费 ,
CST.OVERHEAD_COST 制造费
FROM CST_ITEM_COSTS CST
WHERE CST.COST_TYPE_ID = 2
AND CST.INVENTORY_ITEM_ID = 12781
AND CST.ORGANIZATION_ID = 1155 ;
 
-- 综合查询 - 库存数量及成本
SELECT MSI.ORGANIZATION_ID 组织 ID,
MSI.INVENTORY_ITEM_ID 物料 ID,
MSI.SEGMENT1 物料编码 ,
MSI.DESCRIPTION 物料说明 ,
MSI.PLANNING_MAKE_BUY_CODE M1P2,
MOQV.SUBINVENTORY_CODE 子库存 ,
MOQV.QTY 当前库存量 ,
CST.ITEM_COST 单位成本 ,
CST.MATERIAL_COST 材料成本 ,
CST.MATERIAL_OVERHEAD_COST 间接费 ,
CST.Resource_Cost 人工费 ,
CST.OUTSIDE_PROCESSING_COST 外协费 ,
CST.OVERHEAD_COST 制造费
FROM MTL_SYSTEM_ITEMS MSI,
CST_ITEM_COSTS CST,
( SELECT MOQ.ORGANIZATION_ID,
MOQ.INVENTORY_ITEM_ID,
MOQ.SUBINVENTORY_CODE,
SUM (MOQ.TRANSACTION_QUANTITY) QTY
FROM mtl_onhand_quantities MOQ
WHERE MOQ.ORGANIZATION_ID = 1155
GROUP BY MOQ.ORGANIZATION_ID,
MOQ.INVENTORY_ITEM_ID,
MOQ.SUBINVENTORY_CODE) MOQV
WHERE MSI.ORGANIZATION_ID = CST.ORGANIZATION_ID(+)
AND MSI.INVENTORY_ITEM_ID = CST.INVENTORY_ITEM_ID(+)
AND MSI.ORGANIZATION_ID = MOQV.ORGANIZATION_ID(+)
AND MSI.INVENTORY_ITEM_ID = MOQV.INVENTORY_ITEM_ID(+)
AND CST.COST_TYPE_ID = 2
AND MSI.ORGANIZATION_ID = 1155
AND MSI.SEGMENT1 = '18020200012'
-- 子库存列表
SELECT * FROM mtl_secondary_inventories;
-- 货位列表
SELECT ORGANIZATION_ID 组织代码 ,
INVENTORY_LOCATION_ID 货位内码 ,
SUBINVENTORY_CODE 子库名称 ,
SEGMENT1 货位编码
FROM mtl_item_locations;
-- 计划员表
SELECT PLANNER_CODE 计划员代码 ,
ORGANIZATION_ID 组织代码 ,
DESCRIPTION 计划员描述 ,
MP.EMPLOYEE_ID 员工 ID,
DISABLE_DATE 失效日期
FROM mtl_planners MP;
-- 科目设置等参数
select * from MTL_PARAMETERS MP
 
9. 物料清单 BOM
--BOM 主表 bom_bill_of_materials
select AA.BILL_SEQUENCE_ID 清单序号 ,
AA.ASSEMBLY_ITEM_ID 装配件内码 ,
AA.ORGANIZATION_ID 组织代码 ,
BB.SEGMENT1 物料编码 ,
BB.DESCRIPTION 物料说明 ,
AA.ASSEMBLY_TYPE 装配类别
from bom_bill_of_materials AA ， mtl_system_items BB
where AA.ASSEMBLY_ITEM_ID = BB.INVENTORY_ITEM_ID
and AA.ORGANIZATION_ID = BB.ORGANIZATION_ID;
--BOM 明细表 bom_inventory_components
select BILL_SEQUENCE_ID 清单序号 ,
COMPONENT_SEQUENCE_ID 构件序号 ,
ITEM_NUM 项目序列 ,
OPERATION_SEQ_NUM 操作序列号 ,
COMPONENT_ITEM_ID 子物料内码 ,
COMPONENT_QUANTITY 构件数量 ,
DISABLE_DATE 失效日期 ,
supply_subinventory 供应子库存 ,
BOM_ITEM_TYPE
from bom_inventory_components;
 
--BOM 明细综合查询 ( 组织 限定供应处 142 装配件 = '5XJ061988')
SELECT VBOM.BID 清单序号 ,
VBOM.F_ITEMID 装配件内码 ,
BB.SEGMENT1 物料编码 ,
BB.DESCRIPTION 物料说明 ,
VBOM.OGT_ID 组织内码 ,
VBOM.CID 操作 ID,
VBOM.ITEM_NUM 物料序号 ,
VBOM.OPID 工序 ,
VBOM.C_ITEMID 子物料内码 ,
CC.SEGMENT1 物料编码 ,
CC.DESCRIPTION 物料说明 ,
VBOM.QTY 构件数量 ,
CC.PRIMARY_UOM_CODE 子计量单位码 ,
CC.PRIMARY_UNIT_OF_MEASURE 子计量单位名 ,
VBOM.WHSE 供应子仓库
FROM ( select AA.BILL_SEQUENCE_ID BID,
BB.ASSEMBLY_ITEM_ID F_ITEMID,
BB.ORGANIZATION_ID OGT_ID,
AA.COMPONENT_SEQUENCE_ID CID,
AA.ITEM_NUM ITEM_NUM,
AA.OPERATION_SEQ_NUM OPID,
AA.COMPONENT_ITEM_ID C_ITEMID,
AA.COMPONENT_QUANTITY QTY,
AA.supply_subinventory WHSE
from bom_inventory_components AA, bom_bill_of_materials BB
where AA.BILL_SEQUENCE_ID = BB.BILL_SEQUENCE_ID) VBOM,
mtl_system_items BB,
mtl_system_items CC
WHERE VBOM.F_ITEMID = BB.INVENTORY_ITEM_ID
and VBOM.OGT_ID = BB.ORGANIZATION_ID
and VBOM.C_ITEMID = CC.INVENTORY_ITEM_ID
and VBOM.OGT_ID = CC.ORGANIZATION_ID
and VBOM.OGT_ID = 142
and BB.SEGMENT1 = '5XJ061988'
ORDER BY VBOM.ITEM_NUM;

0----------



so_headers_all；so_lines_all；
表名:ONT.OE_order_headers_all
说明:订单头
HEADER_ID NUMBER 订单头标识码
ORG_ID NUMBER OU ID
ORDER_TYPE_ID NUMBER 订单类型ID
ORDER_NUMBER NUMBER 订单编号
ORDERED_DATE DATE 定购日期
REQUEST_DATE DATE 客户要求发货日期
DEMAND_CLASS_CODE VARCHAR2(30) 需求分类Code
PRICE_LIST_ID NUMBER 价目表ID
TRANSACTIONAL_CURR_CODE VARCHAR2(15) 币种
CUST_PO_NUMBER VARCHAR2(50) 合同号
INVOICING_RULE_ID NUMBER(15) 开票规则ID
ACCOUNTING_RULE_ID NUMBER(15) 会计规则ID
PAYMENT_TERM_ID NUMBER(15) 付款条件ID
SHIPPING_METHOD_CODE VARCHAR2(30) 发运方法Code
FOB_POINT_CODE VARCHAR2(30) FOB Code
FREIGHT_TERMS_CODE VARCHAR2(30) 运费条款Code
SHIP_FROM_ORG_ID NUMBER 发货库存组织ID
SHIP_TO_ORG_ID NUMBER 客户Account_ID
INVOICE_TO_ORG_ID NUMBER 开票客户Account_ID
SOLD_TO_CONTACT_ID NUMBER 经办人ID
SHIP_TO_CONTACT_ID NUMBER 发货至联系人ID
INVOICE_TO_CONTACT_ID NUMBER 开票至联系人ID
CREATION_DATE DATE 输入日期
CREATED_BY NUMBER 输入人ID
LAST_UPDATED_BY NUMBER 更新人
LAST_UPDATE_DATE DATE 更新日期
LAST_UPDATE_LOGIN NUMBER 更新人用户
ATTRIBUTE1 DATE 合同收到日期
ATTRIBUTE2 DATE 客户要求到货日期
ATTRIBUTE3 VARCHAR2(240) 到货视同验收
ATTRIBUTE11 VARCHAR2(240) 客户行业分类Code
ATTRIBUTE12 VARCHAR2(240) 合同文本金额
ATTRIBUTE13 VARCHAR2(240) 是否需要客服到货确认
ATTRIBUTE14 DATE 承诺核销日期
CANCELLED_FLAG VARCHAR2(1) 是否取消
OPEN_FLAG VARCHAR2(1) 是否未结
BOOKED_FLAG VARCHAR2(1) 登记与否
SALESREP_ID NUMBER(15) 销售员ID
RETURN_REASON_CODE VARCHAR2(30) 退货原因Code
SALES_CHANNEL_CODE VARCHAR2(30) 销售渠道Code
ORDER_CATEGORY_CODE VARCHAR2(30) 订单类别
SHIPPING_INSTRUCTIONS VARCHAR2(2000) 老合同号
PACKING_INSTRUCTIONS VARCHAR2(2000) 包装指令
FLOW_STATUS_CODE VARCHAR2(30) 工作流状态代码
BOOKED_DATE DATE 下单日期


表名:ONT.OE_order_lines_all
说明:订单行
LINE_ID NUMBER 行ID
ORG_ID NUMBER OU ID
HEADER_ID NUMBER 头ID
LINE_TYPE_ID NUMBER 行类型ID
LINE_NUMBER NUMBER 行号
ORDERED_ITEM VARCHAR2(2000) Item编码
REQUEST_DATE DATE 计划发货日期
PROMISE_DATE DATE 承诺到货日期
SCHEDULE_SHIP_DATE DATE 产品可用/计划理货日期
ORDER_QUANTITY_UOM VARCHAR2(3) 定购UOM
CANCELLED_QUANTITY NUMBER 取消数量
SHIPPED_QUANTITY NUMBER 发运数量
ORDERED_QUANTITY NUMBER 定购数量
SHIPPING_QUANTITY_UOM VARCHAR2(3) 发运UOM
DELIVERY_LEAD_TIME NUMBER 发运在途时间
SHIP_FROM_ORG_ID NUMBER 发货库存组织ID
SHIP_TO_ORG_ID NUMBER 发货至客户Account ID
INVOICE_TO_ORG_ID NUMBER 开票至客户Account ID
SHIP_TO_CONTACT_ID NUMBER 发货至联系人ID
INVOICE_TO_CONTACT_ID NUMBER 开票至联系人ID
SOLD_TO_ORG_ID NUMBER 客户Account ID
CUST_PO_NUMBER VARCHAR2(50) 合同号
INVENTORY_ITEM_ID NUMBER
INVOICE_INTERFACE_STATUS_CODE VARCHAR2(30) AR接口状态
DEMAND_CLASS_CODE VARCHAR2(30) 需求分类
PRICE_LIST_ID NUMBER 价目表ID
SHIPPING_METHOD_CODE VARCHAR2(30) 发运方法CODE
FREIGHT_TERMS_CODE VARCHAR2(30) 运费方法Code
FOB_POINT_CODE VARCHAR2(30) FOB Code
PAYMENT_TERM_ID NUMBER(15) 付款条件ID
INVOICING_RULE_ID NUMBER(15) 开票规则ID
ACCOUNTING_RULE_ID NUMBER(15) 会计规则ID
ITEM_REVISION VARCHAR2(3) Item版本
UNIT_SELLING_PRICE NUMBER 销售单价
UNIT_LIST_PRICE NUMBER 价目表价格
CONTEXT VARCHAR2(30)
ATTRIBUTE1 VARCHAR2(240) 标准产品
ATTRIBUTE2 VARCHAR2(240) 直发行
ATTRIBUTE3 VARCHAR2(240) Item
ATTRIBUTE4 VARCHAR2(240) 财务分类
ATTRIBUTE5 VARCHAR2(240) 工程评审单价
ATTRIBUTE6 VARCHAR2(240) 订单行备注
ATTRIBUTE7 VARCHAR2(240) Old Promised Date1
ATTRIBUTE8 VARCHAR2(240) Promised date1 Change Reason
ATTRIBUTE9 VARCHAR2(240) Old Promised Date2
ATTRIBUTE10 VARCHAR2(240) Promised date2 Change Reason
ATTRIBUTE11 VARCHAR2(240) Old Promised Date3
ATTRIBUTE12 VARCHAR2(240) Promised Date3 Change Reason
ATTRIBUTE13 VARCHAR2(240) 合同评审号
ATTRIBUTE14 VARCHAR2(240) 合同评审项
CREATION_DATE DATE 输入日期
CREATED_BY NUMBER 输入人ID
LAST_UPDATE_DATE DATE 更新日期
LAST_UPDATED_BY NUMBER 更新人ID
LAST_UPDATE_LOGIN NUMBER 更新人用户
TOP_MODEL_LINE_ID NUMBER 顶层模型行ID
LINK_TO_LINE_ID NUMBER 上层行ID
ITEM_TYPE_CODE VARCHAR2(30) Item类型
VISIBLE_DEMAND_FLAG VARCHAR2(1) 是否挂需求
LINE_CATEGORY_CODE VARCHAR2(30) 行类别
ATO_LINE_ID NUMBER 最临近的ATO模型行ID
SCHEDULE_ARRIVAL_DATE DATE 家户到货日期
SCHEDULE_STATUS_CODE VARCHAR2(30) 计划状态
CANCELLED_FLAG VARCHAR2(1) 取消标记
OPEN_FLAG VARCHAR2(1)
BOOKED_FLAG VARCHAR2(1) 登记标记
SALESREP_ID NUMBER(15) 销售员ID
RETURN_REASON_CODE VARCHAR2(30) 退货原因Code
ORDERED_ITEM_ID NUMBER Item ID
SHIPPING_INTERFACED_FLAG VARCHAR2(1) 是否已经到发运接口
FULFILLED_FLAG VARCHAR2(1)
INVOICED_QUANTITY NUMBER 开票数量
SHIPPABLE_FLAG VARCHAR2(1) 是否可发运
FLOW_STATUS_CODE VARCHAR2(30) 行工作流状态
SUBINVENTORY VARCHAR2(10) 发货子库存

表名:oe_transaction_types_tl以及oe_transaction_types_all
说明:订单类别表

oe_transaction_types_tl
TRANSACTION_TYPE_ID NUMBER 订单类型ID
LANGUAGE VARCHAR2(4) 语言
NAME VARCHAR2(30) 订单类型名称
DESCRIPTION VARCHAR2(2000) 订单类型描述

oe_transaction_types_all
TRANSACTION_TYPE_ID NUMBER 订单类型ID
TRANSACTION_TYPE_CODE VARCHAR2(30) 行/头
ORDER_CATEGORY_CODE VARCHAR2(30) 销售/RMA
START_DATE_ACTIVE DATE 生效日期
END_DATE_ACTIVE DATE 失效日期
ORG_ID NUMBER OU ID
ATTRIBUTE4 VARCHAR2(240) 是否需要到发运系统
ATTRIBUTE5 VARCHAR2(240) 订单部门
ATTRIBUTE6 VARCHAR2(240) 业务类型Code
ATTRIBUTE7 VARCHAR2(240) 是否海外订单


Fold:XXEUL_OM_RELATED_INFO
说明:完整的订单数据
oh.header_id 订单头ID
oh.org_id OU ID
oh.order_type_id 订单类型ID
ttl.name 订单类型
ttl.descriptionorder_type_desc order_type_name 订单类型描述
tt.attribute5 order_dept_code 订单部门代码
fv_dept.description order_dept_desc 订单部门
tt.attribute6 type_class_code 订单业务代码
fv_class.description order_type_class_desc 订单业务描述
tt.attribute7 oversea_flag 是否海外订单
oh.order_number 订单编号
oh.ordered_date 合同签订日期
oh.request_date 客户要求发货日期
oh.booked_date 登记日期
oh.DEMAND_CLASS_CODE 需求分类代码
oh.price_list_id 价目表ID
oh.TRANSACTIONAL_CURR_CODE 币种
oh.CUST_PO_NUMBER 合同号
oh.PAYMENT_TERM_ID 付款条件ID
rt.name term_name 付款条件名称
oh.SHIPPING_METHOD_CODE 发运方法CODE
ship_meth.meaning SHIPPING_METHOD_MEANING 发运方法
oh.fob_point_code FOB Code
fob.meaning fob_point_meaning FOB名称
fob.attribute5 fob_ship_point FOB发运时间点
oh.FREIGHT_TERMS_CODE 运费条款Code
oh.sold_to_org_id sold_to_customer_id 客户
rc.customer_number 客户编码
rc.customer_name 客户Party名称
rc.Account_name 客户Account名称
oh.ship_from_org_id order_ship_from_org_id 发货库存组织ID
ship_from.organization_code ship_from_org_code 发货库存组织Code
rc_ship.customer_id ship_to_customer_id 发货至客户Account ID
rc_ship.customer_name ship_to_customer_name 发货至客户Name
rc_bill.customer_id invoice_to_customer_id 开票至客户Account ID
rc_bill.customer_name invoice_to_customer_name 开票至客户Name
ship_contact.last_Name ship_contact_name 发运联系人名称
ship_contact.First_Name ship_contact_phone 发运联系人电话
bill_contact.last_Name invoice_contact_name 开票联系人名称
bill_contact.First_Name invoice_contact_phone 开票联系人电话
oh.CREATION_DATE ORDER_CREATION_DATE 订单创建日期
fu.user_name creater_name 订单创建用户
oh.ATTRIBUTE1 Contract_Received_Date 合同收到日期
oh.ATTRIBUTE2 Customer_Request_Arrive_Date 客户要求到货日期
oh.ATTRIBUTE3 Due_At_Theoretic_Date 到货视同验收
oh.orig_sys_document_ref 导入的10.7老订单号
oh.ATTRIBUTE11 Customer_Industry_Class 客户行业分类Code
fv_ind.description Customer_Industry_Name 客户行业分类名称
oh.ATTRIBUTE12 Contract_Amount 合同文本金额
oh.ATTRIBUTE13 CSC_Need_Confirm 是否需要客服到货确认
oh.ATTRIBUTE14 Promised_Loan_Application_Date 承诺核销日期
oh.CANCELLED_FLAG ORDER_CANCELLED_FLAG 订单取消标记
oh.OPEN_FLAG ORDER_OPEN_FLAG 订单Open标记
oh.BOOKED_FLAG 订单登记标记
oh.SALESREP_ID 销售员ID
salerep.name SALESREP_NAME 销售员姓名
oh.SALES_CHANNEL_CODE 销售渠道Code
fv_chnl.meaning SALES_CHANNEL_MEANING 销售渠道
oh.ORDER_CATEGORY_CODE 订单类别
oh.SHIPPING_INSTRUCTIONS 老合同号
oh.PACKING_INSTRUCTIONS 包装指令
oh.FLOW_STATUS_CODE ORDER_FLOW_STATUS_CODE 订单头工作流Code
xc_audit.audit_flag 是否通过审计
xc_audit.audit_date 审计通过日期
ol.line_id 订单行ID
ol.LINE_TYPE_ID 订单行类型ID
ttl_line.name line_type_name 订单行类型名称
ol.LINE_NUMBER 订单行号
ol.REQUEST_DATE LINE_REQUEST_DATE 计划发货日期
ol.PROMISE_DATE 承诺到货日期
ol.SCHEDULE_SHIP_DATE 计划理货日期
ol.ORDER_QUANTITY_UOM 订单数量UOM
ol.CANCELLED_QUANTITY 取消数量
ol.SHIPPED_QUANTITY 发运数量
ol.ORDERED_QUANTITY 定购数量
ol.DELIVERY_LEAD_TIME 发运在途时间
ol.SHIP_FROM_ORG_ID LINE_SHIP_FROM_ORG_ID 行发货库存组织ID
line_ship_from.organization_code line_ship_from_org_code 行发货库存组织CODE
ol.INVENTORY_ITEM_ID Item ID
msi.segment1 item_segment1 Item编码
item_description item_description Item描述
ol.INVOICE_INTERFACE_STATUS_CODE 行AR接口状态
ol.UNIT_SELLING_PRICE 销售单价
ol.UNIT_LIST_PRICE 价目表价格
ol.ATTRIBUTE1 Standard_Item 是否标准Item
ol.ATTRIBUTE2 Need_Dropshipped 是否直发
substr(ol.ATTRIBUTE413) Main_Category_Code 产品大类代码
fv_main.description Main_Category_Desc 产品大类描述
ol.ATTRIBUTE4 Item_category 产品分类代码
fv_cate.description Item_category_description 产品分类描述
ol.ATTRIBUTE5 Item_Audited_Price 工程费用评审单价
ol.ATTRIBUTE6 Order_Line_memo 订单行备注
ol.ATTRIBUTE13 Audit_Number 行评审书号
ol.ATTRIBUTE14 Audit_Content 行评审书项
ol.CREATION_DATE LINE_CREATION_DATE 订单行创建日期
ol.TOP_MODEL_LINE_ID 顶层Model行ID
ol.ITEM_TYPE_CODE Item Type
ol.VISIBLE_DEMAND_FLAG 是否挂需求
ol.SCHEDULE_ARRIVAL_DATE 计划到货日期
ol.SCHEDULE_STATUS_CODE 计划状态代码
ol.CANCELLED_FLAG LINE_CANCELLED_FLAG 行取消标记
ol.OPEN_FLAG LINE_OPEN_FLAG 行Open标记
ol.SHIPPING_INTERFACED_FLAG 行发运接口标记
ol.INVOICED_QUANTITY 开票数量
ol.FLOW_STATUS_CODE LINE_FLOW_STATUS_CODE 行工作流状态代码
ATO_FLAG ATO_FLAG ATO行标记

Fold:XXEUL_OE_DILIVERY_RECORDS
说明:完整的订单发运记录
wdd.source_header_id header_id 订单头ID
wdd.source_line_id line_id 订单行ID
wdd.delivery_detail_id 交货行ID
wnd.delivery_id 交货ID
wnd.namedelivery_name 交货名称
wnd.initial_pickup_date ERP发运时间
wdd.requested_quantity erp_request_quantity 需要发货数据
xsh.SHIPPED_QUANTITY spc_shipped_quantity SCM发运数量
wdd.shipped_quantity spc_confirmed_quantity ERP发运数量
xsh.SHIPCONFIRM_DATE SCM发运出库时间
xsh.DELIVERY_ACK_DATE SCM到货确认时间
xsh.DELIVERY_ACK_PER SCM到货确认人
xsh.SERVICE_ACK_DATE 客服到货确认时间
xsh.SERVICE_ACK_PER 客服到货确认人
xsh.SERVICE_ACK_COM 客服到货确认备注


Fold:XXEUL_PRICING_LIST
说明:完整的订单发运记录
qh.list_header_id 价目表ID
qh.namelist_name 价目表名称
qh.currency_code 价目表币种
ql.list_line_id 价目表行ID
msi.inventory_item_id Item ID
ql.product_attr_val_disp item_segment1 Item编码
msi.description item_description Item描述
ql.operand price 价目表价格
ql.product_uom_codeuom UOM


Fold:Ra Customers V
说明:完整的客户头记录
customer_id 客户Account ID
customer_name   组织名称
customer_number 客户编码
Account_Name 客户名称
status 状态

Fold:Ra Addresses
说明:完整的客户地址信息
address_id 客户AddressID
customer_id 客户account_ID
org_id OU_ID
address1,  
address2,  
address3,
address4,
postal_code
country
city
province
county
state
status

Fold:Ra Site Use
说明:完整的客户地址对应的目的
Address Id 客户AddressID
Site Use Code 目的
Primary Flag 是否主要
Location 目的描述
Org Id OU_ID

Fold:MTL_TXN_REQUEST_LINES_V
说明:完整的搬运单行信息
LINE_ID NUMBER 行ID
REQUEST_NUMBER VARCHAR2(30) 搬运单号
MOVE_ORDER_TYPE NUMBER 搬运单类型CODE
MOVE_ORDER_TYPE_NAME VARCHAR2(80) 搬运单类型名称
DESCRIPTION VARCHAR2(240) 搬运单头描述
HEADER_ID NUMBER 搬运单头ID
TRANSACTION_SOURCE_TYPE_ID NUMBER 库存事务处理来源类型ID
TRANSACTION_TYPE_ID NUMBER 库存事务处理类型ID
TRANSACTION_TYPE_NAME VARCHAR2(30) 搬运单事务处理类型
LINE_NUMBER NUMBER
ORGANIZATION_ID NUMBER 库存组织ID
INVENTORY_ITEM_ID NUMBER
REVISION VARCHAR2(3) 版本号
FROM_SUBINVENTORY_ID NUMBER 来源子库存
FROM_SUBINVENTORY_CODE VARCHAR2(10) 来源子库存货位类型
FROM_SUB_LOCATOR_TYPE NUMBER 来源子库存ID
FROM_LOCATOR_ID NUMBER 来源子库存货位ID
TO_SUBINVENTORY_CODE VARCHAR2(10) 目标子库存
TO_SUB_LOCATOR_TYPE NUMBER 目标子库存货位类型
TO_SUBINVENTORY_ID NUMBER 目标子库存ID
TO_LOCATOR_ID NUMBER 目标子库存货位ID
SHIP_TO_LOCATION_ID NUMBER 发运至地点ID
LOT_NUMBER VARCHAR2(30) 批号
UOM_CODE VARCHAR2(3) UOM
QUANTITY NUMBER 搬运单数量
REQUIRED_QUANTITY NUMBER 请求数量
QUANTITY_DELIVERED NUMBER 已经处理数量
QUANTITY_DETAILED NUMBER 行分配数量
DATE_REQUIRED DATE 请求日期
REASON_ID NUMBER 事务处理原因ID
LINE_STATUS NUMBER 行状态
STATUS_DATE DATE 行状态变化日期
LAST_UPDATED_BY NUMBER 最后更新人ID
LAST_UPDATE_DATE DATE 最后更新日期
CREATED_BY NUMBER 创建人ID
CREATION_DATE DATE 行创建日期
ATTRIBUTE1 VARCHAR2(150) 行备注
ATTRIBUTE2 VARCHAR2(150) 行非标物品描述
TXN_SOURCE_LINE_ID NUMBER 挑库单行对应的订单行ID
PRIMARY_QUANTITY NUMBER 主交易数量


Fold:MTL_TXN_REQUEST_HEADERS_V
说明:完整的搬运单头信息
HEADER_ID NUMBER 订单头ID
REQUEST_NUMBER VARCHAR2(30) 搬运单号
TRANSACTION_TYPE_ID NUMBER 搬运单类型CODE
TRANSACTION_TYPE_NAME VARCHAR2(30) 搬运单类型名称
MOVE_ORDER_TYPE NUMBER 搬运单类型
MOVE_ORDER_TYPE_NAME VARCHAR2(80) 搬运单类型名称
ORGANIZATION_ID NUMBER 库存组织ID
DESCRIPTION VARCHAR2(240) 搬运单头描述
DATE_REQUIRED DATE 头请求日期
FROM_SUBINVENTORY_CODE VARCHAR2(10) 来源子库存
TO_SUBINVENTORY_CODE VARCHAR2(10) 目标子库存
SHIP_TO_LOCATION_ID NUMBER 发货至地址ID
HEADER_STATUS NUMBER 头状态
HEADER_STATUS_NAME VARCHAR2(80) 头状态名称
STATUS_DATE DATE 头状态日期
LAST_UPDATED_BY NUMBER 最近更新人
LAST_UPDATE_DATE DATE 最近更新日期
CREATED_BY NUMBER 创建人
CREATION_DATE DATE 创建日期
ATTRIBUTE1 VARCHAR2(150) 搬运单头备注
ATTRIBUTE2 VARCHAR2(150) 借货退货原因
ATTRIBUTE3 VARCHAR2(150) 借货合同号
ATTRIBUTE4 VARCHAR2(150) 退货方法
ATTRIBUTE5 VARCHAR2(150) 搬运单输入状态
ATTRIBUTE6 VARCHAR2(150) 来源子库存货位
TRANSACTION_ACTION_ID NUMBER

Fold:Fnd Lookup Values Vl
说明:OM 的Quick Code ：SALES_CHANNEL
Lookup Code 销售渠道编码
Meaning 销售渠道名称
Description 销售渠道英文描述
Loan_Inv_Org1 销售渠道对应的借货库存组织1
Loan_subinventory1 销售渠道对应的借货子库存1
Loan_Inv_Org2 销售渠道对应的借货库存组织2
Loan_subinventory2 销售渠道对应的借货子库存2
Branch Office Manager Email 办事处主任Email
CSC Job Notice Email 客服任务令Email
Ship Notice Email 发货通知发送的人员Email
Sales_Zone_id 销售大区ID

Fold:XXEUL_OM_ORDER_TYPE
说明:OM 的订单类型
Transfer To Shipping System 是否进入发运系统
Order Dept Code 订单部门Code
Type Class Code 订单业务Code
Is Abroad Order 是否海外订单
Name 订单类型名称
Description 订单类型描述
Transaction Type Id 订单类型ID
Transaction Type Code 订单类型Code
Demand Class Code 订单需求分类


Fold:Wsh Regions Tl
说明:销售区域
Region Id 销售大区ID
Zone 销售大区名称



------查询 OU下的库存和库存物料明细查询
 SELECT HR_OPERATING_UNITS.ORGANIZATION_ID AS OU_ID,
       HR_OPERATING_UNITS.NAME AS OU_NAME,
       HR_OPERATING_UNITS.SHORT_CODE as OU_Short_Code,
       ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_ID AS INV_ORG_ID,
       ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_CODE AS INV_ORG_CODE,
       ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_NAME AS INV_ORG_NAME,
       INVENTORY_ITEM_ID,
       MTL_SYSTEM_ITEMS_B.SEGMENT1 AS ITEM_NAME,
       MTL_SYSTEM_ITEMS_B.DESCRIPTION AS ITEM_DESCRIPTION,
       ENABLED_FLAG,
       MTL_SYSTEM_ITEMS_B.PURCHASING_ITEM_FLAG,
       MTL_SYSTEM_ITEMS_B.CUSTOMER_ORDER_FLAG,
       MTL_SYSTEM_ITEMS_B.INTERNAL_ORDER_FLAG,
       MTL_SYSTEM_ITEMS_B.SERVICE_ITEM_FLAG,
       MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_FLAG,
       MTL_SYSTEM_ITEMS_B.ENG_ITEM_FLAG,
       MTL_SYSTEM_ITEMS_B.PURCHASING_ENABLED_FLAG,
       MTL_SYSTEM_ITEMS_B.CUSTOMER_ORDER_ENABLED_FLAG,
       MTL_SYSTEM_ITEMS_B.INTERNAL_ORDER_ENABLED_FLAG,
       MTL_SYSTEM_ITEMS_B.SO_TRANSACTIONS_FLAG,
       MTL_SYSTEM_ITEMS_B.MTL_TRANSACTIONS_ENABLED_FLAG,
       MTL_SYSTEM_ITEMS_B.STOCK_ENABLED_FLAG,
       MTL_SYSTEM_ITEMS_B.BOM_ENABLED_FLAG,
       MTL_SYSTEM_ITEMS_B.BUILD_IN_WIP_FLAG
  FROM MTL_SYSTEM_ITEMS_B
 inner join Org_Organization_Definitions
    on Org_Organization_Definitions.ORGANIZATION_ID =
       MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID
 INNER JOIN HR_OPERATING_UNITS
    ON HR_OPERATING_UNITS.ORGANIZATION_ID =
       ORG_ORGANIZATION_DEFINITIONS.OPERATING_UNIT
 WHERE hr_operating_units.Name like '%230059_OU_内蒙古金海伊利乳业有限责任公司%'
 AND  MTL_SYSTEM_ITEMS_B.SEGMENT1='100000064900'
 




ORACLE EBS常用表及查询语句（最终整理版）
建议去看参考二





参考一：                                                             


call fnd_global.APPS_INITIALIZE(1318,50583,401)

select fnd_profile.VALUE('ORG_ID') FROM DUAL

select * from hr_operating_units hou where hou.organization_id=204

--fnd

select * from fnd_application   

select * from fnd_application_tl where application_id=101

select * from fnd_application_vl where application_id = 101

----值集

select * from fnd_flex_value_sets   

select * from fnd_flex_values       

select * from fnd_flex_values_vl

----弹性域

select * from fnd_id_flexs         

select * from fnd_id_flex_structures where id_flex_code='GL#'

select * from fnd_id_flex_segments where id_flex_code='GL#' and id_flex_num=50671

select * from fnd_profile_options_vl

select * from fnd_concurrent_programs    程序表

select * from fnd_concurrent_requests    请求表

select * from fnd_concurrent_processes   进程表

--inv(库存)

select * from org_organization_definitions   库存组织

select * from mtl_parameters                 组织参数

select * from mtl_system_items_b where inventory_item_id = 171 and organization_id=204 物料表

select * from mtl_secondary_inventories    子库存

select * from mtl_item_locations           货位

select * from mtl_lot_numbers              批次

select * from mtl_onhand_quantities        现有量表

select * from mtl_serial_numbers           序列

select * from mtl_material_transactions    物料事务记录

select * from mtl_transaction_accounts     会计分录

select * from mtl_transaction_types        事务类型

select * from mtl_txn_source_types         事务来源类型

select * from mfg_lookups ml where ml.LOOKUP_TYPE = 'MTL_TRANSACTION_ACTION'

--po（采购订单）

select * from po_requisition_headers_all   请求头

select * from po_requisition_lines_all     请求行

select * from po_headers_all               订单头

select * from po_lines_all                 订单行

select * from po_line_locations_all       

select * from po_distributions_all          分配

select * from po_releases_all               发送

select * from rcv_shipment_headers          采购接收头

select * from rcv_shipment_lines            采购接收行

select * from rcv_transactions              接收事务处理

select * from po_agents                    

select * from po_vendors                    订单

select * from po_vendor_sites_all

--oe（销售）

select * from ra_customers                  客户

select * from ra_addresses_all              地址

select * from ra_site_uses_all              用户

select * from oe_order_headers_all          销售头

select * from oe_order_lines_all            销售行

select * from wsh_new_deliveries            发送

select * from wsh_delivery_details

select * from wsh_delivery_assignments

--gl（总账）

select * from gl_sets_of_books     总帐

select * from gl_code_combinations gcc where gcc.summary_flag='Y'   科目组合

select * from gl_balances          科目余额

select * from gl_je_batches        凭证批

select * from gl_je_headers        凭证头

select * from gl_je_lines          凭证行

select * from gl_je_categories     凭证分类

select * from gl_je_sources        凭证来源

select * from gl_summary_templates 科目汇总模板

select * from gl_account_hierarchies 科目汇总模板层次

--ar（应收）

select * from ar_batches_all                 事务处理批

select * from ra_customer_trx_all            发票头

select * from ra_customer_trx_lines_all      发票行

select * from ra_cust_trx_line_gl_dist_all   发票分配

select * from ar_cash_receipts_all           收款

select * from ar_receivable_applications_all 核销

select * from ar_payment_schedules_all       发票调整

select * from ar_adjustments_all             会计分录

select * from ar_distributions_all           付款计划

--ap（应付）

select * from ap_invoices_all               发票头

select * from ap_invoice_distributions_all 发票行

select * from ap_payment_schedules_all      付款计划

select * from ap_check_stocks_all           单据

select * from ap_checks_all                 付款

select * from ap_bank_branches              银行

select * from ap_bank_accounts_all          银行帐号

select * from ap_invoice_payments_all       核销

========================华丽的分割线=========================

INV库存
organization 两个含义:
1. 经营单位，A/B/C分公司，A下面有A1，A2等工厂，主题目标是为了独立核算此组织
ORG，ORG_ID;
2. 库存组织，例如制造商的仓库，例如A1，A2等工厂
Organization_id;

HR_ORGANIZATION_UNITS －
Org_organization_definitions 
Mtl_subinventory_ 库存组织单位
MTL_PARAMETERS -库存组织参数（没有用ID，直接用name）
MTL_SYSTEM_ITEMS_b -物料信息（同上，应用了库存组织name）
MTL_SECONDARY_INVENTORIES -子库存组织 - 
MTL_ITEM_LOCATTIONS -货位 - SUBINVENTROY_CODE

Mtl_Material_Transactions - (库存)物料事物表
成本 mtl_transaction_accounts
transaction_cost是事物成本；
ACTUAL_COST是通过成本算法计算出来的实际成本，主计量单位

现有量
汇总历史记录（正负合计）
Mtl_Material_Transactions
MTL_ONHAND_QUANTITIES现有量表，组织/子库存/货位/物品 summary可能按照挑库先进先出统计，如果设置了"不允许负库存"，这样就不可能出现负数

PO
请购单头表
Po_Requisition_Headers_all
行表
Po_Requisition_lines_all
采购订单
PO_HEADER_ALL
PO_LINES_ALL
采购接收－退货/组织间转移/正常状态 都需要使用这个模块
RCV_TRANSACTIONS
1. 接收100单位货物,放入“待质检”货位
2. 接受/拒绝
3. 库存/退回
有三个不同的状态！例如：接收100个，80个接受入库，20个退回，那么有80个接受事务/20个退回事物
select TRANSACTION_TYPE，DESTINATION_TYPE_CODE from RCV_TRANSACTIONS
可以看出以下阶段：
A1.RECEIVE – RECEIVING
A2.ACCEPT – RECEIVING
A3.DELIERY – INVETORY(影响库存现有量)

如果按照正常模式，最后会触发产生MTL_MATERIAL_TRANSACTIONS

销售订单
OE_ORDER_headers_all
SOLD_FROM_ORG_ID
SOLD_TO_ORG_ID 就是客户层
SHIP_FROM_ORG_ID
SHIP_TO_ORG_ID 就是客户收货层
INVOICE_TO_ORG_ID 就是客户收单层
DELIVER_TO_ORG_ID
和客户结构有关
客户 RA_customers 
客户Address Ra_Addresses
Address 货品抵达 site RA_SITE_USES_ALL
Address 发票抵达 site 
OE_ORDER_LINEs_all

GL凭证
gl_je_batches
凭证日期:                DEFAULT_EFFECTIVE_DATE
会计期间:                DEFAULT_PERIOD_NAME
原币种凭证批借贷方汇总: RUNNING_TOTAL_DR/CR 比如美元
本位币凭证批借贷方汇总: RUNNING_TOTAL_ACCOUNTED_DR/CR 

gl_je_headers日记账头信息
批号:     JE_BATCH_ID
会计期间: PERIOD_NAME
币种:     CURRENCY_CODE
汇率类型: CURRENCY_CONVERSION_TYPE
汇率日期: CURRENCY_CONVERSION_DATE
帐套:     SET_OF_BOOKS_ID 参考 GL_SETS_OF_BOOKS
凭证类型: JE_CATEGORY 参考 GL_JE_SOURCES
凭证来源: JE_SOURCE

gl_je_lines日记账体信息
CODE_COMBINATION_ID 科目组合编号

GL_BALANCES 总帐余额
PERIOD_NET_DR/CR 净值
BEGIN_BALANCE_DR/CR 期初额

AR应收发票
RA_CUSTOMER_TRX_ALL
    CUSTOMER_TRX_ID 发票编号
    BILL_TO_SITE_USE_ID 客户收单方编号
    PRIMARY_SALES_ID销售员
REFERENCE是Oracle提供的外部编号输入框，但是由于版本问题和长度(<=30)，不建议用户使用，如果要使用外部编号，请使用说明性弹性域

RA_CUSTOMER_TRX_LINES_ALL
    LINE_ID            行号
    INVENTORY_ITEM_ID 可以为空，比如非物料的服务，只在DE script ION中出现 /税行
    DE script ION      
    QUANTITY_INVOICE   开票数量
    LINE_TYPE          行类型 (一般/税)
    EXTEND_PRICE       本行金额
注意：税行是隐藏行，所以至少会有两行

收款情况
AR_CASH_RECEIPTS_ALL（还包含了非收款信息）
    CASH_RECEIPT_ID 内部code
    RECEIPT_NUMBER   收款号
    RECEIPT_DATE     收款日期
    AMOUNT           总额
    RECEIPT_TYPE     现金/杂项 Cash/Misc
    FUNCTIONAL_AMOUNT 本位币计量金额
   UI上为RECEIPTS 
   核销关系不是一一对应，也不是一次核销100%,UI上右下方的Application 按钮
   AR_RECEIVABLE_APPLICATIONS_ALL
    APPLIED_CUSTOMER_TRX_ID   发票编号
    APPLIED_CUSTOMER_TRX_LINE_ID   发票行编号

    STATUS APP表示核销 /UNAPP表示未核销
        AMOUNT_APPLIED                 匹配金额
    注意:红冲收款报表时间跨月的问题；必须联查 AR_CASH_RECEIPTS_ALL和   AR_CASH_RECEIPT_HISTORY_ALL

AP
应付帐款(是我方人员按照供应商提供的纸张发票信息录入)UI 上的invoice
AP_INVOICES_ALL

实际付款PAYMENT
AP_CHECKS_ALL

核销关系 同AR，右下方的Payment 按钮
AP_INVOICE_PAYMENTS_ALL客户余额表，情况比较复杂:比如两个用户合并，应收应付差额，预付款

资产信息FA_ADDITIONS
名称
编号
分类
数量

资产类别
FA_CATEGORIES

资产帐簿
FA_BOOK_CONTROLS 和会计帐簿有什么关系？
FA_BOOKS 
UI中的Inquiry
Mothed是折旧方法(直线法/产量法)

FA_DISTRIBUTION_HISTORY分配assignment，给什么部门使用多少
LOCATION_ID 部门 联查FA_LOCATIONS

折旧信息(分摊方法)
FA_DEPRN_DETAIL
period_counter 折旧期间编号

折旧事务(新增、重建、转移、报废)
FA_TRANSACTION_HEADERS

========================华丽的分割线=========================

fnd_user －－－ 系统用户表

po_vendors －－－ 供应商信息表

po_vendor_sites －－－ 供应商地点信息表

hr_organization_units －－－ 组织及库存组织表

per_people_f －－－ 员工表

wip_entities －－－ 作业名信息表

wip_discrete_jobs －－－ 离散作业表

wip_requirement_operations －－－ 作业名物料需求发放表

po_headers_all －－－ 采购订单头表

po_lines_all －－－ 采购订单行表

po_line_locations_all －－－ 采购行地点表

rcv_transactions －－－ 接收交易表

bom_bill_of_materials －－－ 物料清单表

bom_inventory_components －－－ 物料清单构成表

mtl_system_items －－－ 物料主表

mtl_onhand_quantities －－－ 库存数据表

mtl_item_locations －－－ 项目货位表

mtl_material_transactions －－－ 出入库记录表

mtl_supply －－－ 供应表

mtl_demand －－－ 需求表


参考二：                                                  

1. OU、库存组织 
SELECT hou.organization_id ou_org_id, --org_id
hou.name ou_name, --ou 名称
ood.organization_id org_org_id, -- 库存组织 id
ood.organization_code org_org_code, -- 库存组织代码
msi.secondary_inventory_name, -- 子库存名称
msi.description -- 子库存描述
FROM hr_organization_information hoi, -- 组织分类表
hr_operating_units hou, --ou 视图
org_organization_definitions ood, -- 库存组织定义视图
mtl_secondary_inventories msi -- 子库存信息表
WHERE hoi.org_information1 = 'OPERATING_UNIT'
AND hoi.organization_id = hou.organization_id
AND ood.operating_unit = hoi.organization_id
AND ood.organization_id = msi.organization_id
-- 获取系统 ID
call fnd_global.APPS_INITIALIZE( 1318 , 50583 , 401 )
select fnd_profile.VALUE( 'ORG_ID' ) FROM DUAL
select * from hr_operating_units hou where hou.organization_id= 204
2. 用户、责任及 HR
-- 系统责任定义 VIEW(FROM FND_RESPONSIBILITY_TL, FND_RESPONSIBILITY)
SELECT APPLICATION_ID,
RESPONSIBILITY_ID,
RESPONSIBILITY_KEY,
END_DATE,
RESPONSIBILITY_NAME,
DESCRIPTION
FROM FND_RESPONSIBILITY_VL;
-- 用户责任关系
SELECT USER_ID, RESPONSIBILITY_ID FROM FND_USER_RESP_GROUPS;
-- 用户表
SELECT USER_ID, USER_NAME, EMPLOYEE_ID, PERSON_PARTY_ID, END_DATE
FROM FND_USER;
-- 人员表 VIEW
SELECT PERSON_ID,
START_DATE,
DATE_OF_BIRTH,
EMPLOYEE_NUMBER,
NATIONAL_IDENTIFIER,
SEX,
FULL_NAME
FROM per_people_f;
-- 综合查询
SELECT USER_NAME, FULL_NAME, RESPONSIBILITY_NAME, CC.DESCRIPTION
FROM FND_USER AA,
FND_USER_RESP_GROUPS BB,
FND_RESPONSIBILITY_VL CC,
per_people_f DD
WHERE AA.USER_ID = BB.USER_ID
AND BB.RESPONSIBILITY_ID = CC.RESPONSIBILITY_ID
AND AA.EMPLOYEE_ID = DD.PERSON_ID
AND RESPONSIBILITY_NAME like '% 供应处 %'
ORDER BY USER_NAME;
-- 综合查询
-- 人员状况基本信息表
SELECT PAF.PERSON_ID 系统 ID,
PAF.FULL_NAME 姓名 ,
PAF.DATE_OF_BIRTH 出生日期 ,
PAF.REGION_OF_BIRTH 出生地区 ,
PAF.NATIONAL_IDENTIFIER 身份证号 ,
PAF.ATTRIBUTE1 招工来源 ,
PAF.ATTRIBUTE3 员工类型 ,
PAF.ATTRIBUTE11 集团合同号 ,
PAF.original_date_of_hire 参加工作日期 ,
PAF.PER_INFORMATION17 省份 ,
DECODE (PAF.SEX, 'M' , ' 男 ' , 'F' , ' 女 ' , 'NULL' ) 性别 , --decode 适合和同一值做比较有多种结果，不适合和多种值比较有多种结果
CASE PAF.SEX
WHEN 'M' THEN ' 男 '
WHEN 'F' THEN ' 女 '
ELSE 'NULL'
END 性别 1, --case 用法一
CASE WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1960' THEN '50 年代 '
WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1970' THEN '60 年代 '
WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1980' THEN '70 年代 '
WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '1990' THEN '80 年代 '
WHEN TO_CHAR(PAF.DATE_OF_BIRTH, 'YYYY' ) < '2000' THEN '90 年代 '
ELSE '21 世纪 ' --case 用法二
END 出生年代
FROM PER_ALL_PEOPLE_F PAF
 
 
 
3. 供应商 VENDOR
-- 供应商主表数据：
SELECT ass.vendor_id vendor_id,
ass.party_id party_id,
ass.segment1 vendor_code,
ass.vendor_name vendor_name,
ass.vendor_name vendor_short_name,
ass.vendor_type_lookup_code vendor_type,
flv.meaning vendor_type_meaning,
hp.tax_reference tax_registered_name,
ass.payment_method_lookup_code payment_method,
att.name term_name,
att.enabled_flag enabled_flag,
att.end_date_active end_date_active,
ass.creation_date creation_date,
ass.created_by created_by,
ass.last_update_date last_update_date,
ass.last_updated_by last_updated_by,
ass.last_update_login last_update_login
FROM ap_suppliers ass,
fnd_lookup_values flv,
hz_parties hp,
ap_terms_tl att
WHERE ass.vendor_type_lookup_code = flv.lookup_code(+)
AND flv.lookup_type(+) = 'VENDOR TYPE'
AND flv.language(+) = userenv ( 'LANG' )
AND ass.party_id = hp.party_id
AND att.language = userenv ( 'LANG' )
AND ass.terms_id = att.term_id(+)
-- 供应商银行信息
SELECT ass.vendor_id vendor_id,
ass.party_id party_id,
bank.party_id bank_id,
bank.party_name bank_name,
branch.party_id branch_id,
branch.party_name bank_branch_name,
ieba.bank_account_num bank_account_num
FROM ap_suppliers ass,
hz_parties hp,
iby_account_owners iao,
iby_ext_bank_accounts ieba,
hz_parties bank,
hz_parties branch
WHERE ass.party_id = hp.party_id
AND hp.party_id = iao.account_owner_party_id(+)
AND iao.ext_bank_account_id = ieba.ext_bank_account_id(+)
AND ieba.bank_id = bank.party_id(+)
AND ieba.branch_id = branch.party_id(+)
ORDER BY ieba.creation_date;
-- 供应商开户行地址信息
SELECT hps.party_id party_id,
hps.party_site_id party_site_id,
hl.location_id location_id,
hl.country country,
hl.province province,
hl.city city,
hl.address1 address1,
hl.address2 address2,
hl.address3 address3,
hl.address4 address4
FROM hz_party_sites hps, hz_locations hl
WHERE hps.location_id = hl.location_id
ORDER BY hps.creation_date
-- 供应商联系人信息
SELECT hr.subject_id subject_id,
hr.object_id object_id,
hr.party_id party_id,
hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
hp.person_first_name contact_person,
hcpp.phone_area_code phone_area_code,
hcpp.phone_number phone_number,
hcpp.phone_extension phone_extension,
hcpf.phone_area_code fax_phone_area_code,
hcpf.phone_number fax_phone_number,
hcpe.email_address email_address
FROM hz_relationships hr,
hz_contact_points hcpp,
hz_contact_points hcpf,
hz_contact_points hcpe,
hz_parties hp
WHERE hr.object_id = hp.party_id
AND hcpp.owner_table_id(+) = hr.party_id
AND hcpf.owner_table_id(+) = hr.party_id
AND hcpe.owner_table_id(+) = hr.party_id
AND hr.object_type = 'PERSON'
AND hr.relationship_code(+) = 'CONTACT'
AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
AND hcpf.owner_table_name(+) = 'HZ_PARTIES'
AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
AND hcpp.contact_point_type(+) = 'PHONE'
AND hcpp.phone_line_type(+) = 'GEN'
AND hcpf.contact_point_type(+) = 'PHONE'
AND hcpf.phone_line_type(+) = 'FAX'
AND hcpe.contact_point_type(+) = 'EMAIL'
AND hcpe.phone_line_type IS NULL
ORDER BY hr.creation_date;
-- 供应商地址主信息
SELECT assa.vendor_site_id vendor_site_id,
assa.vendor_id vendor_id,
assa.vendor_site_code vendor_code,
assa.vendor_site_code address_short_name,
assa.address_line1 address_line1,
assa.address_line2 address_line2,
assa.address_line3 address_line3,
assa.address_line4 address_line4,
assa.org_id org_id,
assa.country country,
assa.province province,
assa.city city,
assa.county county,
assa.zip zip,
assa.pay_site_flag pay_site_flag,
assa.purchasing_site_flag purchasing_site_flag,
assa.inactive_date inactive_date,
assa.creation_date creation_date,
assa.created_by created_by,
assa.last_update_date last_update_date,
assa.last_updated_by last_updated_by,
assa.last_update_login last_update_login
FROM ap_suppliers ass, ap_supplier_sites_all assa
WHERE assa.vendor_id = ass.vendor_id;
-- 供应商地址联系人信息： phone 、 fax 和 Email
SELECT hcpp.phone_area_code phone_area_code,
hcpp.phone_number phone_number,
hcpp.phone_extension phone_extension,
hcpf.phone_area_code fax_phone_area_code,
hcpf.phone_number fax_phone_number,
hcpe.email_address email_address
FROM ap_supplier_sites_all assa,
hz_contact_points hcpp,
hz_contact_points hcpf,
hz_contact_points hcpe,
hz_party_sites hps
WHERE assa.party_site_id = hps.party_site_id
AND hcpp.owner_table_id(+) = assa.party_site_id
AND hcpf.owner_table_id(+) = assa.party_site_id
AND hcpe.owner_table_id(+) = assa.party_site_id
AND hcpp.owner_table_name(+) = 'HZ_PARTY_SITES'
AND hcpf.owner_table_name(+) = 'HZ_PARTY_SITES'
AND hcpe.owner_table_name(+) = 'HZ_PARTY_SITES'
AND hcpp.contact_point_type(+) = 'PHONE'
AND hcpp.phone_line_type(+) = 'GEN'
AND hcpf.contact_point_type(+) = 'PHONE'
AND hcpf.phone_line_type(+) = 'FAX'
AND hcpe.contact_point_type(+) = 'EMAIL'
AND hcpe.phone_line_type IS NULL ;
-- 供应商地址收件人信息
SELECT assa.party_site_id
FROM ap_supplier_sites_all assa
-- 根据 party_site_id 得到供应商地址的收件人名称
SELECT hps.addressee FROM hz_party_sites hps;
-- 供应商银行帐户分配层次关系
SELECT * FROM iby_pmt_instr_uses_all;
-- 供应商银行帐户分配层次关系明细 ( 不包括供应商层的分配信息 ):
SELECT * FROM iby_external_payees_all;
 
4. 客户 CUSTOMER
--SQL 查询
-- 客户账户表 以许继 1063 电网客户为例 -->>PARTY_ID = 21302
SELECT * FROM hz_cust_accounts AA WHERE AA.CUST_ACCOUNT_ID = 1063 ;
 
-- 客户名称及地址全局信息表 -->> PARTY_NUMBER = 19316
SELECT * FROM hz_parties AA WHERE AA.PARTY_ID = 21302 ;
 
-- 客户地点账户主文件
SELECT * FROM hz_cust_acct_sites_all WHERE CUST_ACCOUNT_ID = 1063 ;
 
-- 客户地点 ( 关联 hz_cust_acct_sites_all)
SELECT * FROM HZ_PARTY_SITES WHERE PARTY_ID = 21302 ;
 
-- 地点地址名称 ( 关联 hz_cust_acct_sites_all)
SELECT AA.ADDRESS1, AA.ADDRESS_KEY
FROM HZ_LOCATIONS AA, HZ_PARTY_SITES BB
WHERE AA.LOCATION_ID = BB.LOCATION_ID
AND BB.PARTY_ID = 21302 ;
 
-- 客户地点业务目的 ( 关联 hz_cust_acct_sites_all 用 CUST_ACCT_SITE_ID)
SELECT * FROM HZ_CUST_SITE_USES_ALL;
 
-- 客户地点详细信息表，以供应处 OU 的身份 ORG_ID = 119
SELECT AA.PARTY_SITE_ID 客户组织地点 ID,
AA.PARTY_ID 客户组织 ID,
AA.LOCATION_ID 地点 ID,
AA.PARTY_SITE_NUMBER 地点编号 ,
AA.IDENTIFYING_ADDRESS_FLAG 地址标示 ,
AA.STATUS 有效否 ,
AA.PARTY_SITE_NAME,
BB.ORG_ID 业务实体 ,
BB.bill_to_flag 收单标示 ,
BB.ship_to_flag 收货标示 ,
CC.ADDRESS1 地点名称 ,
DD.SITE_USE_ID,
DD.SITE_USE_CODE,
DD.PRIMARY_FLAG,
DD.STATUS,
DD.LOCATION 业务目的 ,
DD.BILL_TO_SITE_USE_ID 收单地 ID,
DD.TAX_CODE
FROM hz_party_sites AA,
hz_cust_acct_sites_all BB,
hz_locations CC,
HZ_CUST_SITE_USES_ALL DD
WHERE AA.PARTY_SITE_ID = BB.PARTY_SITE_ID
AND BB.CUST_ACCOUNT_ID = 1063
AND BB.ORG_ID = 119
AND AA.STATUS = 'A'
AND AA.LOCATION_ID = CC.LOCATION_ID
AND BB.CUST_ACCT_SITE_ID(+) = DD.CUST_ACCT_SITE_ID
AND DD.STATUS <> 'I' ;
 
--************* 综合查询 ************--
-- 客户主数据
SELECT hca.cust_account_id customer_id,
hp.party_number customer_number,
hp.party_name customer_name,
hp.party_name customer_short_name,
hca.customer_type customer_type,
alt.meaning customer_type_meaning,
hca.customer_class_code customer_class,
alc.meaning customer_class_meaning,
hp.tax_reference tax_registered_name,
rt.name term_name,
hca.creation_date creation_date,
hca.created_by created_by,
hca.last_update_date last_update_date,
hca.last_updated_by last_updated_by,
hca.last_update_login last_update_login
FROM hz_parties hp,
hz_cust_accounts hca,
ar_lookups alt,
ar_lookups alc,
hz_customer_profiles hcp,
ra_terms rt
WHERE hp.party_id = hca.party_id
AND hca.customer_type = alt.lookup_code(+)
AND alt.lookup_type = 'CUSTOMER_TYPE'
AND hca.customer_class_code = alc.lookup_code(+)
AND alc.lookup_type(+) = 'CUSTOMER CLASS'
AND hca.cust_account_id = hcp.cust_account_id(+)
AND hcp.standard_terms = rt.term_id(+)
 
-- 客户收款方法 SQL
SELECT arm.name receipt_method_name
FROM hz_cust_accounts hca,
ra_cust_receipt_methods rcrm,
ar_receipt_methods arm
WHERE hca.cust_account_id = rcrm.customer_id
AND rcrm.receipt_method_id = arm.receipt_method_id
ORDER BY rcrm.creation_date;
-- 客户账户层银行账户信息 SQL
SELECT hca.cust_account_id cust_account_id,
hp.party_id party_id,
bank.party_id bank_id,
bank.party_name bank_name,
branch.party_id branch_id,
branch.party_name bank_branch_name,
ieba.bank_account_num bank_account_num
FROM hz_cust_accounts hca,
hz_parties hp,
iby_account_owners iao,
iby_ext_bank_accounts ieba,
hz_parties bank,
hz_parties branch
WHERE hca.party_id = hp.party_id
AND hp.party_id = iao.account_owner_party_id(+)
AND iao.ext_bank_account_id = ieba.ext_bank_account_id(+)
AND ieba.bank_id = bank.party_id(+)
AND ieba.branch_id = branch.party_id(+)
ORDER BY ieba.creation_date;
-- 客户开户行地址信息 SQL
SELECT hl.country || '-' || hl.province || '-' || hl.city || '-' ||
hl.address1 || '-' || hl.address2 || '-' || hl.address3 || '-' ||
hl.address4 bank_address
FROM hz_party_sites hps, hz_locations hl
WHERE hps.location_id = hl.location_id
ORDER BY hps.creation_date;
-- 客户账户层联系人信息：联系人、电话、手机和 Email SQL
SELECT hr.party_id party_id,
hcar.cust_account_id cust_account_id,
hcar.cust_acct_site_id cust_acct_site_id,
hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
hp.person_first_name contact_person,
hcpp.phone_area_code phone_area_code,
hcpp.phone_number phone_number,
hcpp.phone_extension phone_extension,
hcpm.phone_area_code mobile_phone_area_code,
hcpm.phone_number mobile_phone_number,
hcpe.email_address email_address
FROM hz_relationships hr,
hz_cust_account_roles hcar,
hz_org_contacts hoc,
hz_contact_points hcpp,
hz_contact_points hcpm,
hz_contact_points hcpe,
hz_parties hp,
hz_cust_accounts hca
WHERE hr.object_id = hp.party_id
AND hr.party_id = hcar.party_id
AND hr.relationship_id = hoc.party_relationship_id(+)
AND hcpp.owner_table_id(+) = hr.party_id
AND hcpm.owner_table_id(+) = hr.party_id
AND hcpe.owner_table_id(+) = hr.party_id
AND hr.object_type = 'PERSON'
AND hr.relationship_code(+) = 'CONTACT'
AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
AND hcpm.owner_table_name(+) = 'HZ_PARTIES'
AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
AND hcpp.contact_point_type(+) = 'PHONE'
AND hcpp.phone_line_type(+) = 'GEN'
AND hcpm.contact_point_type(+) = 'PHONE'
AND hcpm.phone_line_type(+) = 'MOBILE'
AND hcpe.contact_point_type(+) = 'EMAIL'
AND hcpe.phone_line_type IS NULL
AND hr.subject_id = hca.party_id
AND hcar.cust_acct_site_id IS NULL
ORDER BY hr.creation_date;
-- 客户地址
SELECT hcasa.cust_acct_site_id customer_site_id,
hcasa.cust_account_id customer_id,
hps.party_site_number customer_site_code,
hps.party_site_name customer_site_name,
hl.address1 address_line1,
hl.address2 address_line2,
hl.address3 address_line3,
hl.address4 address_line4,
hcasa.org_id org_id,
hl.country country,
hl.province province,
hl.city city,
hl.county county,
hl.postal_code zip,
hcasa.bill_to_flag bill_to_flag,
hcasa.ship_to_flag ship_to_flag,
hca.creation_date creation_date,
hca.created_by created_by,
hca.last_update_date last_update_date,
hca.last_updated_by last_updated_by,
hca.last_update_login last_update_login
FROM hz_cust_accounts hca,
hz_cust_acct_sites_all hcasa,
hz_party_sites hps,
hz_locations hl
WHERE hca.cust_account_id = hcasa.cust_account_id
AND hcasa.party_site_id = hps.party_site_id
AND hps.location_id = hl.location_id;
 
-- 客户账户层地址 contact person 信息 :phone,mobile,email
SELECT hr.party_id party_id,
hcar.cust_account_id cust_account_id,
hcar.cust_acct_site_id cust_acct_site_id,
hp.person_last_name || ' ' || hp.person_middle_name || ' ' ||
hp.person_first_name contact_person,
hcpp.phone_area_code phone_area_code,
hcpp.phone_number phone_number,
hcpp.phone_extension phone_extension,
hcpm.phone_area_code mobile_phone_area_code,
hcpm.phone_number mobile_phone_number,
hcpe.email_address email_address
FROM hz_relationships hr,
hz_cust_account_roles hcar,
hz_org_contacts hoc,
hz_contact_points hcpp,
hz_contact_points hcpm,
hz_contact_points hcpe,
hz_parties hp,
hz_cust_accounts hca
WHERE hr.object_id = hp.party_id
AND hr.party_id = hcar.party_id
AND hr.relationship_id = hoc.party_relationship_id(+)
AND hcpp.owner_table_id(+) = hr.party_id
AND hcpm.owner_table_id(+) = hr.party_id
AND hcpe.owner_table_id(+) = hr.party_id
AND hr.object_type = 'PERSON'
AND hr.relationship_code(+) = 'CONTACT'
AND hcpp.owner_table_name(+) = 'HZ_PARTIES'
AND hcpm.owner_table_name(+) = 'HZ_PARTIES'
AND hcpe.owner_table_name(+) = 'HZ_PARTIES'
AND hcpp.contact_point_type(+) = 'PHONE'
AND hcpp.phone_line_type(+) = 'GEN'
AND hcpm.contact_point_type(+) = 'PHONE'
AND hcpm.phone_line_type(+) = 'MOBILE'
AND hcpe.contact_point_type(+) = 'EMAIL'
AND hcpe.phone_line_type IS NULL
AND hr.subject_id = hca.party_id
AND hca.cust_account_id = hcar.cust_account_id
ORDER BY hr.creation_date;
 
-- 客户账户地点地址
SELECT hp.party_id,
hca.cust_account_id,
hcasa.cust_acct_site_id,
hcasa.bill_to_flag,
hcasa.ship_to_flag,
hcsua.site_use_id,
hcasa.party_site_id,
hcsua.site_use_code,
hcsua.primary_flag,
hcsua.location,
hcsua.org_id
FROM hz_parties hp,
hz_cust_accounts hca,
hz_party_sites hps,
hz_cust_acct_sites_all hcasa,
hz_cust_site_uses_all hcsua
WHERE hp.party_id = hca.party_id
AND hca.cust_account_id = hcasa.cust_account_id
AND hcasa.party_site_id = hps.party_site_id
AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
-- 客户主配置文件
SELECT * FROM hz_cust_profile_classes;
SELECT * FROM hz_customer_profiles;
SELECT * FROM hz_cust_prof_class_amts;
SELECT * FROM hz_cust_profile_amts;
 
5. 订单 OE
--
select * from oe_order_headers_all 销售头
select * from oe_order_lines_all 销售行
select * from wsh_new_deliveries 发送
select * from wsh_delivery_details
select * from wsh_delivery_assignments
-- 综合查询 1- 未结销售订单
SELECT H.ORDER_NUMBER 销售订单 ,
h.cust_po_number 客户 PO,
cust.account_number 客户编码 ,
hp.party_name 客户名称 ,
ship_use.location 收货地 ,
bill_use.location 收单地 ,
h.ordered_date 订单日期 ,
H.ATTRIBUTE1 合同号 ,
h.attribute2 屏号 ,
h.attribute3 来源编码 ,
l.line_number 行号 ,
l.ordered_item 物料 ,
msi.description 物料说明 ,
l.order_quantity_uom 订购单位 ,
l.ordered_quantity 订购数量 ,
l.cancelled_quantity 取消数量 ,
l.shipped_quantity 发运数量 ,
l.schedule_ship_date 计划发运日期 ,
l.booked_flag 登记标记 ,
ol.MEANING 工作流状态 ,
l.cancelled_flag 取消标记
FROM OE_ORDER_HEADERS_ALL H,
OE_ORDER_LINES_ALL L,
HZ_CUST_ACCOUNTS CUST,
hz_parties hp,
hz_cust_site_uses_all ship_use,
hz_cust_site_uses_all bill_use,
mtl_system_items_b msi,
oe_lookups ol
WHERE 1 = 1
AND H.HEADER_ID = L.HEADER_ID
AND H.SOLD_TO_ORG_ID = CUST.CUST_ACCOUNT_ID
and cust.party_id = hp.party_id
and h.ship_to_org_id = ship_use.site_use_id
and h.invoice_to_org_id = bill_use.site_use_id
and l.flow_status_code not in ( 'CLOSED' , 'CANCELLED' )
and l.inventory_item_id = msi.inventory_item_id
and msi.organization_id = 141
and l.flow_status_code = ol.LOOKUP_CODE
and ol.LOOKUP_TYPE = 'LINE_FLOW_STATUS'
AND CUST.ACCOUNT_NUMBER IN ( '91010072' , '91010067' , '91010036' )
order by party_name ，收货地，销售订单 ;


6. 采购申请 PR
-- 申请单头 （以电网组织 ORG_ID=112 内部申请 =14140002781 为例
SELECT PRH.REQUISITION_HEADER_ID 申请单头 ID,
PRH.PREPARER_ID,
PRH.Org_Id OU_ID,
PRH.SEGMENT1 申请单编号 ,
PRH.Creation_Date 创建日期 ,
PRH.Created_By 编制人 ID,
FU.USER_NAME 用户名称 ,
PP.FULL_NAME 用户姓名 ,
PRH.Approved_Date 批准日期 ,
PRH.Description 说明 ,
PRH.Authorization_Status 状态 ,
PRH.Type_Lookup_Code 类型 ,
PRH.Transferred_To_Oe_Flag 传递标示
FROM PO_REQUISITION_HEADERS_ALL PRH, FND_USER FU, per_people_f PP
WHERE PRH.CREATED_BY = FU.USER_ID
AND FU.EMPLOYEE_ID = PP.PERSON_ID
AND PRH.ORG_ID = 112
AND PRH.SEGMENT1 = '14140002781' ;
-->> 内部申请 =14140002781 申请单头 ID = 3379
-- 申请单行明细
SELECT PRL.REQUISITION_HEADER_ID 申请单 ID,
PRL.REQUISITION_LINE_ID 行 ID,
PRL.LINE_NUM 行号 ,
PRL.CATEGORY_ID 分类 ID,
PRL.ITEM_ID 物料 ID,
ITEM.SEGMENT1 物料编码 ,
PRL.ITEM_DESCRIPTION 物料说明 ,
PRL.Quantity 需求数 ,
PRL.Quantity_Delivered 送货数 ,
PRL.Quantity_Cancelled 取消数 ,
PRL.Unit_Meas_Lookup_Code 单位 ,
PRL.Unit_Price 参考价 ,
PRL.Need_By_Date 需求日期 ,
PRL.Source_Type_Code 来源类型 ,
PRL.Org_Id OU_ID,
PRL.Source_Organization_Id 对方组织 ID,
PRL.Destination_Organization_Id 本方组织 ID
from PO_REQUISITION_LINES_ALL PRL,MTL_SYSTEM_ITEMS ITEM
WHERE PRL.ORG_ID = 112
AND PRL.ITEM_ID = ITEM.INVENTORY_ITEM_ID
AND PRL.Destination_Organization_Id = ITEM.ORGANIZATION_ID
AND PRL.REQUISITION_HEADER_ID = 3379 ;
-- 申请单头 ( 加对方订单编号 )
SELECT PRH.REQUISITION_HEADER_ID 申请单头 ID,
PRH.PREPARER_ID,
PRH.Org_Id OU_ID,
PRH.SEGMENT1 申请单编号 ,
PRH.Creation_Date 创建日期 ,
PRH.Created_By 编制人 ID,
FU.USER_NAME 用户名称 ,
PP.FULL_NAME 用户姓名 ,
PRH.Approved_Date 批准日期 ,
PRH.Description 说明 ,
PRH.Authorization_Status 状态 ,
PRH.Type_Lookup_Code 类型 ,
PRH.Transferred_To_Oe_Flag 传递标示 ,
OEH.ORDER_NUMBER 对方 CO 编号
FROM PO_REQUISITION_HEADERS_ALL PRH, FND_USER FU, per_people_f PP,OE_ORDER_HEADERS_ALL OEH
WHERE PRH.CREATED_BY = FU.USER_ID
AND FU.EMPLOYEE_ID = PP.PERSON_ID
AND PRH.REQUISITION_HEADER_ID = OEH.SOURCE_DOCUMENT_ID(+)
AND PRH.ORG_ID = 112
AND PRH.SEGMENT1 = '14140002781' ;
--( 销售订单记录有对方 OU_ID, 申请单关键字 SOURCE_DOCUMENT_ID 申请单号 SOURCE_DOCEMENT_REF)
 
******************* 综合查询类 *******************
-- 申请单头综合查询 （进限制只能查询 -- 电网组织 ORG_ID=112)
SELECT PRH.REQUISITION_HEADER_ID 申请单头 ID,
PRH.Org_Id 组织 ID,
PRH.SEGMENT1 申请单编号 ,
PRH.Creation_Date 创建日期 ,
PRH.Created_By 编制人 ID,
FU.USER_NAME 用户名称 ,
PP.FULL_NAME 用户姓名 ,
PRH.Approved_Date 批准日期 ,
PRH.Description 说明 ,
PRH.Authorization_Status 状态 ,
PRH.Type_Lookup_Code 类型 ,
PRH.Transferred_To_Oe_Flag 传递标示 ,
PRL.REQUISITION_LINE_ID 行 ID,
PRL.LINE_NUM 行号 ,
PRL.CATEGORY_ID 分类 ID,
PRL.ITEM_ID 物料 ID,
ITEM.SEGMENT1 物料编码 ,
PRL.ITEM_DESCRIPTION 物料说明 ,
PRL.Quantity 需求数 ,
PRL.Quantity_Delivered 送货数 ,
PRL.Quantity_Cancelled 取消数 ,
PRL.Unit_Meas_Lookup_Code 单位 ,
PRL.Unit_Price 参考价 ,
PRL.Need_By_Date 需求日期 ,
PRL.Source_Type_Code 来源类型 ,
PRL.Source_Organization_Id 对方组织 ID,
PRL.Destination_Organization_Id 本方组织 ID
FROM PO_REQUISITION_HEADERS_ALL PRH,
FND_USER FU,
per_people_f PP,
PO_REQUISITION_LINES_ALL PRL,
MTL_SYSTEM_ITEMS ITEM
WHERE PRH.CREATED_BY = FU.USER_ID
AND FU.EMPLOYEE_ID = PP.PERSON_ID
AND PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
AND PRH.Org_Id = PRL.ORG_ID
AND PRL.ITEM_ID = ITEM.INVENTORY_ITEM_ID
AND PRL.Destination_Organization_Id = ITEM.ORGANIZATION_ID
AND PRH.ORG_ID = 112 ;
 
-- 若需创建视图只需在 SELECT 语句前加上
CREATE OR REPLACE VIEW CUX_INV_PR112 AS
7. 采购订单 PO
-- 采购单头信息 TYPE_LOOKUP_CODE='STANDARD' （以供应处 OU ORG_ID=119 采购单 ='' 为例）
-- 类型说明 TYPE_LOOKUP_CODE='STANDARD' 为采购单 TYPE_LOOKUP_CODE='BLANKET' 为采购协议
SELECT POH.ORG_ID OU_ID,
POH.PO_HEADER_ID 采购单头 ID,
POH.TYPE_LOOKUP_CODE 类型 ,
POH.AUTHORIZATION_STATUS 状态 ,
POH.VENDOR_ID 供应商 ID,
VENDOR.VENDOR_NAME 供应商名 ,
POH.VENDOR_SITE_ID 供应商地址 ID,
POH.VENDOR_CONTACT_ID 供应商联系人 ID,
POH.SHIP_TO_LOCATION_ID 本方收货地 ID,
POH.BILL_TO_LOCATION_ID 本方收单地 ID,
POH.CREATION_DATE 创建日期 ,
POH.APPROVED_FLAG 审批 YN,
POH.APPROVED_DATE 审批日期 ,
POH.COMMENTS 采购单说明 ,
POH.TERMS_ID 条款 ID,
POH.AGENT_ID 采购员 ID,
AGT_PP.LAST_NAME 采购员 ,
POH.CREATED_BY 创建者 ID,
FU.USER_NAME 创建用户 ,
PP.FULL_NAME 用户姓名
FROM PO_HEADERS_ALL POH, FND_USER FU, per_people_f PP,PER_ALL_PEOPLE_F AGT_PP,ap_suppliers VENDOR
WHERE POH.CREATED_BY = FU.USER_ID
AND FU.EMPLOYEE_ID = PP.PERSON_ID
AND POH.AGENT_ID = AGT_PP.PERSON_ID
AND POH.VENDOR_ID=VENDOR.VENDOR_ID
AND POH.ORG_ID = 119
AND POH.TYPE_LOOKUP_CODE = 'STANDARD'
AND POH.SEGMENT1 = '14730005436' ;
/*
FND_USER FU, per_people_f PP 用户相关表
po_agents_name_v 采购员视图 ----> PO_AGENTS.AGENT_ID = PER_ALL_PEOPLE_F.PERSON_ID 采购员相关表
ap_suppliers 供应商主表
*/
 
-->> POH.SEGMENT1 = '14730005436' PO_HEADER_ID = 10068
-- 采购单行信息
SELECT POL.ORG_ID OU_ID,
POL.PO_HEADER_ID 采购单头 ID,
POL.PO_LINE_ID 行 ID,
POL.LINE_NUM 行号 ,
POL.ITEM_ID 物料 ID,
ITEM.SEGMENT1 物料编码 ,
POL.ITEM_DESCRIPTION 物料说明 ,
POL.UNIT_MEAS_LOOKUP_CODE 单位 ,
POL.UNIT_PRICE 单价 ,
PO_LCT.QUANTITY 订购数 ,
PO_LCT.QUANTITY_RECEIVED 验收数 ,
PO_LCT.QUANTITY_ACCEPTED 接收数 ,
PO_LCT.QUANTITY_REJECTED 拒绝数 ,
PO_LCT.QUANTITY_CANCELLED 取消数 ,
PO_LCT.QUANTITY_BILLED 到票数 ,
PO_LCT.PROMISED_DATE 承诺日期 ,
PO_LCT.NEED_BY_DATE 需求日期
FROM PO_LINES_ALL POL,
Po_Line_Locations_all PO_LCT,
MTL_SYSTEM_ITEMS ITEM
WHERE POL.ORG_ID = PO_LCT.ORG_ID
AND POL.PO_LINE_ID = PO_LCT.PO_LINE_ID
AND POL.ITEM_ID = ITEM.INVENTORY_ITEM_ID
AND ITEM.ORGANIZATION_ID = 142
AND POL.Org_Id = 119
AND POL.PO_HEADER_ID = 10068 ;
-- 说明： Po_Line_Locations_all 系 “ 发运表 ”
 
-- 综合查询 1 ，所分配给供应处组织的物料，存在采购协议，但缺失采购员或缺失仓库；
select MSIF.Segment1 物料编码 ,
MSIF.Description 物料描述 ,
MSIF.LONG_DESCRIPTION 物料详细描述 ,
--MSIF.primary_unit_of_measure 计量单位 ,
PRF.LAST_NAME 采购员 ,
MISD.subinventory_code 默认接收库存 ,
PLA.unit_price 未税价 ,
round (PLA.unit_price * ( 1 + ZRB.percentage_rate / 100 ), 2 ) 含税价 ,
PV.VENDOR_NAME 供应商名称
from apps.PO_HEADERS_ALL PHA,
apps.PO_LINES_ALL PLA,
apps.MTL_SYSTEM_ITEMS_FVL MSIF,
apps.MTL_ITEM_SUB_DEFAULTS MISD,
apps.PER_PEOPLE_F PRF,
apps.PO_VENDORS PV,
apps.PO_VENDOR_SITES_ALL PVSA,
apps.ZX_RATES_B ZRB
where PHA.Type_Lookup_Code = 'BLANKET' and PHA.Org_Id = 119 and
PHA.PO_HEADER_ID = PLA.Po_Header_Id and
PHA.Global_Agreement_Flag = 'Y' and PHA.Approved_Flag in ( 'Y' , 'R' ) and
NVL (PHA.end_Date, sysdate ) >= sysdate and
NVL (PLA.Expiration_Date, sysdate ) >= sysdate and
PLA.Cancel_Flag = 'N' and PLA.Item_Id = MSIF.INVENTORY_ITEM_ID and
MSIF.ORGANIZATION_ID = 142 and
MSIF.INVENTORY_ITEM_ID = MISD.INVENTORY_ITEM_ID(+) and
MISD.ORGANIZATION_ID(+) = 142 and MISD.default_type(+) = 2 and
MSIF.BUYER_ID = PRF.PERSON_ID(+) and
PRF.EFFECTIVE_END_DATE(+) = to_date( '4712-12-31' , 'YYYY-MM-DD' ) and
PHA.VENDOR_ID = PV.VENDOR_ID and
PHA.Vendor_Site_Id = PVSA.VENDOR_SITE_ID and
PVSA.VAT_CODE = ZRB.tax_rate_code and
(MISD.subinventory_code is null or PRF.LAST_NAME is null )
 
-- 采购其他相关表
select * from po_distributions_all 分配
select * from po_releases_all
select * from rcv_shipment_headers 采购接收头
select * from rcv_shipment_lines 采购接收行
select * from rcv_transactions 接收事务处理
select * from po_agents
select * from po_vendors
select * from po_vendor_sites_all
 
8. 库存 INV
-- 物料主表
select MSI.ORGANIZATION_ID 组织 ID,
MSI.INVENTORY_ITEM_ID 物料 ID,
MSI.SEGMENT1 物料编码 ,
MSI.DESCRIPTION 物料说明 ,
MSI.ITEM_TYPE 项目类型 ,
MSI.PLANNING_MAKE_BUY_CODE 制造或购买 ,
MSI.PRIMARY_UNIT_OF_MEASURE 基本度量单位 ,
MSI.BOM_ENABLED_FLAG BOM 标志 ,
MSI.INVENTORY_ASSET_FLAG 库存资产否 ,
MSI.BUYER_ID 采购员 ID,
MSI.PURCHASING_ENABLED_FLAG 可采购否 ,
MSI.PURCHASING_ITEM_FLAG 采购项目 ,
MSI.UNIT_OF_ISSUE 单位 ,
MSI.INVENTORY_ITEM_FLAG 是否为库存 ,
MSI.LOT_CONTROL_CODE 是否批量 ,
MSI.RESERVABLE_TYPE 是否要预留 ,
MSI.STOCK_ENABLED_FLAG 能否库存 ,
MSI.FIXED_DAYS_SUPPLY 固定提前期 ,
MSI.FIXED_LOT_MULTIPLIER 固定批量大小 ,
MSI.INVENTORY_PLANNING_CODE 库存计划方法 ,
MSI.MAXIMUM_ORDER_QUANTITY 最大定单数 ,
MSI.MINIMUM_ORDER_QUANTITY 最小定单数 ,
MSI.FULL_LEAD_TIME 固定提前期 ,
MSI.PLANNER_CODE 计划员码 ,
MISD.SUBINVENTORY_CODE 接收子仓库 ,
MSI.SOURCE_SUBINVENTORY 来源子仓库 ,
MSI.WIP_SUPPLY_SUBINVENTORY 供应子仓库 ,
MSI.ATTRIBUTE12 老编码 ,
MSI.INVENTORY_ITEM_STATUS_CODE 物料状态 ,
MSS.SAFETY_STOCK_QUANTITY 安全库存量
from mtl_system_items MSI, MTL_ITEM_SUB_DEFAULTS MISD,mtl_safety_stocks MSS
where MSI.ORGANIZATION_ID = MISD.ORGANIZATION_ID(+)
and MSI.INVENTORY_ITEM_ID = MISD.INVENTORY_ITEM_ID(+)
and MSI.ORGANIZATION_ID = MSS.ORGANIZATION_ID(+)
and MSI.INVENTORY_ITEM_ID = MSS.INVENTORY_ITEM_ID(+)
and MSI.ORGANIZATION_ID = 1155
and MSI.SEGMENT1 = '18020200012'
-- 物料库存数量
SELECT MOQ.ORGANIZATION_ID,
MOQ.INVENTORY_ITEM_ID,
MOQ.SUBINVENTORY_CODE,
SUM (MOQ.TRANSACTION_QUANTITY) QTY
FROM mtl_onhand_quantities MOQ
WHERE MOQ.INVENTORY_ITEM_ID = 12781
AND MOQ.ORGANIZATION_ID = 1155
GROUP BY MOQ.ORGANIZATION_ID, MOQ.INVENTORY_ITEM_ID, MOQ.SUBINVENTORY_CODE;
-- 移动平均成本
SELECT CST.INVENTORY_ITEM_ID ITEM_ID,
CST.ORGANIZATION_ID ORG_ID,
CST.COST_TYPE_ID 成本类型 ,
CST.ITEM_COST 单位成本 ,
CST.MATERIAL_COST 材料成本 ,
CST.MATERIAL_OVERHEAD_COST 间接费 ,
CST.Resource_Cost 人工费 ,
CST.OUTSIDE_PROCESSING_COST 外协费 ,
CST.OVERHEAD_COST 制造费
FROM CST_ITEM_COSTS CST
WHERE CST.COST_TYPE_ID = 2
AND CST.INVENTORY_ITEM_ID = 12781
AND CST.ORGANIZATION_ID = 1155 ;
 
-- 综合查询 - 库存数量及成本
SELECT MSI.ORGANIZATION_ID 组织 ID,
MSI.INVENTORY_ITEM_ID 物料 ID,
MSI.SEGMENT1 物料编码 ,
MSI.DESCRIPTION 物料说明 ,
MSI.PLANNING_MAKE_BUY_CODE M1P2,
MOQV.SUBINVENTORY_CODE 子库存 ,
MOQV.QTY 当前库存量 ,
CST.ITEM_COST 单位成本 ,
CST.MATERIAL_COST 材料成本 ,
CST.MATERIAL_OVERHEAD_COST 间接费 ,
CST.Resource_Cost 人工费 ,
CST.OUTSIDE_PROCESSING_COST 外协费 ,
CST.OVERHEAD_COST 制造费
FROM MTL_SYSTEM_ITEMS MSI,
CST_ITEM_COSTS CST,
( SELECT MOQ.ORGANIZATION_ID,
MOQ.INVENTORY_ITEM_ID,
MOQ.SUBINVENTORY_CODE,
SUM (MOQ.TRANSACTION_QUANTITY) QTY
FROM mtl_onhand_quantities MOQ
WHERE MOQ.ORGANIZATION_ID = 1155
GROUP BY MOQ.ORGANIZATION_ID,
MOQ.INVENTORY_ITEM_ID,
MOQ.SUBINVENTORY_CODE) MOQV
WHERE MSI.ORGANIZATION_ID = CST.ORGANIZATION_ID(+)
AND MSI.INVENTORY_ITEM_ID = CST.INVENTORY_ITEM_ID(+)
AND MSI.ORGANIZATION_ID = MOQV.ORGANIZATION_ID(+)
AND MSI.INVENTORY_ITEM_ID = MOQV.INVENTORY_ITEM_ID(+)
AND CST.COST_TYPE_ID = 2
AND MSI.ORGANIZATION_ID = 1155
AND MSI.SEGMENT1 = '18020200012'
-- 子库存列表
SELECT * FROM mtl_secondary_inventories;
-- 货位列表
SELECT ORGANIZATION_ID 组织代码 ,
INVENTORY_LOCATION_ID 货位内码 ,
SUBINVENTORY_CODE 子库名称 ,
SEGMENT1 货位编码
FROM mtl_item_locations;
-- 计划员表
SELECT PLANNER_CODE 计划员代码 ,
ORGANIZATION_ID 组织代码 ,
DESCRIPTION 计划员描述 ,
MP.EMPLOYEE_ID 员工 ID,
DISABLE_DATE 失效日期
FROM mtl_planners MP;
-- 科目设置等参数
select * from MTL_PARAMETERS MP
 
9. 物料清单 BOM
--BOM 主表 bom_bill_of_materials
select AA.BILL_SEQUENCE_ID 清单序号 ,
AA.ASSEMBLY_ITEM_ID 装配件内码 ,
AA.ORGANIZATION_ID 组织代码 ,
BB.SEGMENT1 物料编码 ,
BB.DESCRIPTION 物料说明 ,
AA.ASSEMBLY_TYPE 装配类别
from bom_bill_of_materials AA ， mtl_system_items BB
where AA.ASSEMBLY_ITEM_ID = BB.INVENTORY_ITEM_ID
and AA.ORGANIZATION_ID = BB.ORGANIZATION_ID;
--BOM 明细表 bom_inventory_components
select BILL_SEQUENCE_ID 清单序号 ,
COMPONENT_SEQUENCE_ID 构件序号 ,
ITEM_NUM 项目序列 ,
OPERATION_SEQ_NUM 操作序列号 ,
COMPONENT_ITEM_ID 子物料内码 ,
COMPONENT_QUANTITY 构件数量 ,
DISABLE_DATE 失效日期 ,
supply_subinventory 供应子库存 ,
BOM_ITEM_TYPE
from bom_inventory_components;
 
--BOM 明细综合查询 ( 组织 限定供应处 142 装配件 = '5XJ061988')
SELECT VBOM.BID 清单序号 ,
VBOM.F_ITEMID 装配件内码 ,
BB.SEGMENT1 物料编码 ,
BB.DESCRIPTION 物料说明 ,
VBOM.OGT_ID 组织内码 ,
VBOM.CID 操作 ID,
VBOM.ITEM_NUM 物料序号 ,
VBOM.OPID 工序 ,
VBOM.C_ITEMID 子物料内码 ,
CC.SEGMENT1 物料编码 ,
CC.DESCRIPTION 物料说明 ,
VBOM.QTY 构件数量 ,
CC.PRIMARY_UOM_CODE 子计量单位码 ,
CC.PRIMARY_UNIT_OF_MEASURE 子计量单位名 ,
VBOM.WHSE 供应子仓库
FROM ( select AA.BILL_SEQUENCE_ID BID,
BB.ASSEMBLY_ITEM_ID F_ITEMID,
BB.ORGANIZATION_ID OGT_ID,
AA.COMPONENT_SEQUENCE_ID CID,
AA.ITEM_NUM ITEM_NUM,
AA.OPERATION_SEQ_NUM OPID,
AA.COMPONENT_ITEM_ID C_ITEMID,
AA.COMPONENT_QUANTITY QTY,
AA.supply_subinventory WHSE
from bom_inventory_components AA, bom_bill_of_materials BB
where AA.BILL_SEQUENCE_ID = BB.BILL_SEQUENCE_ID) VBOM,
mtl_system_items BB,
mtl_system_items CC
WHERE VBOM.F_ITEMID = BB.INVENTORY_ITEM_ID
and VBOM.OGT_ID = BB.ORGANIZATION_ID
and VBOM.C_ITEMID = CC.INVENTORY_ITEM_ID
and VBOM.OGT_ID = CC.ORGANIZATION_ID
and VBOM.OGT_ID = 142
and BB.SEGMENT1 = '5XJ061988'
ORDER BY VBOM.ITEM_NUM;
 
-- 单层 BOM 成本查询 ( 需系统提交请求计算后 )
select inventory_item_id, organization_id, item_cost, program_update_date
from bom.cst_item_costs
where inventory_item_id = 23760
and organization_id = 142 ;
 
select inventory_item_id, organization_id, item_cost, program_update_date
from cst_item_cost_details
where inventory_item_id = 23760
and organization_id = 142 ;
 
10. 作业任务 WIP
说明： 查询作业任务头以及作业任务工序和 BOM 情况
-- 作业任务头信息表
-- （以直流 OU_ID=117 ； ORGANIZATION_ID=1155; 及任务 WIP_ENTITY_NAME='XJ39562'; 装配件编码 SEGMENT1 = '07D9202.92742' 为例）
SELECT AA.WIP_ENTITY_ID 任务令 ID,
AA.ORGANIZATION_ID 组织 ID,
AA.WIP_ENTITY_NAME 任务名称 ,
AA.ENTITY_TYPE 任务类型 ,
AA.CREATION_DATE 创建日期 ,
AA.CREATED_BY 创建者 ID,
AA.DESCRIPTION 说明 ,
AA.PRIMARY_ITEM_ID 装配件 ID,
BB.SEGMENT1 物料编码 ,
BB.DESCRIPTION 物料说明
FROM wip_entities AA, mtl_system_items BB
WHERE AA.PRIMARY_ITEM_ID = BB.INVENTORY_ITEM_ID
and AA.ORGANIZATION_ID = BB.ORGANIZATION_ID
and AA.ORGANIZATION_ID = 1155
and AA.WIP_ENTITY_NAME = 'XJ39562' ;
--=> WIP_ENTITY_ID = 48825
 
-- 离散作业任务详细主信息表
-- 用途 1 ）作业任务下达及完成情况查询
-- 说明 1 ）此表包括 wip_entities 表大部分信息 2) 重复作业任务表为 wip_repetitive_items, wip_repetitive_schedules
select AA.WIP_ENTITY_ID 任务令 ID,
BB.WIP_ENTITY_NAME 任务名称 ,
AA.ORGANIZATION_ID 组织 ID,
AA.SOURCE_LINE_ID 行 ID,
AA.STATUS_TYPE 状态 TYPE,
AA.PRIMARY_ITEM_ID 装配件 ID,
CC.SEGMENT1 物料编码 ,
CC.DESCRIPTION 物料说明 ,
AA.FIRM_PLANNED_FLAG,
AA.JOB_TYPE 作业类型 ,
AA.WIP_SUPPLY_TYPE 供应 TYPE,
AA.CLASS_CODE 任务类别 ,
AA.SCHEDULED_START_DATE 起始时间 ,
AA.DATE_RELEASED 下达时间 ,
AA.SCHEDULED_COMPLETION_DATE 完工时间 ,
AA.DATE_COMPLETED 完工时间 ,
AA.DATE_CLOSED 关门时间 ,
AA.START_QUANTITY 计划数 ,
AA.QUANTITY_COMPLETED 完工数 ,
AA.QUANTITY_SCRAPPED 报废数 ,
AA.NET_QUANTITY MRP 净值 ,
AA.COMPLETION_SUBINVENTORY 接收子库 ,
AA.COMPLETION_LOCATOR_ID 货位
from wip_discrete_jobs AA, wip.wip_entities BB, mtl_system_items CC
where AA.WIP_ENTITY_ID = BB.WIP_ENTITY_ID
and AA.PRIMARY_ITEM_ID = CC.INVENTORY_ITEM_ID
and AA.ORGANIZATION_ID = CC.ORGANIZATION_ID
and AA.organization_id = 1155
and BB.WIP_ENTITY_NAME = 'XJ39562' ;
/*
1 ）任务状态 TYPE 值说明：
STATUS_TYPE =1 未发放的 - 收费不允许
STATUS_TYPE =3 发入 - 收费允许
STATUS_TYPE =4 完成 - 允许收费
STATUS_TYPE =5 完成 - 不允许收费
STATUS_TYPE =6 暂挂 - 不允许收费
STATUS_TYPE =7 已取消 - 不允许收费
STATUS_TYPE =8 等待物料单加载
STATUS_TYPE =9 失败的物料单加载
STATUS_TYPE =10 等待路线加载
STATUS_TYPE =11 失败的路线加载
STATUS_TYPE =12 关闭 - 不可收费
STATUS_TYPE =13 等待 - 成批加载
STATUS_TYPE =14 等待关闭
STATUS_TYPE =15 关闭失败
2 ）供应类型 TYPE 值说明：
WIP_SUPPLY_TYPE =1 推式
WIP_SUPPLY_TYPE =2 装配拉式
WIP_SUPPLY_TYPE =3 操作拉式
WIP_SUPPLY_TYPE =4 大量
WIP_SUPPLY_TYPE =5 供应商
WIP_SUPPLY_TYPE =6 虚拟
WIP_SUPPLY_TYPE =7 以帐单为基础
*/
 
-- 离散作业任务工序状况表
select AA.ORGANIZATION_ID 组织 ID,
AA.WIP_ENTITY_ID 任务令 ID,
BB.WIP_ENTITY_NAME 任务名称 ,
AA.OPERATION_SEQ_NUM 工序号 ,
AA.DESCRIPTION 工序描述 ,
AA.DEPARTMENT_ID 部门 ID,
AA.SCHEDULED_QUANTITY 计划数量 ,
AA.QUANTITY_IN_QUEUE 排队数量 ,
AA.QUANTITY_RUNNING 运行数量 ,
AA.QUANTITY_WAITING_TO_MOVE 待移动数量 ,
AA.QUANTITY_REJECTED 故障品数量 ,
AA.QUANTITY_SCRAPPED 报废品数量 ,
AA.QUANTITY_COMPLETED 完工数量 ,
AA.FIRST_UNIT_START_DATE 最早一个单位上线时间 ,
AA.FIRST_UNIT_COMPLETION_DATE 最早一个单位完成时间 ,
AA.LAST_UNIT_START_DATE 最后一个单位上线时间 ,
AA.LAST_UNIT_COMPLETION_DATE 最后一个单位完工时间 ,
AA.PREVIOUS_OPERATION_SEQ_NUM 前一工序序号 ,
AA.NEXT_OPERATION_SEQ_NUM 下一工序序号 ,
AA.COUNT_POINT_TYPE 是否自动计费 ,
AA.BACKFLUSH_FLAG 倒冲否 ,
AA.MINIMUM_TRANSFER_QUANTITY 最小传送数量 ,
AA.DATE_LAST_MOVED 最后移动时间
from wip_operations AA,wip_entities BB
where AA.WIP_ENTITY_ID = BB.WIP_ENTITY_ID
and BB.WIP_ENTITY_NAME = 'XJ39562' ;
-- 离散作业任务子查询 ——— 工单工序状况查询（不单独使用）
select WDJ.ORGANIZATION_ID,
WDJ.WIP_ENTITY_ID,
COUNT ( 1 ) COUNT_OPER,
max ( decode (wo.quantity_completed, 1 , wo.operation_seq_num, 10 )) OPER
from WIP_DISCRETE_JOBS WDJ, WIP_OPERATIONS WO
where 1 = 1
AND WDJ.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
AND WDJ.wip_entity_id = '48825'
group by WDJ.ORGANIZATION_ID,WDJ.WIP_ENTITY_ID;
 
 
-- 离散作业任务 BOM ( 无材料费 )
SELECT WOP.ORGANIZATION_ID 组织 ID,
WOP.WIP_ENTITY_ID 任务令 ID,
BB.WIP_ENTITY_NAME 装配件名称 ,
BB.PRIMARY_ITEM_ID 装配件 ID,
CC.SEGMENT1 装配件物料编码 ,
CC.DESCRIPTION 装配件说明 ,
WOP.OPERATION_SEQ_NUM 工序号 ,
WOP.DEPARTMENT_ID 部门 ID,
WOP.WIP_SUPPLY_TYPE 供应类型 ,
WOP.DATE_REQUIRED 要求日期 ,
WOP.INVENTORY_ITEM_ID 子物料 ID,
DD.SEGMENT1 子物料编码 ,
DD.DESCRIPTION 子物料说明 ,
WOP.QUANTITY_PER_ASSEMBLY 单位需量 ,
WOP.REQUIRED_QUANTITY 总需求量 ,
WOP.QUANTITY_ISSUED 已发放量 ,
WOP.COMMENTS 注释 ,
WOP.SUPPLY_SUBINVENTORY 供应子库
FROM wip_requirement_operations WOP,
wip_entities BB,
mtl_system_items CC,
mtl_system_items DD
WHERE WOP.WIP_ENTITY_ID = BB.WIP_ENTITY_ID
and BB.PRIMARY_ITEM_ID = CC.INVENTORY_ITEM_ID
and BB.ORGANIZATION_ID = CC.ORGANIZATION_ID
and WOP.INVENTORY_ITEM_ID = DD.INVENTORY_ITEM_ID
and WOP.ORGANIZATION_ID = DD.ORGANIZATION_ID
and WOP.ORGANIZATION_ID = 1155
and BB.WIP_ENTITY_NAME = 'XJ39562' ;
 
-- 作业任务已发放材料处理记录清单 0101 （最详细） （内码为 48825 为例）
-- 用途 1 ）查询工单发料详细明细，包括发料类型、时间、用户等
select MTL.TRANSACTION_ID 交易 ID,
MTL.INVENTORY_ITEM_ID 项目 ID,
CC.SEGMENT1 物料编码 ,
CC.DESCRIPTION 物料说明 ,
MTL.ORGANIZATION_ID 组织 ID,
MTL.SUBINVENTORY_CODE 子库名称 ,
MTL.TRANSACTION_TYPE_ID 交易类型 ID,
BB.TRANSACTION_TYPE_NAME 交易类型名称 ,
MTL.TRANSACTION_QUANTITY 交易数量 ,
MTL.TRANSACTION_UOM 单位 ,
MTL.TRANSACTION_DATE 交易日期 ,
MTL.TRANSACTION_REFERENCE 交易参考 ,
MTL.TRANSACTION_SOURCE_ID 参考源 ID,
FF.WIP_ENTITY_NAME 任务名称 ,
MTL.DEPARTMENT_ID 部门 ID,
MTL.OPERATION_SEQ_NUM 工序号 ,
ROUND (MTL.PRIOR_COST, 2 ) 原来成本 ,
ROUND (MTL.NEW_COST, 2 ) 新成本 ,
MTL.TRANSACTION_QUANTITY * ROUND (MTL.PRIOR_COST, 2 ) 交易金额 ,
DD.USER_NAME 用户名称 ,
EE.FULL_NAME 用户姓名
from mtl_material_transactions MTL,
mtl_transaction_types BB,
mtl_system_items CC,
FND_USER DD,
per_people_f EE,
wip_entities FF
where MTL.TRANSACTION_TYPE_ID = BB.TRANSACTION_TYPE_ID
and MTL.CREATED_BY = DD.USER_ID
and MTL.INVENTORY_ITEM_ID = CC.INVENTORY_ITEM_ID
and MTL.ORGANIZATION_ID = CC.ORGANIZATION_ID
and DD.EMPLOYEE_ID = EE.PERSON_ID
and MTL.TRANSACTION_SOURCE_ID = FF.WIP_ENTITY_ID
and MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )
and MTL.ORGANIZATION_ID = 1155
and MTL.TRANSACTION_SOURCE_ID = 48825 ;
-- 按工单的材料费汇总（不单独使用）
select MTL.ORGANIZATION_ID,
MTL.TRANSACTION_SOURCE_ID WIP_ENTITY_ID,
ABS ( round ( SUM (MTL.TRANSACTION_QUANTITY * MTL.PRIOR_COST), 2 )) AMT
from mtl_material_transactions MTL
where MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )
and MTL.ORGANIZATION_ID = 1155
and MTL.TRANSACTION_SOURCE_ID = 48825
group by MTL.ORGANIZATION_ID, MTL.TRANSACTION_SOURCE_ID;
 
-- 离散作业任务子查询 01——— 材料消耗状况及材料费综合查询
-- 用途 1 ）查询发料状况 2 ）查询材料费物料小计
SELECT WOP.ORGANIZATION_ID 组织 ID,
WOP.WIP_ENTITY_ID 任务令 ID,
BB.WIP_ENTITY_NAME 装配件名称 ,
BB.PRIMARY_ITEM_ID 装配件 ID,
CC.SEGMENT1 装配件物料编码 ,
CC.DESCRIPTION 装配件说明 ,
WOP.OPERATION_SEQ_NUM 工序号 ,
WOP.DEPARTMENT_ID 部门 ID,
WOP.WIP_SUPPLY_TYPE 供应类型 ,
WOP.DATE_REQUIRED 要求日期 ,
WOP.INVENTORY_ITEM_ID 子物料 ID,
DD.SEGMENT1 子物料编码 ,
DD.DESCRIPTION 子物料说明 ,
WOP.QUANTITY_PER_ASSEMBLY 单位需量 ,
WOP.REQUIRED_QUANTITY 总需求量 ,
WOP.QUANTITY_ISSUED 已发放量 ,
CST.AMT 已发生材料费 ,
WOP.COMMENTS 注释 ,
WOP.SUPPLY_SUBINVENTORY 供应子库
FROM wip_requirement_operations WOP,
wip_entities BB,
mtl_system_items CC,
mtl_system_items DD,
( select MTL.ORGANIZATION_ID orgID,
MTL.TRANSACTION_SOURCE_ID wipID,
MTL.OPERATION_SEQ_NUM oprID,
MTL.INVENTORY_ITEM_ID itemID,
sum (MTL.TRANSACTION_QUANTITY * ROUND (MTL.actual_cost, 2 )) amt
from mtl_material_transactions MTL
where MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )
and MTL.ORGANIZATION_ID = 1155
and MTL.TRANSACTION_SOURCE_ID = 48825
group by MTL.ORGANIZATION_ID,
MTL.TRANSACTION_SOURCE_ID,
MTL.OPERATION_SEQ_NUM,
MTL.INVENTORY_ITEM_ID) CST
WHERE WOP.WIP_ENTITY_ID = BB.WIP_ENTITY_ID
and BB.PRIMARY_ITEM_ID = CC.INVENTORY_ITEM_ID
and BB.ORGANIZATION_ID = CC.ORGANIZATION_ID
and WOP.INVENTORY_ITEM_ID = DD.INVENTORY_ITEM_ID
and WOP.ORGANIZATION_ID = DD.ORGANIZATION_ID
and WOP.ORGANIZATION_ID = CST.orgID
and WOP.WIP_ENTITY_ID = CST.wipID
and WOP.OPERATION_SEQ_NUM = CST.oprID
and WOP.INVENTORY_ITEM_ID = CST.itemID
and WOP.ORGANIZATION_ID = 1155
and BB.WIP_ENTITY_NAME = 'XJ39562' ;
 
-- 离散作业任务子查询 0201——— 作业资源报工明细表
SELECT WTA.ORGANIZATION_ID 组织代码 ,
WTA.TRANSACTION_ID 交易代码 ,
WTA.REFERENCE_ACCOUNT 参考科目 ,
WTA.TRANSACTION_DATE 报工日期 ,
WTA.WIP_ENTITY_ID 任务令内码 ,
WTA.ACCOUNTING_LINE_TYPE 会计栏类型 ,
WTA.BASE_TRANSACTION_VALUE 费用额 ,
WTA.CONTRA_SET_ID 反方集代码 ,
WTA.PRIMARY_QUANTITY 基本数量 ,
WTA.RATE_OR_AMOUNT 率或金额 ,
WTA.BASIS_TYPE 基本类型 ,
WTA.RESOURCE_ID 资源代码 ,
WTA.COST_ELEMENT_ID 成本要素 ID,
WTA.ACCOUNTING_LINE_TYPE 成本类型 ID,
WTA.OVERHEAD_BASIS_FACTOR 费用因子 ,
WTA.BASIS_RESOURCE_ID 基本资源 ID,
WTA.CREATED_BY 录入人 ID,
DD.USER_NAME 用户名称 ,
EE.FULL_NAME 用户姓名
FROM wip_transaction_accounts WTA, FND_USER DD, per_people_f EE
WHERE WTA.CREATED_BY = DD.USER_ID
and DD.EMPLOYEE_ID = EE.PERSON_ID
and WTA.BASE_TRANSACTION_VALUE <> 0
and WTA.ORGANIZATION_ID = 1155
and WTA.WIP_ENTITY_ID = 48839 ;
-- 成本类型 ID ACCOUNTING_LINE_TYPE
SELECT * FROM MFG_LOOKUPS ML
WHERE ML.LOOKUP_TYPE LIKE 'CST_ACCOUNTING_LINE_TYPE'
ORDER BY ML.LOOKUP_CODE;
-- 成本要素 ID COST_ELEMENT_ID
--( 待补充 --------------------------------------------------------------------------?)
 
-- 统计人工费与制造费 ( 不单独应用 )
SELECT ORGANIZATION_ID, WIP_ENTITY_ID, SUM (HR_FEE) HR_FEE, SUM (MD_FEE) MD_FEE
FROM ( Select WTA.ORGANIZATION_ID,
WTA.WIP_ENTITY_ID,
decode (COST_ELEMENT_ID, 3 , WTA.BASE_TRANSACTION_VALUE, 0 ) HR_FEE,
decode (COST_ELEMENT_ID, 5 , WTA.BASE_TRANSACTION_VALUE, 0 ) MD_FEE
from WIP_TRANSACTION_ACCOUNTS WTA
where WTA.ACCOUNTING_LINE_TYPE = 7
and WTA.BASE_TRANSACTION_VALUE <> 0 ) WTA_COST
WHERE WTA_COST.ORGANIZATION_ID = 1155
AND WTA_COST.WIP_ENTITY_ID = '48839'
GROUP BY WTA_COST.ORGANIZATION_ID,WTA_COST.WIP_ENTITY_ID;
 
-- 工单进度及费用信息综合查询 ( 未下达及下达零发料和报工的看不到 )
select WE.WIP_ENTITY_NAME 任务名称 ,
MSI.SEGMENT1 物料 ,
MSI.DESCRIPTION 物料描述 ,
MSI.PRIMARY_UNIT_OF_MEASURE 单位 ,
WDJ.SCHEDULED_START_DATE 计划开始时间 ,
WDJ.SCHEDULED_COMPLETION_DATE 计划完成时间 ,
WDJ.START_QUANTITY 工单数量 ,
WDJ.QUANTITY_COMPLETED 完成数量 ,
WDJ.DATE_RELEASED 实际开始时间 ,
WDJ.DATE_COMPLETED 时间完成时间 ,
WDJ.DESCRIPTION 工单备注 ,
PP.SEGMENT1 项目号 ,
PP.DESCRIPTION 项目描述 ,
PT.TASK_NUMBER 任务号 ,
PT.DESCRIPTION 任务描述 ,
WO.COUNT_OPER 工序数 ,
WO1.OPERATION_SEQ_NUM 当前工序 ,
WO1.DESCRIPTION 当前工序描述 ,
MTA.MT_FEE 材料费 ,
WCT.HR_FEE 人工费 ,
WCT.MD_FEE 制造费 ,
WE.WIP_ENTITY_ID,
WE.ORGANIZATION_ID,
WDJ.PRIMARY_ITEM_ID,
WDJ.PROJECT_ID,
WDJ.TASK_ID
from WIP_ENTITIES WE,
WIP_OPERATIONS WO1,
WIP_DISCRETE_JOBS WDJ,
MTL_SYSTEM_ITEMS_B MSI,
PA_PROJECTS_ALL PP,
PA_TASKS PT,
( select WDJ.ORGANIZATION_ID,
WDJ.WIP_ENTITY_ID,
COUNT ( 1 ) COUNT_OPER,
max ( decode (wo.quantity_completed, 1 , wo.operation_seq_num, 10 )) OPER
from WIP_DISCRETE_JOBS WDJ, WIP_OPERATIONS WO
where WDJ.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
group by WDJ.ORGANIZATION_ID, WDJ.WIP_ENTITY_ID) WO, -- 工序进度
( select MTL.ORGANIZATION_ID,
MTL.TRANSACTION_SOURCE_ID WIP_ENTITY_ID,
ABS ( SUM (MTL.TRANSACTION_QUANTITY * MTL.actual_cost)) MT_FEE
from mtl_material_transactions MTL
where MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )
group by MTL.ORGANIZATION_ID, MTL.TRANSACTION_SOURCE_ID) MTA, -- 材料费
( select WTA_COST.ORGANIZATION_ID,
WTA_COST.WIP_ENTITY_ID,
SUM (WTA_COST.HR_FEE1) HR_FEE,
SUM (WTA_COST.MD_FEE1) MD_FEE
from ( select WTA.ORGANIZATION_ID,
WTA.WIP_ENTITY_ID,
decode (COST_ELEMENT_ID,
3 ,
WTA.BASE_TRANSACTION_VALUE,
0 ) HR_FEE1,
decode (COST_ELEMENT_ID,
5 ,
WTA.BASE_TRANSACTION_VALUE,
0 ) MD_FEE1
from WIP_TRANSACTION_ACCOUNTS WTA
where WTA.ACCOUNTING_LINE_TYPE = 7
and WTA.BASE_TRANSACTION_VALUE <> 0 ) WTA_COST
group by WTA_COST.ORGANIZATION_ID, WTA_COST.WIP_ENTITY_ID) WCT -- 人工与制造
WHERE 1 = 1
AND WE.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
AND WE.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
AND WDJ.ORGANIZATION_ID = MSI.ORGANIZATION_ID
AND WDJ.PRIMARY_ITEM_ID = MSI.INVENTORY_ITEM_ID
AND WE.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
AND WO1.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
AND WO.OPER = WO1.OPERATION_SEQ_NUM
AND WE.ORGANIZATION_ID = MTA.ORGANIZATION_ID
AND WE.WIP_ENTITY_ID = MTA.WIP_ENTITY_ID(+)
AND WE.ORGANIZATION_ID = WCT.ORGANIZATION_ID
AND WE.WIP_ENTITY_ID = WCT.WIP_ENTITY_ID(+)
AND WDJ.PROJECT_ID = PP.PROJECT_ID(+)
AND WDJ.TASK_ID = PT.TASK_ID(+)
and we.organization_id = 1155
and we.wip_entity_id = '48825' ;
 
-- 工单进度及费用信息综合查询 ( 不论是否下达和发料都能看到 )
SELECT WDJ.WIP_ENTITY_ID 任务令 ID,
WE.WIP_ENTITY_NAME 任务名称 ,
WDJ.ORGANIZATION_ID 组织 ID,
WDJ.STATUS_TYPE 状态 ,
WDJ.PRIMARY_ITEM_ID 装配件 ID,
MSI.SEGMENT1 物料编码 ,
MSI.DESCRIPTION 物料说明 ,
WDJ.FIRM_PLANNED_FLAG 任务类型 ,
WDJ.JOB_TYPE 作业类型 ,
WDJ.WIP_SUPPLY_TYPE 供应类型 ,
WDJ.CLASS_CODE 任务类别 ,
WDJ.SCHEDULED_START_DATE 起始时间 ,
WDJ.DATE_RELEASED 下达时间 ,
WDJ.DATE_COMPLETED 完工时间 ,
WDJ.DATE_CLOSED 关闭时间 ,
WDJ.START_QUANTITY 计划数 ,
WDJ.QUANTITY_COMPLETED 完工数 ,
WDJ.QUANTITY_SCRAPPED 报废数 ,
WDJ.NET_QUANTITY MRP 净值 ,
WDJ.DESCRIPTION 工单备注 ,
WDJ.COMPLETION_SUBINVENTORY 接收子库 ,
WDJ.COMPLETION_LOCATOR_ID 货位 ID,
WDJ.PROJECT_ID 项目 ID,
WDJ.TASK_ID 项目任务 ID,
PP.SEGMENT1 项目号 ,
PP.DESCRIPTION 项目描述 ,
PT.TASK_NUMBER 任务号 ,
PT.DESCRIPTION 任务描述 ,
WPF.COUNT_OPER 工序数 ,
WPF.CUR_OPER 当前工序 ,
WPF.CUR_OPERNAME 工序名 ,
WPF.MT_FEE 材料费 ,
WPF.HR_FEE 人工费 ,
WPF.MD_FEE 制造费
FROM wip_discrete_jobs WDJ,
wip.wip_entities WE,
mtl_system_items MSI,
PA_PROJECTS_ALL PP,
PA_TASKS PT,
( select WDJ1.WIP_ENTITY_ID,
WDJ1.ORGANIZATION_ID,
WO.COUNT_OPER,
WO1.OPERATION_SEQ_NUM CUR_OPER,
WO1.DESCRIPTION CUR_OPERNAME,
MTA.MT_FEE,
WCT.HR_FEE,
WCT.MD_FEE
from WIP_OPERATIONS WO1,
WIP_DISCRETE_JOBS WDJ1,
( select WDJ.ORGANIZATION_ID,
WDJ.WIP_ENTITY_ID,
COUNT ( 1 ) COUNT_OPER,
max ( decode (wo.quantity_completed,
1 ,
wo.operation_seq_num,
10 )) OPER
from WIP_DISCRETE_JOBS WDJ, WIP_OPERATIONS WO
where WDJ.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
group by WDJ.ORGANIZATION_ID, WDJ.WIP_ENTITY_ID) WO, -- 工序进度
( select MTL.ORGANIZATION_ID,
MTL.TRANSACTION_SOURCE_ID WIP_ENTITY_ID,
ABS ( SUM (MTL.TRANSACTION_QUANTITY * MTL.actual_cost)) MT_FEE
from mtl_material_transactions MTL
where MTL.Transaction_Type_Id in ( 35 , 38 , 43 , 48 )
group by MTL.ORGANIZATION_ID, MTL.TRANSACTION_SOURCE_ID) MTA, -- 材料费
( select WTA_COST.ORGANIZATION_ID,
WTA_COST.WIP_ENTITY_ID,
SUM (WTA_COST.HR_FEE1) HR_FEE,
SUM (WTA_COST.MD_FEE1) MD_FEE
from ( select WTA.ORGANIZATION_ID,
WTA.WIP_ENTITY_ID,
decode (COST_ELEMENT_ID,
3 ,
WTA.BASE_TRANSACTION_VALUE,
0 ) HR_FEE1,
decode (COST_ELEMENT_ID,
5 ,
WTA.BASE_TRANSACTION_VALUE,
0 ) MD_FEE1
from WIP_TRANSACTION_ACCOUNTS WTA
where WTA.ACCOUNTING_LINE_TYPE = 7
and WTA.BASE_TRANSACTION_VALUE <> 0 ) WTA_COST
group by WTA_COST.ORGANIZATION_ID, WTA_COST.WIP_ENTITY_ID) WCT -- 人工与制造
WHERE 1 = 1
AND WDJ1.WIP_ENTITY_ID = WO.WIP_ENTITY_ID(+)
AND WO1.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
AND WO.OPER = WO1.OPERATION_SEQ_NUM
AND WDJ1.ORGANIZATION_ID = MTA.ORGANIZATION_ID
AND WDJ1.WIP_ENTITY_ID = MTA.WIP_ENTITY_ID(+)
AND WDJ1.ORGANIZATION_ID = WCT.ORGANIZATION_ID
AND WDJ1.WIP_ENTITY_ID = WCT.WIP_ENTITY_ID(+)) WPF
WHERE WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
AND WDJ.ORGANIZATION_ID = WE.ORGANIZATION_ID
AND WDJ.PRIMARY_ITEM_ID = MSI.INVENTORY_ITEM_ID
AND WDJ.ORGANIZATION_ID = MSI.ORGANIZATION_ID
AND WDJ.PROJECT_ID = PP.PROJECT_ID(+)
AND WDJ.TASK_ID = PT.TASK_ID(+)
AND WDJ.ORGANIZATION_ID = WPF.ORGANIZATION_ID(+)
AND WDJ.WIP_ENTITY_ID = WPF.WIP_ENTITY_ID(+)
AND WDJ.organization_id = 1155
and PP.SEGMENT1 = '07D9202' ;
 
11. MRP相关查询 
 
12. 总账 GL
select * from gl_sets_of_books 总帐
select * from gl_code_combinations gcc where gcc.summary_flag='Y' 科目组合
select * from gl_balances 科目余额
select * from gl_je_batches 凭证批
select * from gl_je_headers 凭证头
select * from gl_je_lines 凭证行
select * from gl_je_categories 凭证分类
select * from gl_je_sources 凭证来源
select * from gl_summary_templates 科目汇总模板
select * from gl_account_hierarchies 科目汇总模板层次
13. 应收 AR 
select * from ar_batches_all 事务处理批
select * from ra_customer_trx_all 发票头
select * from ra_customer_trx_lines_all 发票行
select * from ra_cust_trx_line_gl_dist_all 发票分配
select * from ar_cash_receipts_all 收款
select * from ar_receivable_applications_all 核销
select * from ar_payment_schedules_all 发票调整
select * from ar_adjustments_all 会计分录
select * from ar_distributions_all 付款计划
14. 应付 AP
select * from ap_invoices_all 发票头
select * from ap_invoice_distributions_all 发票行
select * from ap_payment_schedules_all 付款计划
select * from ap_check_stocks_all 单据
select * from ap_checks_all 付款
select * from ap_bank_branches 银行
select * from ap_bank_accounts_all 银行帐号
select * from ap_invoice_payments_all 核销
 
15. 应用、值集、弹性域 
--fnd
select * from fnd_application
select * from fnd_application_tl where application_id= 101
select * from fnd_application_vl where application_id = 101
-- 值集
select * from fnd_flex_value_sets
select * from fnd_flex_values
select * from fnd_flex_values_vl
-- 弹性域
select * from fnd_id_flexs
select * from fnd_id_flex_structures where id_flex_code= 'GL#'
select * from fnd_id_flex_segments where id_flex_code= 'GL#' and id_flex_num= 50671
 
select * from fnd_profile_options_vl
select * from fnd_concurrent_programs 程序表
select * from fnd_concurrent_requests 请求表
select * from fnd_concurrent_processes 进程表
16. 许继配送管理相关表 
--- 为了实现系统内方便的配送发货模式而开发
-- 配送关系 （以供应处角度 ORGANIZATION_ID = 142 ）
SELECT AA.CUSTOMER_RELATION_ID 配送关系 ID,
AA.ORGANIZATION_ID 组织 ID,
AA.CUST_ACCOUNT_ID 客户 ID,
CC.PARTY_NAME 客户名称 ,
AA.CUST_ACCT_SITE_ID 配送地 ID,
DD.LOCATION 客户地点 ,
DD.STATUS A 有效 ,
AA.DELIVERY_BY_SO_FLAG 源于 CO,
AA.OUTBOUND_TRX_TYPE_ID 出库类型 ,
AA.OUTBOUND_RET_TRX_TYPE_ID 出库 R 类型 ,
AA.OUTBOUND_COST_CCID 出库账户 ID,
EE.concatenated_segments 出库账户 ,
AA.CUST_ORG_ID 客户库存组织 ID,
AA.INBOUND_TRX_TYPE_ID 入库类型 ,
AA.INBOUND_RET_TRX_TYPE_ID 入库 R 类型 ,
AA.INBOUND_CONFIRM_FLAG 入库确认 ,
AA.INBOUND_COST_CCID 入库账户 ID,
FF.concatenated_segments 入库账户 ,
AA.MANAGE_CHARGE 加价率 ,
AA.SETTLE_MODE 结算模式 ,
AA.INBOUND_SUBIN_CODE 接收子仓库 ,
AA.OUTBOUND_SUBIN_CODE 配送子库存 ,
AA.ATTRIBUTE1 直接生产发料 ,
AA.Creation_Date 创建日期 ,
AA.CREATED_BY 创建者 ,
AA.LAST_UPDATED_BY 更新者 ,
AA.LAST_UPDATE_DATE 更新日期
FROM CUX_INV_CUSTOMER_RELATION_ALL AA,
hz_cust_accounts BB,
hz_parties CC,
HZ_CUST_SITE_USES_ALL DD,
gl_code_combinations_kfv EE,
gl_code_combinations_kfv FF
WHERE AA.ORGANIZATION_ID = 142
AND AA.CUST_ACCOUNT_ID = BB.CUST_ACCOUNT_ID
AND BB.PARTY_ID = CC.PARTY_ID
AND AA.Cust_Acct_Site_Id = DD.Site_Use_Id
AND DD.STATUS = 'A'
AND AA.OUTBOUND_COST_CCID = EE.code_combination_id
AND AA.INBOUND_COST_CCID = FF.code_combination_id
and CC.PARTY_NAME = ' 许继电气电网保护自动化公司 ' ;
-- 配送单头
SELECT AA.DN_HEADER_ID 配送单 ID,
AA.DN_NUMBER 配送单编号 ,
AA.DN_STATUS_CODE 状态 ,
AA.CUST_ACCOUNT_ID 客户 ID,
CC.PARTY_NAME 客户名称 ,
AA.CUST_ACCT_SITE_ID 配送地址 ID,
DD.LOCATION 客户地点 ,
AA.DELIVERY_ORG_ID 配送方组织 ID,
AA.CUST_ORG_ID 客户组织 ID,
AA.MANAGE_CHARGE 费率 ,
AA.INBOUND_CONFIRM_FLAG 入库确认否 ,
AA.SO_HEADER_ID 销售订单 ID,
EE.ORDER_NUMBER 销售订单 ,
EE.CUST_PO_NUMBER 客户 PO,
ee.attribute1,
ee.attribute2,
AA.PROCESS_FLAG,
AA.COMMENTS 配送单说明
FROM CUX_INV_DN_HEADERS_ALL AA, hz_cust_accounts BB, hz_parties CC, HZ_CUST_SITE_USES_ALL DD,OE_ORDER_HEADERS_ALL EE
WHERE AA.DELIVERY_ORG_ID = 142
AND AA.CUST_ACCOUNT_ID = BB.CUST_ACCOUNT_ID
AND BB.PARTY_ID = CC.PARTY_ID
AND AA.Cust_Acct_Site_Id = DD.Site_Use_Id
AND DD.STATUS = 'A'
AND AA.SO_HEADER_ID = EE.HEADER_ID
AND AA.DN_NUMBER = '14780016022' ;
-- 配送单明细
SELECT AA.DN_HEADER_ID,
AA.DN_LINE_ID,
AA.SO_LINE_ID,
LL.LINE_NUMBER SO 行号 ,
AA.INVENTORY_ITEM_ID 物料 ID,
CC.SEGMENT1 物料编码 ,
CC.DESCRIPTION 物料说明 ,
AA.OUTBOUND_SUBIN_CODE 发出仓 ,
AA.OUTBOUND_LOCATOR_ID 发出货位 ,
AA.REQUIRE_DATE 需求日期 ,
AA.REQUIRE_QTY 需求数 ,
AA.OUTBOUND_QTY 已出库 ,
AA.INBOUND_QTY 已接收 ,
AA.ATTRIBUTE1 最近确认接收数 ,
AA.INBOUND_SUBIN_CODE 入库仓 ,
AA.INBOUND_LOCATOR_ID 入库货位 ,
AA.RETURN_NO_RECEIVE_QTY 退回数 ,
AA.OUTING_QTY,
AA.INING_QTY,
AA.REQUEST_ID 最近打印请求 ID
FROM CUX_INV_DN_LINES_ALL AA, CUX_INV_DN_HEADERS_ALL BB,mtl_system_items CC,OE_ORDER_LINES_ALL LL
WHERE AA.DN_HEADER_ID = BB.DN_HEADER_ID
AND AA.INVENTORY_ITEM_ID = CC.INVENTORY_ITEM_ID
AND BB.DELIVERY_ORG_ID = CC.ORGANIZATION_ID
AND AA.SO_LINE_ID = LL.LINE_ID
AND BB.DN_NUMBER = '14780016022' ;
 
 
 
99-其他相关表 
1) 会计科目组合表 
-- 查询会计科目分段信息
select * from gl_code_combinations;
-- 查询会计科目组合信息
select * from gl_code_combinations_kfv;
2) 查询自定义的客户化相关表和视图 
-- 静态数据字典中的视图分为三类，它们分别由三个前缀够成： user_* 、 all_* 、 dba_*
-- user_* 该视图存储了关于当前用户所拥有的对象的信息。（即所有在该用户模式下的对象）
-- all_* 该视图存储了当前用户能够访问的对象的信息。（与 user_* 相比， all_* 并不需要拥有该对象，只需要具有访问该对象的权限即可）
-- dba_* 该视图存储了数据库中所有对象的信息。（前提是当前用户具有访问这些数据库的权限，一般来说必须具有管理员权限
-- 查询该用户拥有哪些表
select * from user_tables where table_name like 'CUX%' ;
-- 查询该用户拥有哪些视图
select * from user_views where view_name like 'CUX%' ;
-- 查询该用户拥有哪些索引
select * from user_indexes;
3) 查询物料处理记录 
说明： mtl_material_transactions 这个表记录了所有涉及仓库收发的物料交易记录，包括：采购、 WIP 、订单、杂项等多种处理模式的内容。
-- 举例： 查询某用户在电网的账户别名发放清单
select AA.TRANSACTION_ID 交易代码 ,
AA.INVENTORY_ITEM_ID 项目内码 ,
CC.SEGMENT1 物料编码 ,
CC.DESCRIPTION 物料说明 ,
AA.ORGANIZATION_ID 组织代码 ,
AA.SUBINVENTORY_CODE 子库名称 ,
AA.TRANSACTION_TYPE_ID 类型 ID,
BB.TRANSACTION_TYPE_NAME 类型名称 ,
AA.TRANSACTION_QUANTITY 数量 ,
AA.TRANSACTION_UOM 单位 ,
AA.TRANSACTION_DATE 交易日期 ,
AA.TRANSACTION_REFERENCE 交易参考 ,
AA.TRANSACTION_SOURCE_ID 参考源 ID,
AA.DEPARTMENT_ID 部门 ID,
AA.OPERATION_SEQ_NUM 工序号 ,
ROUND (AA.Actual_Cost, 2 ) 实际成本 ,
ROUND (AA.Transaction_Cost, 2 ) 处理成本 ,
ROUND (AA.PRIOR_COST, 2 ) 旧成本 ,
ROUND (AA.NEW_COST, 2 ) 新成本 ,
ROUND (AA.VARIANCE_AMOUNT, 2 ) 差异金额 ,
AA.TRANSACTION_QUANTITY * ROUND (AA.PRIOR_COST, 2 ) 交易金额 ,
DD.USER_NAME 用户名称 ,
EE.FULL_NAME 用户姓名 ,
AA.ATTRIBUTE1 弹性域人名 ,
AA.ATTRIBUTE15 弹性域备注
from mtl_material_transactions AA ,
mtl_transaction_types BB,
mtl_system_items CC,
FND_USER DD,
per_people_f EE
where AA.TRANSACTION_TYPE_ID = BB.TRANSACTION_TYPE_ID and
AA.CREATED_BY = DD.USER_ID and
AA.INVENTORY_ITEM_ID = CC.INVENTORY_ITEM_ID and
AA.ORGANIZATION_ID = CC.ORGANIZATION_ID and
DD.EMPLOYEE_ID = EE.PERSON_ID and
AA.ORGANIZATION_ID = 1155 AND
CC.SEGMENT1= '07D9202.92742' and
AA.TRANSACTION_DATE >= TO_DATE( '2011-01-29 00:00:00' , 'YYYY-MM-DD HH24:MI:SS' )
order by aa.TRANSACTION_ID;
/* 物料处理记录 mtl_material_transactions 表，类型与成本说明：
-- 杂项收 TRANSACTION_TYPE_ID = 41 录入价格优先， =Actual_Cost ，移动平均 TRANSACTION_QUANTITY > 0 , 调整类似
注： 1 ）如果再接收界面录入了价格，以录入价格计入 Actual_Cost ，进行移动平均
2 ）如果没有录入价格，字段 NULL ，则系统会以当前成本接收，计入 Actual_Cost
-- 杂项发 TRANSACTION_TYPE_ID = 31 以出 =Actual_Cost ， TRANSACTION_QUANTITY < 0 , 调整类似
-- 采购收 TRANSACTION_TYPE_ID = 18 以 入 =Actual_Cost ，移动平均 TRANSACTION_QUANTITY > 0
-- 采购退 TRANSACTION_TYPE_ID = 36 以 出 =Actual_Cost ， TRANSACTION_QUANTITY < 0
注： 1) 系统按采购成本退货和扣除库存金额，不考虑已消耗状况；
2) 如果库存金额够扣除，则扣除后重新计算出一个新成本；
3 ）如果库存金额不够扣除，则扣除全部金额，就会出现有库存量而单位成本 =0 的物资，不够扣的部分计入字段 VARIANCE_AMOUNT 。
-- 作业发 TRANSACTION_TYPE_ID = 35 以当前成本出， =Actual_Cost ， TRANSACTION_QUANTITY < 0 ，特定组件发料类似
-- 作业退 TRANSACTION_TYPE_ID = 43 以当前成本入， =Actual_Cost ，不移动平均 TRANSACTION_QUANTITY > 0
-- 配送出 TRANSACTION_TYPE_ID = 100 以当前成本出， =Actual_Cost ， TRANSACTION_QUANTITY < 0
-- 配送退 TRANSACTION_TYPE_ID = 101 以配送价入 ， =Actual_Cost ，移动平均 TRANSACTION_QUANTITY > 0
-- 销售发 TRANSACTION_TYPE_ID = 33 以当前成本出， =Actual_Cost ， TRANSACTION_QUANTITY < 0
-- 销售退 TRANSACTION_TYPE_ID = 15 以当前成本入， =Actual_Cost ， TRANSACTION_QUANTITY > 0
*/
-- 物料处理记录类型列表
select bb.transaction_type_id 类型 ID,
bb.transaction_type_name 别名 ,
bb.description 说明
from mtl_transaction_types BB
order by bb.transaction_type_id
-- 交易来源类型列表
SELECT *
FROM mtl_txn_source_types
-- 交易原因代码表
SELECT REASON_ID 原因代码 , REASON_NAME 名称 , DESCRIPTION 描述
FROM inv.mtl_transaction_reasons;

工艺路线



SELECT MSIB.SEGMENT1,MSIB.DESCRIPTION,BORV.resource_code,BR.DESCRIPTION
  FROM BOM_OPERATIONAL_ROUTINGS_V BOR,
       BOM_OPERATION_SEQUENCES_V  BOS,
       BOM_OPERATION_RESOURCES_V  BORV,
       BOM_RESOURCES              BR,MTL_SYSTEM_ITEMS_B MSIB
 WHERE BOR.ORGANIZATION_ID = 86
   AND BR.ORGANIZATION_ID = 86
   AND BOR.ASSEMBLY_ITEM_ID = MSIB.INVENTORY_ITEM_ID
   AND MSIB.ORGANIZATION_ID=86
   AND BOR.ROUTING_SEQUENCE_ID = BOS.ROUTING_SEQUENCE_ID
   AND BOS.OPERATION_SEQUENCE_ID = BORV.OPERATION_SEQUENCE_ID
   AND BR.RESOURCE_ID = BORV.RESOURCE_ID
   AND BOS.OPERATION_SEQ_NUM =
       (SELECT MAX(BOS1.OPERATION_SEQ_NUM)
          FROM BOM_OPERATION_SEQUENCES_V  BOS1,
               BOM_OPERATIONAL_ROUTINGS_V BOR1
         WHERE BOS1.ROUTING_SEQUENCE_ID = BOR1.ROUTING_SEQUENCE_ID
           AND BOR1.ROUTING_SEQUENCE_ID = BOR.ROUTING_SEQUENCE_ID
           AND BOR1.ALTERNATE_ROUTING_DESIGNATOR IS NULL)
   AND BOR.ALTERNATE_ROUTING_DESIGNATOR IS NULL
   AND NVL(BR.ATTRIBUTE15, 'N') = 'Y'
================资产=========
fa.fa_additions_b 存储资产基础信息
fa.fa_books 存储资产成本及成本变动信息
fa.fa_transaction_headers 存储资产事务处理历史记录(增加、转移、调整、报废、重建等)
fa.fa_distribution_history  存储资产分配历史记录(员工、费用帐户、地点)
fa.fa_deprn_summary 存储资产折旧汇总信息
fa.fa_deprn_detail  存储资产折旧明细信息
fa.fa_retirements 存储资产报废信息
fa.fa_book_controls 存储资产账簿
fa.fa_categories_b  存储资产类别
fa.fa_categories_tl 存储资产类别说明
fa.fa_category_books  存储资产类别的总帐帐户
fa.fa_category_book_defaults  存储资产类别的默认折旧规则
fa.fa_deprn_periods 存储资产期间
 



------------资产明细--主查询--
select 
fa.asset_id, --资产编号
fa.creation_date, --资产创建时间
fdp.period_name, --期间
fa.asset_number, --资产编码
fa.tag_number, --资产标签
fa.manufacturer_name, --制造商
fdh.book_type_code, --资产帐簿
fa.model_number, --型号
fa.current_units, --数量
fav.description, --资产描述
FDH.CODE_COMBINATION_ID CODE_COMBINATION_ID,
FDH.location_id, --资产地点ID
FA.ASSET_CATEGORY_ID category_id, --资产类别ID
NVL(papf.last_name, '无') last_name, --资产保管员
NVL(papf.employee_number, '无') employee_number, --员工编码
fb.life_in_months / 12 life_year, --------使用年限---new
fa.current_units units, ---数量---new
fb.unit_of_measure uom, -----------计量单位----new
fb.date_placed_in_service,----启用日期------new
fdp.period_name
FROM 
  fa_deprn_periods        fdp,-------------------------资产折旧周期
  fa_additions_b          fa,---------------------------资产详细资料
  fa_additions_tl         fav,---------------------------资产语言种类
  fa_distribution_history fdh,----------------------------资产分配明细
  per_all_people_f        papf,
  fa_books                fb ----new
WHERE   
  fdh.book_type_code = 'FA BOOK 230001' -------------传入参数'SHMC_FA_6810'
  AND fa.asset_id = fdh.asset_id
  AND fa.asset_id = fb.asset_id ---------new
  AND fb.book_type_code = fdh.book_type_code ---new
  AND fdp.period_close_date between fb.date_effective  AND nvl(fb.date_ineffective, sysdate) --new
  AND fdh.distribution_id = (SELECT MAX(DH2.DISTRIBUTION_ID) FROM FA_DISTRIBUTION_HISTORY DH2  
     WHERE DH2.ASSET_ID = FA.ASSET_ID AND dh2.book_type_code = fdh.book_type_code
        AND DH2.DATE_EFFECTIVE <= NVL(FDP.PERIOD_CLOSE_DATE, SYSDATE))
  AND fdh.book_type_code = fdp.book_type_code
  AND fa.asset_id = fav.asset_id
  AND fav.language = 'ZHS'
  AND fdp.period_name = '2014-07' ----------------传入参数'MAY-08'
  AND fdh.assigned_to = papf.person_id(+)
  AND nvl(papf.effective_end_date, sysdate + 1) > sysdate
AR 应收
应收事务处理相关表
SELECT * FROM ar.ar_batches_all;                  --事务处理批
SELECT * FROM ar.ra_customer_trx_all;            --应收事务头/发票头            
SELECT * FROM ra.ra_customer_trx_lines_all;     --应收事务行项目/发票行          
SELECT * FROM ra.ra_cust_trx_line_gl_dist_all;--应收事务分配行/发票分配            
SELECT * FROM ar.ar_payment_schedules_all;      --收款计划/发票调整          
收款相关表
SELECT * FROM ar.ar_cash_receipts_all;             --收款表            
SELECT * FROM ar.ar_cash_receipt_history_all;    --收款历史表            
SELECT * FROM ar.ar_distributions_all;             --收款分配表/付款计划            
SELECT * FROM ar.ar_misc_cash_distributions_all;--杂项历史记录分配表            
SELECT * FROM ar.ar_receivable_applications_all;--收款核销表
Subledger accounting 子分类账
SELECT * FROM ar_adjustments_all;  --会计分录
SELECT * FROM xla.xla_events;       --会计事件表            
SELECT * FROM xla.xla_transaction_entites; --事务处理表            
SELECT * FROM xla.xla_ae_headers;   --子分类帐日记账头            
SELECT * FROM xla.xla_ae_lines;      --子分类帐日记账行            
SELECT * FROM xla.xla_distributions_link;  --子分类帐日记帐行关联表            
SELECT * FROM xla.xla_events_error;         --会计事件错误提示表 
接口相关表 应收临时表          
SELECT * FROM ar.ra_interface_lines_all;              --应收接口行表          
SELECT * FROM ar.ra_interface_distributions_all;  --应收接口分配行表          

接口相关表 收款临时表          
SELECT * FROM ar. ar_interim_cash_receipts_all;   --收款标准接口  
主数据相关表/视图
SELECT * FROM apps.po_vendors;             --客户           
SELECT * FROM apps.po_vendor_sites_all;     --客户地点            
SELECT * FROM ap.ap_bank_branches_all;        --银行        
SELECT * FROM ap.ap_bank_accounts_all;        --银行账户          
SELECT * FROM ap.ap_bank_account_uses_all; --银行账户使用表        
SELECT * FROM apps.gl_period_statuses_v;    --期间，取期间视图      
SELECT * FROM apps.hr_operating_units;        --业务实体视图            
税相关表
SELECT * FROM zx_lines_det_factors; --税决定因素表           
SELECT * FROM zx_lines; --税行
注：应收模块税仅含这个表。
ra_customer_trx_all 应收发票   
发票编号：customer_trx _id
客户收单方编号：bill_to_site_use_id
销售员编号：primary_sales_id
reference是Oracle提供的外部编号输入框，但是由于版本问题和长度(<=30)，不建议用户使用，如果要使用外部编号，请使用说明性弹性域。
ra_customer_trx_lines_all 应收发票行、明细信息
行号：line_id
物料编号：inventory_item_id –-可以为空，比如非物料的服务
开票数量：quantity_invoice
行类型：line_type –-发票行一般有两种类型（item一般/tax税）
本行金额：extend_price
注意：税行是隐藏行，所以至少会有两行
ar_cash_receipts_all 收款情况表
 还包含了非收款信息
内部code：cash_receipt_id
收款号：receipt_number
收款日期：receipt_date
总额：amount
类型：receipt_type --现金/杂项（Cash/Misc）
本位币计算金额：functional_amount

ar_receivable_applications_all核销关系表
UI上为receipts，核销关系不是一一对应，也不是一次核销100%，UI上右下方的Application按钮
发票编号：applied_customer_trx_id
发票行编号：applied_customer_trx_line_id
状态：status –-app表示核销；unapp表示未核销
匹配金额：amount_applied  

注意：红冲收款报表时间跨月的问题；必须联查ar_cash_receipts_all和ap_cash_receipt_history_all。
=======
====收款方法获取SQL=====
select  rm.name,
        rm.receipt_method_id,
        ba.bank_acct_use_id ,
        cba.bank_account_num,
        ce_bank_and_account_util.get_masked_bank_acct_num(cba.bank_account_id),
        bb.bank_name,
        bb.bank_branch_name,
        bb.branch_party_id ,
        cba.currency_code,
        rc.creation_status,
        rc.name receipt_class_name,
        rc.remit_flag,
        hr.name  ou_name,
        rc.notes_receivable,
        nvl(rma.override_remit_account_flag,'Y') ,
        rc.creation_method_code,
        rm.payment_type_code,
        cba.receipt_multi_currency_flag receipt_multi_currency_flag,
        rma.org_id ,
        cba.account_owner_org_id
from ar_receipt_methods rm,
     ar_receipt_classes rc,
     ar_lookups l,
     ce_bank_accounts cba,
     ce_bank_acct_uses_all ba,
     ce_bank_branches_v bb,
     ar_receipt_method_accounts_all rma ,
     hr_operating_units hr
where rm.receipt_class_id = rc.receipt_class_id
and  rma.org_id = ba.org_id
and  hr.organization_id = rma.org_id
and rc.creation_status = l.lookup_code
and l.lookup_type = 'RECEIPT_CREATION_STATUS'
and ((rc.creation_method_code = 'MANUAL')
      or (rc.creation_method_code = 'BR_REMIT')
      or (rc.creation_method_code = 'AUTOMATIC'
          and rc.remit_flag = 'Y'
          and rc.confirm_flag = 'N'))
and cba.account_classification = 'INTERNAL'
and cba.bank_branch_id = bb.branch_party_id
and rm.receipt_method_id = rma.receipt_method_id
and cba.bank_account_id = ba.bank_account_id
and cba.ar_use_allowed_flag = 'Y'
and NVL(ba.AR_USE_ENABLE_FLAG, 'N') = 'Y'
and rma.remit_bank_acct_use_id = ba.bank_acct_use_id
 
====打开期间===
Select   MAX (P.START_DATE)  INTO  l_g_date
        From Gl_Period_Statuses p, Fnd_Application_Vl a
       Where P.Application_Id = A.Application_Id
         And A.Application_Short_Name = 'AR'
         And P.Adjustment_Period_Flag = 'N'
         And P.Set_Of_Books_Id = fnd_profile.value('GL_SET_OF_BKS_ID')
         And P.Closing_Status = 'O'  ;
/
