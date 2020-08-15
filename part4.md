# Databases in Context: A Just-in-Time Tutorial, Part 4

[Steve Mattingly](https://www.linkedin.com/in/steve-mattingly-aab8064a), Assistant Professor of Computer Science, [Davis & Elkins College](https://www.dewv.edu).

*Databases in Context: A Just-in-Time Tutorial* by Stephen S. Mattingly is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/). ![Creative Commons Attribution-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)

------

Learn more about Open Educational Resources at [UNESCO](http://www.unesco.org/new/en/communication-and-information/access-to-knowledge/open-educational-resources/). ![UNESCO Open Educational Resources logo](http://www.unesco.org/new/typo3temp/pics/5d3118e041.jpg)

------

[Contents](#Contents)

------

## Views

You have seen two ways to model an organization's data: the natural end-user perspective and the normalized technician's perspective.

While the primary components of a relational database are from the normalized perspective, it is possible to present the data in a more natural way.

A **view** is a virtual table that is defined by a query. For example, consider the following query that joins three tables.

```
mysql> select first_name, last_name, name from
    -> student left outer join student_major on student.email = student_major.email  
    -> left outer join major on student_major.major_name = major.name;        
+------------+-----------+------------------+
| first_name | last_name | name             |
+------------+-----------+------------------+
| Alice      | Albert    | Computer Science |
| Bob        | Booth     | Computer Science |
| Bob        | Booth     | Philosophy       |
| Charlie    | Cadillac  | English          |
| Debbie     | Davis     | English          |
| Debbie     | Davis     | Philosophy       |
| Eric       | Elkins    | Biology          |
| Frank      | Forest    | Undecided        |
| Gary       | Gatehouse | Computer Science |
| Gary       | Gatehouse | Mathematics      |
| Hannah     | Hermanson | Chemistry        |
| Irving     | Icehouse  | Chemistry        |
+------------+-----------+------------------+
12 rows in set (0.00 sec)       
```

This is a relatively complex query for something that seems straightforward to the end user. But that query can be used to define a view.

```
mysql> create view major_view as 
    -> select first_name, last_name, name from  
    -> student left outer join student_major on student.email = student_major.email  
    -> left outer join major on student_major.major_name = major.name;        
Query OK, 0 rows affected (0.02 sec)
```

The view then provides a much simpler way to access the data.

```
mysql> select * from major_view;
+------------+-----------+------------------+
| first_name | last_name | name             |
+------------+-----------+------------------+
| Alice      | Albert    | Computer Science |
| Bob        | Booth     | Computer Science |
| Bob        | Booth     | Philosophy       |
| Charlie    | Cadillac  | English          |
| Debbie     | Davis     | English          |
| Debbie     | Davis     | Philosophy       |
| Eric       | Elkins    | Biology          |
| Frank      | Forest    | Undecided        |
| Gary       | Gatehouse | Computer Science |
| Gary       | Gatehouse | Mathematics      |
| Hannah     | Hermanson | Chemistry        |
| Irving     | Icehouse  | Chemistry        |
+------------+-----------+------------------+
12 rows in set (0.04 sec)
```

### Views as external schema

Database professionals often describe systems with a **3 schema architecture**. (Here the word "schema" means roughly the viewpoint or model that is used to think about the system.) You have already seen two of these schemas. 

The viewpoints of users and non-technical stakeholders, often implemented in views, are called **external schemas**. (There can be multiple external schemas because different groups of stakeholders might think of things differently.) 

The database designer's viewpoint, usually implemented as tables, is called the **conceptual schema**.

Finally, there is the **physical schema**. This is the viewpoint of the database administrator, in the most specialized sense of the term. The details of this level are typically hidden by the abstractions of the DBMS, and are beyond the scope of this tutorial. They deal with how the data is physically stored, evaluating tradeoffs that arise from the characteristics of alternative [storage engines](https://en.wikipedia.org/wiki/storage_engine) ([MySQL supports several](https://dev.mysql.com/doc/refman/5.7/en/storage-engine-setting.html)), [OS file systems](https://en.wikipedia.org/wiki/File_system#File_systems_and_operating_systems), [storage devices](https://en.wikipedia.org/wiki/Computer_data_storage#Characteristics_of_storage), and so forth. This requires a highly specialized skill set, with much of it specific to one DBMS product.

### Views as security technique

In some situations, views provide a security benefit, too. You can give a MySQL user account permissions to access data through a view, while denying permissions to see or modify data in the underlying tables.

Suppose that some database users only need to deal with data related to student athletes. Following the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege), you could restrict their access as follows.

(This section assumes that you are using the MySQL `root` account or another account with sufficient privileges. Depending on your MySQL environment, some of the details could vary.)

First, create views for access to the needed data. 

```
mysql> create view athletes as 
    -> select first_name, last_name, email, academic_rank, residential_status 
    -> from student where email in 
    -> (select email from student_sport);
Query OK, 0 rows affected (0.00 sec)

mysql> create view sport_roster as 
    -> select first_name, last_name, student.email, gender, sport_name 
    -> from student join student_sport on student.email = student_sport.email;
Query OK, 0 rows affected (0.01 sec)
```

Next, create an account for each user who will have restricted access. 

```
mysql> -- Create an account with username = athletics_user and password = JocksRule
mysql> -- This account can only sign in from localhost (the MySQL server).
mysql> create user 'athletics_user'@'localhost' identified by 'JocksRule';                                                                        
Query OK, 0 rows affected (0.03 sec)
```

You can test this account as follows.

```
mysql> exit;
Bye
$ mysql -u athletics_user -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 50
Server version: 5.5.53-0ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
+--------------------+
1 row in set (0.00 sec)
```

The `exit` command signs you out of the `mysql` client and returns you to the operating system prompt. The command `mysql -u athletics_user -p` starts the client again, with specific options.

- `-u athletics_user` says to sign in with the newly created username.
- `-p` says that the client should prompt us to enter the password. For security, the prompt does not display the password characters as you type them.

When you have signed in with the new account, a `show databases;` command shows very little because the new account has few permissions.

To change this, sign out from the `athletics_user` account, and sign in as you normally do. (Alternatively, you can open two terminals and two MySQL sessions, one with each account.)

```
mysql> -- who am I?
mysql> select CURRENT_USER();
+----------------+
| CURRENT_USER() |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.00 sec)

mysql> grant select on athletes to 'athletics_user'@'localhost';
Query OK, 0 rows affected (0.03 sec)

mysql> grant select on sport_roster to 'athletics_user'@'localhost';
Query OK, 0 rows affected (0.00 sec)
```

The new user now has just enough access to perform their job, as show below.

```
mysql> select CURRENT_USER();
+--------------------------+
| CURRENT_USER()           |
+--------------------------+
| athletics_user@localhost |
+--------------------------+
1 row in set (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| learning_center    |
+--------------------+
2 rows in set (0.00 sec)

mysql> use learning_center;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+---------------------------+
| Tables_in_learning_center |
+---------------------------+
| athletes                  |
| sport_roster              |
+---------------------------+
2 rows in set (0.00 sec)

mysql> select * from sport_roster;
+------------+-----------+--------------------+--------+------------+
| first_name | last_name | email              | gender | sport_name |
+------------+-----------+--------------------+--------+------------+
| Charlie    | Cadillac  | ccadillac@dewv.net | Men    | Baseball   |
| Eric       | Elkins    | eelkins@dewv.net   | Men    | Baseball   |
| Bob        | Booth     | bbooth@dewv.net    | Men    | Golf       |
| Charlie    | Cadillac  | ccadillac@dewv.net | Men    | Soccer     |
| Debbie     | Davis     | ddavis@dewv.net    | Women  | Soccer     |
| Debbie     | Davis     | ddavis@dewv.net    | Women  | Softball   |
+------------+-----------+--------------------+--------+------------+
6 rows in set (0.00 sec)

mysql> select * from student;
ERROR 1142 (42000): SELECT command denied to user 'athletics_user'@'localhost' for table 'student'

mysql> update sport_roster set first_name = 'Debra' 
    -> where gender = 'Women' and sport_name = 'Soccer';    
ERROR 1142 (42000): UPDATE command denied to user 'athletics_user'@'localhost' for table 'sport_roster'
```

Consistent with the granted permissions, the new user can `SELECT` data from two views, but not from other views or tables. In addition, the user cannot `UPDATE`, `DELETE`, or `INSERT` on the views that they can see; only `SELECT` permission was granted.

### Modifying view contents is problematic

Even when a user has permissions to modify a view, some modifications lead to difficulties.

```
mysql> select CURRENT_USER();
+----------------+
| CURRENT_USER() |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.00 sec)

mysql> update sport_roster set first_name = 'Debra' where gender = 'Women' and sport_name = 'Soccer';                                              
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from sport_roster;
+------------+-----------+--------------------+--------+------------+
| first_name | last_name | email              | gender | sport_name |
+------------+-----------+--------------------+--------+------------+
| Charlie    | Cadillac  | ccadillac@dewv.net | Men    | Baseball   |
| Eric       | Elkins    | eelkins@dewv.net   | Men    | Baseball   |
| Bob        | Booth     | bbooth@dewv.net    | Men    | Golf       |
| Charlie    | Cadillac  | ccadillac@dewv.net | Men    | Soccer     |
| Debra      | Davis     | ddavis@dewv.net    | Women  | Soccer     |
| Debra      | Davis     | ddavis@dewv.net    | Women  | Softball   |
+------------+-----------+--------------------+--------+------------+
6 rows in set (0.00 sec)

```

Notice that the `root` user was permitted to update data through the view. The results are misleading, though. The `WHERE` clause matches only one row in the view, and the DBMS indicates that only one row was changed. But the last query shows that *two* rows in the view are now different. (Compare with the "before" data that was displayed by the other user's `SELECT` above.)

Although the view shows two rows with email of `ddavis@dewv.net`, there is only one `ddavis@dewv.net` row in the underlying `student` table. The join query that defines the view shows two rows because the student plays two sports. The user may not expect, notice, and/or understand this outcome.

Some modifications to views are impossible. Here are two examples.

- The defining query for a view might use an aggregate function. There is no way to modify the contents of the resulting column, because the contents are not stored in any actual table.
- The defining query for a view might include only a proper subset of a table's columns. If some of the excluded columns have no default value and do not allow `NULL`s, it will be impossible to `INSERT` into the view. An attempted `INSERT` will fail because a row cannot be created in the underlying table without specifying a value for columns that are not present in the view.

The bottom line is that modifying data through views should be performed with great care, if at all.

### Exercise set 15

1. Following the athletics example above, create one or more views for users who are only concerned with commuter students.
2. Create a MySQL account with username `commuter`  and password `more parking`. Set permissions so that this account can retrieve but not modify contents of the views from the previous exercise.

## Indexes

A database **index** is similar in concept to a book's index. Like the pages of a book, table rows are physically stored in a particular order. Accessing pages or rows based on their physical sequence is efficient-- it is the natural way to "read" data. But sometimes there is a need to access data in a different order. This is where indexes come in.

A book's index does not repeat the entire book contents, but it does allow you to efficiently access the contents in a different order. If you want to find a particular topic in a book, you don't have to start on page 1 and search sequentially until you find it. It's more efficient to turn to the topic index, find your topic alphabetically, and follow the reference(s) directly to the proper page(s).

A **table scan** is an expensive operation that finds data by sequentially searching each row in a table. To improve performance, a table index tracks values in one or more columns, along with references to the rows where those values appear. When the indexed columns appear in clauses like `WHERE` or `ORDER BY`, the DBMS can use the index to efficiently access data by following a process similar to the book example.

Some books have more than one index, such as a topic index and a people index. Database tables can also have more than one index, for efficient access based on different (sets of) columns.

Just as a book's index is printed on extra pages beyond the main content, a database index requires storage in addition to the table data. Unlike a printed book, the data in database tables typically changes with time. As a result, the contents of a table's indexes may also need to be updated. These costs must be weighed against the performance gain from having the index, and how often it would help. In other word, it is not wise to build indexes for all columns of all tables.

An index is also a convenient way for a DBMS to enforce uniqueness and other constraints; any attempt to put a nonconforming entry into the index can be rejected. A table's primary key is unique and is frequently used for accessing data, so many DBMSs including MySQL implement primary key constraints as a unique index.

MySQL's `SHOW INDEX` statement displays information about a table's indexes. (Note that the output rows in the illustration have been shortened; many more columns are actually displayed.)

```
mysql> show index from student_sport;
+---------------+------------+----------+--------------+-------------+-
| Table         | Non_unique | Key_name | Seq_in_index | Column_name |
+---------------+------------+----------+--------------+-------------+-
| student_sport |          0 | PRIMARY  |            1 | email       | 
| student_sport |          0 | PRIMARY  |            2 | sport_name  | 
| student_sport |          0 | PRIMARY  |            3 | gender      |
| student_sport |          1 | fk_sport |            1 | sport_name  | 
| student_sport |          1 | fk_sport |            2 | gender      |
+---------------+------------+----------+--------------+-------------+-
5 rows in set (0.00 sec)
```

This indicates that the table has two indexes. The first is on three columns that implement the primary key. The second is on the remaining two columns, which are a foreign key for the `sport` table. The primary key is a unique index, and the foreign key is not.

When a database designer or administrator decides that an additional index would be beneficial, it can be added with `CREATE INDEX`. Here is the `student` table's index information before and after adding an index that would improve lookups on last name.

```
mysql> show index from student;
+---------+------------+----------+--------------+-------------+-
| Table   | Non_unique | Key_name | Seq_in_index | Column_name | 
+---------+------------+----------+--------------+-------------+-
| student |          0 | PRIMARY  |            1 | email       | 
+---------+------------+----------+--------------+-------------+-
1 row in set (0.00 sec)

mysql> create index student_last_name on student(last_name);
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show index from student;
+---------+------------+-------------------+--------------+-------------+-
| Table   | Non_unique | Key_name          | Seq_in_index | Column_name | 
+---------+------------+-------------------+--------------+-------------+-
| student |          0 | PRIMARY           |            1 | email       | 
| student |          1 | student_last_name |            1 | last_name   | 
+---------+------------+-------------------+--------------+-------------+-
2 rows in set (0.00 sec)
```

### Exercise set 16

1. Examine the indexes that currently exist in the database. Create one additional index that will have the greatest improvement on database performance.

## Performance analysis and optimization

Generally, the DBMS will choose which index(es) to use when executing a query. The choice of index is included in the output from MySQL's `EXPLAIN` command, which shows the details of how an SQL statement would be processed.

```
mysql> explain select * from student;
+----+-------------+---------+------+---------------+------+---------+------+------+-------+
| id | select_type | table   | type | possible_keys | key  | key_len | ref  | rows | Extra |
+----+-------------+---------+------+---------------+------+---------+------+------+-------+
|  1 | SIMPLE      | student | ALL  | NULL          | NULL | NULL    | NULL |    9 |       |
+----+-------------+---------+------+---------------+------+---------+------+------+-------+
1 row in set (0.00 sec)

mysql> explain select * from student where email = 'ddavis@dewv.net';
+----+-------------+---------+-------+---------------+---------+---------+-------+------+-------
| id | select_type | table   | type  | possible_keys | key     | key_len | ref   | rows | Extra 
+----+-------------+---------+-------+---------------+---------+---------+-------+------+-------
|  1 | SIMPLE      | student | const | PRIMARY       | PRIMARY | 130     | const |    1 |       
+----+-------------+---------+-------+---------------+---------+---------+-------+------+-------
1 row in set (0.00 sec)

mysql> explain select * from student where last_name = 'Davis';
+----+-------------+---------+------+-------------------+-------------------+---------+-------+-
| id | select_type | table   | type | possible_keys     | key               | key_len | ref   | 
+----+-------------+---------+------+-------------------+-------------------+---------+-------+-
|  1 | SIMPLE      | student | ref  | student_last_name | student_last_name | 130     | const | 
+----+-------------+---------+------+-------------------+-------------------+---------+-------+-
1 row in set (0.00 sec)
```

In the first example above, MySQL does not detect any `possible_keys` (indexes) to apply to the query, because returning all rows requires a full table scan. (This is the equivalent of reading a book all the way through, front to back.) The column labeled `rows` means that MySQL must look at (all) 9 rows of the table to complete the query.

In the second example, MySQL identifies the `PRIMARY` key as a possible key to apply, and chooses to use it, as indicated in the `key` column. This query filters on `email` , which is the table's primary key. The DBMS only needs to look at one row. (This is the equivalent of looking up a value in a book's subject index, then going directly to the one listed page.)

In the third example, MySQL identifies and uses a different index to use. The `last_name` column that is used in the `WHERE` clause is indexed by the `student_last_name` index, so the DBMS only needs to look at one row, a detail that is not displayed in the truncated example. (This is the equivalent of looking up a value in a book's person index, then going directly to the one listed page.)

The values shown in the `rows` column are actually *estimates* of the number of rows the DBMS will process to perform the `EXPLAIN`ed statement. MySQL estimates these numbers, and chooses indexes, based on **key distribution data**. For example, one of the columns not shown above in the partial output from `SHOW INDEX` is the index's **cardinality**-- the number of *unique* values it contains. The higher the cardinality, the more "selective" the index is, and the more likely it will be used, if it's relevant.

Although they are unlikely to have an effect on the small database used in this tutorial, there are two MySQL-specific commands that can be used to improve performance.

1. The `ANALYZE TABLE` command updates MySQL's stored key distribution data for the specified table.
2. The `OPTIMIZE TABLE` command rearranges the physical storage of a table and its index(es) data for faster retrieval.

Note that these commands can lock database table so that they are read-only or completely unavailable to other users of the server. Due to its nature, the `OPTIMIZE TABLE` command may take a long time to run for large tables.

### Exercise set 17

1. Show the `EXPLAIN` command  output for a query that uses the index you defined in the previous set of exercises.
2. Use `EXPLAIN` to analyze a join or other multi-table query, and briefly explain the output it shows.

## Data integrity

### Transactions

Entity and referential integrity go a long way toward ensuring the integrity of database contents. 

```
mysql> delete from sport where name = 'Soccer';
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`learning_center`.`student_sport`, CONSTRAINT `fk2` FOREIGN KEY (`sport_name`, `gender`) REFERENCES `sport` (`name`, `gender`))
```

The example shows that a foreign key constraint prevents deleting the sport Soccer because that  would "strand" records that show students play that sport.

If the college really did discontinue the sport, the `student_sport` rows would need to be deleted first.

```
mysql> delete from student_sport where sport_name = 'Soccer';
Query OK, 2 rows affected (0.00 sec)

mysql> delete from sport where name = 'Soccer';
Query OK, 2 rows affected (0.00 sec)
```

When the two statements above are complete, the database is in a consistent state.

But there could still be issues, simply because they are two separate statements. Consider these scenarios.

- A human user runs the first statement, but is interrupted before they can execute the second statement. The interruption could be anything from a dropped network connection to a power failure to a fire alarm. 


- An application executes the first statement. Then some kind of technical failure prevents it from executing the second.
- An application executes the first statement. Then it executes the second, but for whatever reason the second statement fails.

In these and other scenarios, the database is left in an undesirable state. While the database contents are not inconsistent, they are also not a full accurate picture.

Sometimes there is a need to group statements so that they are treated as a unit-- all of them succeed, or all of them fail. This leads to the concept of a **transaction**.

```
mysql> -- 1. Create a sort of "save point". Changes are held in a "temporary" area.
mysql> start transaction;

mysql> -- 2. Perform the first delete.
mysql> delete from student_sport where sport_name = 'Soccer';
Query OK, 2 rows affected (0.00 sec)

mysql> -- ONLY this database session will see this result.
mysql> -- Other sessions will still see Soccer in the table.
mysql> select count(*) from student_sport where sport_name = 'Soccer';
+----------+
| count(*) |
+----------+
|        0 |
+----------+
1 row in set (0.01 sec)

mysql> -- 3. Perform the second delete.
mysql> delete from sport where name = 'Soccer';
Query OK, 2 rows affected (0.00 sec)

mysql> -- 4a. Finalize all changes since the save point.
mysql> commit;
Query OK, 0 rows affected (0.00 sec)

mysql> -- Now all sessions will see the effect of BOTH deletes.
```

The two deletes were wrapped in a transaction; only when the transaction was committed did the changes become visible outside of this user session.

There is an alternative to committing the transaction. At the point marked 4a. above, the user could have done this.

```
mysql> -- 4b. Abandon changes and return to the save point.
mysql> rollback;
Query OK, 0 rows affected (0.00 sec)

mysql> select count(*) from student_sport where sport_name = 'Soccer';
+----------+
| count(*) |
+----------+
|        2 |
+----------+
1 row in set (0.01 sec)

mysql> -- Now no one sees the effect of either of the deletes.
```

There is a third alternative. If a user starts a transaction and terminates their session without an explicit commit, the DBMS will rollback the transaction. This ensures the results are "all or nothing". 

### Backup and restore

A DBMS like MySQL uses many files to store the contents of multiple databases, tables, indexes, and other database objects. These files may be spread across different storage devices, and even different servers.

At any point in time, the DBMS may be holding recent changes in memory, or in transaction log files. There may be considerable delay before the changes are written to the files that store table data.

For these and other reasons, you cannot backup data for DBMSs like MySQL by copying files using native operating system commands. Assuming you can identify all the files that need to be copied, there is no guarantee that you will capture them in a consistent and up-to-date state that the DBMS can use.

In general, you must use special tools to backup and restore DBMS data. MySQL provides a program named `mysqldump`. (This is not a command that runs within the `mysql` client; it is an executable program that is launched from an OS command prompt.)

```bash
mysqldump learning_center > backup.sql
```

This tells the backup tool to dump the `learning_center` database to a file named `backup.sql`. (In many cases you will need to provide a username and password, using the same `-u` and `-p` flags that you do for the `mysql` client.)

To restore a backup, use the `mysql` client in batch mode-- not the interactive mode that you normally use. (Again, a username and password will usually be needed.)

```bash
mysql -u root -p learning_center < backup.sql
```

You can restore the backup to a different database, as long as the target database already exists on the server. Use `CREATE DATABASE <database name>;` to create a new database.

### Exercise set 18

1. Start a transaction. Delete or modify some records. Run a query to show the results. Rollback the transaction. Run a query to show the unchanged values.
2. Backup the `learning_center` database using `mysqldump`. Use `DROP TABLE <tablename>;` to destroy at least one table, and `TRUNCATE TABLE <tablename>;` to destroy the contents of at least one table. Restore the backup to reverse the changes.
3. Create a new database with any name you choose. Restore your `learning_center` backup to this new database.
4. Transactions work for standard SQL data manipulation statements like `INSERT`, `UPDATE`, and `DELETE`. They generally do not work for SQL data definition statements and administrative commands like `DROP TABLE` and `TRUNCATE TABLE`. Using the "extra" copy of the database that you restored in the previous exercise, start a transaction and show that some changes cannot be rolled back.

# Contents

[TOC]
