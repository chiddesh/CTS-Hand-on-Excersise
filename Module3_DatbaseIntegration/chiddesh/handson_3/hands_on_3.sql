use college_db;
-- TASK 1
select concat(s.first_name," ",s.last_name) as full_name,count(*) from students s join enrollments using(student_id) 
group by s.student_id 
having (count(*)>(select avg(enrollment_count) from (select count(*) as enrollment_count from enrollments group by student_id) as t));
select c.course_name from courses c join enrollments e using(course_id) group by course_id
having(count(*)=(select count(*) from enrollments where course_id=c.course_id and grade='A' group by course_id));
select prof_name,p.department_id,salary from professors p
where salary=(select max(salary) from professors where department_id=p.department_id);
select p.department_id,d.dept_name,avg(p.salary) as average_salary from professors p join departments d using(department_id) group by p.department_id having(avg(p.salary)>85000);

-- TASK 2
create or replace view vw_student_enrollment_summary as
select concat(s.first_name,' ',s.last_name) as full_name, d.dept_name as department_name, 
coalesce(avg(case e.grade
when 'A' then 4
when 'B' then 3
when 'C' then 2
when 'D' then 1
when 'F' then 0
end
),0) as GPA,
count(course_id) as courses_enrolled
from students s left join enrollments e using(student_id) 
left join departments d using(department_id)
group by s.student_id;

create or replace view vw_course_stats as 
select c.course_name, c.course_code, count(e.course_id) as total_enrollments,
coalesce(avg(case e.grade
when 'A' then 4
when 'B' then 3
when 'C' then 2
when 'D' then 1
when 'F' then 0
end
),0) as avg_gpa
from courses c left join enrollments e using(course_id) group by course_id;

select * from vw_student_enrollment_summary where GPA>3.0;
/*
update vw_student_enrollment_summary set GPA=3 where full_name='Arjun Mehta';
the above command doesn't work
updation through a view is not possible if there are any joins or aggregate functions used
*/
drop view vw_student_enrollment_summary;
drop view vw_course_stats;

create or replace view vw_student_enrollment_summary as
select concat(s.first_name,' ',s.last_name) as full_name, d.dept_name as department_name, 
coalesce(avg(case e.grade
when 'A' then 4
when 'B' then 3
when 'C' then 2
when 'D' then 1
when 'F' then 0
end
),0) as GPA,
count(course_id) as courses_enrolled
from students s left join enrollments e using(student_id) 
left join departments d using(department_id)
group by s.student_id;

create or replace view vw_course_stats as 
select * from courses with check option;

-- TASK 3
Delimiter //
create procedure sp_enroll_student(in s_id int, in c_id int, in e_date date)
Begin
if not exists(
select * from enrollments where student_id=s_id and course_id=c_id and enrollment_date=e_date
)
then
insert into enrollments(student_id,course_id,enrollment_date) values(s_id,c_id,e_date);
else
select "enrollment already exists" as msg;
end if;
end //
Delimiter ;
create table department_transfer_log(transfer_id int auto_increment primary key,student_id int,old_dept_id int,new_dept_id int, transfer_date timestamp default current_timestamp,foreign key(student_id) references students(student_id),foreign key(new_dept_id) references departments(department_id));
Delimiter //
create procedure sp_transfer_student(in s_id int,in nd_id int)
begin
declare od_id int;
declare exit handler for sqlexception
begin
select "some error has occurred" as msg;
rollback;
end;
start transaction;
select department_id into od_id from students where student_id=s_id;
update students set department_id=nd_id where student_id=s_id;
insert into department_transfer_log(student_id,old_dept_id,new_dept_id) values(s_id,od_id,nd_id);
commit;
end //
Delimiter ;

call sp_transfer_student(20,5);
start transaction;
insert into enrollments(student_id,course_id,enrollment_date,grade) values
(9,1,current_date(),'A');
savepoint sp_1;
insert into enrollments(student_id,course_id,enrollment_date,grade) values
(10,1,current_date(),'A');
rollback to sp_1;
commit;
select * from enrollments;