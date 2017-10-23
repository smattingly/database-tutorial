# Databases in Context: A Just-in-Time Tutorial, Part 3

[Steve Mattingly](https://www.linkedin.com/in/steve-mattingly-aab8064a), Assistant Professor of Computer Science, [Davis & Elkins College](https://www.dewv.edu).

*Databases in Context: A Just-in-Time Tutorial* by Stephen S. Mattingly is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/). ![Creative Commons Attribution-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)

------

Learn more about Open Educational Resources at [UNESCO](http://www.unesco.org/new/en/communication-and-information/access-to-knowledge/open-educational-resources/). ![UNESCO Open Educational Resources logo](http://www.unesco.org/new/typo3temp/pics/5d3118e041.jpg)

------

[Contents](#Contents)

------

## Joining tables

Normalization prevents data anomalies, but at a cost. Retrieving data is now more complicated, and often requires more resources.

The naïve unnormalized table designs that you started with did not come from nowhere. They represent a typical user view of the data. After normalization, you need a way to retrieve and present the data in a way that makes sense to users. You need to write queries that **join** tables.

It is easy to write a query that retrieves data from multiple tables.

```
mysql> select student.email, visit2nf.email, academic_rank, location from student, visit2nf;                                            
+---------------------+---------------------+---------------+----------------+
| email               | email               | academic_rank | location       |
+---------------------+---------------------+---------------+----------------+
| aalbert@dewv.net    | aalbert@dewv.net    | Junior        | Albert Hall    |
| bbooth@dewv.net     | aalbert@dewv.net    | Sophomore     | Albert Hall    |
| ccadillac@dewv.net  | aalbert@dewv.net    | Junior        | Albert Hall    |
| ddavis@dewv.net     | aalbert@dewv.net    | Freshman      | Albert Hall    |
| eelkins@dewv.net    | aalbert@dewv.net    | Senior        | Albert Hall    |
| fforest@dewv.net    | aalbert@dewv.net    | Freshman      | Albert Hall    |
| ggatehouse@dewv.net | aalbert@dewv.net    | Sophomore     | Albert Hall    |
| hhermanson@dewv.net | aalbert@dewv.net    | Senior        | Albert Hall    |
| iicehouse@dewv.net  | aalbert@dewv.net    | Sophomore     | Albert Hall    |
| aalbert@dewv.net    | bbooth@dewv.net     | Junior        | Albert Hall    |
| bbooth@dewv.net     | bbooth@dewv.net     | Sophomore     | Albert Hall    |
................... (LOTS OF ROWS REMOVED TO SAVE SPACE) .....................
| iicehouse@dewv.net  | hhermanson@dewv.net | Sophomore     | Albert Hall    |
| aalbert@dewv.net    | iicehouse@dewv.net  | Junior        | Albert Hall    |
| bbooth@dewv.net     | iicehouse@dewv.net  | Sophomore     | Albert Hall    |
| ccadillac@dewv.net  | iicehouse@dewv.net  | Junior        | Albert Hall    |
| ddavis@dewv.net     | iicehouse@dewv.net  | Freshman      | Albert Hall    |
| eelkins@dewv.net    | iicehouse@dewv.net  | Senior        | Albert Hall    |
| fforest@dewv.net    | iicehouse@dewv.net  | Freshman      | Albert Hall    |
| ggatehouse@dewv.net | iicehouse@dewv.net  | Sophomore     | Albert Hall    |
| hhermanson@dewv.net | iicehouse@dewv.net  | Senior        | Albert Hall    |
| iicehouse@dewv.net  | iicehouse@dewv.net  | Sophomore     | Albert Hall    |
+---------------------+---------------------+---------------+----------------+
126 rows in set (0.00 sec)
```

By listing multiple tables in the `FROM` clause, you generate the **Cartesian product** of the tables. The `student` table contains 9 rows, and the `visit2nf` table contains 14 rows. Their Cartesian product contains 9 times 14, or 126 rows. Each result row is a single `student` row combined with a single `visit2nf` row, and there is one result row for every possible combination.

What do these results represent? *Absolutely nothing meaningful.* It's as if you blindly shuffled the two tables together. This illustrates an important point: you can combine data in ways that make no sense. Just because a query is valid SQL, that doesn't mean it produces meaningful data. 

### Inner joins

A join is a query that combines rows from multiple tables in a meaningful way. When a DBMS processes a join query, it begins with the Cartesian product of the tables, then filters it to remove combinations that make no sense. Here's an example.

```
mysql> select student.email, visit2nf.email, academic_rank, location 
    -> from student, visit2nf 
    -> where student.email = visit2nf.email;
+---------------------+---------------------+---------------+----------------+
| email               | email               | academic_rank | location       |
+---------------------+---------------------+---------------+----------------+
| aalbert@dewv.net    | aalbert@dewv.net    | Junior        | Albert Hall    |
| bbooth@dewv.net     | bbooth@dewv.net     | Sophomore     | Albert Hall    |
| ccadillac@dewv.net  | ccadillac@dewv.net  | Junior        | Albert Hall    |
| ccadillac@dewv.net  | ccadillac@dewv.net  | Junior        | Albert Hall    |
| ddavis@dewv.net     | ddavis@dewv.net     | Freshman      | Albert Hall    |
| ddavis@dewv.net     | ddavis@dewv.net     | Freshman      | Writing center |
| ddavis@dewv.net     | ddavis@dewv.net     | Freshman      | Albert Hall    |
| eelkins@dewv.net    | eelkins@dewv.net    | Senior        | Albert Hall    |
| fforest@dewv.net    | fforest@dewv.net    | Freshman      | Albert Hall    |
| fforest@dewv.net    | fforest@dewv.net    | Freshman      | Albert Hall    |
| ggatehouse@dewv.net | ggatehouse@dewv.net | Sophomore     | Albert Hall    |
| ggatehouse@dewv.net | ggatehouse@dewv.net | Sophomore     | Albert Hall    |
| hhermanson@dewv.net | hhermanson@dewv.net | Senior        | Albert Hall    |
| iicehouse@dewv.net  | iicehouse@dewv.net  | Sophomore     | Albert Hall    |
+---------------------+---------------------+---------------+----------------+
14 rows in set (0.01 sec)
```

First, notice the syntax of `student.email` and `visit2nf.email`. When multiple tables are involved, it's possible for column names to be ambiguous because they appear in multiple tables. In these cases, you must specify which column you mean by using the table name and a dot.

The `WHERE` clause filters the Cartesian product, keeping only the rows where the `student` table email matches the `visit2nf` email. Those rows belong together-- the results make sense. In a sense, the join query follows the reference from one table to another, reversing the decomposition due to normalization.

Most often, a join matches primary key values in one table with foreign key values in another. But a join can match any column values with the same underlying domain.

The join syntax above is a good way to introduce joins, because you are already familiar with  `WHERE` clauses. Although this syntax is easier to grasp at first, you should use a newer, ANSI-standard syntax for joins. Here is the same query using ANSI join syntax.

```
mysql> select student.email, visit2nf.email, academic_rank, location 
    -> from student inner join visit2nf 
    -> on student.email = visit2nf.email;     
+---------------------+---------------------+---------------+----------------+
| email               | email               | academic_rank | location       |
+---------------------+---------------------+---------------+----------------+
| aalbert@dewv.net    | aalbert@dewv.net    | Junior        | Albert Hall    |
| bbooth@dewv.net     | bbooth@dewv.net     | Sophomore     | Albert Hall    |
| ccadillac@dewv.net  | ccadillac@dewv.net  | Junior        | Albert Hall    |
| ccadillac@dewv.net  | ccadillac@dewv.net  | Junior        | Albert Hall    |
| ddavis@dewv.net     | ddavis@dewv.net     | Freshman      | Albert Hall    |
| ddavis@dewv.net     | ddavis@dewv.net     | Freshman      | Writing center |
| ddavis@dewv.net     | ddavis@dewv.net     | Freshman      | Albert Hall    |
| eelkins@dewv.net    | eelkins@dewv.net    | Senior        | Albert Hall    |
| fforest@dewv.net    | fforest@dewv.net    | Freshman      | Albert Hall    |
| fforest@dewv.net    | fforest@dewv.net    | Freshman      | Albert Hall    |
| ggatehouse@dewv.net | ggatehouse@dewv.net | Sophomore     | Albert Hall    |
| ggatehouse@dewv.net | ggatehouse@dewv.net | Sophomore     | Albert Hall    |
| hhermanson@dewv.net | hhermanson@dewv.net | Senior        | Albert Hall    |
| iicehouse@dewv.net  | iicehouse@dewv.net  | Sophomore     | Albert Hall    |
+---------------------+---------------------+---------------+----------------+
14 rows in set (0.01 sec)
```

The meaning is the same, so the results are identical. Both email columns are shown for illustration purposes, but in a real world situation you would typically list only one. Either one will work-- after all, they're the same.

An **inner join** is a join where all result rows contain data from both tables. This is by far the most common scenario, so inner joins are often thought of as the default type of join. In fact, you can drop the first word from the `INNER JOIN` syntax and use just `JOIN`. They mean the same thing. 

Notice that you can still use a `WHERE` clause to perform further filtering of results.

```
mysql> select student.email, academic_rank, location 
    -> from student join visit2nf 
    -> on student.email = visit2nf.email 
    -> where location = 'Writing center';
+-----------------+---------------+----------------+
| email           | academic_rank | location       |
+-----------------+---------------+----------------+
| ddavis@dewv.net | Freshman      | Writing center |
+-----------------+---------------+----------------+
1 row in set (0.00 sec)
```

Where a many-to-many relationship has been decomposed into three tables, you may need to join all three. 

```
mysql> select first_name, last_name, name, season  
    -> from student join student_sport 
    -> on student.email = student_sport.email 
    -> join sport
    -> on student_sport.sport_name = sport.name and student_sport.gender = sport.gender;
+------------+-----------+----------+--------+
| first_name | last_name | name     | season |
+------------+-----------+----------+--------+
| Charlie    | Cadillac  | Baseball | Spring |
| Eric       | Elkins    | Baseball | Spring |
| Bob        | Booth     | Golf     | Fall   |
| Charlie    | Cadillac  | Soccer   | Fall   |
| Debbie     | Davis     | Soccer   | Fall   |
| Debbie     | Davis     | Softball | Spring |
+------------+-----------+----------+--------+
6 rows in set (0.00 sec)
```

This connects `student` to `student_sport` through matching email values, then connects those results to `sport` by matching (sport) name and (sport) gender. (Recall that $\lbrace$`name`, `gender`$\rbrace$ is the primary key for `sport`.)

#### Exercise set 9

1. Write a join query to list the first and last names of students, along with the purpose of each visit they have made. Sort the results by last name and then by first name.

2. Repeat the previous query, but list only the visits where the student achieved their purpose.

3. Write a join query to list the first and last name of students, along with their majors. (If a student has two majors, their name should appear in two different result rows.) 

4. Write the join query needed to produce the following results.

   ```
   +----------------+---------+---------+-------+
   | location       | cubicle | printer | color |
   +----------------+---------+---------+-------+
   | NLC            | A       | P1      | No    |
   | NLC            | B       | P2      | Yes   |
   | NLC            | C       | P2      | Yes   |
   | Writing center | A       | P3      | Yes   |
   | Writing center | B       | P4      | No    |
   +----------------+---------+---------+-------+
   5 rows in set (0.00 sec)
   ```

5. Modify the three-table join example to remove the clause that matches gender values. How and why are the results different?

### Outer joins

Suppose you are asked to list all student names, along with the name of their SLP instructor, if any.

```
mysql> select student.first_name, student.last_name, 
    -> staff.first_name, staff.last_name 
    -> from student inner join staff 
    -> on student.slp_instructor_first_name = staff.first_name 
    -> and student.slp_instructor_last_name = staff.last_name;
+------------+-----------+------------+------------+
| first_name | last_name | first_name | last_name  |
+------------+-----------+------------+------------+
| Alice      | Albert    | Sam        | Studybuddy |
| Charlie    | Cadillac  | Terry      | Tutor      |
| Gary       | Gatehouse | Terry      | Tutor      |
| Irving     | Icehouse  | Sam        | Studybuddy |
+------------+-----------+------------+------------+
4 rows in set (0.00 sec)
```

This is a good start, but a quick check shows that there are 9 rows in the `student` table. What happened to the other 5 students?

An inner join returns a result row when there are matching rows in both tables. When you want to keep all rows from one of the tables, even where there is no match in the other, you need an **outer join**.

```
mysql> select student.first_name, student.last_name, 
    -> staff.first_name, staff.last_name 
    -> from student left outer join staff 
    -> on student.slp_instructor_first_name = staff.first_name 
    -> and student.slp_instructor_last_name = staff.last_name;
+------------+-----------+------------+------------+
| first_name | last_name | first_name | last_name  |
+------------+-----------+------------+------------+
| Alice      | Albert    | Sam        | Studybuddy |
| Bob        | Booth     | NULL       | NULL       |
| Charlie    | Cadillac  | Terry      | Tutor      |
| Debbie     | Davis     | NULL       | NULL       |
| Eric       | Elkins    | NULL       | NULL       |
| Frank      | Forest    | NULL       | NULL       |
| Gary       | Gatehouse | Terry      | Tutor      |
| Hannah     | Hermanson | NULL       | NULL       |
| Irving     | Icehouse  | Sam        | Studybuddy |
+------------+-----------+------------+------------+
9 rows in set (0.00 sec)
```

Here, the keywords `LEFT OUTER JOIN` tell the DBMS that you want to return all rows from the table to the left (before) the keywords. So, all nine `student` rows are returned. Where there is no corresponding staff data, `NULL`s are filled in.

Changing the query to use `RIGHT OUTER JOIN` produces these results.

```
+------------+-----------+------------+------------+
| first_name | last_name | first_name | last_name  |
+------------+-----------+------------+------------+
| NULL       | NULL      | Chris      | Calendar   |
| NULL       | NULL      | Edna       | Editor     |
| NULL       | NULL      | Greg       | Guardian   |
| Alice      | Albert    | Sam        | Studybuddy |
| Irving     | Icehouse  | Sam        | Studybuddy |
| Charlie    | Cadillac  | Terry      | Tutor      |
| Gary       | Gatehouse | Terry      | Tutor      |
+------------+-----------+------------+------------+
7 rows in set (0.00 sec)
```

This ensures that every `staff` row is returned at least once, along with each corresponding `student` row, if any.

#### Exercise set 10

1. List the first and last name of *every* student, along with the sports that they play, if any. You only need to join two tables for this query.

2. List *every* team (sport and gender), along with the students that play it, as shown below. You will need to join three tables.

   ```
   +-----------------+--------+------------+-----------+
   | name            | gender | first_name | last_name |
   +-----------------+--------+------------+-----------+
   | Baseball        | Men    | Charlie    | Cadillac  |
   | Baseball        | Men    | Eric       | Elkins    |
   | Basketball      | Men    | NULL       | NULL      |
   | Basketball      | Women  | NULL       | NULL      |
   | Cross country   | Men    | NULL       | NULL      |
   | Cross country   | Women  | NULL       | NULL      |
   | Golf            | Men    | Bob        | Booth     |
   | Lacrosse        | Men    | NULL       | NULL      |
   | Lacrosse        | Women  | NULL       | NULL      |
   | Soccer          | Men    | Charlie    | Cadillac  |
   | Soccer          | Women  | Debbie     | Davis     |
   | Softball        | Women  | Debbie     | Davis     |
   | Swimming        | Men    | NULL       | NULL      |
   | Swimming        | Women  | NULL       | NULL      |
   | Tennis          | Men    | NULL       | NULL      |
   | Tennis          | Women  | NULL       | NULL      |
   | Track and field | Men    | NULL       | NULL      |
   | Track and field | Women  | NULL       | NULL      |
   | Volleyball      | Women  | NULL       | NULL      |
   +-----------------+--------+------------+-----------+
   19 rows in set (0.01 sec)
   ```

### Self joins

Sometimes it can be useful to join a table with itself. These queries often answer questions about pairs of entities, because they put columns from two different rows of the same table into one row of results.

One obstacle is that you need a way to refer to these two different rows, and you can't just use the table name because it is the same table in both cases. You address this by giving an **alias** to each table in the query.

Suppose you are asked to list all college sports that have both a Men's and a Women's team. You can do this with a self join. Here is a start.

```
mysql> select a.name, a.gender, b.name, b.gender 
    -> from sport a join sport b 
    -> on a.name = b.name where a.gender <> b.gender;
+-----------------+--------+-----------------+--------+
| name            | gender | name            | gender |
+-----------------+--------+-----------------+--------+
| Basketball      | Men    | Basketball      | Women  |
| Basketball      | Women  | Basketball      | Men    |
| Cross country   | Men    | Cross country   | Women  |
| Cross country   | Women  | Cross country   | Men    |
| Lacrosse        | Men    | Lacrosse        | Women  |
| Lacrosse        | Women  | Lacrosse        | Men    |
| Soccer          | Men    | Soccer          | Women  |
| Soccer          | Women  | Soccer          | Men    |
| Swimming        | Men    | Swimming        | Women  |
| Swimming        | Women  | Swimming        | Men    |
| Tennis          | Men    | Tennis          | Women  |
| Tennis          | Women  | Tennis          | Men    |
| Track and field | Men    | Track and field | Women  |
| Track and field | Women  | Track and field | Men    |
+-----------------+--------+-----------------+--------+
14 rows in set (0.00 sec)

```

This uses the aliases `a` and `b` to refer to two distinct "versions" or hypothetical copies of the `sport` table. (More accurately, the aliases refer to two sets of rows from the table.)

It asks for the name and gender of two sports teams, call them `a` and `b`, where the sport names match but the genders do not match. (The `<>` symbol means "is not equal to".)

This is a good start, but there is too much data returned. For example, look at the last two result rows. The next-to-last tells you that Track and field has a Men's team but also a Women's team. The last row tells you that Track and field has a Women's team but also a Men's team.

In other words, the last two result rows really represent the same fact. You asked for pairs with different genders, but the results show each pair twice: once in each "direction."

The fix for this is not exactly obvious.

```
mysql> select a.name, a.gender, b.name, b.gender 
    -> from sport a join sport b 
    -> on a.name = b.name where a.gender < b.gender;
+-----------------+--------+-----------------+--------+
| name            | gender | name            | gender |
+-----------------+--------+-----------------+--------+
| Basketball      | Men    | Basketball      | Women  |
| Cross country   | Men    | Cross country   | Women  |
| Lacrosse        | Men    | Lacrosse        | Women  |
| Soccer          | Men    | Soccer          | Women  |
| Swimming        | Men    | Swimming        | Women  |
| Tennis          | Men    | Tennis          | Women  |
| Track and field | Men    | Track and field | Women  |
+-----------------+--------+-----------------+--------+
7 rows in set (0.00 sec)
```

Using the `<` operator filters for pairs `a` and `b` where the the first gender is (alphabetically) less than the second. That is still a "not equal" test, but it is only true in one direction for each pair. (You would get equivalent results if you used `>` instead.)

To complete your query for the requested result, you should probably display only one column: one copy of the `name` value. The other columns were included to better illustrate how the results were obtained.

#### Exercise set 11

1. Use a self join to list the names of all sports that are played in more than one season.

2. Use a self join to list all pairs of students who have the same SLP instructor. The results should list each pair of students only once.

3. Use a self join to list the name of each staff member and the name of their assistant, excluding people who are their own assistant:

   ```
   +------------+------------+------------+-----------+
   | first_name | last_name  | first_name | last_name |
   +------------+------------+------------+-----------+
   | Sam        | Studybuddy | Chris      | Calendar  |
   | Terry      | Tutor      | Chris      | Calendar  |
   | Edna       | Editor     | Greg       | Guardian  |
   +------------+------------+------------+-----------+
   3 rows in set (0.00 sec)
   ```

## Processing data with aggregate functions

SQL includes a number of **aggregate functions** that summarize or "roll up" data in table rows.

For example, if you wanted to check how many rows were in the `visit2nf` table, you would probably run `SELECT * FROM visit2nf;`, then ignore the rows and look at the count shown by MySQL's status display.

But, an aggregate function allows you to ask the question that you really wanted.

```
mysql> select count(*) from visit2nf;
+----------+
| count(*) |
+----------+
|       14 |
+----------+
1 row in set (0.00 sec)
```

The `count` aggregate function returns the number of rows that match some criterion; the `*` criterion matches everything.

Because every row has an `email` value, the following produces the same result.

```
mysql> select count(email) from visit2nf;                                                                            
+--------------+
| count(email) |
+--------------+
|           14 |
+--------------+
1 row in set (0.00 sec)
```

But some of those email address are duplicates, so leave them out.

```
mysql> select count(distinct email) from visit2nf;                                                          
+-----------------------+
| count(distinct email) |
+-----------------------+
|                     9 |
+-----------------------+
1 row in set (0.00 sec)
```

You can use a `WHERE` clause with aggregate functions. This asks how many visits were made by Eric Elkins.

```
mysql> select count(*) from visit2nf where email = 'eelkins@dewv.net';
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

### The `GROUP BY` clause

Suppose you want to know how many visits were made by *each* student. You could repeat the previous query with different email values, then put all that together. It's easier to group the results by email address.

```
mysql> select count(*) from visit2nf group by email;
+----------+
| count(*) |
+----------+
|        1 |
|        1 |
|        2 |
|        3 |
|        1 |
|        2 |
|        2 |
|        1 |
|        1 |
+----------+
9 rows in set (0.00 sec)
```

This tells you that one student (email address) visited 3 times, three visited twice, and so on. But it's more helpful like this.

```
mysql> select email, count(*) from visit2nf group by email;                                                          
+---------------------+----------+
| email               | count(*) |
+---------------------+----------+
| aalbert@dewv.net    |        1 |
| bbooth@dewv.net     |        1 |
| ccadillac@dewv.net  |        2 |
| ddavis@dewv.net     |        3 |
| eelkins@dewv.net    |        1 |
| fforest@dewv.net    |        2 |
| ggatehouse@dewv.net |        2 |
| hhermanson@dewv.net |        1 |
| iicehouse@dewv.net  |        1 |
+---------------------+----------+
9 rows in set (0.00 sec)
```

Now you know which email is on 3 visits, and so forth.

#### The `HAVING` clause

Suppose that you were asked to list all students who have visited more than once. You can filter aggregate *results* with `HAVING`.

```
mysql> select email, count(*) from visit2nf group by email having count(*) > 1;
+---------------------+----------+
| email               | count(*) |
+---------------------+----------+
| ccadillac@dewv.net  |        2 |
| ddavis@dewv.net     |        3 |
| fforest@dewv.net    |        2 |
| ggatehouse@dewv.net |        2 |
+---------------------+----------+
4 rows in set (0.00 sec)
```

This computes the number of visits for each email address, then displays only the counts that are greater than one.

Like `WHERE`, the `HAVING` clause determines what data is displayed. The difference is that `WHERE` determines which rows *go into* the aggregate function, while `HAVING` determines which aggregate results are displayed. 

```
mysql> select email, count(*) from visit2nf 
    -> where email <> 'ddavis@dewv.net' 
    -> group by email having count(*) > 1;     
+---------------------+----------+
| email               | count(*) |
+---------------------+----------+
| ccadillac@dewv.net  |        2 |
| fforest@dewv.net    |        2 |
| ggatehouse@dewv.net |        2 |
+---------------------+----------+
3 rows in set (0.00 sec)
```

 There are many aggregate functions besides `COUNT()`. Here are examples of the most commonly used.

```
-- Use MIN() to find minimum value: who has the earliest visit on record?
mysql> select email, min(check_in_time) from visit2nf;
+------------------+---------------------+
| email            | min(check_in_time)  |
+------------------+---------------------+
| aalbert@dewv.net | 2016-08-30 13:35:55 |
+------------------+---------------------+
1 row in set (0.00 sec)

-- Use MAX() to find maximum value: when was the most recent visit for each student?
mysql> select email, max(check_in_time) from visit2nf group by email;                                                
+---------------------+---------------------+
| email               | max(check_in_time)  |
+---------------------+---------------------+
| aalbert@dewv.net    | 2016-08-30 15:15:05 |
| bbooth@dewv.net     | 2016-08-30 15:44:54 |
| ccadillac@dewv.net  | 2016-08-31 11:51:15 |
| ddavis@dewv.net     | 2016-08-31 16:00:06 |
| eelkins@dewv.net    | 2016-08-30 15:49:59 |
| fforest@dewv.net    | 2016-08-31 11:19:15 |
| ggatehouse@dewv.net | 2016-08-31 14:36:56 |
| hhermanson@dewv.net | 2016-08-30 15:55:55 |
| iicehouse@dewv.net  | 2016-08-30 14:56:56 |
+---------------------+---------------------+
9 rows in set (0.00 sec)

-- Use SUM() to total numeric values
mysql> select location, sum(memory) from computer group by location;
+----------------+-------------+
| location       | sum(memory) |
+----------------+-------------+
| NLC            |          20 |
| Writing center |           8 |
+----------------+-------------+
2 rows in set (0.00 sec)

-- Use AVG() to compute the average of numeric values
mysql> select avg(memory) from computer;
+-------------+
| avg(memory) |
+-------------+
|      5.6000 |
+-------------+
1 row in set (0.00 sec)
```

### Exercise set 12

1. Write a single query that lists each gender and how many sports exist for that gender.
2. Write a single query to list major names and the number of students who have that major. (It is okay if majors with no students are not in the results.)
3. Write a single query to answer this question: how many computers have less than 8GB of memory?
4. Write a single query to list the locations that have more than one SLP instructor.

## Subqueries 

Consider the following query.

```
mysql> select email from student_major 
    -> where major_name = 'Computer Science' or major_name = 'Philosophy';
+---------------------+
| email               |
+---------------------+
| aalbert@dewv.net    |
| bbooth@dewv.net     |
| ggatehouse@dewv.net |
| bbooth@dewv.net     |
| ddavis@dewv.net     |
+---------------------+
5 rows in set (0.00 sec)
```

This is straightforward, but can become awkward if there are many different values you want to match on. The `IN` operator allows you to specify a set of values.

```
mysql> select email from student_major 
    -> where major_name in ('Computer Science', 'Philosophy', 'English');  
+---------------------+
| email               |
+---------------------+
| aalbert@dewv.net    |
| bbooth@dewv.net     |
| ggatehouse@dewv.net |
| ccadillac@dewv.net  |
| ddavis@dewv.net     |
| bbooth@dewv.net     |
| ddavis@dewv.net     |
+---------------------+
7 rows in set (0.00 sec)
```

The `IN` operator can also match on sets that are produced by a **subquery**-- a secondary query nested within the main one.

```
mysql> select email from student_major where major_name = 'Computer Science' 
    -> and email in (select email from student_sport);            
+-----------------+
| email           |
+-----------------+
| bbooth@dewv.net |
+-----------------+
1 row in set (0.00 sec)
```

This query lists all Computer Science majors who are athletes. The subquery (or "inner" query) generates all student athlete emails, then the main or "outer" query uses `IN` to match with emails of Computer Science majors.

Subqueries can also appear in the `SELECT` list.

```
mysql> select location, cubicle, memory, 
    -> (select avg(memory) from computer) as 'average memory' from computer;                          
+----------------+---------+--------+----------------+
| location       | cubicle | memory | average memory |
+----------------+---------+--------+----------------+
| NLC            | A       |      4 |         5.6000 |
| NLC            | B       |      8 |         5.6000 |
| NLC            | C       |      8 |         5.6000 |
| Writing center | A       |      4 |         5.6000 |
| Writing center | B       |      4 |         5.6000 |
+----------------+---------+--------+----------------+
5 rows in set (0.01 sec)
```

This query lists each computer, its amount of memory, and the average amount of memory. Notice that `AS` is used to label one of the result columns, replacing the awkward system-generated label.

When a subquery uses a value from the main query, it is called a **correlated subquery**. This query is similar to the previous one, but lists the average memory for computers at that computer's location.

```
mysql> select location, cubicle, memory, 
    -> (select avg(memory) from computer where computer.location = a.location) 
    -> as 'location average' from computer a;   
+----------------+---------+--------+------------------+
| location       | cubicle | memory | location average |
+----------------+---------+--------+------------------+
| NLC            | A       |      4 |           6.6667 |
| NLC            | B       |      8 |           6.6667 |
| NLC            | C       |      8 |           6.6667 |
| Writing center | A       |      4 |           4.0000 |
| Writing center | B       |      4 |           4.0000 |
+----------------+---------+--------+------------------+
5 rows in set (0.00 sec)
```

Because the subquery is on the same table as the main query, you must use an alias for one table instance.

`IN` is not the only SQL operator for use with subqueries.

The `EXISTS` operator checks for the existence of records that satisfy criteria stated in the subquery. Suppose you wanted to find the sports that have athletes in the database.

```
mysql> select distinct name, gender from sport where exists 
    -> (select * from student_sport where sport.name = student_sport.sport_name 
    -> and sport.gender = student_sport.gender);
+----------+--------+
| name     | gender |
+----------+--------+
| Baseball | Men    |
| Golf     | Men    |
| Soccer   | Men    |
| Soccer   | Women  |
| Softball | Women  |
+----------+--------+
5 rows in set (0.00 sec)
```

It is common to `SELECT *` in subqueries that follow `EXISTS` because it does not matter what columns are in the result rows; the point is just to check if there *are* any result rows.

Both `IN` and `EXISTS` can be combined with `NOT`. For example, this reverses the logic of the previous query, listing sports that do not have any athletes in the database.

```
mysql> select distinct name, gender from sport where not exists 
    -> (select * from student_sport where sport.name = student_sport.sport_name 
    -> and sport.gender = student_sport.gender);
+-----------------+--------+
| name            | gender |
+-----------------+--------+
| Basketball      | Men    |
| Basketball      | Women  |
| Cross country   | Men    |
| Cross country   | Women  |
| Lacrosse        | Men    |
| Lacrosse        | Women  |
| Swimming        | Men    |
| Swimming        | Women  |
| Tennis          | Men    |
| Tennis          | Women  |
| Track and field | Men    |
| Track and field | Women  |
| Volleyball      | Women  |
+-----------------+--------+
13 rows in set (0.00 sec)
```

The `ALL` operator applies a comparison to values from the main query and the entire set of values returned by the subquery. Say that you've heard some concerns that some locations have better computer equipment than others.

```
mysql> select location, cubicle, memory from computer a 
    -> where memory > all (select memory from computer where computer.location <> a.location);   
+----------+---------+--------+
| location | cubicle | memory |
+----------+---------+--------+
| NLC      | B       |      8 |
| NLC      | C       |      8 |
+----------+---------+--------+
2 rows in set (0.00 sec)
```

This tells you that there are two computers, both at the NLC location, with more memory than all of the computers at other locations. 

To follow up, you could use the `ANY` operator to find the computers with the least amount of memory.

```
mysql> select location, cubicle, memory from computer a 
    -> where memory < any (select memory from computer); 
+----------------+---------+--------+
| location       | cubicle | memory |
+----------------+---------+--------+
| NLC            | A       |      4 |
| Writing center | A       |      4 |
| Writing center | B       |      4 |
+----------------+---------+--------+
3 rows in set (0.00 sec)
```

As is often the case, this is equivalent to a subquery that uses an aggregate function. Here, you would get the same results with `select location, cubicle, memory from computer where memory = (select min(memory) from computer);`.  

###Exercise set 13 

Use the subquery operators introduced in this section to answer the following. Where possible, give other queries that would also return the correct results.

1. List the name of all sports played by both men and women. 
2. List every student email, their associated major(s), and the number of students who have that major.
3. Without using an aggregate function, write a query that returns the earliest visit check in time.
4. All students in the database have at least one major listed, even if it is listed as "Undecided". Write a query that shows this is true. (Hint: show that there are no exceptions to the stated rule.)

##Set operations 

SQL defines a set `UNION` operator that allows you to append one query's results to another. Suppose that you wanted to list all email addresses in the database.

```
mysql> select email from student
    -> union
    -> select email from staff;
+----------------------+
| email                |
+----------------------+
| aalbert@dewv.net     |
| bbooth@dewv.net      |
| ccadillac@dewv.net   |
| ddavis@dewv.net      |
| eelkins@dewv.net     |
| fforest@dewv.net     |
| ggatehouse@dewv.net  |
| hhermanson@dewv.net  |
| iicehouse@dewv.net   |
| ccalendar@dewv.net   |
| sstudybuddy@dewv.net |
| ttutor@dewv.net      |
| eeditor@dewv.net     |
| gguardian@dewv.net   |
+----------------------+
14 rows in set (0.01 sec)
```

When using `UNION`, the two queries must be **union compatible**: they must return the same number of columns, and the corresponding columns must have the same data type.

MySQL also provides operators for set intersection (`INTERSECT`) and set difference (`MINUS`).

# Contents

[TOC]
