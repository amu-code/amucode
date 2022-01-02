======================
linux shell 命令部分
========================
linux 常用命令：
VI 命令：
/pattern：从光标开始处向文件尾搜索pattern 
?pattern：从光标开始处向文件首搜索pattern 
n：在同一方向重复上一次搜索命令 
N：在反方向上重复上一次搜索命令 
：s/p1/p2/g：将当前行中所有p1均用p2替代 
：n1,n2s/p1/p2/g：将第n1至n2行中所有p1均用p2替代 
：g/p1/s//p2/g：将文件中所有p1均用p2替换
$:代表 最后一行
下命令将文中所有的字符串idiots替换成managers：
:1,$s/idiots/manages/g
3. 以下命令指定只在第5至第15行间进行替换:
:5,15s/dog/cat/g
整页翻页命令为：Ctrl + f 键   f 的英文全拼为：forward；
Ctrl + b 键  b 的英文全拼为：backWord；
翻半页命令为：Ctrl + d 键  d 的英文全拼为：down；
  Ctrl + u 键  u 的英文全拼为：up；
直接查看该脚本的最后一行：输入:$，然后回车；
在键盘按下大写G ；
在键盘按Shift + g；
直接查看该脚本的第一行：    
输入:0或:1，然后回车；
   在键盘按下小写gg；   
--awk 命令
awk是行处理器: 相比较屏幕处理的优点，在处理庞大文件时不会出现内存溢出或是处理缓慢的问题，通常用来格式化文本信息
awk处理过程: 依次对每一行进行处理，然后输出

awk [-F|-f|-v] ‘BEGIN{} //{command1; command2} END{}’ file
[-F|-f|-v]   大参数，-F指定分隔符，-f调用脚本，-v定义变量 var=value
'  '          引用代码块
BEGIN   初始化代码块，在对每一行进行处理之前，初始化代码，主要是引用全局变量，设置FS分隔符
//           匹配代码块，可以是字符串或正则表达式
{}           命令代码块，包含一条或多条命令
；          多条命令使用分号分隔
END      结尾代码块，在对每一行进行处理之后再执行的代码块，主要是进行最终计算或输出结尾摘要信息
----每个目录大小---
du -sh *
======================
linux end
========================
===============
FTP命令部分
==============
FTP连接命令
sftp -P 22 appltest@10.60.137.155
sftp -P 22 appldev@172.16.0.204
kaifa2018!
/u04/test/apps/apps_st/appl/cux/12.0.0/reports/ZHS
/u04/test/inst/apps/TEST_erptest/logs/appl/conc/out
 sftp -P 22 root@10.60.137.155
#!/bin/bash
#用户
USER=root
#密码
PASSWORD=123456
#本机所需下载到的目录名称
dir=abc01
cd ${dir}
#sftp目录(待下载文件目录)
dir=abc
#sftp的IP
IP=192.168.1.66
#端口
#PORT=22
lftp -u ${USER},${PASSWORD} sftp://${IP} << EOF
cd  ${dir}
mget -c *
by
EOF 
===============
FTP命令部分
==============
---------------------------------------------
 UE常用
---------------------------------------------
UE 常用：
Ctrl+F5 :转为小写
ALT+F5 :转为大写
----数字标
select to_char(8762128.98769,'FML9G999G999G999G999D0099') from dual

FM 去空格 L（￥） G分隔符 D小数点 0099 表示 最少2位小数 到第五进行四舍五入

结果：￥8,762,128.9877
--------------UE ---
回撤替换:^p


---------------------------------------------
 excel常用
---------------------------------------------
 透视表--
 选择区域--点击插入--选择透视表
 ----
 a列中查找b列的值，使用函数
 =if(countif(a:a,b1),"T","F");
 excle重复数据检查函数：
 =countif(A1:A10,A1)
 COUNTIF 函数语法具有以下两项参数：
1) Range：要进行计数的单元格范围，其中包括数字和名称、数组或包含数字的引用。空值和文本值将被忽略。
2) Criteria：判定条件，在计数范围内符合规定条件才进行计数。 
----vlookup-----
 Vlookup（lookup|_value,table_array,col_index_num,range_lookup）
