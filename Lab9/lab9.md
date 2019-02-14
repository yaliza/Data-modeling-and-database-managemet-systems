1. Создайте объектный тип, который соответствует предметной области базы данных из лабораторной работы №2.
~~~sql
create or replace type pulpit_header_ty as object
 (firstname VARCHAR(50),
  lastname VARCHAR(50),
  pulpit_id NUMBER(3),
  member function getPulpitName return varchar
 ); 
/

create or replace type body pulpit_header_ty as 
    member function getPulpitName return varchar is 
            pulpit_name_var varchar(300);
        begin 
            select name into pulpit_name_var from pulpit where id = pulpit_id; 
            return pulpit_name_var; 
        end; 
    end; 
/
~~~
2. Создайте объектную таблицу на основе объектного типа из задания 1.
~~~sql
create table pulpit_header_obj_table of pulpit_header_ty;
~~~
3. Вставьте в объектную таблицу несколько строк.
~~~sql
insert into pulpit_header_obj_table values ('Иван', 'Иванов', 1);
insert into pulpit_header_obj_table values ('Петр', 'Петров', 2);
~~~
4. Создайте таблицу, содержащую объект-столбец.
~~~sql
create table pulpit_header_ref_table (
    id number primary key,
    pulpit ref pulpit_header_ty);
~~~
5. Вставьте в объект-столбец данные (из объектной таблицы).
~~~sql
insert into  pulpit_header_ref_table select 1, ref(b) from  pulpit_header_obj_table b where firstname = 'Иван';
insert into  pulpit_header_ref_table select 2, ref(b) from  pulpit_header_obj_table b where firstname = 'Петр';
~~~
6. Выполните выборку, обновление, удаление из таблицы, содержащей объект-столбец.
~~~sql
select id, deref(pulpit).firstname as "Имя",  deref(pulpit).lastname as "Фамилия",   deref(pulpit).getPulpitName() as "кафедрА" 
from pulpit_header_ref_table;
~~~
~~~sql
update   pulpit_header_obj_table set firstname = 'Петя' where firstname = 'Петр';
~~~
~~~sql
delete from pulpit_header_obj_table where firstname = 'Иван';
~~~