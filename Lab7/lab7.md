1. Добавьте в таблицу SALARY столбец TAX (налог) для вычисления ежемесячного
подоходного налога на зарплату по прогрессивной шкале. Налог вычисляется по
следующему правилу:
налог равен 9% от начисленной в месяце зарплаты, если суммарная зарплата с
начала года до конца рассматриваемого месяца не превышает 20 000;
налог равен 12% от начисленной в месяце зарплаты, если суммарная зарплата с
начала года до конца рассматриваемого месяца больше 20 000, но не превышает 30
000;
налог равен 15% от начисленной в месяце зарплаты, если суммарная зарплата с
начала года до конца рассматриваемого месяца больше 30 000.
~~~sql
ALTER TABLE salary ADD (tax NUMBER (15));
~~~
2. Составьте программу вычисления налога и вставки её в таблицу SALARY:
a) с помощью простого цикла (loop) с курсором и оператора if;
~~~sql
DECLARE
   COUNTSAL NUMBER(16);
   SALARY_RES NUMBER(16);
   CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
   R sal_cursor%ROWTYPE;
BEGIN
   OPEN sal_cursor;
   LOOP
       FETCH sal_cursor INTO R;
       EXIT WHEN sal_cursor%NOTFOUND;
       SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY S
           WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

        IF COUNTSAL < 20000 THEN
            SALARY_RES := R.SALVALUE * 0.09;
        ELSIF COUNTSAL < 30000 THEN
            SALARY_RES := R.SALVALUE * 0.12;
        ELSE
            SALARY_RES := R.SALVALUE * 0.15;
        END IF;

        UPDATE SALARY 
        SET TAX = SALARY_RES
        WHERE CURRENT OF sal_cursor;
   END LOOP;
   CLOSE sal_cursor;
   COMMIT;
END;
~~~
b) с помощью простого цикла (loop) с курсором и оператора case;
~~~sql
CREATE OR REPLACE PROCEDURE TASK_SIMPLE_LOOP_CURSOR_CASE AS
   COUNTSAL NUMBER(16);
   CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
   R sal_cursor%ROWTYPE;
BEGIN
   OPEN sal_cursor;
   LOOP
       FETCH sal_cursor INTO R;
       EXIT WHEN sal_cursor%NOTFOUND;
       SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY S
           WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

        UPDATE SALARY 
        SET TAX =
           CASE
               WHEN COUNTSAL < 20000 THEN R.SALVALUE * 0.09
               WHEN COUNTSAL < 30000 THEN R.SALVALUE * 0.12
               ELSE R.SALVALUE * 0.15
           END
        WHERE CURRENT OF sal_cursor;
   END LOOP;
   CLOSE sal_cursor;
   COMMIT;
END TASK_SIMPLE_LOOP_CURSOR_CASE;
~~~
c) с помощью курсорного цикла FOR;
~~~sql
CREATE OR REPLACE PROCEDURE TASK_LOOP_CURSOR AS
    COUNTSAL NUMBER(16);
    CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, YEAR, MONTH, TAX FROM SALARY FOR UPDATE OF TAX;
 BEGIN
     FOR cur_sal IN sal_cursor  
     LOOP
             SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY sal
             WHERE sal.EMPNO = cur_sal.EMPNO AND sal.MONTH < cur_sal.MONTH AND sal.YEAR = cur_sal.YEAR;
             UPDATE SALARY
             SET TAX =  
             CASE
                WHEN COUNTSAL < 20000 THEN cur_sal.SALVALUE * 0.09
                WHEN COUNTSAL < 30000 THEN cur_sal.SALVALUE * 0.12
                ELSE cur_sal.SALVALUE * 0.15
             END
             WHERE CURRENT OF sal_cursor;
     END LOOP; 
COMMIT; 
END TASK_LOOP_CURSOR;
~~~
d) с помощью курсора с параметром, передавая номер сотрудника, для которого
необходимо посчитать налог.
~~~sql
CREATE  OR  REPLACE  PROCEDURE  TASK_PARAM (EMPID  NUMBER)  AS
    CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
    COUNTSAL NUMBER(16);
BEGIN
    FOR cur_sal IN sal_cursor  
     LOOP
         SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY sal
         WHERE sal.EMPNO = cur_sal.EMPNO AND sal.MONTH < cur_sal.MONTH AND sal.YEAR = cur_sal.YEAR;
         UPDATE SALARY
         SET TAX =  
            CASE
                WHEN COUNTSAL < 20000 THEN cur_sal.SALVALUE * 0.09
                WHEN COUNTSAL < 30000 THEN cur_sal.SALVALUE * 0.12
                ELSE cur_sal.SALVALUE * 0.15
            END
            WHERE CURRENT OF sal_cursor;
     END LOOP; 
   COMMIT;