vlookup函数参数说明如下：
lookup|_value：在表格或区域的第一列中要搜索的值。
table_array：包含数据的单元格区域，即要查找的范围。
col_index_num：参数中返回的搜寻值的列号。
range_lookup：逻辑值，指定希望Vlookup查找精确匹配值（0）还是近似值（1）。
-win---打开计算器命令
calc.exe
--------异常定义----

================
plsql部分 常用语句
================

---依赖--
       SELECT * from user_dependencies  ud WHERE ud.referenced_name='CUX_AR_BALANCE_RECLASS_INT'

        
e_exception  exception; --自定义异常
e_exception_1  exception;
pragma exception_init(e_exception_1,-20005); --自定义异常
raise e_exception_1;
raise_application_error('-20006','THE NUMBER CAN NOT equal to 6');  --自定义异常
exception
when e_exception_1 then
  l_err_msg:=sqlerrm;
  l_err_code:=sqlcode;
  dbms_output.put_line(l_err_code || ' '||l_err_msg ||'THE NUMBER CAN NOT equal to 7');
when e_exception then
  l_err_msg:=sqlerrm;
  l_err_code:=sqlcode;
  dbms_output.put_line(l_err_code || ' '||l_err_msg ||'THE NUMBER CAN NOT equal to 8');
when others then
 l_err_msg:=sqlerrm;
 l_err_code:=sqlcode;
 dbms_output.put_line(' error,  '||l_err_code || ' '||l_err_msg);
----数组使用----------
 DECLARE
  TYPE type_array IS VARRAY(3) OF VARCHAR2(10);---- 一维固定数据 3个元素
   v_array type_array:=type_array('abc','bcd','def');
  BEGIN
  FOR i IN 1..v_array.count LOOP
   dbms_output.put_line(v_array(i));
   END LOOP;
   END;

DECLARE
TYPE type_tab IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;------ 一维可变数组
v_tab type_tab;
BEGIN
    v_tab(1):='abc';
    v_tab(2):='bcd';
    v_tab(3):='cde';
FOR i IN 1..v_tab.count LOOP
dbms_output.put_line(v_tab(i));
END LOOP;
END;

-- 如果在定义类型type_tab时省略了INDEX BY BINARY_INTEGER，则必须用v_tab.extend语句“移动”行
DECLARE
TYPE type_tab IS TABLE OF VARCHAR2(10);
v_tab type_tab := type_tab();
BEGIN
    v_tab.extend;
v_tab(1):='abc';
    v_tab.extend;
v_tab(2):='bcd';
    v_tab.extend;
v_tab(3):='cde';
FOR i IN 1..v_tab.count LOOP
dbms_output.put_line(v_tab(i));
END LOOP;
END;

----多为数组----
yy表结构
/*ID INTEGER Y
NAME VARCHAR2(10) Y
CODE CHAR(3) Y*/

TYPE type_tab IS TABLE OF yy%ROWTYPE INDEX BY BINARY_INTEGER;
    v_tab type_tab;
BEGIN
    -- 向变量数组v_tab填充数据
    SELECT * BULK COLLECT INTO v_tab FROM yy;
 -- 循环提取所有行
FOR i IN 1..v_tab.count LOOP
        -- 每一行有三个数据分别打印
      dbms_output.put(v_tab(i).id||' ');
        dbms_output.put(v_tab(i).name||' ');
        dbms_output.put_line(v_tab(i).code||' ');
    END LOOP;
END;
-- 先定义record作为多维数组的类型
TYPE type_rec IS RECORD(ID INT ,CODE VARCHAR2(10) ,NAME CHAR(3));
TYPE type_tab IS TABLE OF type_rec INDEX BY BINARY_INTEGER;
v_tab type_tab;
=======end============
3.高效的游标循环
　　declare
　　cursor myemp_cur
　　is select * from myemp;
　　type myemp_tab is table of myemp%rowtype;
　　myemp_rd myemp_tab;
　　begin
　　 open myemp_cur;
　　 loop
　　 fetch myemp_cur bulk collect into myemp_rd limit 20;
　　 for i in 1..myemp_rd.count loop
　　  dbms_output.put_line('姓名：'||myemp_rd(i).ename);
　　 end loop;
　　 exit when myemp_cur%notfound;
　　 end loop;
　　end;

