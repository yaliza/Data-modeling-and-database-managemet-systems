1. Развернуть группу строк информирующую о количестве сотрудников на каждой должности в настоящий момент 
времени, превращая их значения в столбцы
~~~sql
select jobname, count(*) empcount from job 
join career using(jobno) 
group by jobname;
~~~
~~~sql
select 
sum(case when jobname='CLERK' then 1 else 0 end) as clerk,
sum(case when jobname='SALESMAN' then 1 else 0 end) as salesman,
sum(case when jobname='PRESIDENT' then 1 else 0 end) as president,
sum(case when jobname='FINANCIAL DIRECTOR' then 1 else 0 end) as fin_director,
sum(case when jobname='EXECUTIVE DIRECTOR' then 1 else 0 end) as exec_director,
sum(case when jobname='MANAGER' then 1 else 0 end) as manager,
sum(case when jobname='DRIVER' then 1 else 0 end) as driver
from job 
join career using(jobno);
~~~
~~~sql
SELECT * FROM
(
  SELECT jobname, empno from job 
  join career using(jobno)
)
PIVOT
(
  COUNT(empno)
  FOR jobname IN ('CLERK', 'SALESMAN','PRESIDENT', 'FINANCIAL DIRECTOR', 'EXECUTIVE DIRECTOR', 'MANAGER', 'DRIVER' )
)
~~~
2. Требуется преобразовать строки в столбцы, создавая для каждого значения заданного столбца отдельный столбец. 
~~~sql
select deptname, empname from dept
join career using(deptno)
join emp using(empno);
~~~
~~~sql
SELECT deptname, empname, ROW_NUMBER() OVER(partition by deptname ORDER BY empname) AS Row_Number  from dept
join career using(deptno)
join emp using(empno); 
~~~
~~~sql
select max(case when deptname='ACCOUNTING' then empname else NULL end) as accounting,
max(case when deptname='OPERATIONS' then empname else NULL end) as operations,
max(case when deptname='RESEARCH' then empname else NULL end) as research,
max(case when deptname='SALES' then empname else NULL end) as sales
from
(
SELECT deptname, empname, ROW_NUMBER() OVER(partition by deptname ORDER BY empname) AS Row_Number  from dept
join career using(deptno)
join emp using(empno)
)
group by Row_Number;
~~~
3. Выполните обратное разворачивание для результирующего множества, полученного  в задании 1.
~~~sql
select 
sum(case when jobname='CLERK' then 1 else 0 end) as clerk,
sum(case when jobname='SALESMAN' then 1 else 0 end) as salesman,
sum(case when jobname='PRESIDENT' then 1 else 0 end) as president,
sum(case when jobname='FINANCIAL DIRECTOR' then 1 else 0 end) as fin_director,
sum(case when jobname='EXECUTIVE DIRECTOR' then 1 else 0 end) as exec_director,
sum(case when jobname='MANAGER' then 1 else 0 end) as manager,
sum(case when jobname='DRIVER' then 1 else 0 end) as driver
from job 
join career using(jobno);
~~~
~~~sql
select j.jobname, job_info.clerk, job_info.salesman, job_info.president, job_info.fin_director, job_info.exec_director, job_info.manager, 
job_info.driver
from (
select 
sum(case when jobname='CLERK' then 1 else 0 end) as clerk,
sum(case when jobname='SALESMAN' then 1 else 0 end) as salesman,
sum(case when jobname='PRESIDENT' then 1 else 0 end) as president,
sum(case when jobname='FINANCIAL DIRECTOR' then 1 else 0 end) as fin_director,
sum(case when jobname='EXECUTIVE DIRECTOR' then 1 else 0 end) as exec_director,
sum(case when jobname='MANAGER' then 1 else 0 end) as manager,
sum(case when jobname='DRIVER' then 1 else 0 end) as driver
from job 
join career using(jobno)
) job_info, 
(select jobname from job) j;
~~~
~~~sql
select j.jobname, 
case j.jobname
when 'CLERK' then job_info.clerk
when 'SALESMAN' then job_info.salesman
when 'PRESIDENT' then job_info.president
when 'FINANCIAL DIRECTOR' then job_info.fin_director
when 'EXECUTIVE DIRECTOR' then  job_info.exec_director
when 'MANAGER' then job_info.manager
when 'DRIVER' then job_info.driver
end as emp_count
from (
select 
sum(case when jobname='CLERK' then 1 else 0 end) as clerk,
sum(case when jobname='SALESMAN' then 1 else 0 end) as salesman,
sum(case when jobname='PRESIDENT' then 1 else 0 end) as president,
sum(case when jobname='FINANCIAL DIRECTOR' then 1 else 0 end) as fin_director,
sum(case when jobname='EXECUTIVE DIRECTOR' then 1 else 0 end) as exec_director,
sum(case when jobname='MANAGER' then 1 else 0 end) as manager,
sum(case when jobname='DRIVER' then 1 else 0 end) as driver
from job 
join career using(jobno)
) job_info, 
(select jobname from job) j;
~~~
4. Составьте запрос, который будет выполнять обратное разворачивание результирующего множества в один столбец. 
~~~sql
select jobname, count(*) empcount from job 
join career using(jobno) 
group by jobname;
~~~
~~~sql
SELECT job_info.jobname, job_info.empcount, ROW_NUMBER() OVER(partition by job_info.jobname ORDER BY job_info.jobname) AS Row_Number
from (
select jobname, count(*) empcount from job 
join career using(jobno) 
group by jobname
) job_info
~~~
~~~sql
SELECT job_info.jobname, job_info.empcount, ROW_NUMBER() OVER(partition by job_info.jobname ORDER BY job_info.jobname) AS Row_Number
from (
select jobname, count(*) empcount from job 
join career using(jobno) 
group by jobname
) job_info,
(select jobname from job WHERE ROWNUM <= 3) j;
~~~
~~~sql
select case tab.Row_Number 
when 1 then tab.jobname
when 2 then TO_CHAR(tab.empcount)
end jobs_emp
from (
SELECT job_info.jobname, job_info.empcount, ROW_NUMBER() OVER(partition by job_info.jobname ORDER BY job_info.jobname) AS Row_Number
from (
select jobname, count(*) empcount from job 
join career using(jobno) 
group by jobname
) job_info,
(select jobname from job WHERE ROWNUM <= 3) j
) tab;
~~~
5. Составьте запрос, который будет исключать повторяющиеся значения из результирующего множества.
~~~sql
select jobname, empname from job 
join career using(jobno) 
join emp using(empno);
~~~
~~~sql
select LAG(jobname) OVER(order by jobname) lag, jobname, empname from job 
join career using(jobno) 
join emp using(empno);
~~~
~~~sql
select DECODE(LAG(jobname) OVER(order by jobname),jobname, NULL, jobname) jobname,  empname from job 
join career using(jobno) 
join emp using(empno);
~~~