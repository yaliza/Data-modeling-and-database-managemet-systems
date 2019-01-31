# 3.3

1. Рефлексивное соединение. Представление отношений родитель-потомок.
Выполните рефлексивное соединение (самосоединение) таблицы EMP.
~~~sql
SELECT employee.EMPNAME || ' works for ' || employer.EMPNAME AS "EMP_MANAGER"
FROM EMP employee JOIN EMP employer
ON (employee.MANAGER_ID = employer.EMPNO);
~~~
2. Иерархический запрос.
Используйте ключевые слова иерархических запросов START WITH, CONNECT BY PRIOR.
(start with - корень, connect by prior - что дети?)
~~~sql
SELECT empname || ' reports to ' || PRIOR empname AS manager_emp
FROM emp
START WITH manager_id IS NULL
CONNECT BY PRIOR empno = manager_id;
~~~
3. Представление отношений потомок-родитель-прародитель
Используйте функцию SYS_CONNECT_BY_PATH получите CLARK и его
руководителя ALLEN, затем руководителя ALLEN ― JOHN KLINTON. А также
ключевые слова иерархических запросов LEVEL, START WITH, CONNECT BY
PRIOR; функцию LTRIM.
(sys_connect_by_path - используется только в иерархических запросах чтоб вывести весь путь от вершины к листу)
(reverse - чтоб вывести в нужном порядке (от наименьшей должности к наибольше, а не наоборот)
(LTRIM же удаляет слева лишний >--)
~~~sql
SELECT REVERSE(LTRIM(SYS_CONNECT_BY_PATH(REVERSE(empname), '>--'), '>--')) "Path"
   FROM emp
   WHERE empname = 'CLARK'
   START WITH manager_id is null
   CONNECT BY PRIOR empno = manager_id;
~~~
4. Иерархическое представление таблицы
~~~sql
SELECT (LTRIM(SYS_CONNECT_BY_PATH(empname, '-->'), '-->')) "Path"
   FROM emp
   START WITH manager_id is null
   CONNECT BY PRIOR empno = manager_id;
~~~
5. Представление уровня иерархии
Используйте ключевые слова иерархических запросов LEVEL, START WITH,
CONNECT BY PRIOR; функцию LPAD.
(параметры LPAD - строка для дополнения символов с левой стороны, второй - сколько символов, третий - какой символ)
~~~sql
SELECT LPAD(empname, LENGTH(empname) + 2*(LEVEL) - 2, '_') AS "Tree"
FROM emp
START WITH manager_id is null
CONNECT BY PRIOR empno = manager_id;
~~~
6. Выбор всех дочерних строк для заданной строки
~~~sql
SELECT empname 
FROM emp
WHERE empname != 'ALLEN'
START WITH empname = 'ALLEN'
CONNECT BY PRIOR empno = manager_id;
~~~

# 3.4
-------------------------------------------------------------------------------
1. Добавление, вычитание дней, месяцев, лет.
Требуется используя значения столбца START_DATE получить дату за десять дней
до и после приема на работу, пол года до и после приема на работу, год до и после
приема на работу сотрудника JOHN KLINTON.
~~~sql
SELECT e.empname, c.startdate, 
c.startdate + 10 as "+10 days",
c.startdate - 10 as "-10 days",
ADD_MONTHS(c.startdate, 6) as "+6 month", 
ADD_MONTHS(c.startdate, -6) as "-6 month",
ADD_MONTHS(c.startdate, 12) as "+ year", 
ADD_MONTHS(c.startdate, -12) as "- year"
from EMP e
INNER JOIN CAREER c
ON e.empno = c.empno
WHERE e.empname = 'JOHN KLINTON'
~~~
2. Определение количества дней между двумя датами.
Требуется найти разность между двумя датами и представить результат в днях.
Вычислите разницу в днях между датами приема на работу сотрудников JOHN
MARTIN и ALEX BOUSH.
~~~sql
SELECT john, alex, john - alex
FROM (
  SELECT startdate AS john  
  FROM EMP e INNER JOIN CAREER c
  ON e.empno = c.empno
  WHERE e.empname = 'JOHN KLINTON'
),
(
  SELECT startdate AS alex
  FROM EMP e INNER JOIN CAREER c
  ON e.empno = c.empno
  WHERE e.empname = 'ALEX BOUSH'
);
~~~
3. Определение количества месяцев или лет между датами
Требуется найти разность между двумя датами в месяцах и в годах.
~~~sql
SELECT john, alex, MONTHS_BETWEEN(john, alex) as "months difference", MONTHS_BETWEEN(john, alex) / 12 as "years difference"
FROM (
  SELECT startdate AS john  
  FROM EMP e INNER JOIN CAREER c
  ON e.empno = c.empno
  WHERE e.empname = 'JOHN KLINTON'
),
(
  SELECT startdate AS alex
  FROM EMP e INNER JOIN CAREER c
  ON e.empno = c.empno
  WHERE e.empname = 'ALEX BOUSH'
);
~~~
4. Определение интервала времени между текущей и следующей записями
Требуется определить интервал времени в днях между двумя датами. Для каждого
сотрудника 20-го отделе найти сколько дней прошло между датой его приема на
работу и датой приема на работу следующего сотрудника.
~~~sql
SELECT empname, startdate, next_startdate - startdate AS diff FROM (
   SELECT startdate, empname, LEAD(startdate) OVER (ORDER BY startdate) AS next_startdate
   from career c
   INNER JOIN emp e ON c.empno = e.empno
   WHERE c.deptno = 20
);
~~~
5. Определение количества дней в году
(TRUNC - усекает дату до заданной единицы)
~~~sql
SELECT startdate, ADD_MONTHS(TRUNC(startdate, 'y'), 12) - TRUNC(startdate, 'y') AS "days in year"
FROM career;
~~~
6. Извлечение единиц времени из даты
Требуется разложить текущую дату на день, месяц, год, секунды, минуты, часы.
Результаты вернуть в численном виде.
~~~sql
SELECT
  TO_NUMBER(TO_CHAR(SYSDATE, 'hh24')) hour,
  TO_NUMBER(TO_CHAR(SYSDATE, 'mi')) min,
  TO_NUMBER(TO_CHAR(SYSDATE, 'ss')) sec,
  TO_NUMBER(TO_CHAR(SYSDATE, 'dd')) day,
  TO_NUMBER(TO_CHAR(SYSDATE, 'mm')) mth,
  TO_NUMBER(TO_CHAR(SYSDATE, 'yyyy')) year
FROM DUAL;
~~~
7. Определение первого и последнего дней месяца
Требуется получить первый и последний дни текущего месяца.
~~~sql
SELECT
 sysdate now, 
 last_day(sysdate) as "last day",
 TRUNC(sysdate, 'mm') as "first day"
FROM DUAL;
~~~
8. Выбор всех дат года, выпадающих на определенный день недели
Требуется возвратить даты начала и конца каждого из четырех кварталов данного
года.
~~~sql
SELECT 
 rownum AS quartal, 
 ADD_MONTHS(TRUNC(SYSDATE, 'y'), (rownum - 1) * 3) AS start_date,
 ADD_MONTHS(TRUNC(SYSDATE, 'y'), rownum * 3) - 1 AS end_date
FROM DUAL
CONNECT BY level <= 4;
~~~
9. Выбор всех дат года, выпадающих на определенный день недели
Требуется найти все даты года, соответствующие заданному дню недели.
Сформируйте список понедельников текущего года.
~~~sql
SELECT * FROM (
  SELECT TRUNC(SYSDATE, 'y') + level - 1 day
  FROM DUAL
  CONNECT BY level <= ADD_MONTHS(TRUNC(SYSDATE, 'y'), 12) - TRUNC(SYSDATE, 'y')
)
WHERE TO_CHAR(day, 'dy') = 'mon';
~~~
10. Создание календаря
Требуется создать календарь на текущий месяц. Календарь должен иметь семь
столбцов в ширину и пять строк вниз.
~~~sql
SELECT 
 MAX(CASE dw WHEN 2 THEN dm END) Mo,
 MAX(CASE dw WHEN 3 THEN dm END) Tu,
 MAX(CASE dw WHEN 4 THEN dm END) We,
 MAX(CASE dw WHEN 5 THEN dm END) Th,
 MAX(CASE dw WHEN 6 THEN dm END) Fr,
 MAX(CASE dw WHEN 7 THEN dm END) Sa,
 MAX(CASE dw WHEN 1 THEN dm END) Su
FROM (
  SELECT * FROM (
    SELECT
      TO_CHAR(TRUNC(SYSDATE, 'mm') + level - 1, 'iw') wk,
      TO_CHAR(TRUNC(SYSDATE, 'mm') + level - 1, 'dd') dm,
      TO_NUMBER(TO_CHAR(TRUNC(SYSDATE, 'mm') + level - 1, 'd')) dw,
      TO_CHAR(TRUNC(SYSDATE, 'mm') + level - 1, 'mm') curr_mth,
      TO_CHAR(SYSDATE, 'mm') mth
    FROM DUAL
    CONNECT BY LEVEL <=31
  )
  WHERE curr_mth = mth
)
GROUP BY wk ORDER BY wk;
~~~