BULK COLLECT 子句会批量检索结果，即一次性将结果集绑定到一个集合变量中，并从SQL引擎发送到PL/SQL引擎。通常可以在SELECT INTO、
FETCH INTO以及RETURNING INTO子句中使用BULK COLLECT.
BULK COLLECT的限制
1、不能对使用字符串类型作键的关联数组使用BULK COLLECT 子句。
2、只能在服务器端的程序中使用BULK COLLECT，如果在客户端使用，就会产生一个不支持这个特性的错误。
3、BULK COLLECT INTO 的目标对象必须是集合类型。
4、复合目标(如对象类型)不能在RETURNING INTO 子句中使用。
5、如果有多个隐式的数据类型转换的情况存在，多重复合目标就不能在BULK COLLECT INTO 子句中使用。
6、如果有一个隐式的数据类型转换，复合目标的集合(如对象类型集合)就不能用于BULK COLLECTINTO 子句中。
===会话临时表    
Create Global Temporary Table Table_Name
(
Col1 Type1,
Col2 Type2
...
)
On Commit Preserve Rows;
-----日期转换
v_start_date   :=to_date(p_date, 'YYYY/MM/DD HH24:MI:SS');
v_end_date     :=to_date(p_date, 'YYYY/MM/DD HH24:MI:SS')+1-0.00001;
V_BEGIN_TIME   DATE := TO_DATE(P_PERIOD_NAME ||  '-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS');
V_END_TIME     DATE := LAST_DAY(TO_DATE(P_PERIOD_NAME ||  '-01 23:59:59', 'YYYY-MM-DD HH24:MI:SS'));                      
     -----获取当前59.59
 SELECT     TRUNC(SYSDATE) + 1 - 1 / (3600 * 24) FROM dual;
 -- 当前日期加25天
select sysdate, sysdate + numtodsinterval(25, 'day') as res from dual;   

-- 当前日期加2月
select sysdate, sysdate + numtoyminterval(2, 'month') as res from dual;
 
-- 当前日期加2年
select sysdate, sysdate + numtoyminterval(2, 'year') as res from dual;  

