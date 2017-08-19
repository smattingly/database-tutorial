# Databases in Context: A Just-in-Time Tutorial

[Steve Mattingly](https://www.linkedin.com/in/steve-mattingly-aab8064a), Assistant Professor of Computer Science, [Davis & Elkins College](https://www.dewv.edu).

*Databases in Context: A Just-in-Time Tutorial* by Stephen S. Mattingly is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/). ![Creative Commons Attribution-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)

------

Learn more about Open Educational Resources at [UNESCO](http://www.unesco.org/new/en/communication-and-information/access-to-knowledge/open-educational-resources/). ![UNESCO Open Educational Resources logo](http://www.unesco.org/new/typo3temp/pics/5d3118e041.jpg)

------

[Contents](#Contents)

------

## Preface

Many textbooks begin by teaching you how to design and/or create databases. Even those that provide some context with running organizational examples often organize their coverage by grouping logically similar database operations. Most are written as if all users write custom queries and execute them using tools that are realistically meant for database experts. 

This tutorial's approach is just-in-time learning in a real organizational context, aimed at current or future technical professionals who are new to database concepts. Just like a new technical employee, you will explore an already existing database and the application software that manipulates it using SQL statements  embedded within the program code. As you learn to perform basic tasks, you will discover some problems with the database design. These problems motivate a redesign, restructuring, and extension of the database that introduces database operations in context.

## Introduction

An operating system implements a file system to hide the details of lower level storage devices. This allows higher level software to store and retrieve data using the abstraction of named files. A tree structure of folders is often used to organize files.

A **Database Management System (DBMS)** is software that hides the details of file systems so that application software can store and retrieve data using even higher level abstractions. Hiding the details of the OS file system can improve the performance, security, and reliability of the data while allowing flexible multi-user remote access.

The details of the data abstractions vary from one type of DBMS to another. Since the 1970s, the relational data model has dominated. More recently, object databases, "NoSQL" databases, and hybrid models have become popular.

This tutorial will focus on MySQL as an example of a relational DBMS. (Most of the content will transfer easily to other relational DBMSs like Microsoft SQL Server and Oracle.) A briefer look at the NoSQL models is also included.

## Relational databases

The "relation" in relational databases refers to the (hopefully) familiar concept of a relation between sets. 

A **set** is a collection of elements where no particular order is defined, and duplicate items are allowed. For example, $\lbrace Bob, Alice \rbrace$ is a set with two elements, and $\lbrace  Linux, iOS, Android, Windows \rbrace$ is a set with four elements.

A **relation** is a mapping from one set to another. For example, suppose that the first set above represents some technology users, and the second set represents the operating systems that they might use. Then the following relation maps one set to the other, telling us who uses which operating system(s): $ \lbrace (Bob, Windows), (Bob, iOS), (Alice, Linux), (Alice, Android), (Alice, Windows) \rbrace$. In this context, the set of all users is called the relation's **domain**, and the set of all OSs is called the relation's **range**.

There are various ways to describe a relation, but here it is given as a set of ordered pairs, where each pair represents a fact: Bob uses Windows, Bob uses iOS, Alice uses Linux, and so on. Database designers often rely on the **Closed World Assumption**, where any fact that is not recorded as true is assumed to be false. Under the Closed World Assumption, Bob does not use Linux and Alice does not use iOS.

Notice that the relation (a mapping between sets) is itself another set. This is an example of **closure**: when an operation's result is the same type of thing as the inputs it operates on, the inputs are **closed** under that operation. For example, the set of integers is closed under the addition, subtraction, and multiplication operations. But the integers are not closed under division, because (for example) 3 divided by 4 is 0.75, and the result is not an integer. Later, you will see that closure in relational DBMS operations supports sophisticated data manipulation.

The set notation used above is common in studies of formal logic. In this tutorial, formal logic notations and concepts will be introduced when and where they are helpful to communicate important points. But databases are typically depicted in tabular format. Here is the relation described above, in table form.

| user  | operating system |
| ----- | ---------------- |
| Bob   | Windows          |
| Bob   | iOS              |
| Alice | Linux            |
| Alice | Android          |
| Alice | Windows          |

So, a **relational database** is a collection of relations that record facts about sets of things that interest us. 

But you will usually think of relations as tables, and a database as a collection of tables.

## SQL and MySQL

Most relational database management software uses a language called **SQL** (Structured Query Language). This is sometimes pronounced as three letters: S-Q-L; sometimes it is pronounced like the word "sequel". SQL is not a full programming language-- it is not Turing complete. It is designed for defining database structures and manipulating their contents.

Relational database theorists like E.F. Codd (the creator of the relational model) have pointed out that SQL is not a full implementation of the relational data model. Also, SQL allows some operations that are not allowed under the relational model (for example, operations that do not have closure). But in everyday practical terms, relational database products typically use SQL.

**MySQL** is a particular software product-- an open source client-server DBMS that uses SQL. Due to its popularity and easy availability, this tutorial uses MySQL. Most of the SQL that you will learn works on other relational DBMS products, but there are some differences. 

## Tracking student participation with a MySQL database

At Davis & Elkins College (D&E), the Naylor Center for Teaching and Learning tracks student participation in its various service offerings. At first, the Learning Center used paper logs for student visits. But paper was problematic. It was difficult to sort, search, and summarize data. Data integrity suffered because students often forgot to check in or to check out. (**Data integrity** refers to the accuracy, completeness, and consistency of data.)

The Learning Center staff collaborated with D&E computer science faculty and students to create a Web application that uses a MySQL database to store student participation data. Through the computer science Professional Experience courses, the [DevOps](https://www.dewv.net/) organization designed, built, and maintains the application and database.

The Learning Center staff explained that they needed to track the following data about student participation in service offerings.

1. Student name
2. Email address
3. Academic rank (freshman, sophomore, junior, senior)
4. Residential status (on- or off-campus)
5. Major
6. Is student an athlete? Yes/No
   a. If so, which sport?
7. Is student in the Supported Learning Program? Yes/No
   a. If so, who is your SLP instructor?
8. Date of student's visit to the Learning Center
9. Length of visit, to nearest quarter hour
10. Location (the Learning Center offers services in Albert Hall, the Writing Center, and the Commuter Lounge)
11. Goal or purpose of the visit
12. Was the goal met? Yes/No/Not sure
13. Did the student meet with a tutor?
    a. If so, for which course?
14. Comments

A naïve approach to database design would create a table with one column for each of the items listed above. After some analysis, though, the computer science students noticed the following important points.

- It is unnecessary to store a Yes/No value for item 6 above. Instead, you can just record the student's sport if they are an athlete; if not, the sport column can be empty. The same idea can be applied to items 7 and 13 above.
- With the move to electronic tracking, items 8 through 10 can be automated as follows. 
  - Each Learning Center location has at least one computer. The computer can be configured to "know" its location. When students arrive, they "check in" by visiting the Web application using the computer. Students must log in to establish their identity, then enter much of the data listed above. But the software automatically stores the location, date, *and time* in the database. 
  - When students leave, they "check out" by again visiting the Web application. Again, the server date and time are captured so that the length of the visit can be automatically calculated. The check out step also provides the opportunity for students to enter "post visit" information: items 12 through 14.

## How to explore a MySQL installation

When you get to the heart of data definitions and manipulations, you can rely on (fairly) standard SQL. But to reach that point, you must start with some details that are specific to your DBMS, OS, and hosting environment.

This tutorial assumes that an instructor has already provided you with: 

1. a default Ubuntu Linux workspace hosted on [Cloud9](https://www.c9.io/) where you can open a bash shell (terminal), and
2. the initial version of the example MySQL database is already in place in your Cloud9 workspace.

If that is not the case, see the appendix for help with setting up a work environment.

### Starting the MySQL server

In the terminal, type `mysql-ctl start`. This starts the MySQL server processes if they are not already running; if they are running they will be restarted. (Important note: this command is specific to the Cloud9 hosting environment. It will not work in a native Linux environment running MySQL. Also, in a production environment you should avoid needless restarts of a running database server.)

You should see a message that indicates the server is started. You may also see a message about checking tables; this is a normal server maintenance task. The database server is now running in the background, waiting for clients to connect. You are returned to the bash prompt.

### Logging in with the `mysql` client

At the bash prompt, type `mysql -u root`. This launches the standard terminal-based MySQL client program; it will connect to the running MySQL server, using `root` as the MySQL username. (Important note: in a production system, you should avoid running as root except when absolutely necessary, and of course the root account should at least have a strong password. Due to the nature of the Cloud9 workspaces, this tutorial neglects this critical security practice, but that is ***not*** a justification for neglecting it in a professional setting.)

In place of the operating system prompt, you should now see a `mysql>` prompt, which tells you that the client is waiting for your command.

### Finding and selecting a database

A MySQL server hosts multiple databases. Each database is a named collection of tables and other things. Each database is a namespace. To list the databases that are present on the server, type `show databases;` and press Enter. You should see the following results.

```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| c9                 |
| mysql              |
| learning_center    |
| performance_schema |
| phpmyadmin         |
+--------------------+
6 rows in set (0.03 sec)
```

A couple of notes:

- Commands end with a semicolon. If you press the Enter key without a final semicolon, you may see a continuation prompt `->`. The client is prompting you to continue with your command. If you have made an error and you want to get back to the `mysql>` prompt, just type a semicolon and press Enter.
- Much like an OS prompt, you can use the up and down arrow keys to cycle through your previous queries. You can then edit them at the database prompt.
- SQL *commands* are not case-sensitive. `SHOW DATAbASeS;` will work fine. However, a few keywords and all user-defined identifiers (such as table and column names) *are* case-sensitive.

At this point, you have not selected a database to use. You will use the `learning_center` database, so select it with the following command: `use learning_center;`. (This is much like using `cd` to change to a particular folder in the file system. Your current folder or database becomes the default namespace for files or table names that appear in your commands.)

By the way, the other databases listed above are automatically created by MySQL for its own internal use, or by related admin tools and the hosting environment. You should generally consider these databases "off limits", because modifying them may prevent MySQL from working correctly.

---

Each time you sit down to work with MySQL, you will need to repeat the preceding steps to:

1. (re)start the MySQL server,
2. login with a MySQL client, and
3. select the database that you want to work on.

---

### Listing the tables in the database 

Now that you are using the `learning_center` database, you can explore its contents. To see a list of tables in the current database, type `show tables;`.

```
mysql> show tables;
+---------------+
| Tables_in_nlc |
+---------------+
| visit         |
+---------------+
1 row in set (0.00 sec)
```

This database has only one table, named `visit`.

You can see a list of the columns in a table with `describe <table_name>;`. (In these instructions, angle brackets `< >` around words like `<table_name>` represent placeholders that you must replace appropriately.) Here's an example.

```false
mysql> describe visit;
+---------------------------+--------------+------+-----+-------------------+-------+
| Field                     | Type         | Null | Key | Default           | Extra |
+---------------------------+--------------+------+-----+-------------------+-------+
| first_name                | varchar(128) | NO   |     | NULL              |       |
| last_name                 | varchar(128) | NO   |     | NULL              |       |
| email                     | varchar(128) | NO   |     | NULL              |       |
| academic_rank             | varchar(128) | NO   |     | NULL              |       |
| residential_status        | varchar(128) | NO   |     | NULL              |       |
| majors                    | varchar(128) | YES  |     | NULL              |       |
| sports                    | varchar(128) | YES  |     | NULL              |       |
| slp_instructor_first_name | varchar(128) | YES  |     | NULL              |       |
| slp_instructor_last_name  | varchar(128) | YES  |     | NULL              |       |
| check_in_time             | timestamp    | NO   |     | CURRENT_TIMESTAMP |       |
| check_out_time            | timestamp    | YES  |     | NULL              |       |
| location                  | varchar(128) | NO   |     | NULL              |       |
| purpose                   | varchar(255) | NO   |     | NULL              |       |
| purpose_achieved          | char(1)      | YES  |     | NULL              |       |
| tutoring                  | varchar(255) | YES  |     | NULL              |       |
| comments                  | varchar(255) | YES  |     | NULL              |       |
+---------------------------+--------------+------+-----+-------------------+-------+
16 rows in set (0.01 sec)
```

Note that `describe` is a non-SQL command specific to the MySQL product; other DMBS products will have different commands with a similar effect.

The first column of these results lists the 16 column names in the `visit` table. **Field** is another word for column, by the way.  The second column lists the datatype for each field. Most have a datatype of `VARCHAR`, which is character (textual) data. The maximum length of a value is specified in parentheses. `purpose_achieved` is a fixed-length one character field because it stores Y or N for Yes or No. Two of the fields store `TIMESTAMP` data, a date and time datatype with some special characteristics. 

## Retrieving data

The `learning_center` database's `visit` table tracks student visits to Learning Center locations. It's time to take a look at the table's data contents.

### All table contents

The SQL `SELECT` statement reads or retrieves rows from database tables. This statement has many complex options, but the most basic form will show all rows and columns in a given table: `select * from <table_name>;`. 

Since you have a table named `visit`, you would display all its rows and columns by executing `select * from visit;`.

Unfortunately, the results are not very readable. With 16 columns the table is so "wide" that each row must wrap, making it hard to see the table structure. One way to work around the problem is to list the results "vertically" with `\G` like this: `select * from visit \G`. (Note that there is no semicolon, and it must be a capital 'G'.) This format is more readable, but you must do a lot of scrolling.

But most of the time, you will work around the problem by selecting only the columns you need to see.

### Selected columns

The asterisk or "star" character in the previous SQL statement asks for all the table columns. Often, you do not need to see all the columns. You can ask for only the columns you need by listing them in the statement: `select <column_name> [ , <column_name> ... ] from <table_name>;`. The square brackets `[ ]` are not SQL; like the angle brackets, they are meta-characters that mark syntax options. The square brackets surround optional portions of statements. The ellipsis `...` means that the optional portion can be repeated.

Remember that you can get a table's column names with the `DESCRIBE` command. So, you can list just the columns you need to see. The list must contain at least one column name, and it can contain more, which are separated by commas. For example, run the query below.

```
mysql> select first_name, last_name, check_in_time, check_out_time from visit;                                            
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Gary       | Gatehouse | 2016-08-30 14:35:55 | 2016-08-30 15:53:44 |
| Charlie    | Cadillac  | 2016-08-30 14:55:55 | 2016-08-30 16:53:44 |
| Irving     | Icehouse  | 2016-08-30 15:56:56 | 2016-08-30 16:56:46 |
| Alice      | Albert    | 2016-08-30 16:15:05 | 2016-08-30 16:50:04 |
| Debbie     | Davis     | 2016-08-30 16:36:56 | 2016-08-30 17:57:47 |
| Bob        | Booth     | 2016-08-30 16:44:54 | 2016-08-30 16:53:44 |
| Eric       | Elkins    | 2016-08-30 16:49:59 | 2016-08-30 16:56:46 |
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
| Frank      | Forest    | 2016-08-30 16:59:05 | 2016-08-30 17:03:40 |
| Frank      | Forest    | 2016-08-31 11:19:15 | 2016-08-31 12:23:22 |
| Charlie    | Cadillac  | 2016-08-31 11:51:15 | 2016-08-31 11:53:44 |
| Debbie     | Davis     | 2016-08-31 13:36:36 | 2016-08-31 14:47:44 |
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL                |
| Debra      | Davis     | 2016-08-31 16:00:06 | NULL                |
+------------+-----------+---------------------+---------------------+
14 rows in set (0.00 sec)
```

These results are much easier to read. They still include all 14 of the table's rows, but only the four columns that you listed. 

Each result row represents a student's visit to a Learning Center location. For example, Gary Gatehouse arrived on August 30 at 2:35 p.m. Gary left at 3:53 p.m. The other details of the visit are not shown here; they are recorded in the other twelve columns that are not listed in the query.

Notice that Gary arrived for another visit on August 31 at almost the same time. The `NULL` entry in the `check_out_time` column means that Gary has not completed the check out process to record the end of his visit. Imagine that it is now the afternoon of August 31, some time after 2:36 p.m. Gary is still participating in his Learning Center activity. In fact it must be after 4:00 p.m., because Debra Davis arrived then; she also is still participating in some Learning Center activity. (Remember that check in and check out times are automatically captured by application software, not entered by users. So these time stamps must be accurate, barring incorrect hardware clocks or a security breach.)

The `NULL` entry that appears in the last two records is a special SQL data value (or *non-*value) that indicates a missing piece of information. It is not a data value so much as the *absence* of any value. In different circumstances, it could imply that the data value is not known, does not exist, or is not applicable.

Notice that the query results are themselves a table, or in formal terms, a relation. This query illustrates closure-- it operates on relations and produces a relation. Like all relations, it is a mapping between sets. Here, the domain is the set of all the college's students, and the range is the set of all valid date/time values. 

### Selected rows

So far, your queries have returned all 14 rows in the table. But suppose that you were only interested in Gary's visits. You can control which rows appear in the results using the `SELECT` statement's `WHERE` clause. Run this example.

```
mysql> select first_name, last_name, check_in_time, check_out_time from visit where first_name = 'Gary';
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Gary       | Gatehouse | 2016-08-30 14:35:55 | 2016-08-30 15:53:44 |
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL                |
+------------+-----------+---------------------+---------------------+
2 rows in set (0.00 sec)
```

The results are only the rows that match the `WHERE` condition. In other words, only rows where the `first_name` column contains `'Gary'` are returned.

`WHERE` conditions are Boolean expressions, and you can write the kind of compound Boolean expressions that your programming experience would lead you to expect. Here are several examples. (Each begins with an SQL comment. The DBMS ignores anything following a double dash `--`.)

```
mysql> -- Example: AND
mysql> select first_name, last_name, check_in_time, check_out_time from visit where first_name = 'Gary' and last_name = 'Gatehouse';
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Gary       | Gatehouse | 2016-08-30 14:35:55 | 2016-08-30 15:53:44 |
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL                |
+------------+-----------+---------------------+---------------------+
2 rows in set (0.00 sec)

mysql> -- Example: OR
mysql> select first_name, last_name, check_in_time, check_out_time from visit where first_name = 'Gary' or first_name = 'Alice';
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Gary       | Gatehouse | 2016-08-30 14:35:55 | 2016-08-30 15:53:44 |
| Alice      | Albert    | 2016-08-30 16:15:05 | 2016-08-30 16:50:04 |
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL                |
+------------+-----------+---------------------+---------------------+
3 rows in set (0.00 sec)

mysql> -- Example: comparison operator with timestamp data
mysql> select first_name, last_name, check_in_time, check_out_time from visit where check_in_time < '2016-08-31';
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Gary       | Gatehouse | 2016-08-30 14:35:55 | 2016-08-30 15:53:44 |
| Charlie    | Cadillac  | 2016-08-30 14:55:55 | 2016-08-30 16:53:44 |
| Irving     | Icehouse  | 2016-08-30 15:56:56 | 2016-08-30 16:56:46 |
| Alice      | Albert    | 2016-08-30 16:15:05 | 2016-08-30 16:50:04 |
| Debbie     | Davis     | 2016-08-30 16:36:56 | 2016-08-30 17:57:47 |
| Bob        | Booth     | 2016-08-30 16:44:54 | 2016-08-30 16:53:44 |
| Eric       | Elkins    | 2016-08-30 16:49:59 | 2016-08-30 16:56:46 |
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
| Frank      | Forest    | 2016-08-30 16:59:05 | 2016-08-30 17:03:40 |
+------------+-----------+---------------------+---------------------+
9 rows in set (0.00 sec)

mysql> -- Example: comparison operator with timestamp data
mysql> select first_name, last_name, check_in_time, check_out_time from visit where check_in_time >= '2016-08-30 16:55';
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
| Frank      | Forest    | 2016-08-30 16:59:05 | 2016-08-30 17:03:40 |
| Frank      | Forest    | 2016-08-31 11:19:15 | 2016-08-31 12:23:22 |
| Charlie    | Cadillac  | 2016-08-31 11:51:15 | 2016-08-31 11:53:44 |
| Debbie     | Davis     | 2016-08-31 13:36:36 | 2016-08-31 14:47:44 |
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL                |
| Debra      | Davis     | 2016-08-31 16:00:06 | NULL                |
+------------+-----------+---------------------+---------------------+
7 rows in set (0.00 sec)

mysql> -- Example: comparison operator with character data
mysql> select first_name, last_name, check_in_time, check_out_time from visit where last_name > 'H';
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Irving     | Icehouse  | 2016-08-30 15:56:56 | 2016-08-30 16:56:46 |
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
+------------+-----------+---------------------+---------------------+
2 rows in set (0.01 sec)

mysql> -- Example: <> means 'not equal'       
mysql> select first_name, last_name, check_in_time, check_out_time from visit where first_name <> 'Gary';
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Charlie    | Cadillac  | 2016-08-30 14:55:55 | 2016-08-30 16:53:44 |
| Irving     | Icehouse  | 2016-08-30 15:56:56 | 2016-08-30 16:56:46 |
| Alice      | Albert    | 2016-08-30 16:15:05 | 2016-08-30 16:50:04 |
| Debbie     | Davis     | 2016-08-30 16:36:56 | 2016-08-30 17:57:47 |
| Bob        | Booth     | 2016-08-30 16:44:54 | 2016-08-30 16:53:44 |
| Eric       | Elkins    | 2016-08-30 16:49:59 | 2016-08-30 16:56:46 |
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
| Frank      | Forest    | 2016-08-30 16:59:05 | 2016-08-30 17:03:40 |
| Frank      | Forest    | 2016-08-31 11:19:15 | 2016-08-31 12:23:22 |
| Charlie    | Cadillac  | 2016-08-31 11:51:15 | 2016-08-31 11:53:44 |
| Debbie     | Davis     | 2016-08-31 13:36:36 | 2016-08-31 14:47:44 |
| Debra      | Davis     | 2016-08-31 16:00:06 | NULL                |
+------------+-----------+---------------------+---------------------+
12 rows in set (0.00 sec)
```

Be careful when using `NULL` in `WHERE` clauses. The following result may surprise you.

```
mysql> select first_name, last_name, check_in_time, check_out_time from visit where check_out_time = NULL;
Empty set (0.00 sec)
```

There are two records with `NULL` in the `check_out_time` column, but the previous query will not return them. This is because (believe it or not) `NULL` does *not* equal `NULL`. That may seem illogical, but remember that `NULL` is the absence of a value, sometimes interpreted as unknown, nonexistent, or undefined. Are two unknown values equal? Two nonexistent values? It seems safest to say that they are not.

So, you must use a special syntax when "matching" on `NULL`.

```
mysql> select first_name, last_name, check_in_time, check_out_time from visit where check_out_time is NULL;
+------------+-----------+---------------------+----------------+
| first_name | last_name | check_in_time       | check_out_time |
+------------+-----------+---------------------+----------------+
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL           |
| Debra      | Davis     | 2016-08-31 16:00:06 | NULL           |
+------------+-----------+---------------------+----------------+
2 rows in set (0.00 sec)

mysql> select first_name, last_name, check_in_time, check_out_time from visit where check_out_time is not NULL;
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Gary       | Gatehouse | 2016-08-30 14:35:55 | 2016-08-30 15:53:44 |
| Charlie    | Cadillac  | 2016-08-30 14:55:55 | 2016-08-30 16:53:44 |
| Irving     | Icehouse  | 2016-08-30 15:56:56 | 2016-08-30 16:56:46 |
| Alice      | Albert    | 2016-08-30 16:15:05 | 2016-08-30 16:50:04 |
| Debbie     | Davis     | 2016-08-30 16:36:56 | 2016-08-30 17:57:47 |
| Bob        | Booth     | 2016-08-30 16:44:54 | 2016-08-30 16:53:44 |
| Eric       | Elkins    | 2016-08-30 16:49:59 | 2016-08-30 16:56:46 |
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
| Frank      | Forest    | 2016-08-30 16:59:05 | 2016-08-30 17:03:40 |
| Frank      | Forest    | 2016-08-31 11:19:15 | 2016-08-31 12:23:22 |
| Charlie    | Cadillac  | 2016-08-31 11:51:15 | 2016-08-31 11:53:44 |
| Debbie     | Davis     | 2016-08-31 13:36:36 | 2016-08-31 14:47:44 |
+------------+-----------+---------------------+---------------------+
12 rows in set (0.00 sec)
```

### Sorting results

The `SELECT` statement's `ORDER BY` clause allows you to sort your results. (Because the queries are becoming longer, these examples have been entered on multiple lines for readability. That is, different clauses of the statement are on separate lines. Pressing Enter will show the continuation prompt `->` until a line that ends with a semicolon is entered. This formatting does not affect the query's meaning.)

```
-- Example: default sort is ascending
mysql> select first_name, last_name, check_in_time, check_out_time 
    -> from visit
    -> where last_name > 'H'
    -> order by first_name;
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
| Irving     | Icehouse  | 2016-08-30 15:56:56 | 2016-08-30 16:56:46 |
+------------+-----------+---------------------+---------------------+
2 rows in set (0.00 sec)

-- Example: how to sort descending
mysql> select first_name, last_name, check_in_time, check_out_time 
    -> from visit
    -> where last_name > 'H'
    -> order by first_name desc;
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Irving     | Icehouse  | 2016-08-30 15:56:56 | 2016-08-30 16:56:46 |
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
+------------+-----------+---------------------+---------------------+
2 rows in set (0.00 sec)

-- Example: primary and secondary sorts, in different directions
mysql> select first_name, last_name, check_in_time, check_out_time 
    -> from visit 
    -> order by last_name asc, check_in_time desc;               
+------------+-----------+---------------------+---------------------+
| first_name | last_name | check_in_time       | check_out_time      |
+------------+-----------+---------------------+---------------------+
| Alice      | Albert    | 2016-08-30 16:15:05 | 2016-08-30 16:50:04 |
| Bob        | Booth     | 2016-08-30 16:44:54 | 2016-08-30 16:53:44 |
| Charlie    | Cadillac  | 2016-08-31 11:51:15 | 2016-08-31 11:53:44 |
| Charlie    | Cadillac  | 2016-08-30 14:55:55 | 2016-08-30 16:53:44 |
| Debra      | Davis     | 2016-08-31 16:00:06 | NULL                |
| Debbie     | Davis     | 2016-08-31 13:36:36 | 2016-08-31 14:47:44 |
| Debbie     | Davis     | 2016-08-30 16:36:56 | 2016-08-30 17:57:47 |
| Eric       | Elkins    | 2016-08-30 16:49:59 | 2016-08-30 16:56:46 |
| Frank      | Forest    | 2016-08-31 11:19:15 | 2016-08-31 12:23:22 |
| Frank      | Forest    | 2016-08-30 16:59:05 | 2016-08-30 17:03:40 |
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL                |
| Gary       | Gatehouse | 2016-08-30 14:35:55 | 2016-08-30 15:53:44 |
| Hannah     | Hermanson | 2016-08-30 16:55:55 | 2016-08-30 16:59:44 |
| Irving     | Icehouse  | 2016-08-30 15:56:56 | 2016-08-30 16:56:46 |
+------------+-----------+---------------------+---------------------+
14 rows in set (0.00 sec)
```

Note that the `ORDER BY` clause comes after the `WHERE` clause, if there is one.

The last example above sorts first by last name, in ascending order. Where records have the same last name, they are sorted by check in time, in descending order. 

If your query does not include an `ORDER BY` clause, the result rows could be returned in any order. In fact, you can sometimes run the same query twice and receive the same results, but in different orders.

Keep in mind that `ORDER BY` only affects the display of the results returned by your query. It has no affect on the contents of the database table.

### Eliminating duplicate results

Suppose that you want to query for the list of all students who have visited a Learning Center location. You might be tempted to do this:

````
mysql> select first_name, last_name from visit order by last_name, first_name;
+------------+-----------+
| first_name | last_name |
+------------+-----------+
| Alice      | Albert    |
| Bob        | Booth     |
| Charlie    | Cadillac  |
| Charlie    | Cadillac  |
| Debbie     | Davis     |
| Debbie     | Davis     |
| Debra      | Davis     |
| Eric       | Elkins    |
| Frank      | Forest    |
| Frank      | Forest    |
| Gary       | Gatehouse |
| Gary       | Gatehouse |
| Hannah     | Hermanson |
| Irving     | Icehouse  |
+------------+-----------+
14 rows in set (0.00 sec)
````

This isn't really what you want. Nothing is missing, but some things are duplicated. Without a `WHERE` clause, the results show all 14 rows in the table. But a `WHERE` clause won't help, because it tests *each **individual** table row* to see if it matches the specified condition. It cannot test conditions involving multiple rows that have already met its condition.  

You need something that takes the results, after any `WHERE` filter is applied, and excludes duplicates from the rows that met the `WHERE` condition. The `DISTINCT` keyword is what you need.

```
mysql> select distinct first_name, last_name from visit order by last_name, first_name;                                  
+------------+-----------+
| first_name | last_name |
+------------+-----------+
| Alice      | Albert    |
| Bob        | Booth     |
| Charlie    | Cadillac  |
| Debbie     | Davis     |
| Debra      | Davis     |
| Eric       | Elkins    |
| Frank      | Forest    |
| Gary       | Gatehouse |
| Hannah     | Hermanson |
| Irving     | Icehouse  |
+------------+-----------+
10 rows in set (0.00 sec)
```

So it appears that 10 different students have visited some Learning Center location. 

Or maybe not. Are Debbie Davis and Debra Davis the same person? How might you test this?

```
mysql> select distinct first_name, last_name, email from visit order by last_name, first_name;
+------------+-----------+---------------------+
| first_name | last_name | email               |
+------------+-----------+---------------------+
| Alice      | Albert    | aalbert@dewv.net    |
| Bob        | Booth     | bbooth@dewv.net     |
| Charlie    | Cadillac  | cadillac@dewv.net   |
| Charlie    | Cadillac  | ccadillac@dewv.net  |
| Debbie     | Davis     | ddavis@dewv.net     |
| Debra      | Davis     | ddavis@dewv.net     |
| Eric       | Elkins    | eelkins@dewv.net    |
| Frank      | Forest    | fforest@dewv.net    |
| Gary       | Gatehouse | ggatehouse@dewv.net |
| Hannah     | Hermanson | hhermanson@dewv.net |
| Irving     | Icehouse  | iicehouse@dewv.net  |
+------------+-----------+---------------------+
11 rows in set (0.00 sec)
```

Debbie Davis and Debra Davis have the same email address. For the purposes of this tutorial, you should assume that this is one person who entered different forms of her first name at different times.  (In a professional setting, you would want to verify this first hand.)

Do you see another problem in these results? Charlie Cadillac shows up with two different email addresses. It's possible that these are two different people, but you will again assume that one person has made a data entry error.

In the next section, you will learn how to fix these problems.

Later, you will learn how an improved database design can help prevent them from happening.

### Exercises

Write a query (a `SELECT` statement) that satisfies each of the following.

1. List the first and last names and check in and check out times for all closed visits.
2. List the first and last names and check in and check out times for all closed visits by Ms. Davis.
3. List the first and last names and check in and check out times for all closed visits by Ms. Davis and Mr. Cadillac. Sort the results by last name, and then by check in time.
4. List all Learning Center locations that appear in the `visit` table. Sort them alphabetically, and eliminate duplicate results.
5. List all sports that appear in the `visit` table. Sort them alphabetically, and eliminate duplicate results. What problems do you see in this data?
6. List all majors that appear in the `visit` table. Sort them alphabetically, and eliminate duplicate results. What problems do you see in this data?

## Updating data

SQL's `UPDATE` statement allows you to modify the data in existing table rows. For example, correct one of the problems uncovered earlier with this statement.

```
mysql> update visit set first_name = 'Debbie' where first_name = 'Debra';

Query OK, 1 row affected (0.05 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

Notice that the `UPDATE` keyword is followed by the name of the table that you want to update, and the keyword `SET`. After `SET` comes a comma-separated list of column names and their new (modified) values. (There is only one column in this statement's "list".) The `WHERE` clause is very important; without it you will update *all* the table's rows.

For safety, it is wise to first verify that your `WHERE` clause matches all and only the rows that you want to update. This is easy to do: just run a `SELECT` statement on the same table, using the same `WHERE` clause, to see which rows match. It's important to understand that the correctness of the `UPDATE` above depends upon the table's contents.  

For example, if the table contained rows with information about Debra Darby, the statement shown would also update those rows.  In that case, you would need to make the `WHERE` clause more specific to match Debra Davis rows but not Debra Darby rows.

Run this `UPDATE` to correct Charlie Cadillac's email address.

```
mysql> update visit set email = 'ccadillac@dewv.net' where email = 'cadillac@dewv.net';

Query OK, 1 row affected (0.04 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

Now suppose that Learning Center staff report some problems involving the Web application. To address these, you will need to run updates that imitate the SQL statements embedded in the Web application' code.

First, Learning Center staff report that Gary Gatehouse tried to check out at 3:15 p.m. on August 31, but was unable to because their network connection was down. Gary reported that he did meet his goals for the visit, and that he did not meet with a tutor.

Begin with a `SELECT` to verify your `WHERE` clause. In the `learning_center` database, each student ***should*** *have one or zero* visit rows with a `NULL` check out time. In user vocabulary, a student should check in and then check out; they should never check in and then check in again without first checking out. But rules that *should* be satisfied are not always, especially when you are investigating and correcting problems. So, this query verifies that the database contents make sense.

```
mysql> select first_name, last_name, check_in_time, check_out_time from visit where check_out_time is NULL;
+------------+-----------+---------------------+----------------+
| first_name | last_name | check_in_time       | check_out_time |
+------------+-----------+---------------------+----------------+
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL           |
| Debbie     | Davis     | 2016-08-31 16:00:06 | NULL           |
+------------+-----------+---------------------+----------------+
2 rows in set (0.03 sec)
```

There are two "open" visits-- those that have `NULL` values to indicate that the student has not yet checked out. They are for two different students, so the data is consistent with expectations. 

Gary Gatehouse's open visit is the one you want to "close" with an update.

```
mysql> update visit set check_out_time = '2016-08-31 15:30', purpose_achieved = 'Y' 
    -> where last_name = 'Gatehouse' and check_out_time is NULL;
Query OK, 1 row affected (0.04 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

MySQL indicates that one row was changed, which matches expectations. You should further verify your changes with a query.

```
mysql> select check_out_time, purpose_achieved, tutoring from visit 
    -> where last_name = 'Gatehouse' and check_in_time > '2016-08-31';
+---------------------+------------------+----------+
| check_out_time      | purpose_achieved | tutoring |
+---------------------+------------------+----------+
| 2016-08-31 15:30:00 | Y                | NULL     |
+---------------------+------------------+----------+
1 row in set (0.00 sec)
```

This shows that the Gatehouse check in from August 31 now has a check out on the same date at 3:30 p.m. The `purpose_achieved` value is Y to indicate Yes, and the tutoring data is not defined. So, the update was correct. 

Here are a couple of points worth clarifying.

- You did not need to do anything about tutoring in your update. Tutoring information defaults to `NULL`, and it stays that way unless the student provides specific tutoring data.
- Complete timestamp values are in the format 'YYYY-MM-DD HH:MM:SS', where the letters represent digits for Year, Month, Day, Hour, Minute, and Second, respectively. The hours use 24-hour encoding. You do not have to provide a complete value, but you must start with year and continue without skipping any units. Zeroes will be used to complete the remaining units that you do not specify. That is why the check out time shown above is greater than the date alone; the date alone is expanded to have a time of all zeroes (midnight), and the check out timestamp is after midnight.

Now suppose that Learning Center staff reported a problem with the system time. When the server was restarted right before the new semester, the system time was incorrect-- it was an hour ahead. Suppose that the server time has already been corrected, after business hours on August 30. This means that the timestamps for August 30 need to be updated to make them one hour earlier. The timestamps for August 31 are already correct.

To fix this, you need to apply some new concepts.

- The list of things that you act on with `SELECT`, `UPDATE`, etc. can contain more than just column names. It can contain expressions.
- A DBMS includes a set of helpful functions for you to use in your expressions.

To see an example of an expression, suppose you are working with MySQL and don't have a calculator handy.

```
mysql> -- an ad hoc query to compute something
mysql> select 5.25 * 3.14159;
+----------------+
| 5.25 * 3.14159 |
+----------------+
|     16.4933475 |
+----------------+
1 row in set (0.00 sec)
```

As for a helpful function, MySQL provides `ADDTIME()`.

```
mysql> select check_in_time, addtime(check_in_time, '-1:00:00'), 
    -> check_out_time, addtime(check_out_time, '-1:00:00') 
    -> from visit where check_in_time < '2016-08-31';
+---------------------+------------------------------------+---------------------+-------------------------------------+
| check_in_time       | addtime(check_in_time, '-1:00:00') | check_out_time      | addtime(check_out_time, '-1:00:00') |
+---------------------+------------------------------------+---------------------+-------------------------------------+
| 2016-08-30 14:35:55 | 2016-08-30 13:35:55                | 2016-08-30 15:53:44 | 2016-08-30 14:53:44                 |
| 2016-08-30 14:55:55 | 2016-08-30 13:55:55                | 2016-08-30 16:53:44 | 2016-08-30 15:53:44                 |
| 2016-08-30 15:56:56 | 2016-08-30 14:56:56                | 2016-08-30 16:56:46 | 2016-08-30 15:56:46                 |
| 2016-08-30 16:15:05 | 2016-08-30 15:15:05                | 2016-08-30 16:50:04 | 2016-08-30 15:50:04                 |
| 2016-08-30 16:36:56 | 2016-08-30 15:36:56                | 2016-08-30 17:57:47 | 2016-08-30 16:57:47                 |
| 2016-08-30 16:44:54 | 2016-08-30 15:44:54                | 2016-08-30 16:53:44 | 2016-08-30 15:53:44                 |
| 2016-08-30 16:49:59 | 2016-08-30 15:49:59                | 2016-08-30 16:56:46 | 2016-08-30 15:56:46                 |
| 2016-08-30 16:55:55 | 2016-08-30 15:55:55                | 2016-08-30 16:59:44 | 2016-08-30 15:59:44                 |
| 2016-08-30 16:59:05 | 2016-08-30 15:59:05                | 2016-08-30 17:03:40 | 2016-08-30 16:03:40                 |
+---------------------+------------------------------------+---------------------+-------------------------------------+
9 rows in set (0.00 sec)
```

This query computes the corrections needed to fix the data problem. (It relies on the fact that there are no check in times earlier than August 30.) For each visit that opened before August 31, it lists the check in and check out times stored in the table. It also computes and displays timestamps that result from adding -1 hours to the stored check in and check out times.

This `SELECT` query does not change anything that is stored in the database. The computed values are simply displayed on the screen. But the results verify that the following `UPDATE` will correct the data problem caused by the incorrect server clock.

```
mysql> update visit set 
    -> check_in_time = addtime(check_in_time, '-1:00:00'), 
    -> check_out_time = addtime(check_out_time, '-1:00:00') 
    -> where check_in_time < '2016-08-31';                                                                                                
Query OK, 9 rows affected (0.01 sec)
Rows matched: 9  Changed: 9  Warnings: 0
```

### Exercises

1. All of the students are "moving up" in academic rank. You will need to use multiple `UPDATE` statements, and plan them carefully. Update the data so that: 
   - current freshmen become sophomores, 
   - current sophomores become juniors, 
   - current juniors become seniors, and
   - current seniors remain unchanged.
2. Using `UPDATE`s, clean up the majors information in the `visit` table. Try to make the values standard or consistent. Be sure that no information is lost.
3. Using `UPDATE`s, clean up the sports information in the `visit` table. Try to make the values standard or consistent. Be sure that no information is lost. (Note: some sports names contain an apostrophe character that is identical to the single quotes enclosing text values. When you use these values in a statement, either escape the apostrophe with a backslash: `'Men\'s golf'`, or use double quotes to enclose the text value: `"Men's golf"`.)

## Creating new data rows

Each time that a student checks in at a Learning Center location, a new row is created in the `visit` table.

The Web application's code contains embedded SQL and dynamically assembles an `INSERT` statement using student data input. This statement creates a row to represent a new visit by Alice Albert.

```
mysql> insert into visit
    -> (first_name, last_name, email, academic_rank, residential_status, location, purpose)
    -> values
    -> ('Alice', 'Albert', 'aalbert@dewv.net', 'Junior', 'On campus', 'NLC', 'more study hall');
Query OK, 1 row affected (0.01 sec)
```

### Default column values

Check the effect of that `INSERT`, because it requires some explanation.

```
mysql> select first_name, last_name, purpose, check_in_time, check_out_time from visit where first_name = 'Alice' and check_out_time is NULL;
+------------+-----------+-----------------+---------------------+----------------+
| first_name | last_name | purpose         | check_in_time       | check_out_time |
+------------+-----------+-----------------+---------------------+----------------+
| Alice      | Albert    | more study hall | 2017-07-03 20:57:41 | NULL           |
+------------+-----------+-----------------+---------------------+----------------+
1 row in set (0.00 sec)
```

Note that the value that you see for `check_in_time` will be different from the one shown above. It should be today's date, and the time should be correct except for the hour. (The discrepancy in the hour is because the Cloud9 hosting server is set for a different time zone. Don't worry about this now.)

Even though your `INSERT` provided no value for `check_in_time`, MySQL automatically stored the server's current time in that column of your new record. To understand why, you must look at the details of the `visit` table's definition.

```
mysql> describe visit;
+---------------------------+--------------+------+-----+-------------------+-------+
| Field                     | Type         | Null | Key | Default           | Extra |
+---------------------------+--------------+------+-----+-------------------+-------+
| first_name                | varchar(128) | NO   |     | NULL              |       |
| last_name                 | varchar(128) | NO   |     | NULL              |       |
| email                     | varchar(128) | NO   |     | NULL              |       |
| academic_rank             | varchar(128) | NO   |     | NULL              |       |
| residential_status        | varchar(128) | NO   |     | NULL              |       |
| majors                    | varchar(128) | YES  |     | NULL              |       |
| sports                    | varchar(128) | YES  |     | NULL              |       |
| slp_instructor_first_name | varchar(128) | YES  |     | NULL              |       |
| slp_instructor_last_name  | varchar(128) | YES  |     | NULL              |       |
| check_in_time             | timestamp    | NO   |     | CURRENT_TIMESTAMP |       |
| check_out_time            | timestamp    | YES  |     | NULL              |       |
| location                  | varchar(128) | NO   |     | NULL              |       |
| purpose                   | varchar(255) | NO   |     | NULL              |       |
| purpose_achieved          | char(1)      | YES  |     | NULL              |       |
| tutoring                  | varchar(255) | YES  |     | NULL              |       |
| comments                  | varchar(255) | YES  |     | NULL              |       |
+---------------------------+--------------+------+-----+-------------------+-------+
16 rows in set (0.00 sec)
```

Remember, `describe` is a MySQL-specific command that displays information about the structure of a table. Look at the column labelled `Default`. All of the `visit` table's columns (fields) have `NULL` listed as their default, except for one. The default for `check_in_time` is `CURRENT_TIMESTAMP`. The table was defined so that each new row would store the server's current time in that column, unless a different value was provided in the `INSERT` statement.

Your `INSERT` statement provided values for seven columns. All the other columns in the new row contain their default values. That default value is `NULL` for all of them except `check_in_time`, which stored the time the row was created. 

### Allowing `NULL`, or not

Notice that the `visit` table's description contains a column labelled `Null`, with a Yes or No for each table column. This indicates whether `NULL`s are allowed in that column. An `INSERT` statement must specify a value for every column that disallows `NULL`, unless a non-null default is defined for the column.

This provides a way of requiring values to be provided.

```
mysql> insert into visit (first_name) values ('Alice');
ERROR 1364 (HY000): Field 'last_name' doesn't have a default value
```

### Exercises

1. Insert a row for a visit by Bob Booth. The location is SC102, and his purpose is to practice his SQL statements. Keep all of Bob's personal information consistent with the data on his other visits.
2. Insert a row for a brand new student, using any appropriate data you can imagine. Your statement must provide a value for every column except one: allow `check_in_time` to take on its default value.
3. Repeat the previous exercise, using different data for another brand new student.

## Deleting data 

The SQL `DELETE` statement removes existing rows from a table.

```
mysql> delete from visit where purpose = 'more study hall';                                                                             
Query OK, 1 row affected (0.02 sec)
```

It is very important to use the correct `WHERE` clause. As before, you should first test your `WHERE` clause with a `SELECT` statement, to be sure it matches all and only the rows that you want to delete. If you do not include a `WHERE` clause, all rows in the table will be deleted. 

Notice that you do not (cannot) list column names, because `DELETE` works on entire rows.

### Exercises

1. In the previous set of exercises, you inserted three rows. Delete them.



# Contents

[TOC]
