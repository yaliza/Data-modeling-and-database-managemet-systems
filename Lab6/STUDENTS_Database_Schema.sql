DROP TABLE report_info;
DROP TABLE semester_subjects;
DROP TABLE reporting;
DROP TABLE semester_info;
DROP TABLE student;
DROP TABLE subject;
DROP TABLE pulpit;
DROP SEQUENCE sq_pulpit;

CREATE SEQUENCE sq_pulpit START WITH 1 MAXVALUE 9999;

CREATE TABLE pulpit (
    id     INTEGER PRIMARY KEY,
    name   VARCHAR2(50) NOT NULL
);

CREATE TABLE report_info (
    id                     INTEGER PRIMARY KEY,
    estimate               VARCHAR2(50),
    date_report                 DATE,
    semester_subjects_id   INTEGER NOT NULL,
    student_id             INTEGER NOT NULL
);

CREATE TABLE reporting (
    id     INTEGER PRIMARY KEY,
    kind   VARCHAR2(50) NOT NULL
);

CREATE TABLE semester_info (
    id         INTEGER PRIMARY KEY,
    num   INTEGER NOT NULL,
    course     INTEGER NOT NULL
);

CREATE TABLE semester_subjects (
    id                 INTEGER PRIMARY KEY,
    hoursnumber        INTEGER NOT NULL,
    semester_info_id   INTEGER NOT NULL,
    reporting_id       INTEGER NOT NULL,
    subject_id         INTEGER NOT NULL
);

CREATE TABLE student (
    id     INTEGER PRIMARY KEY,
    name   VARCHAR2(50) NOT NULL,
    pulpit_id   INTEGER
);

CREATE TABLE subject (
    id     INTEGER PRIMARY KEY,
    name   VARCHAR2(50) NOT NULL
);

ALTER TABLE student
    ADD CONSTRAINT student_pulpit_fk FOREIGN KEY ( pulpit_id )
        REFERENCES pulpit ( id );

ALTER TABLE report_info
    ADD CONSTRAINT report_info_student_fk FOREIGN KEY ( student_id )
        REFERENCES student ( id )  ON DELETE CASCADE;

ALTER TABLE semester_subjects
    ADD CONSTRAINT reporting_fk FOREIGN KEY ( reporting_id )
        REFERENCES reporting ( id )  ON DELETE CASCADE;

ALTER TABLE semester_subjects
    ADD CONSTRAINT semester_info_fk FOREIGN KEY ( semester_info_id )
        REFERENCES semester_info ( id )  ON DELETE CASCADE;

ALTER TABLE report_info
    ADD CONSTRAINT semester_subjects_fk FOREIGN KEY ( semester_subjects_id )
        REFERENCES semester_subjects ( id )  ON DELETE CASCADE;

ALTER TABLE semester_subjects
    ADD CONSTRAINT subject_fk FOREIGN KEY ( subject_id )
        REFERENCES subject ( id )  ON DELETE CASCADE;
        
CREATE OR REPLACE TRIGGER pulpit_trig BEFORE INSERT ON pulpit FOR EACH ROW BEGIN
:NEW.id:=sq_pulpit.NEXTVAL;
END;
/

CREATE INDEX student_name_ind ON student(name);
CREATE INDEX pulpit_name_ind ON pulpit(name);
CREATE INDEX subject_name_ind ON subject(name);

INSERT INTO semester_info VALUES(1, 1, 1);
INSERT INTO semester_info VALUES(2, 2, 1);
INSERT INTO semester_info VALUES(3, 1, 2);
INSERT INTO semester_info VALUES(4, 2, 2);
INSERT INTO semester_info VALUES(5, 1, 3);
INSERT INTO semester_info VALUES(6, 2, 3);
INSERT INTO semester_info VALUES(7, 1, 4);
INSERT INTO semester_info VALUES(8, 2, 4);