-----转换语言。
 EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_LANGUAGE=''SIMPLIFIED CHINESE''';
---同义词
CREATE SYNONYM apps.CUX_TEST_AM FOR cux.CUX_TEST_AM;
  select * from user_synonyms
 程序 - 逐级添加/删除汇总模板
Oracle序列创建和使用
CREATE SEQUENCE SEQ_DEMO 
INCREMENT BY 1 
START WITH 1 
NOMAXvalue 
NOCYCLE 
NOCACHE;

alter sequence mySeq maxValue 500
 drop sequence 序列名称
 
 -----表空间--
 SELECT a.tablespace_name "表空间名"
        ,total "表空间大小"
        ,free "表空间剩余大小"
        ,(total - free) "表空间使用大小"
        ,total / (1024 * 1024 * 1024) "表空间大小(G)"
        ,free / (1024 * 1024 * 1024) "表空间剩余大小(G)"
        ,(total - free) / (1024 * 1024 * 1024) "表空间使用大小(G)"
        ,round((total - free) / total, 4) * 100 "使用率 %"
 FROM   (SELECT tablespace_name
               ,SUM(bytes) free
         FROM   dba_free_space
         GROUP  BY tablespace_name) a
       ,(SELECT tablespace_name
               ,SUM(bytes) total
         FROM   dba_data_files
         GROUP  BY tablespace_name) b
 WHERE  a.tablespace_name = b.tablespace_name;
 
 
----oracle 锁-------
SELECT o.object_name,
       s.machine,
       s.sid,
       s.serial#
  FROM v$locked_object l,
       dba_objects     o,
       v$session       s
 WHERE l.object_id　 = 　o.object_id
   AND l.session_id = s.sid;
alter system kill session 'sid,serial#';

===================
ebs 开发部分
=================

/*注释新写法*/
  /*===============================================================
  *         Copyright (C) YILI Group All rights reserved
  * ===============================================================
  *    Program Name:XXX
  *    Author      :XX
  *    Date        :2020.6.2
  *    Purpose     :CUX.库存商品调整校验报表
  *    Parameters  :
  *    Update History
  *    Version    Date         Name            Description
  *    --------  ----------  ---------------  --------------------
  *     V1.0    2020.6.2       amu              Creation    
  *===============================================================*/
   函数和过程注释
/*===============================================================
* Purpose         :
*===============================================================*/
---初始化
BEGIN
   FND_GLOBAL.APPS_INITIALIZE(USER_ID => ,RESP_ID => ,RESP_APPL_ID => );
END;
--FORSM 注释
 /*==================================================
    --Description ：PRE-FORM触发器
    --Argument ： 
    --History：1.00  2017-09-06  ZHOUJIANSEN  Creation
   ==================================================*/
    
    
------异常处理

   EXCEPTION
          WHEN OTHERS THEN
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, SQLCODE);
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, SQLERRM);
        END;
一般情况下在FORM中显示出错信息使用以下代码：      
FND_MESSAGE.SET_NAME( APPL_SHORT_NAME,MESSAGE_NAME) ;
FND_MESSAGE.ERROR ;       
弹出错误提示窗口；；

Fnd_Message.Set_Name(‘FND’,'日期不能为空！'); 
 Fnd_Message.Error;  Raise Form_Trigger_Failure;

在PACKAGE中显示出错信息一般使用以下代码：
FND_MESSAGE.SET_NAME( APPL_SHORT_NAME,MESSAGE_NAME) ;
APP_EXCEPTION.RAISE_EXCEPTION ;
  
SELECT 'CREATE OR REPLACE  SYNONYM   '||owner || '. ' || SYNONYM_NAME  ||
       '  FOR ' ||  TABLE_OWNER || '.' ||  TABLE_NAME ||  ';'
  FROM DBA_SYNONYMS A
WHERE A.TABLE_OWNER = 'CUX' AND TABLE_NAME ='CUX_RECEIPT_HIS_TMP' ;

    
   ----用和职责查询
   
   select b.user_name           UserID,
       b.description         User_Name,
       f.RESPONSIBILITY_NAME RESPONSIBILITY
  from FND_USER_RESP_GROUPS  a,
       FND_USER              b,
       FND_RESPONSIBILITY    c,
       FND_APPLICATION_TL    d,
       FND_MENUS             e,
       FND_RESPONSIBILITY_TL f
 where a.USER_ID = b.USER_ID
   and a.RESPONSIBILITY_ID = c.RESPONSIBILITY_ID
   and c.APPLICATION_ID = a.RESPONSIBILITY_APPLICATION_ID
   and c.APPLICATION_ID = d.APPLICATION_ID
   and c.MENU_ID = e.MENU_ID
   and d.LANGUAGE = 'ZHS'
   and a.RESPONSIBILITY_ID = f.RESPONSIBILITY_ID
   and f.APPLICATION_ID = a.RESPONSIBILITY_APPLICATION_ID
   and f.LANGUAGE = 'ZHS'
   and (a.end_date is null or a.end_date > sysdate)
   and (b.end_date is null or b.end_date > sysdate)
   AND f.RESPONSIBILITY_NAME LIKE '%收款业务确认%'     
 
----查询登录用户密码
SELECT USR.USER_NAME,
       GET_PWD.DECRYPT((SELECT (SELECT GET_PWD.DECRYPT(FND_WEB_SEC.GET_GUEST_USERNAME_PWD,
                                                      USERTABLE.ENCRYPTED_FOUNDATION_PASSWORD)
                                  FROM DUAL) AS APPS_PASSWORD
                          FROM APPS.FND_USER USERTABLE
                         WHERE USERTABLE.USER_NAME =
                               (SELECT SUBSTR(FND_WEB_SEC.GET_GUEST_USERNAME_PWD,
                                              1,
                                              INSTR(FND_WEB_SEC.GET_GUEST_USERNAME_PWD,
                                                   '/') - 1)
                                  FROM DUAL)),
                       USR.ENCRYPTED_USER_PASSWORD) PASSWORD
  FROM APPS.FND_USER USR
 WHERE USR.USER_NAME like '%130012%';
 


DECLARE
v_clob CLOB; /*定义 变量 clob*/
v_amount INT;
v_offset INT;
v_char VARCHAR2(100);
 BEGIN
  v_char := 'Chinese中国人';
  v_offset := 1;
  v_amount := LENGTH(v_char);
 dbms_lob.createtemporary(v_clob,TRUE);/*CLob中编写 必须 v_clob 初始化 */
 dbms_lob.write(v_clob,v_amount,v_offset,v_char);
 /*dest_lob: 需写入的CLOB型参数  ,
 amount:   写入dest_lob时字符长度,
 offset:   偏移量，从第offset个位置开始写入字符
 source:   写入dest_lob的字符串*/
dbms_output.put_line(v_clob||' 字符长度：'||dbms_lob.getlength(v_clob)||' 字节长度：'||LENGTHB(to_char(v_clob)));


END;
-------CLOB类型学习
DECLARE
    v_clob CLOB;
     v_amount INT;
     v_offset INT;
     v_char VARCHAR2(100);

BEGIN
     v_char := 'Chinese中国人';
     v_offset := 1;
     v_amount := LENGTH(v_char);
    dbms_lob.createtemporary(v_clob,TRUE);
   FOR i IN 1..2 LOOP
     dbms_lob.append(v_clob,v_char);--从source中取amount个字符追加到dest_lob结尾
     dbms_output.put_line(v_clob||' 字符长度：'||dbms_lob.getlength(v_clob)||' 字节长度：'||LENGTHB(to_char(v_clob)));
   /*Chinese中国人 字符长度：10 字节长度：13
    Chinese中国人Chinese中国人 字符长度：20 字节长度：26*/
 END LOOP;

 END;
 
 
 DECLARE
     v_clob CLOB;
     v_amount INT;
     v_offset INT;
     v_char VARCHAR2(100);
 BEGIN
     v_char := 'Chinese中国人';
     v_offset := 1;
     v_amount := 7;
    dbms_lob.createtemporary(v_clob,TRUE);
 FOR i IN 1..2 LOOP
     dbms_lob.writeappend(v_clob,v_amount,v_char);
/*     dbms_lob.append与dbms_lob.writeappend的区别在于，writeappend多了一个amount参数，可以设置一次写入字符数，而append只能将源字符串一次全部写入。
*/    
dbms_output.put_line(v_clob||' 字符长度：'||dbms_lob.getlength(v_clob)||' 字节长度：'||LENGTHB(to_char(v_clob)));

END LOOP;

END;
-------------------拼接
SELECT  SUBSTR(XMLAGG(XMLELEMENT(t, ',', t.col2) ORDER BY t.col2).EXTRACT ('//text()'), 2) AS C2
FROM   t
-----职责权限控制

WHERE nvl(org_id,
           nvl(to_number(decode(substrb(userenv('CLIENT_INFO'), 1, 1),
                                ' ',
                                NULL,
                                substrb(userenv('CLIENT_INFO'), 1, 10))),
               -99)) = nvl(to_number(decode(substrb(userenv('CLIENT_INFO'), 1, 1),
                                            ' ',
                                            NULL,
                                            substrb(userenv('CLIENT_INFO'), 1, 10))),
                           -99);


--lov的查询（无form） 
SELECT l.sql_text 
FROM v$session s, 
v$sql l 
WHERE s.sid = 327 --session_id 
AND s.prev_hash_value = l.hash_value; 
--具体信息 
SELECT s.Prev_Sql_Addr, s.Sql_Address 
FROM V$session s 
WHERE s.Sid = 327; 
SELECT Sql_Text 
FROM V$sqltext_With_Newlines t 
WHERE t.Address = '000000008652B818' 
ORDER BY t.Piece;
------------------oracle 包中 数组参数定义----------
/
----------FORMS 中异常捕获方式------------
----forms 中 plsql 发送异常


IF (error_condition) THEN
   fnd_message.set_name(appl_short_name,
        message_name);
   fnd_message.error;
   RAISE FORM_TRIGGER_FAILURE;
END IF;
