1. Создайте представление, содержащее данные о сотрудниках пенсионного возраста.
~~~sql
CREATE VIEW RETIREMENT AS
SELECT *
FROM EMP
WHERE MONTHS_BETWEEN(SYSDATE, birthdate) / 12 >= 60;
~~~
2. Создайте представление, содержащее данные об уволенных сотрудниках: имя сотрудника, дата увольнения, отдел, должность.
~~~sql
CREATE VIEW DISMISS AS
SELECT e.empname, c.enddate, d.deptname, j.jobname, e.empno
FROM EMP e 
INNER JOIN career c on c.empno = e.empno
INNER JOIN dept d on d.deptno = c.deptno
INNER JOIN job j on j.jobno = c.jobno
WHERE c.enddate is not null;
~~~
3. Создайте представление, содержащее имя сотрудника, должность, занимаемую сотрудником в данный момент, суммарную заработную плату сотрудника за третий квартал 2010 года. Первый столбец назвать Sotrudnik, второй – Dolzhnost, третий – Itogo_3_kv.
~~~sql
CREATE VIEW kvartal(Sotrudnik, Dolzhnost, Itogo_3_kv) AS
SELECT e.empname, j.jobname, SUM(s.salvalue)
FROM job j
INNER JOIN career c ON j.jobno = c.jobno
INNER JOIN emp e ON e.empno = c.empno
INNER JOIN salary s ON s.empno = e.empno
WHERE s.year = 2010 
AND s.month BETWEEN 7 AND 9
AND c.enddate IS NULL
GROUP BY e.empname, j.jobname;
~~~
4. На основе представления из задания 2 и таблицы SALARY создайте представление, содержащее данные об уволенных сотрудниках, которым зарплата начислялась более 2 раз. В созданном представлении месяц начисления зарплаты и сумма зарплаты вывести в одном столбце, в качестве разделителя использовать запятую.
~~~sql
CREATE VIEW strange_view AS
SELECT d.*, s.month || ', ' || s.salvalue AS month_sum
FROM DISMISS d INNER JOIN salary s ON s.empno = d.empno
WHERE s.empno IN (
    SELECT empno
    FROM DISMISS NATURAL JOIN salary
    GROUP BY empno
    HAVING COUNT(salvalue) > 2
);
~~~