-- TASK 1 CREATE THE DATABASE AND TABLES
create database college_db;
use college_db;

create table departments(
  department_id int primary key auto_increment, 
  dept_name varchar(100) not null, 
  hod_name varchar(100), 
  budget decimal(12,2)
  );

create table students(
  student_id int primary key auto_increment, 
  first_name varchar(50) not null, 
  last_name varchar(50) not null, 
  email varchar(100) unique not null, 
  date_of_birth date, 
  department_id int,
  enrollment_year int, 
  foreign key(department_id) references departments(department_id)
  );


create table courses(
  course_id int primary key auto_increment, 
  course_name varchar(150) not null, 
  course_code varchar(20) unique, 
  credits int, 
  department_id int, 
  foreign key(department_id) references departments(department_id)
  );

create table enrollments(
  enrollment_id int primary key auto_increment, 
  student_id int, 
  course_id int, 
  enrollment_date date, 
  grade char(2) check(grade in ('A','B','C','D','F') or grade is null), 
  foreign key(course_id) references courses(course_id),
  foreign key(student_id) references students(student_id)
  );

  create table professors(
    professor_id int primary key auto_increment,
    prof_name varchar(100) not null,
    email varchar(100) unique,
    department_id int,
    salary decimal(10,2),
    foreign key(department_id) references departments(department_id)
  );

describe departments;
describe students;
describe courses;
describe enrollments;
describe professors;


-- TASK 2 VERIFY NORMALISATION
/*
1NF: there are no columns in any of the tables which store multiple values together as same entry...so 1NF is satisfied
2NF: there are no partial dependencies so far in any of the tables and every entry in a row depends and can be uniquely identified only using the primary key..so 2NF is satisfed
3NF: there are no transitive dependencies in any of the tables..so 3NF is satisfied

	 if dept_name is stored in students table then would it violate 3NF?
     yes it would, in this scenario dept_name can be uniquely identified by dept_id and there is really no need for the primary key for this
     this would inturn increase duplication..say 10 students are of cyber department then cyber department name is repeatedly stored ten times..that's not efficient
     however our current structure eliminates this redundancy
*/

-- TASK 3 ALTER AND EXTEND THE SCHEMA

alter table students add phone_number varchar(15);
alter table courses add max_seats int default 60;
alter table enrollments add constraint check_grade check(grade in ('A','B','C','D','F') or grade is null);
alter table departments change column hod_name head_of_department varchar(100);
alter table students drop column phone_number;

describe departments;
describe students;
describe courses;
describe enrollments;
describe professors;



















