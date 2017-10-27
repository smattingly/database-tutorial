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

Finally, there is the **physical schema**. The details of this level are typically hidden by the abstractions of the DBMS, and are beyond the scope of this tutorial. They deal with how the data is physically stored, considering issues like OS file system characteristics, performance and reliability of storage devices, and so forth. This requires a highly specialized skill set, with much of it specific to one DBMS product.

###Views as security technique

In some situations, views provide a security benefit, too. You can give a MySQL user account permissions to access data through a view, while denying permissions to see or modify data in the underlying tables.

Suppose that some database users only need to deal with data related to student athletes. Following the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege), you could restrict their access as follows.

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

To change this, sign out from the `athletics_user` account, and sign in as `root` again. (Alternatively, you can open two terminals and two MySQL sessions, one with each account.)

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

###Modifying view contents is problematic

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

1. Following the athletics example above, create one or more views for users who are only concerned with  commuter students.
2. Create a MySQL account with username `commuter`  and password `more parking`. Set permissions so that this account can retrieve but not modify contents of the views from the previous exercise.

# Contents

[TOC]
