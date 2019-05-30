1. Получить результирующее множество,  содержащее количество сотрудников в каждом отделе, а также общее количество сотрудников. 
~~~sql
    select 
        case grouping(deptname)
                when 0 then deptname
                else 'Total'
        end deptname,
        count(*) number_of_employees
        from emp join career using(empno) join dept using(deptno)
        group by rollup(deptname);
~~~
2. Требуется найти количество сотрудников по отделам, по должностям и для каждого сочетания DEPTNAME/JOBNAME. 
~~~sql
select deptname, jobname,
    case grouping(deptname) || grouping(jobname)
        when '00' then 'total by dept and job'
        when '10' then 'total by job'
        when '01' then 'total by dept'
        when '11' then 'grand total by table'
    end category,
    count(*) emp_num
    from emp join salary using(empno) join career using(empno) join job using(jobno) join dept using(deptno) 
    group by cube(deptname, jobname)
    order by grouping(deptname), grouping(jobname);
~~~
3. Требуется найти среднее значение суммы всех заработных плат по отделам, по должностям и для каждого сочетания DEPTNAME/JOBNAME.
~~~sql
select deptname, jobname,
    case grouping(deptname) || grouping(jobname)
        when '00' then 'total by dept and job'
        when '10' then 'total by job'
        when '01' then 'total by dept'
        when '11' then 'grand total by table'
    end category,
    round(avg(salvalue), 2) as average_salary
    from salary join career using(empno) join job using(jobno) join dept using(deptno) 
    group by cube(deptname, jobname)
    order by grouping(deptname), grouping(jobname);
~~~
4. Создайте запрос на распознавание строк, сформированных оператором GROUP BY, и строк, являющихся результатом выполнения CUBE. 
~~~sql
select deptname, jobname,
    grouping(deptname),
    grouping(jobname),
    round(avg(salvalue), 2) as average_salary
    from salary join career using(empno) join job using(jobno) join dept using(deptno) 
    group by cube(deptname, jobname)
    order by grouping(deptname), grouping(jobname);

select deptname, jobname,
    round(avg(salvalue), 2) as average_salary,
    case instr(grouping(deptname) || grouping(jobname), '1')
        when 0 then 'false'
        else 'true'
    end is_by_cube
    from salary join career using(empno) join job using(jobno) join dept using(deptno) 
    group by cube(deptname, jobname)
    order by grouping(deptname), grouping(jobname);
~~~
5. Агрегация разных групп одновременно
~~~sql
select empname,
    deptname, 
    count(empno) over (partition by deptname) deptname_emp_count,
    jobname,
    count(empno) over (partition by jobname) jobname_emp_count,
    count(*) over () total
    from emp join career using(empno) join job using(jobno) join dept using(deptno) 
~~~
6. Агрегация скользящего множества значений
~~~sql
select startdate, salvalue,
sum(salvalue) over(order by startdate RANGE BETWEEN 90 PRECEDING AND CURRENT ROW) spending_pattern
from career join salary using(empno) order by 1;
~~~
7. Определение доли от целого в процентном выражении 
~~~sql
select jobname, 
    count(empno) num_emps,
    round(100*RATIO_TO_REPORT(sum(salvalue)) OVER (), 1) || '%' pct_of_all_salaries
    from salary join career using(empno) join job using(jobno)
    group by jobname
~~~