END  TASK_PARAM;
~~~
3. Оформите составленные программы в виде процедур.
a) с помощью простого цикла (loop) с курсором и оператора if;
~~~sql
CREATE OR REPLACE PROCEDURE TASK_SIMPLE_LOOP_CURSOR_IF AS
   COUNTSAL NUMBER(16);
   SALARY_RES NUMBER(16);
   CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
   R sal_cursor%ROWTYPE;
BEGIN
   OPEN sal_cursor;
   LOOP
       FETCH sal_cursor INTO R;
       EXIT WHEN sal_cursor%NOTFOUND;
       SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY S
           WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

        IF COUNTSAL < 20000 THEN
            SALARY_RES := R.SALVALUE * 0.09;
        ELSIF COUNTSAL < 30000 THEN
            SALARY_RES := R.SALVALUE * 0.12;
        ELSE
            SALARY_RES := R.SALVALUE * 0.15;
        END IF;

        UPDATE SALARY 
        SET TAX = SALARY_RES
        WHERE CURRENT OF sal_cursor;
   END LOOP;
   CLOSE sal_cursor;
   COMMIT;
END TASK_SIMPLE_LOOP_CURSOR_IF;
~~~
b) с помощью простого цикла (loop) с курсором и оператора case;
~~~sql
CREATE OR REPLACE PROCEDURE TASK_SIMPLE_LOOP_CURSOR_CASE AS
   COUNTSAL NUMBER(16);
   CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
   R sal_cursor%ROWTYPE;
BEGIN
   OPEN sal_cursor;
   LOOP
       FETCH sal_cursor INTO R;
       EXIT WHEN sal_cursor%NOTFOUND;
       SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY S
           WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

        UPDATE SALARY 
        SET TAX =
           CASE
               WHEN COUNTSAL < 20000 THEN R.SALVALUE * 0.09
               WHEN COUNTSAL < 30000 THEN R.SALVALUE * 0.12
               ELSE R.SALVALUE * 0.15
           END
        WHERE CURRENT OF sal_cursor;
   END LOOP;
   CLOSE sal_cursor;
   COMMIT;
END TASK_SIMPLE_LOOP_CURSOR_CASE;
~~~
c) с помощью курсорного цикла FOR;
~~~sql
CREATE OR REPLACE PROCEDURE TASK_LOOP_CURSOR AS
    COUNTSAL NUMBER(16);
    CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, YEAR, MONTH, TAX FROM SALARY FOR UPDATE OF TAX;
 BEGIN
     FOR cur_sal IN sal_cursor  
     LOOP
             SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY sal
             WHERE sal.EMPNO = cur_sal.EMPNO AND sal.MONTH < cur_sal.MONTH AND sal.YEAR = cur_sal.YEAR;
             UPDATE SALARY
             SET TAX =  
             CASE
                WHEN COUNTSAL < 20000 THEN cur_sal.SALVALUE * 0.09
                WHEN COUNTSAL < 30000 THEN cur_sal.SALVALUE * 0.12
                ELSE cur_sal.SALVALUE * 0.15
             END
             WHERE CURRENT OF sal_cursor;
     END LOOP; 
COMMIT; 
END TASK_LOOP_CURSOR;
~~~
d) с помощью курсора с параметром, передавая номер сотрудника, для которого
необходимо посчитать налог.
~~~sql
CREATE  OR  REPLACE  PROCEDURE  TASK_PARAM (EMPID  NUMBER)  AS
    CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
    COUNTSAL NUMBER(16);
BEGIN
    FOR cur_sal IN sal_cursor  
     LOOP
         SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY sal
         WHERE sal.EMPNO = cur_sal.EMPNO AND sal.MONTH < cur_sal.MONTH AND sal.YEAR = cur_sal.YEAR;
         UPDATE SALARY
         SET TAX =  
            CASE
                WHEN COUNTSAL < 20000 THEN cur_sal.SALVALUE * 0.09
                WHEN COUNTSAL < 30000 THEN cur_sal.SALVALUE * 0.12
                ELSE cur_sal.SALVALUE * 0.15
            END
            WHERE CURRENT OF sal_cursor;
     END LOOP; 
   COMMIT;
END  TASK_PARAM;
~~~
4. Создайте функцию, вычисляющую налог на зарплату за всё время начислений для
конкретного сотрудника. В качестве параметров передать процент налога (до 20000, до
30000, выше 30000, номер сотрудника).
~~~sql
CREATE  OR  REPLACE  PROCEDURE  TASK_4 (EMPID  NUMBER, UNDER_20k NUMBER,
    OVER_20k NUMBER, OVER_30k NUMBER)  AS
    CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
    COUNTSAL NUMBER(16);
