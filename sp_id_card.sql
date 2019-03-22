create or replace package sp_id_card is

/********************************************************************
#function:身份证信息查询
#version:1.00
#author:qcf
#createdate:2015-5-26
#input: card_id VARCHAR2 身份证号码
#output:out_msg VARCHAR2 身份证信息
#modifyexplain:
********************************************************************/

function is_number(str varchar2) return integer; --判断输入的身份证是否为数字
function is_date(in_date varchar2) return integer; --判断输入的是否是身份证号码
function is_idcard(card_id varchar2) return integer; --判断输入的是否是身份证号码
function is_areacode(card_id varchar2) return integer; --判断前6位是否为地区号
function get_age(card_id in varchar2) return varchar2; --获取年龄
function get_sex(card_id varchar2) return varchar2; --获取性别
function get_area(card_id varchar2) return varchar2; --获取地区信息
function get_day(card_id varchar2) return varchar2; --获取出生日期
function get_card_info(card_id varchar2) return varchar2;--身份信息简介
procedure id_card_info(card_id varchar2, out_msg out varchar); --身份信息简介
end sp_id_card;
/
create or replace package body sp_id_card is

/********************************************************************
#function:身份证信息查询
#version:1.00
#author:qcf
#createdate:2015-5-26
#input: card_id VARCHAR2 身份证号码
#output:out_msg VARCHAR2 身份证信息
#modifyexplain:
********************************************************************/

--判断输入的身份证是否为数字

function is_number(str varchar2) return integer is
begin
if (length(trim(translate(str, '0123456789', ' '))) is null) then
return 1;
else
return 0;
end if;
end is_number;

function is_date(in_date varchar2) return integer is
val date;
begin
val := to_date(nvl(in_date, 'a'), 'yyyy-mm-dd hh24:mi:ss');
return 1;
exception
when others then
return 0;
end;

--判断输入的是否是身份证号码

function is_idcard(card_id varchar2) return integer is
idcardlen integer default 0;
begin
idcardlen := length(card_id);
if (idcardlen = 18 and is_number(card_id) = 1 and
is_date(substr(card_id, 7, 8)) = 1) and is_areacode(card_id) = 1 or
(idcardlen = 18 and
is_number(substr(card_id, 1, idcardlen - 1)) = 1 and
substr(card_id, -1, 1) = 'X' and
is_date(substr(card_id, 7, 8)) = 1) and is_areacode(card_id) = 1 then
return 1;
else
return 0;
end if;
end is_idcard;

--判断前6位是否为地区号

function is_areacode(card_id varchar2) return integer is

v_areacode varchar2(6);
begin
select a.area_no
into v_areacode
from idcard_area a
where a.area_no = substr(card_id, 1, 6);
return 1;
exception
when no_data_found then
return 0;
end is_areacode;

--获取年龄

function get_age(card_id in varchar2) return varchar2 is
agevalue varchar2(10);
begin
if is_idcard(card_id) = 0 then
return '身份证号码错误，请核查！';
end if;

if (length(trim(card_id)) = 18) then
select (to_char(sysdate, 'yyyy') -
to_char(substr(card_id, 7, 4)))
into agevalue
from dual;
else
if (length(trim(card_id)) = 15) then
select (to_char(sysdate, 'yyyy') -
to_char('19' || substr(card_id, 7, 2)))
into agevalue
from dual;
else
agevalue := '0';
end if;
end if;
return agevalue;
end get_age;

--获取性别

function get_sex(card_id varchar2) return varchar2 is
idcardlen integer;
begin
idcardlen := length(card_id);
if is_idcard(card_id) = 0 then
return '身份证号码错误，请核查！';
end if;

if idcardlen = 18 and substr(card_id, 17, 1) in (2, 4, 6, 8, 0) then
return('女');
end if;
if idcardlen = 18 and substr(card_id, 17, 1) in (1, 3, 5, 7, 9) then
return('男');
end if;
if idcardlen = 15 and substr(card_id, 15, 1) in (1, 3, 5, 7, 9) then
return('男');
end if;
if idcardlen = 15 and substr(card_id, 15, 1) in (2, 4, 6, 8, 0) then
return('女');
end if;
end get_sex;

--获取地区信息

function get_area(card_id varchar2) return varchar2 is
-- IDCardLen integer;
v_area_name varchar2(100);
begin
-- IDCardLen := length(card_id);
if is_idcard(card_id) = 0 then
return '身份证号码错误，请核查！';
end if;

select a.area_name
into v_area_name
from idcard_area a
where a.area_no = substr(card_id, 1, 6);
return v_area_name;
end get_area;
--获取出生日期
function get_day(card_id varchar2) return varchar2 is
v_year varchar2(100);
v_mounth varchar2(100);
v_day varchar2(100);
begin
if is_idcard(card_id) = 0 then
return '身份证号码错误，请核查！';
end if;

select substr(card_id, 7, 4) into v_year from dual;
select substr(card_id, 11, 2) into v_mounth from dual;
select substr(card_id, 13, 2) into v_day from dual;
return v_year || '年' || v_mounth || '月' || v_day || '日';
end get_day;

----身份信息简介

function get_card_info(card_id varchar2) return varchar2 is

-- v_name varchar2(200) ;--姓名
v_age varchar2(200); --年龄
v_sex varchar2(200); --性别
v_area varchar2(200); --地区
v_day varchar2(200); --出生日期

begin
if is_idcard(card_id) = 0 then
return '身份证号码错误，请核查！';
end if;
if is_idcard(card_id) = 1 then
v_age := get_age(card_id);
v_sex := get_sex(card_id);
v_area := get_area(card_id);
v_day := get_day(card_id);

return '年龄：' || v_age || '，性别：' || v_sex || '，地区：' ||
v_area || '，出生年月：' || v_day;
end if;
end get_card_info;

--身份信息简介

procedure id_card_info(card_id varchar2, out_msg out varchar) is

-- v_name varchar2(200) ;--姓名
v_age varchar2(200); --年龄
v_sex varchar2(200); --性别
v_area varchar2(200); --地区
v_day varchar2(200); --出生日期

begin
if is_idcard(card_id) = 0 then
out_msg := '身份证号码错误，请核查！';
end if;
if is_idcard(card_id) = 1 then
v_age := get_age(card_id);
v_sex := get_sex(card_id);
v_area := get_area(card_id);
v_day := get_day(card_id);

out_msg := '年龄：' || v_age || '，性别：' || v_sex || '，地区：' ||
v_area || '，出生年月：' || v_day;
dbms_output.put_line('年龄：' || v_age || '，性别：' || v_sex ||
'，地区：' || v_area || '，出生年月：' || v_day);
end if;
end;

end sp_id_card;
/
