use college_db;

-- TASK 1
explain format=JSON
SELECT s.first_name, s.last_name, c.course_name FROM 
enrollments e   JOIN students s ON s.student_id = e.student_id   JOIN courses c ON c.course_id = 
e.course_id   WHERE s.enrollment_year = 2022;
/*
EXPLAIN
"{
  query_block"": {"
    "select_id": 1
    "cost_info": {
      "query_cost": "1.92"
    }
    "nested_loop": [
      {
        "table": {
          "table_name": "s"
          "access_type": "ALL"
          "possible_keys": [
            "PRIMARY"
          ]
          "rows_examined_per_scan": 8
          "rows_produced_per_join": 1
          "filtered": "12.50"
          "cost_info": {
            "read_cost": "0.95"
            "eval_cost": "0.10"
            "prefix_cost": "1.05"
            "data_read_per_join": "824"
          }
          "used_columns": [
            "student_id"
            "first_name"
            "last_name"
            "enrollment_year"
          ]
          "attached_condition": "(`college_db`.`s`.`enrollment_year` = 2022)"
        }
      }
      {
        "table": {
          "table_name": "e"
          "access_type": "ref"
          "possible_keys": [
            "student_id"
            "course_id"
          ]
          "key": "student_id"
          "used_key_parts": [
            "student_id"
          ]
          "key_length": "5"
          "ref": [
            "college_db.s.student_id"
          ]
          "rows_examined_per_scan": 1
          "rows_produced_per_join": 1
          "filtered": "100.00"
          "cost_info": {
            "read_cost": "0.31"
            "eval_cost": "0.12"
            "prefix_cost": "1.49"
            "data_read_per_join": "40"
          }
          "used_columns": [
            "student_id"
            "course_id"
          ]
          "attached_condition": "(`college_db`.`e`.`course_id` is not null)"
        }
      }
      {
        "table": {
          "table_name": "c"
          "access_type": "eq_ref"
          "possible_keys": [
            "PRIMARY"
          ]
          "key": "PRIMARY"
          "used_key_parts": [
            "course_id"
          ]
          "key_length": "4"
          "ref": [
            "college_db.e.course_id"
          ]
          "rows_examined_per_scan": 1
          "rows_produced_per_join": 1
          "filtered": "100.00"
          "cost_info": {
            "read_cost": "0.31"
            "eval_cost": "0.12"
            "prefix_cost": "1.93"
            "data_read_per_join": "880"
          }
          "used_columns": [
            "course_id"
            "course_name"
          ]
        }
      }
    ]
  }
}"
*/

-- the above query execution plan intends to do a full table scan on the table students...this can be inferred from the following part of the output
/*
"table_name": "s"
"access_type": "ALL"
*/

/*
estimated rows examined=8(students table)+1(enrollments table)+1(courses table)=10
*/

-- TASK 2
create index idx_enrollment_year on students(enrollment_year);
create unique index idx_student_id_and_course_id on enrollments(student_id,course_id);
create index idx_course_code on courses(course_code);

explain format=JSON
SELECT s.first_name, s.last_name, c.course_name FROM 
enrollments e   JOIN students s ON s.student_id = e.student_id   JOIN courses c ON c.course_id = 
e.course_id   WHERE s.enrollment_year = 2022;
/*
EXPLAIN
"{
  query_block"": {"
    "select_id": 1
    "cost_info": {
      "query_cost": "4.47"
    }
    "nested_loop": [
      {
        "table": {
          "table_name": "s"
          "access_type": "ref"
          "possible_keys": [
            "PRIMARY"
            "idx_enrollment_year"
          ]
          "key": "idx_enrollment_year"
          "used_key_parts": [
            "enrollment_year"
          ]
          "key_length": "5"
          "ref": [
            "const"
          ]
          "rows_examined_per_scan": 4
          "rows_produced_per_join": 4
          "filtered": "100.00"
          "cost_info": {
            "read_cost": "0.50"
            "eval_cost": "0.40"
            "prefix_cost": "0.90"
            "data_read_per_join": "3K"
          }
          "used_columns": [
            "student_id"
            "first_name"
            "last_name"
            "enrollment_year"
          ]
        }
      }
      {
        "table": {
          "table_name": "e"
          "access_type": "ref"
          "possible_keys": [
            "idx_student_id_and_course_id"
            "course_id"
          ]
          "key": "idx_student_id_and_course_id"
          "used_key_parts": [
            "student_id"
          ]
          "key_length": "5"
          "ref": [
            "college_db.s.student_id"
          ]
          "rows_examined_per_scan": 1
          "rows_produced_per_join": 5
          "filtered": "100.00"
          "using_index": true
          "cost_info": {
            "read_cost": "1.00"
            "eval_cost": "0.57"
            "prefix_cost": "2.47"
            "data_read_per_join": "182"
          }
          "used_columns": [
            "student_id"
            "course_id"
          ]
          "attached_condition": "(`college_db`.`e`.`course_id` is not null)"
        }
      }
      {
        "table": {
          "table_name": "c"
          "access_type": "eq_ref"
          "possible_keys": [
            "PRIMARY"
          ]
          "key": "PRIMARY"
          "used_key_parts": [
            "course_id"
          ]
          "key_length": "4"
          "ref": [
            "college_db.e.course_id"
          ]
          "rows_examined_per_scan": 1
          "rows_produced_per_join": 5
          "filtered": "100.00"
          "cost_info": {
            "read_cost": "1.43"
            "eval_cost": "0.57"
            "prefix_cost": "4.47"
            "data_read_per_join": "3K"
          }
          "used_columns": [
            "course_id"
            "course_name"
          ]
        }
      }
    ]
  }
}"
*/
/* we can see from the ouput that the full table sequential scan on students table is now changed to reference/index based scan
this should reduce the estimated no of rows examined in theory..let's calculate it
estimated rows examined = 4(students table)+1(enrollments table)+1(courses table) = 6
when compared to previous 10 rows examined this is definitely much more optimized
*/
-- partial indexing doesn't work in MySQL