BEGIN
    FOR cur_sal IN sal_cursor  
     LOOP
         SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY sal
         WHERE sal.EMPNO = cur_sal.EMPNO AND sal.MONTH < cur_sal.MONTH AND sal.YEAR = cur_sal.YEAR;
         UPDATE SALARY
         SET TAX =  
            CASE
                WHEN COUNTSAL < 20000 THEN cur_sal.SALVALUE * UNDER_20k
                WHEN COUNTSAL < 30000 THEN cur_sal.SALVALUE * OVER_20k
                ELSE cur_sal.SALVALUE * OVER_30k
            END
            WHERE CURRENT OF sal_cursor;
     END LOOP; 
   COMMIT;
END  TASK_4;
~~~
5. Создайте подпрограмму, вычисляющую суммарный налог на зарплату сотрудника
за всё время начислений. В качестве параметров передать процент налога (до 20000, до
30000, выше 30000, номер сотрудника). Возвращаемое значение – суммарный налог.
~~~sql
CREATE OR  REPLACE  FUNCTION  TASK_5 (EMPID  NUMBER, UNDER_20k NUMBER,
    OVER_20k NUMBER, OVER_30k NUMBER) RETURN NUMBER   AS
    CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID;
    RESULT NUMBER(16);
    COUNTSAL NUMBER(16);
BEGIN
    RESULT := 0;
    FOR R IN sal_cursor LOOP
        SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

        RESULT := RESULT +
            CASE
                WHEN COUNTSAL < 20000 THEN R.SALVALUE * UNDER_20k
                WHEN COUNTSAL < 30000 THEN R.SALVALUE * OVER_20k
                ELSE R.SALVALUE * OVER_30k
            END;
    END LOOP;
    RETURN RESULT;
END  TASK_5;
~~~
6. Создайте пакет, включающий в свой состав процедуру вычисления налога для всех
сотрудников, процедуру вычисления налогов для отдельного сотрудника,
идентифицируемого своим номером, функцию вычисления суммарного налога на
зарплату сотрудника за всё время начислений.
~~~sql
CREATE OR REPLACE PACKAGE TAX_EVAL AS
    PROCEDURE TASK_SIMPLE_LOOP_CURSOR_IF;
    PROCEDURE TASK_PARAM (EMPID NUMBER);
    FUNCTION TASK_5 (UNDER_20k NUMBER, OVER_20k NUMBER, OVER_30k NUMBER, EMPID  NUMBER) RETURN NUMBER;
END TAX_EVAL;

CREATE OR REPLACE PACKAGE BODY TAX_EVAL AS

PROCEDURE TASK_SIMPLE_LOOP_CURSOR_IF AS
   COUNTSAL NUMBER(16);
   SALARY_RES NUMBER(16);
   CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
   R sal_cursor%ROWTYPE;
BEGIN
   OPEN sal_cursor;
   LOOP
       FETCH sal_cursor INTO R;
       EXIT WHEN sal_cursor%NOTFOUND;
       SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY S
           WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

        IF COUNTSAL < 20000 THEN
            SALARY_RES := R.SALVALUE * 0.09;
        ELSIF COUNTSAL < 30000 THEN
            SALARY_RES := R.SALVALUE * 0.12;
        ELSE
            SALARY_RES := R.SALVALUE * 0.15;
        END IF;

        UPDATE SALARY 
        SET TAX = SALARY_RES
        WHERE CURRENT OF sal_cursor;
   END LOOP;
   CLOSE sal_cursor;
   COMMIT;
END TASK_SIMPLE_LOOP_CURSOR_IF;

PROCEDURE  TASK_PARAM (EMPID  NUMBER)  AS
    CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
    COUNTSAL NUMBER(16);
BEGIN
    FOR cur_sal IN sal_cursor  
     LOOP
         SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY sal
         WHERE sal.EMPNO = cur_sal.EMPNO AND sal.MONTH < cur_sal.MONTH AND sal.YEAR = cur_sal.YEAR;
         UPDATE SALARY
         SET TAX =  
            CASE
                WHEN COUNTSAL < 20000 THEN cur_sal.SALVALUE * 0.09
                WHEN COUNTSAL < 30000 THEN cur_sal.SALVALUE * 0.12
                ELSE cur_sal.SALVALUE * 0.15
            END
            WHERE CURRENT OF sal_cursor;
     END LOOP; 
   COMMIT;
END  TASK_PARAM;

FUNCTION TASK_5 (UNDER_20k NUMBER, OVER_20k NUMBER, OVER_30k NUMBER, EMPID  NUMBER) RETURN NUMBER
AS
    CURSOR sal_cursor IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID;
    RESULT NUMBER(16);
    COUNTSAL NUMBER(16);