INSERT INTO subject VALUES(1, 'programming');
INSERT INTO subject VALUES(2, 'operating systems');
INSERT INTO subject VALUES(3, 'mathmatical modeling');
INSERT INTO subject VALUES(4, 'algorithms and data structures');
INSERT INTO subject VALUES(5, 'economics');
INSERT INTO subject VALUES(6, 'differential equations');
INSERT INTO subject VALUES(7, 'human life safety');
INSERT INTO subject VALUES(8, 'physical education');


INSERT INTO reporting VALUES (1, 'exam');
INSERT INTO reporting VALUES (2, 'test');

INSERT INTO semester_subjects VALUES(1, 64, 1, 1, 1);
INSERT INTO semester_subjects VALUES(2, 70, 1, 2, 8);
INSERT INTO semester_subjects VALUES(3, 70, 2, 2, 8);
INSERT INTO semester_subjects VALUES(4, 70, 3, 2, 8);
INSERT INTO semester_subjects VALUES(5, 70, 4, 2, 8);
INSERT INTO semester_subjects VALUES(6, 70, 5, 2, 8);
INSERT INTO semester_subjects VALUES(7, 70, 6, 2, 8);
INSERT INTO semester_subjects VALUES(8, 50, 4, 1, 2);
INSERT INTO semester_subjects VALUES(9, 50, 3, 2, 4);
INSERT INTO semester_subjects VALUES(10, 40, 4, 1, 5);
INSERT INTO semester_subjects VALUES(11, 70, 4, 1, 6);
INSERT INTO semester_subjects VALUES(12, 60, 4, 1, 3);
INSERT INTO semester_subjects VALUES(13, 64, 2, 1, 1);


INSERT INTO pulpit VALUES (1, 'management information systems');
INSERT INTO pulpit VALUES (2, 'programming technology');
INSERT INTO pulpit VALUES (3, 'computational mathematics');


INSERT INTO student  VALUES (1, 'Vasya', 1);
INSERT INTO student  VALUES (2, 'Kate', 2);
INSERT INTO student  VALUES (3, 'Serge', 3);
INSERT INTO student  VALUES (4, 'Clar', 1);
INSERT INTO student (id, name)  VALUES (5, 'Harry');
INSERT INTO student (id, name)  VALUES (6, 'Denis');


INSERT INTO report_info VALUES (1, '9', to_date('19-06-2017', 'dd-mm-yyyy'), 12 , 5);
INSERT INTO report_info VALUES (2, '4', to_date('19-06-2017', 'dd-mm-yyyy'), 12 , 6);
INSERT INTO report_info VALUES (3, '6', to_date('15-06-2017', 'dd-mm-yyyy'), 11 , 5);
INSERT INTO report_info VALUES (4, '7', to_date('15-06-2017', 'dd-mm-yyyy'), 11 , 6);
INSERT INTO report_info VALUES (5, '8', to_date('13-06-2017', 'dd-mm-yyyy'), 10 , 5);
INSERT INTO report_info VALUES (6, '8', to_date('13-06-2017', 'dd-mm-yyyy'), 10 , 6);
INSERT INTO report_info VALUES (7, '10', to_date('24-06-2017', 'dd-mm-yyyy'), 8 , 5);
INSERT INTO report_info VALUES (8, '9', to_date('24-06-2017', 'dd-mm-yyyy'), 8 , 6);
INSERT INTO report_info VALUES (9, '10', to_date('24-06-2017', 'dd-mm-yyyy'), 8 , 5);
INSERT INTO report_info VALUES (10, '9', to_date('24-06-2017', 'dd-mm-yyyy'), 8 , 6);
INSERT INTO report_info VALUES (11, 'pass', to_date('01-06-2017', 'dd-mm-yyyy'), 5 , 5);
INSERT INTO report_info VALUES (12, 'pass', to_date('01-06-2017', 'dd-mm-yyyy'), 5 , 6);