# postgresql-for-everybody-assignments

### Many-to-Many database design implementation assignment
```sql
--creating tables
CREATE TABLE student (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE course CASCADE;
CREATE TABLE course (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE roster CASCADE;
CREATE TABLE roster (
    id SERIAL,
    student_id INTEGER REFERENCES student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    role INTEGER,
    UNIQUE(student_id, course_id),
    PRIMARY KEY (id)
);

--inserting data into student table
INSERT INTO student (name) VALUES ('Judith');
INSERT INTO student (name) VALUES ('Destiny');
INSERT INTO student (name) VALUES ('Marcella');  
INSERT INTO student (name) VALUES ('Ridley');  
INSERT INTO student (name) VALUES ('Sorley');
INSERT INTO student (name) VALUES ('Eubha');
INSERT INTO student (name) VALUES ('Jamal');
INSERT INTO student (name) VALUES ('Kennedy'); 
INSERT INTO student (name) VALUES ('Litrell'); 
INSERT INTO student (name) VALUES ('Oswald');
INSERT INTO student (name) VALUES ('Keeley'); 
INSERT INTO student (name) values ('Architha');
INSERT INTO STUDENT (name) VALUES ('Capri);
INSERT INTO student (name) VALUES ('Leigha');
INSERT INTO student (name) VALUES ('Skyler');

--inserting data into course table
INSERT INTO course (title) VALUES ('si106');
INSERT INTO course (title) VALUES ('si110');
INSERT INTO course (title) VALUES ('si206');

--inserting data into roster table, keeping in mind the relation between different courses and students
INSERT INTO roster (student_id, course_id, role) VALUES (1,1,1);
INSERT INTO roster (student_id, course_id, role) VALUES (2,1,0); 
INSERT INTO roster (student_id, course_id, role) VALUES (3,1,0);  
INSERT INTO roster (student_id, course_id, role) VALUES (4,1,0);
INSERT INTO roster (student_id, course_id, role) VALUES (5,1,0); 
INSERT INTO roster (student_id, course_id, role) VALUES (6,2,1);                                                                  
INSERT INTO roster (student_id, course_id, role) VALUES (7,2,0);                                                                  
INSERT INTO roster (student_id, course_id, role) VALUES (8,2,0);                                                                  
INSERT INTO roster (student_id, course_id, role) VALUES (9,2,0);                                                                  
INSERT INTO roster (student_id, course_id, role) VALUES (10,2,0);                                                                 
INSERT INTO roster (student_id, course_id, role) VALUES (11,3,1);                                                                 
INSERT INTO roster (student_id, course_id, role) VALUES (12,3,0);                                                                 
INSERT INTO roster (student_id, course_id, role) VALUES (13,3,0);                                                                 
INSERT INTO roster (student_id, course_id, role) VALUES (14,3,0);                                                                 
INSERT INTO roster (student_id, course_id, role) VALUES (15,3,0); 

--running the test query
SELECT student.name, course.title, roster.role
    FROM student 
    JOIN roster ON student.id = roster.student_id
    JOIN course ON roster.course_id = course.id
    ORDER BY course.title, roster.role DESC, student.name;
```
#### Output
![Screenshot 2021-07-29 000152](https://user-images.githubusercontent.com/66962188/127380919-40b7957c-bd2f-4d04-9fdb-9d8212f99aa5.jpg)
