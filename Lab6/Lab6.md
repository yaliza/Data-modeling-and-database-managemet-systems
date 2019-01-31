1. Составьте на выборку данных с использованием рефлексивного
соединения для таблицы из задания 5 лабораторной работы №2
рефлексивное соединение таблицы semester_info:
~~~sql
SELECT ((semafter.num + 2 * (semafter.course - 1)) || ' semester comes after ' || (sembefore.num + 2 * (sembefore.course - 1)) || ' semester ') AS "semester sequence"
FROM semester_info semafter JOIN semester_info sembefore
ON ((semafter.num + 2 * (semafter.course - 1)) =  (sembefore.num + 2 * (sembefore.course - 1) + 1));
~~~
Составьте запросы на выборку данных с использованием следующих
операторов, конструкций функций языка SQL:
2. простого оператора CASE ();
выведем информацию обо всех предметах, которые у нас есть:
~~~sql
SELECT sem_sub.hoursnumber, sub.name, sem.course, sem.num as semester_num, 
    CASE rep.kind
        WHEN 'exam' THEN 'students take an exam in this subject' 
        ELSE 'students do not need to take an exam in this subject.'
    END AS reporting_info
FROM semester_subjects sem_sub 
INNER JOIN reporting  rep  on rep.id = sem_sub.reporting_id
INNER JOIN subject sub on sub.id = sem_sub.subject_id
INNER JOIN semester_info sem on sem.id = sem_sub.semester_info_id;
~~~
3. поискового оператора CASE();
выведем информацию о студентах на конкретном семестре(распределены ли по кафедрам или нет)
~~~sql
SELECT sem.course, sem.num as sem_num,
    CASE 
        WHEN sem.course > 2 THEN 'students are distributed in the departments'
        ELSE 'students are not distributed in the departments' 
    END AS department_info
FROM  semester_info sem;
~~~
4. оператора WITH();
Все студенты кафедры management information systems
~~~sql
WITH students_man_info_systems AS (
    SELECT student.name
    FROM student
    INNER JOIN pulpit pul ON student.pulpit_id = pul.id
    WHERE pul.name = 'management information systems'
) 
SELECT * from  students_man_info_systems;
~~~
5. встроенного представления();
~~~sql
см предыдущее
~~~
6. некоррелированного запроса
Выведем студентов кафедр "management information systems" и "programming technology"
~~~sql
SELECT st.name
FROM student st 
WHERE st.pulpit_id in (
    SELECT id FROM pulpit
    WHERE name = 'management information systems' or name = 'programming technology'
)
~~~
7. коррелированного запроса
~~~sql
SELECT st.name
FROM student st 
WHERE st.pulpit_id in (
    SELECT id FROM pulpit
    WHERE (name = 'management information systems' or name = 'programming technology') 
    and st.pulpit_id = id
)
~~~
8. функции NULLIF
Выведем список предметов в каждом семестре. Если по нему экзамен - то выведем соответственно exam, иначе - ничего.
~~~sql
SELECT sem_sub.hoursNumber, sub.name, sem.course, sem.num as semester_num, NULLIF(rep.kind, 'test') as exam
FROM semester_subjects sem_sub
INNER JOIN semester_info sem ON sem.id = sem_sub.semester_info_id
INNER JOIN subject sub ON sub.id = sem_sub.subject_id 
INNER JOIN reporting rep ON rep.id = sem_sub.reporting_id;
~~~
9. функции NVL2
Выведем список студентов. Если студент уже распределен на какую-то кафедру, то выведем 'distributed to the department', 
иначе - 'do not distributed to the department'
~~~sql
SELECT name, NVL2(pulpit_id, 'distributed to the department', 'do not distributed to the department') as dept_info from student;
~~~
10. TOP-N анализа();
Выведем первые 5 строк предметов, у которых меньше всего часов(в семестре):
~~~sql
SELECT sem_sub.hoursNumber, sub.name, sem.course, sem.num as semester_num, rep.kind as exam
FROM semester_subjects sem_sub
INNER JOIN semester_info sem ON sem.id = sem_sub.semester_info_id
INNER JOIN subject sub ON sub.id = sem_sub.subject_id 
INNER JOIN reporting rep ON rep.id = sem_sub.reporting_id
WHERE rownum <= 5
ORDER BY sem_sub.hoursNumber
~~~
11. функции ROLLUP()
Выведем среднюю оценку по всем предметам, по предметам за определенный курс, за определенный семестр:
~~~sql
SELECT sub.name, sem.course, sem.num as sem_num, AVG(TO_NUMBER(rep_info.estimate)) as average_estimate
FROM semester_subjects sem_sub
INNER JOIN semester_info sem ON sem.id = sem_sub.semester_info_id
INNER JOIN subject sub ON sub.id = sem_sub.subject_id 
INNER JOIN reporting rep ON rep.id = sem_sub.reporting_id
INNER JOIN report_info rep_info ON sem_sub.id = rep_info.semester_subjects_id
WHERE rep.kind = 'exam'
GROUP BY ROLLUP(sub.name, sem.course, sem.num);
~~~
12. Составьте запрос на использование оператора MERGE языка манипулирования данными.
Создадим таблицу students_copy на основе student.
Припишем к каждому имени копированного студента префикс copy_
~~~sql
CREATE TABLE students_copy AS  SELECT * FROM student;

INSERT INTO students_copy (id, name)  VALUES(8, 'newStudent');

MERGE INTO students_copy st_copy
USING (SELECT * FROM student) st
ON (st_copy.id = st.id)
WHEN MATCHED THEN UPDATE SET st_copy.name = 'copy_' || st.name  
WHEN NOT MATCHED THEN INSERT (st_copy.id, st_copy.name)
VALUES (st.id, st.name);
~~~