BEGIN
    RESULT := 0;
    FOR R IN sal_cursor LOOP
        SELECT SUM(SALVALUE) INTO COUNTSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

        RESULT := RESULT +
            CASE
                WHEN COUNTSAL < 20000 THEN R.SALVALUE * UNDER_20k
                WHEN COUNTSAL < 30000 THEN R.SALVALUE * OVER_20k
                ELSE R.SALVALUE * OVER_30k
            END;
    END LOOP;
    RETURN RESULT;
END  TASK_5;

END TAX_EVAL;
~~~
7. Создайте триггер, действующий при обновлении данных в таблице SALARY. А
именно, если происходит обновление поля SALVALUE, то при назначении новой
зарплаты, меньшей чем должностной оклад (таблица JOB, поле MINSALARY), изменение
не вносится и сохраняется старое значение, если новое значение зарплаты больше
должностного оклада, то изменение вносится.
~~~sql
CREATE OR REPLACE TRIGGER CHECK_SALARY
    BEFORE UPDATE OF SALVALUE ON SALARY FOR EACH ROW
DECLARE
    CURSOR CUR(EMPID CAREER.EMPNO%TYPE) IS
        SELECT MINSALARY FROM JOB
            WHERE JOBNO = (SELECT JOBNO FROM CAREER WHERE EMPID = EMPNO AND ENDDATE IS NULL);
    R JOB.MINSALARY%TYPE;
BEGIN
    OPEN CUR(:NEW.EMPNO);
    FETCH CUR INTO R;
    IF :NEW.SALVALUE < R THEN
        :NEW.SALVALUE := :OLD.SALVALUE;
    END IF;
    CLOSE CUR;
END CHECK_SALARY;
~~~
8. Создайте триггер, действующий при удалении записи из таблицы CAREER. Если в
удаляемой строке поле ENDDATE содержит NULL, то запись не удаляется, в противном
случае удаляется.
~~~sql
CREATE OR REPLACE TRIGGER CHECK_NOT_NULL
    BEFORE DELETE ON CAREER
    FOR EACH ROW
BEGIN
    IF :OLD.ENDDATE IS NULL
        Raise_Application_Error(-20100, 'You can not delete it');
    END IF;
END CHECK_NOT_NULL; 
или
CREATE OR REPLACE TRIGGER CHECK_NOT_NULL
    BEFORE DELETE ON CAREER
    FOR EACH ROW
    WHEN (OLD.ENDDATE IS NULL)
BEGIN
    Raise_Application_Error(-20100, 'You can not delete it');
END CHECK_NOT_NULL; 
~~~
9. Создайте триггер, действующий на добавление или изменение данных в таблице
EMP. Если во вставляемой или изменяемой строке поле BIRTHDATE содержит NULL, то
после вставки или изменения должно быть выдано сообщение ‘BERTHDATE is NULL’.
Если во вставляемой или изменяемой строке поле BIRTHDATE содержит дату ранее ‘01-
01-1940’, то должно быть выдано сообщение ‘PENTIONA’. Во вновь вставляемой строке
имя служащего должно быть приведено к заглавным буквам.
~~~sql
CREATE OR REPLACE TRIGGER ON_EMP_INSERT_UPDATE
    BEFORE INSERT OR UPDATE ON EMP
    FOR EACH ROW
BEGIN
    IF :NEW.BIRTHDATE IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('BIRTHDATE IS NULL');
    END IF;

    IF :NEW.BIRTHDATE < to_date('01-01-1940', 'dd-mm-yyyy') THEN
        DBMS_OUTPUT.PUT_LINE('PENTIONA');
    END IF;

    :NEW.EMPNAME := UPPER(:NEW.EMPNAME);
END ON_EMP_INSERT_UPDATE;
~~~
10. Создайте программу изменения типа заданной переменной из символьного типа
(VARCHAR2) в числовой тип (NUMBER). Программа должна содержать раздел
обработки исключений. Обработка должна заключаться в выдаче сообщения ‘ERROR:
argument is not a number’ . Исключительная ситуация возникает при задании строки в виде
числа с запятой, разделяющей дробную и целую части.
~~~sql
DECLARE
    X number;
    FUNCTION str2nr(str in varchar2) return NUMBER  IS
    BEGIN
        RETURN CAST(str AS NUMBER);
        EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('CLASS CAST EXCEPTION ' || str);
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20103, 'SHOULD NOT GET THERE');
        RETURN NULL;
    END;
BEGIN
    x := str2nr('ads');
    DBMS_OUTPUT.PUT_LINE(x);
    x := str2nr( '5.5' );
    DBMS_OUTPUT.PUT_LINE(x);
    x := str2nr( '17' );
    DBMS_OUTPUT.PUT_LINE(x);
    x := str2nr( '5,432' );
    DBMS_OUTPUT.PUT_LINE(x);
END;
~~~