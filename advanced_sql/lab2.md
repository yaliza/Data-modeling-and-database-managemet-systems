1.1.Используя функцию RANK выполнить ранжирование значений средних зарплат по годам.  
~~~sql
select round(avg(salvalue), 2) average, year, RANK() OVER (ORDER BY year) my_rank 
from salary
group by YEAR;
~~~
1.2.Используя функцию DENSE_RANK выполнить ранжирование значений суммарных зарплат по годам и месяцам.  
~~~sql
select sum(salvalue), year, month, DENSE_RANK() OVER (partition by year ORDER BY month) my_rank 
from salary
group by YEAR, month;
~~~
1.3.Используя функции RANK и DENSE_RANK выполнить ранжирование значенийзарплат по годам и месяцам для каждого имени сотрудника (PARTITIONBY).
~~~sql
select decode(lag(empname) over(order by empname), empname, null, empname) empname, salvalue, year, month, DENSE_RANK() OVER (ORDER BY empname) emp_rank, RANK() OVER (partition by year ORDER BY month) month_year_rank
from emp
join salary using(empno)
~~~ 
1.4.Используя функцию RANK выполнить ранжирование значений средних зарплат по годам и месяцам, по годам, по месяцам (CUBE, GROUPING_ID).
~~~sql
select year, month, round(avg(salvalue), 2) average, RANK() OVER(partition by grouping_id(year, month) order by round(avg(salvalue), 2)) my_rank 
from salary
group by cube(year, month)
order by grouping_id(year, month);
~~~
1.5.Используя функцию CUME_DIST определить позицию зарплаты сотрудника относительно должностей.
~~~sql
select jobname, empname, salvalue, round(CUME_DIST() over(order by salvalue), 2) as cume_dist
from job
join career using(jobno)
join salary using(empno)
join emp using(empno)
~~~
1.6.Используя функцию PERCENT_RANKопределить позицию зарплаты сотрудника относительно должностей.
~~~sql
select jobname, empname, salvalue, round(PERCENT_RANK() over(order by salvalue), 2) as cume_dist
from job
join career using(jobno)
join salary using(empno)
join emp using(empno)
~~~
1.7.Используя функцию NTILE разделите записи таблицы EMP на три группы. 
~~~sql
select empname, birthdate, NTILE(4) OVER (ORDER BY birthdate) AS ds from emp;
~~~
1.8.Примените функцию ROW_NUMBER строкам любой таблицы учебной базы данных. 
~~~sql
select empname, jobname, ROW_NUMBER() OVER(partition by empname order by empname) row_num
from job
join career using(jobno)javascript:ob_PPR_TAB('#')
join salary using(empno)
join emp using(empno)
~~~
2.1.Вычислите кумулятивные значения заработных плат для каждого сотрудника (RANGE BETWEEN UNBOUNDED PRECEDING)
~~~sql
SELECT EMPNAME, SALVALUE, SUM(SALVALUE) OVER(PARTITION BY EMPNAME ORDER BY SUM(SALVALUE) RANGE UNBOUNDED PRECEDING) AS AVG_SALARY
FROM SALARY 
JOIN EMP USING(EMPNO)
GROUP BY EMPNAME, SALVALUE;
~~~
2.2. Вычислите сумму для каждого интервала 2010 года в 90 дней, начиная с даты приема на работу первого сотрудника, чтобы увидеть динамику изменения расходов для каждого 90-дневного периода между датами приема на работу первого и последнего сотрудника (RANGE BETWEEN n PRECEDING AND CURRENT ROW)
~~~sql
SELECT EMPNAME, YEAR, MONTH, SALVALUE, SUM(SALVALUE) OVER(PARTITION BY EMPNAME ORDER BY MONTH RANGE BETWEEN 2
PRECEDING AND CURRENT ROW) AS SPENDING_PATTERN FROM SALARY 
JOIN EMP USING (EMPNO)
WHERE YEAR = 2010
ORDER BY EMPNAME, YEAR, MONTH
~~~
2.3. Вычислите средние значения заработных плат за текущий и два предыдущих месяца для каждого сотрудника (ROWS n PRECEDING).
~~~sql
select empname, salvalue, sum(salvalue) over (partition by empname order by month rows 2 preceding) sliding_total 
FROM SALARY 
JOIN EMP USING(EMPNO);
~~~
2.4. Вычислите средние агрегированные значения заработных плат каждого сотрудника за январь 2010 года (ROWS UNBOUNDED PRECEDING). 
~~~sql
select empname, salvalue, avg(salvalue) over (partition by empname order by year ROWS UNBOUNDED PRECEDING) average_total
FROM SALARY 
JOIN EMP USING(EMPNO)
where year = 2007;
~~~