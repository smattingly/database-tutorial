-- This script sets up the environment expected at the beginning of the tutorial.

create database learning_center;

use learning_center;

create table visit (
  first_name varchar(128) not NULL,
  last_name varchar(128) not NULL,
  email varchar(128) not NULL,
  academic_rank varchar(128) not NULL,
  residential_status varchar(128) not NULL,
  majors varchar(128),
  sports varchar(128),
  slp_instructor_first_name varchar(128),
  slp_instructor_last_name varchar(128),
  check_in_time timestamp not NULL default CURRENT_TIMESTAMP, 
  check_out_time timestamp NULL default NULL,
  location varchar(128) not NULL,
  purpose varchar(255) not NULL,
  purpose_achieved char(1),
  tutoring varchar(255),
  comments varchar(255)
);

insert into visit values 
  ('Gary', 'Gatehouse', 'ggatehouse@dewv.net', 'Sophomore', 'On campus', 'Math, Comp Sci', NULL, 'Terry', 'Tutor', '2016-08-30 14:35:55', '2016-08-30 15:53:44', 'Albert Hall', 'study hall', 'Y', NULL, 'New year, fresh start!'),
  ('Charlie', 'Cadillac', 'ccadillac@dewv.net', 'Junior', 'Off campus', 'English', 'Men\'s soccer, Baseball', 'Tery', 'Tutor', '2016-08-30 14:55:55', '2016-08-30 16:53:44', 'Albert Hall', 'baseball meeting', '?', NULL, NULL),
  ('Irving', 'Icehouse', 'iicehouse@dewv.net', 'Sophomore', 'On campus', 'Chemistry', NULL, 'Sam', 'Studybuddy', '2016-08-30 15:56:56', '2016-08-30 16:56:46', 'Albert Hall', 'Meet SLP instructor', 'Y', NULL, 'Cubicle B computer is not working.'),
  ('Alice', 'Albert', 'aalbert@dewv.net', 'Junior', 'On campus', 'Computer Science', NULL, 'Sam', 'Studybuddy', '2016-08-30 16:15:05', '2016-08-30 16:50:04', 'Albert Hall', 'Study hall', 'Y', NULL, NULL),
  ('Debbie', 'Davis', 'ddavis@dewv.net', 'Freshman', 'On campus', 'Philosophy and English', 'Women\'s soccer, Softball', NULL, NULL, '2016-08-30 16:36:56', '2016-08-30 17:57:47', 'Albert Hall', 'Tour of learning center', 'Y', NULL, NULL),
  ('Bob', 'Booth', 'bbooth@dewv.net', 'Sophomore', 'On campus', 'Computer Science, Philosophy', 'Men\'s golf', NULL, NULL, '2016-08-30 16:44:54', '2016-08-30 16:53:44', 'Albert Hall', 'study hall', 'Y', NULL, 'New year, fresh start!'),
  ('Eric', 'Elkins', 'eelkins@dewv.net', 'Senior', 'Off campus', 'Biology', 'Baseball', NULL, NULL, '2016-08-30 16:49:59', '2016-08-30 16:56:46', 'Albert Hall', 'Team Meeting', 'N', NULL, 'Sorry coach i had wrong time. my bad'),
  ('Hannah', 'Hermanson', 'hhermanson@dewv.net', 'Senior', 'On campus', 'Chemistry', NULL, NULL, NULL, '2016-08-30 16:55:55', '2016-08-30 16:59:44', 'Albert Hall', 'study hall', 'Y', NULL, NULL),
  ('Frank', 'Forest', 'fforest@dewv.net', 'Freshman', 'On campus', 'Undecided', NULL, NULL, NULL, '2016-08-30 16:59:05', '2016-08-30 17:03:40', 'Albert Hall', 'math help', 'Y', 'Math 101', NULL),
  ('Frank', 'Forest', 'fforest@dewv.net', 'Freshman', 'On campus', 'Undecided', NULL, NULL, NULL, '2016-08-31 11:19:15', '2016-08-31 12:23:22', 'Albert Hall', 'math help', 'Y', 'MATH 101', NULL),
  ('Charlie', 'Cadillac', 'cadillac@dewv.net', 'Junior', 'Off campus', 'English', 'Men\'s soccer, Baseball', 'Tery', 'Tutor', '2016-08-31 11:51:15', '2016-08-31 11:53:44', 'Albert Hall', 'get form signature', 'Y', NULL, NULL),
  ('Debbie', 'Davis', 'ddavis@dewv.net', 'Freshman', 'On campus', 'Philosophy and English', 'Women\'s soccer, Softball', NULL, NULL, '2016-08-31 13:36:36', '2016-08-31 14:47:44', 'Writing center', 'Help with paper', 'Y', NULL, NULL),
  ('Gary', 'Gatehouse', 'ggatehouse@dewv.net', 'Sophomore', 'On campus', 'Math, Comp Sci', NULL, 'Terry', 'Tutor', '2016-08-31 14:36:56', NULL, 'Albert Hall', 'study hall', NULL, NULL, NULL),
  ('Debra', 'Davis', 'ddavis@dewv.net', 'Freshman', 'On campus', 'Philosophy and English', 'Women\'s soccer, Softball', NULL, NULL, '2016-08-31 16:00:06', NULL, 'Albert Hall', 'MATH 101', NULL, NULL, NULL)
;
