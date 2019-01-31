Триггер должен препятствовать удалению информации о предмете, если
в базе данных есть сведения о студентах, сдававших этот предмет.
~~~sql
CREATE OR REPLACE TRIGGER ON_DELETE_SUBJECT
    BEFORE DELETE ON subject
    FOR EACH ROW
DECLARE
    CURSOR CUR(SUBID SUBJECT.ID%TYPE) IS
        SELECT count(st.id) as "num" FROM semester_subjects sem_sub
            INNER JOIN report_info rep_info ON sem_sub.id = rep_info.semester_subjects_id
            INNER JOIN student st ON st.id = rep_info.student_id
            WHERE  sem_sub.subject_id = SUBID;
    R NUMBER;
BEGIN
    OPEN CUR(:OLD.ID);
    FETCH CUR INTO R;
    IF R > 0 THEN
        Raise_Application_Error(-20100, 'YOU CAN NOT DELETE THIS SUBJECT BECAUSE YOU HAVE STUDENTS PASSED IT');
    END IF;
END ON_DELETE_SUBJECT;
~~~
Примеры:
~~~sql
delete from subject where name = 'operating systems' and id = 2;
delete from subject where id = 3 and name = 'mathmatical modeling';
delete from subject where id = 1 and name = 'programming';
~~~