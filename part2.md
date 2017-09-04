# Databases in Context: A Just-in-Time Tutorial, Part 2

[Steve Mattingly](https://www.linkedin.com/in/steve-mattingly-aab8064a), Assistant Professor of Computer Science, [Davis & Elkins College](https://www.dewv.edu).

*Databases in Context: A Just-in-Time Tutorial* by Stephen S. Mattingly is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/). ![Creative Commons Attribution-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)

------

Learn more about Open Educational Resources at [UNESCO](http://www.unesco.org/new/en/communication-and-information/access-to-knowledge/open-educational-resources/). ![UNESCO Open Educational Resources logo](http://www.unesco.org/new/typo3temp/pics/5d3118e041.jpg)

------

[Contents](#Contents)

------

## Designing databases to avoid data anomalies

So far, you have learned the basics of Creating, Reading, Updating, and Deleting rows in a relational database table. (These are sometimes called the **CRUD** operations.)

Along the way, you dealt with some data problems related to the design of the `visit` table.

- It is difficult to extract a definitive list of majors or sports.


- One person entered her name in multiple different forms.
- One person entered his email address correctly for one visit, and incorrectly for another.

There are some other problems that you might have picked up on.

- There is no way to record a student's data before they visit a Learning Center location. This is called an **insert anomaly**.
- Removing all of a student's visits (maybe to archive them at year end) will remove all information about the student. This is called a **deletion anomaly**.
- The same facts are recorded in multiple places, which can lead to update problems. For example, suppose Frank Forest declares a History major, but only one of his two `visit` rows is updated. This would leave the data in an inconsistent state due to an **update anomaly**.

The `visit` table's design resembles the kind of data records that non-specialists often create using spreadsheets or user-friendly applications for database management. The table represents the user or client's view of the world. Inexperienced technical staff might base a design on the user's view. But the problems identified above show that it is not a good design for use with a relational DBMS.

Database designers know to decompose the user's view into multiple pieces that can be better managed by the DBMS. This process of breaking the user's view into multiple pieces is called **normalization**. Normalization eliminates problematic redundancy to prevent data anomalies and help ensure data integrity.

Database experts have defined a series of "normal forms," which describe specific properties of good relational database design. The initial design of the `visit` table is an intentionally bad example: it does not satisfy any of these normal forms.

### First normal form

Recall that it was difficult to extract a list of all majors or of all sports from the unnormalized design. In formal terms, you were trying to define the domain for those columns.

**First normal form (1NF)** requires that every column contain a single value drawn from a domain of atomic values. **Atomic values** are values that cannot be divided into identifiable pieces. 

In practice, this means that every column of every row must contain one simple value. 

The initial design violates 1NF because of values like the ones below.

```
mysql> -- Query for values containing ', ' or ' and '. 
mysql> -- (Note: the 'like' operator matches text patterns. The % wildcard matches anything.)

mysql> select distinct majors from visit where majors like '%, %' or majors like '% and %';
+------------------------------+
| majors                       |
+------------------------------+
| Math, Comp Sci               |
| Philosophy and English       |
| Computer Science, Philosophy |
+------------------------------+
3 rows in set (0.03 sec)

mysql> select distinct sports from visit where sports like '%, %' or sports like '% and %';     
+--------------------------+
| sports                   |
+--------------------------+
| Men's soccer, Baseball   |
| Women's soccer, Softball |
+--------------------------+
2 rows in set (0.00 sec)
```

These are not really single values. Each row shown contains two values in a single column. These multi-value entries are sometimes called **repeating groups**.

Arguably, an address column with values like `'100 Campus Drive Elkins WV 26241'` also violates 1NF. Although this is a single address value it is arguably not atomic: street address, city, state, and postal code are identifiable pieces that could be separate columns. It is likely that a user would want to select data based on city values or postal code. As a result, most database designers would use multiple columns for this data. 

On the other hand, most designers would store phone numbers in a single column with values like `'+1 304 555 1000'`, even though there are separate country code, area code, exchange, and number portions. There seems to be little practical reason for separate columns, unless you know there will be a need to query by area code or similar.

Bottom line: the formal concept of atomic values is a bit ambiguous in practice.

To satisfy first normal form, you will decompose `visit` into three new tables.

- `sport` is a new table for facts about the college's sports teams.
- `major` is a new table for facts about the college's majors.
- `visit1nf` is a modified copy of the unnormalized `visit` table, without the `sports` and `majors` columns. As before, the table stores facts about student visits to Learning Center locations. (You will leave the original `visit` table in place for easy reference.)

Use a `CREATE TABLE` statement to make a new table to store facts about the college's sports.

```
mysql> create table sport (
    -> name varchar(15) NOT NULL,
    -> gender varchar(5) NOT NULL,
    -> season varchar(6) NOT NULL,
    -> constraint primary key(name, gender)
    -> );
Query OK, 0 rows affected (0.03 sec)
```

This table has three columns, and captures more sports information than is embedded in the `visit` table. (More on that after the table is populated with data.) All of the columns have a datatype of `VARCHAR`, which is character (textual) data. The maximum length of a value is specified in parentheses.

You have now created a new table, but there are no rows in it. Populate the new table with the following `INSERT`  statement.

```
mysql> insert into sport(name, gender, season) values
    -> ('Basketball', 'Men', 'Fall'),
    -> ('Basketball', 'Women', 'Fall'),
    -> ('Cross country', 'Men', 'Fall'),
    -> ('Cross country', 'Women', 'Fall'),
    -> ('Soccer', 'Men', 'Fall'),
    -> ('Soccer', 'Women', 'Fall'),
    -> ('Swimming', 'Men', 'Fall'),
    -> ('Swimming', 'Women', 'Fall'),
    -> ('Track and field', 'Men', 'Fall'),
    -> ('Track and field', 'Women', 'Fall'),
    -> ('Golf', 'Men', 'Fall'),
    -> ('Volleyball', 'Women', 'Fall'),
    -> ('Baseball', 'Men', 'Spring'),
    -> ('Softball', 'Women', 'Spring'),
    -> ('Lacrosse', 'Men', 'Spring'),
    -> ('Lacrosse', 'Women', 'Spring'),
    -> ('Tennis', 'Men', 'Spring'),
    -> ('Tennis', 'Women', 'Spring');
Query OK, 18 rows affected (0.01 sec)
Records: 18  Duplicates: 0  Warnings: 0
```

Each row represents facts about a single specific sport. Sets of columns within the row can represent different facts about that sport. 

The set $\lbrace$`name`, `gender`$\rbrace$ identifies a specific sport and says that it exists. For example, the plain English interpretation of this set of columns from the first row is "There is a sport known as Men's Basketball." A set of columns that uniquely identify a single row is called a **candidate key**. If the set contains more than one column, it is called a **compound key**.

Some tables have more than one candidate key, though this one does not. One candidate key is selected (more or less arbitrarily) as the **primary key**.  The set $\lbrace$`name`, `gender`$\rbrace$ is this table's only candidate key, so it must be the primary key.

The last line in the `CREATE TABLE` statement above defines a `PRIMARY KEY` constraint. This tells the DBMS which set of columns have been selected as the primary key. Based on this constraint, the DBMS enforces certain rules.

- Primary key columns must not be `NULL`. The DBMS will reject data containing `NULL` for any primary key column. Each `sport` row must have a non-null value for `name` and `gender`.
- Primary key values must be unique. The DBMS will reject operations that would result in multiple rows with the same values in primary key columns. The `sport` table can have only one row with $\lbrace$`name`, `gender`$\rbrace$ containing $\lbrace$'Basketball', 'Men'$\rbrace$.

These rules ensure **entity integrity**: you can always identify the unique **entity** (or "thing") that the row's facts are about.

Each non-key column represents a single fact about the entity that is identified by the primary key value. For example, the only non-key column in the first row (`season`) tells us that the sport identified by the primary key value $\lbrace$'Basketball', 'Men'$\rbrace$ is played in the Fall season.

Non-key columns may or may not accept `NULL`s, depending on the applicable rules about valid data. These rules are not set by database design practices, but are **business rules**: user requirements and policies, relevant laws, and logic constraints. The `season` column is defined with a `NOT NULL` constraint-- interpreted as a business rule that says "Every sport has a season, and you must specify that season for every sport." 

This table is a complete definition of domain values for the college's sports, drawn from athletic rosters. Having a complete domain definition is helpful for multiple reasons.

- There is no need to guess at column sizes, so they can be defined as small as possible in order to save space. 
- The database captures information about all currently existing sports-- even those that are not currently associated with any student in the data. In other words, some insert anomalies have been eliminated. 

Next comes a table for facts about the college's majors. Create and populate it as follows.

 ```
mysql> create table major (
    -> name varchar(29) NOT NULL,
    -> constraint primary key (name)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> insert into major(name) values
    -> ('Undecided'),
    -> ('Accounting'),
    -> ('Adventure Recreation'),
    -> ('Appalachian Studies'),
    -> ('Art'),
    -> ('Biology'),
    -> ('Business'),
    -> ('Chemistry'),
    -> ('Child and Family Studies'),
    -> ('Computer Science'),
    -> ('Criminal Justice'),
    -> ('Criminology'),
    -> ('Design and Technical Theatre'),
    -> ('Early Childhood Education'),
    -> ('Economics'),
    -> ('Education'),
    -> ('English'),
    -> ('Environmental Science'),
    -> ('Exercise Science'),
    -> ('Finance'),
    -> ('History'),
    -> ('Hospitality Management'),
    -> ('Management'),
    -> ('Marketing'),
    -> ('Mathematics'),
    -> ('Music'),
    -> ('Nursing'),
    -> ('Philosophy'),
    -> ('Physical Education'),
    -> ('Political Science'),
    -> ('Pre-Dental'),
    -> ('Pre-Law'),
    -> ('Pre-Medical'),
    -> ('Pre-Ministerial'),
    -> ('Pre-Pharmacy'),
    -> ('Pre-Physical Therapy'),
    -> ('Pre-Veterinary'),
    -> ('Psychology and Human Services'),
    -> ('Religion and Philosophy'),
    -> ('Sociology'),
    -> ('Sport Management'),
    -> ('Sustainability Studies'),
    -> ('Theatre Arts');
Query OK, 43 rows affected (0.01 sec)
Records: 43  Duplicates: 0  Warnings: 0
 ```

Again, this is a complete set of domain values (drawn from the academic catalog) for the college's majors, allowing space efficiency and eliminating insert anomalies. 

Notice that there is only one column, therefore it must be

- a key column, 
- the one and only candidate key, and 
- the primary key. 

Each row of this table records the simple fact that an entity exists: a unique major with a particular name.

To complete the decomposition, you will create and populate a modified copy of the `visit` table. 

To see how an existing table was created, use the (MySQL-specific) command `SHOW CREATE TABLE <tablename>;`. The result is easier to work with when you use the vertical display option `\G` as shown below.

```
mysql> show create table visit \G
*************************** 1. row ***************************
       Table: visit
Create Table: CREATE TABLE `visit` (
  `first_name` varchar(128) NOT NULL,
  `last_name` varchar(128) NOT NULL,
  `email` varchar(128) NOT NULL,
  `academic_rank` varchar(128) NOT NULL,
  `residential_status` varchar(128) NOT NULL,
  `majors` varchar(128) DEFAULT NULL,
  `sports` varchar(128) DEFAULT NULL,
  `slp_instructor_first_name` varchar(128) DEFAULT NULL,
  `slp_instructor_last_name` varchar(128) DEFAULT NULL,
  `check_in_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `check_out_time` timestamp NULL DEFAULT NULL,
  `location` varchar(128) NOT NULL,
  `purpose` varchar(255) NOT NULL,
  `purpose_achieved` char(1) DEFAULT NULL,
  `tutoring` varchar(255) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.00 sec)
```

Copy the `CREATE TABLE` statement to your clipboard. (Begin with `CREATE TABLE` in all capitals and include everything that follows except for the last line.) Paste this into a separate text editor because it is too tedious to manipulate it in the `mysql` client.

In your text editor, modify the statement as follows. 

1. Change the table name to `visit1nf`. You are leaving the original `visit` table in place for later reference.
2. Remove the line for the `majors` column. This data will not appear in your new `visit1nf` table.
3. Remove the line for the `sports` column. This data will not appear in your new `visit1nf` table.
4. Add a comma to the end of the line for the `comments` column, followed by a new line that reads `constraint primary key(email, check_in_time)`. This tells the DBMS that each row can be uniquely identified by an email address and a check in time.
5. Add a semicolon at the end.

Copy and paste the modified statement into your `mysql` client.

```
mysql> CREATE TABLE `visit1nf` (
    ->   `first_name` varchar(128) NOT NULL,
    ->   `last_name` varchar(128) NOT NULL,
    ->   `email` varchar(128) NOT NULL,
    ->   `academic_rank` varchar(128) NOT NULL,
    ->   `residential_status` varchar(128) NOT NULL,
    ->   `slp_instructor_first_name` varchar(128) DEFAULT NULL,
    ->   `slp_instructor_last_name` varchar(128) DEFAULT NULL,
    ->   `check_in_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ->   `check_out_time` timestamp NULL DEFAULT NULL,
    ->   `location` varchar(128) NOT NULL,
    ->   `purpose` varchar(255) NOT NULL,
    ->   `purpose_achieved` char(1) DEFAULT NULL,
    ->   `tutoring` varchar(255) DEFAULT NULL,
    ->   `comments` varchar(255) DEFAULT NULL,
    ->   constraint primary key(email, check_in_time)
    -> ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
Query OK, 0 rows affected (0.03 sec)
```

The `PRIMARY KEY` constraint ensures that  `email` and `check_in_time` cannot contain `NULL`s. The `NOT NULL` constraints appearing on the lines for those columns are logically redundant, but it is best to include them because a DBMS may otherwise define a default value for the columns to prevent `NULL`s. 

Now copy the contents of the unnormalized `visit` (excluding `sports` and `majors`) to `visit1nf` as follows.

```
mysql> insert into visit1nf 
    ->   (first_name, last_name, email, academic_rank, residential_status,
    ->   slp_instructor_first_name, slp_instructor_last_name, check_in_time,
    ->   check_out_time, location, purpose, purpose_achieved, tutoring, comments)
    ->   select first_name, last_name, email, academic_rank, residential_status,
    ->   slp_instructor_first_name, slp_instructor_last_name, check_in_time,
    ->   check_out_time, location, purpose, purpose_achieved, tutoring, comments
    ->   from visit;
Query OK, 14 rows affected (0.04 sec)
Records: 14  Duplicates: 0  Warnings: 0
```

This form of the `INSERT` statement does not explicitly list data values. Instead, it `SELECT`s rows from `visit` and `INSERT`s them into `visit1nf`. The column list excludes the `sports` and `majors` columns, which do not exist in the new table. 

The original `visit` table does not satisfy 1NF, but you have now decomposed it into three tables, all in 1NF. All columns in these tables have single values drawn from domains of atomic values. There are no repeating groups. Each row contains a unique key value, and each non-key column tells a single fact about that key.

Of course, the normalized tables cannot currently tell us which students play which sports, or which students have which majors. When information is lost in this way, it is called a **lossy decomposition**. 

To preserve all information and achieve a **lossless composition**, you will need two more tables. One table will record facts about which students play which sports-- call it `student_sport`. The other will record facts about which students have which majors-- call it `student_major`. 

These tables are needed because of **many-to-many** relationships in the data. That is, one student can play multiple sports, and one sport can have many student athletes. One student can have multiple majors, and one major will typically have multiple students.

Because each row in these tables captures the fact that two things are associated-- a student has a major, or a student plays a sport-- they are called **associative tables**. They are also known as cross-reference tables, and by many other names. These tables are needed when there is a many-to-many relationship between two entities.

Create and populate the `student_sport` table as follows.

```
mysql> create table student_sport (
    ->   email varchar(128) NOT NULL,
    ->   sport_name varchar(15) NOT NULL,
    ->   gender varchar(5) NOT NULL,
    ->   constraint primary key(email, sport_name, gender)
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql> insert into student_sport(email, sport_name, gender) values 
    ->   ('ccadillac@dewv.net', 'Soccer', 'Men'), 
    ->   ('ccadillac@dewv.net', 'Baseball', 'Men'), 
    ->   ('ddavis@dewv.net', 'Soccer', 'Women'),
    ->   ('ddavis@dewv.net', 'Softball', 'Women'), 
    ->   ('bbooth@dewv.net', 'Golf', 'Men'),   
    ->   ('eelkins@dewv.net', 'Baseball', 'Men') 
    -> ;
Query OK, 6 rows affected (0.01 sec)
Records: 6  Duplicates: 0  Warnings: 0
```

The table's primary key is $\lbrace$`email`, `sport_name`, `gender`$\rbrace$. Each row in the table captures the fact that some particular student plays some particular sport. The same student may appear with multiple sports, and the same sport may appear with multiple students.

A similar table is needed to associate students and majors. This is left as an exercise.

#### Exercise set 5

Use the `tee <filename>;` and `notee;` commands to capture your solutions to the following exercises. Use the filename `exercise5-1.txt` for the first exercise, and so on.

1. Write and execute one or more `INSERT` statements on the `sport` table that are rejected for violating entity integrity.
2. Write and execute one or more `INSERT` statements on the `major` table that are rejected for violating entity integrity.
3. Write and execute one or more `UPDATE` statements on the `sport` table that are rejected for violating entity integrity.
4. Write and execute one or more `UPDATE` statements on the `major` table that are rejected for violating entity integrity.
5. Following the `student_sport` example, create and populate the `student_major` table. It should properly capture all facts about which students have which majors.

### Functional dependency

Before moving on to higher normal forms, you must master the concept of **functional dependency**. Here are some examples from the `learning_center` database tables.

1. In the `visit1nf` table, there is a functional dependency from email address to first and last names.
2. In the `visit1nf` table, there is a functional dependency from email address and check in time to location and check out time.
3. In the `sport` table, there is a functional dependency from name and gender to season.

More generally, a functional dependency exists between two sets of a table's columns if business rules require rows with matching values for one set of columns to have matching values for the other set of columns.

Each functional dependency is a relationship between two *sets* of columns. When you have values for columns in the first set, they imply values for the second set. Here are the same three examples, using different terms.

1. An $\lbrace$`email`$\rbrace$ value uniquely identifies one value for (each column in) $\lbrace$`first_name`, `last_name`$\rbrace$.
2. Values for $\lbrace$`email`, `check_in_time`$\rbrace$ are enough to look up values for $\lbrace$`location`, `check_out_time`$\rbrace$.
3. Given values for a sport's $\lbrace$`name`, `gender`$\rbrace$ you can figure out the sport's $\lbrace$`season`$\rbrace$.

Each of these relationships can be described as a function. A **function** is a relation with the additional property that each domain value maps to a *single* range value. A single email address must correspond to a single person.  The value of a function $f(x)$ is always the same for the same value of $x$.

On the surface, the functional dependency concept is straightforward. But there are some common misunderstandings and pitfalls you need to avoid. 

#### Be careful with the direction of dependency

All of the following state *the same fact* about a functional dependency from A to B. But because they arrange the terms differently, it's easy to mistake the direction of dependency.

- There is a functional dependency from A to B.
- B is functionally dependent on A.
- A (functionally) determines B.
- B is (functionally) determined by A.
- A is a **determinant** for B.

#### Some functional dependencies are trivial

Suppose that A determines B. This necessarily implies certain **trivial functional dependencies**, described in the subsections below. This tutorial will generally exclude these trivial dependencies when defining normalization concepts, and will not repeat this caveat with each definition. That makes the resulting definitions less precise, but easier to grasp.

##### Every superset of A determines B.

If $\lbrace$`email`$\rbrace$ determines $\lbrace$`first_name`, `last_name`$\rbrace$ then it trivially follows that $\lbrace$`email`, `academic_rank`$\rbrace$ determines $\lbrace$`first_name`, `last_name`$\rbrace$.

##### A determines every subset of B.

If $\lbrace$`email`$\rbrace$ determines $\lbrace$`first_name`, `last_name`$\rbrace$ then it trivially follows that $\lbrace$`email`$\rbrace$ determines $\lbrace$`first_name`$\rbrace$.

##### A determines A.

This is simply the principle of identity: $\lbrace$`email`$\rbrace$ trivially determines $\lbrace$`email`$\rbrace$.  $\lbrace$`first_name`$\rbrace$ trivially determines $\lbrace$`first_name`$\rbrace$.

#### Functional dependency is about valid values, not current facts 

Consider the  `sport` table.

```
mysql> select * from sport;
+-----------------+--------+--------+
| name            | gender | season |
+-----------------+--------+--------+
| Basketball      | Men    | Fall   |
| Basketball      | Women  | Fall   |
| Cross country   | Men    | Fall   |
| Cross country   | Women  | Fall   |
| Soccer          | Men    | Fall   |
| Soccer          | Women  | Fall   |
| Swimming        | Men    | Fall   |
| Swimming        | Women  | Fall   |
| Track and field | Men    | Fall   |
| Track and field | Women  | Fall   |
| Golf            | Men    | Fall   |
| Volleyball      | Women  | Fall   |
| Baseball        | Men    | Spring |
| Softball        | Women  | Spring |
| Lacrosse        | Men    | Spring |
| Lacrosse        | Women  | Spring |
| Tennis          | Men    | Spring |
| Tennis          | Women  | Spring |
+-----------------+--------+--------+
18 rows in set (0.06 sec)
```

Many textbooks would claim that the table's contents demonstrate a functional dependency from $\lbrace$`name`$\rbrace$ to $\lbrace$`season`$\rbrace$. This claim is presumably based on the Closed World Assumption, and allows for objective "correct" answers to exercises and exam questions. 

This is dangerous in practice because the Closed World Assumption is about current facts, not possible future facts. In other words, applying the Closed World Assumption to the data above implies that Women's Golf *does not currently exist* as a sport. It does *not* imply that Women's Golf *will never exist at any time in the future*. 

Suppose the college adds a Women's Golf team that plays in the Spring. The result would be a (men's) golf team that plays in the Fall, and a (women's) golf team that plays in the Spring. Clearly, there is no functional dependency from sports name to season in this situation.

Recall that a functional dependency exists "if *valid data requires* rows with matching values for one set of columns to have matching values for the other set of columns." Valid data means data that satisfies the organization's business rules. 

There are two mutually exclusive ways to look at the situation where Women's Golf is added as a Spring sport.

1. There *was* a functional dependency in the past, but *now* there is not.
2. There never was a functional dependency.

Here are the same conflicting descriptions, using different words.

1. In the past, it was not acceptable to play the same sport in different seasons, but now it is acceptable.
2. It has always been acceptable to play the same sport in different seasons. In the past the college did not, but now it does.

If a business rule has been changed to permit a situation that was forbidden in the past, then the first description is accurate. A change to the database design is needed, but that's to be expected when business rules change.

But if there was no business rule explicitly forbidding multiple seasons for one sport, the second description is accurate. The new situation is not fundamentally different; the college simply added a new sport without any change to laws, policies, etc. The database should support this without design changes.

This implies several things.

- Database designs should generally avoid enforcing restrictions that are not firmly established as formal, long-term business rules. Design changes are typically needed only when business rules change (unfortunate but unavoidable), or when experience reveals a mismatch between the design and the business rules (a failure in the analysis and design process).
- You must look beyond existing data when hunting for functional dependencies, and consider valid data that might appear in the future. Existing data may demonstrate that a functional dependency does not exist, by providing a counter example. But absence of a counter example is not proof that a dependency exists; it may or may not.
- For purposes of this tutorial, there is *not* a functional dependency from sports name to season.

#### Counterexamples must use valid, consistent data

Consider this claim made earlier: a single email address must correspond to a single person. 

Notice this implies a business rule that says students cannot use a "shared" email address like `chess.club@dewv.net` within the database. The domain of valid values here is *individual* email addresses.

Now consider this problematic argument. An individual email address uniquely determines one person *at a specific point in time*, but the same email address might be recycled for use by a second (different) person at a later point in time. Therefore, there is no functional dependency from email address to first name, last name, and other personal details.

The observation that email addresses might be "recycled" someday is insightful. But the conclusion is not justified, given the current design of the `learning_center` database. Like most relational databases, `learning_center` is a **current database**, which means that it is intended to record a set of facts that are true at this point in time-- and therefore are mutually consistent.

Some relational databases are designed to store changing **temporal data**-- facts that are true for specified limited periods of time. Usually, these designs include columns that indicate the date range that a fact applies, or flags to indicate whether a row's fact is the current or most recent data. 

Without any of these temporal qualifiers, it is inconsistent to have rows that list the same email address for different people. The proposed counterexample is not valid data. So, there is a functional dependency from email to first name and last name.

#### Exercise set 6

1. In a text file named `exercise6-1.txt`, list every functional dependency in the database.

### Second normal form

With a solid understanding of functional dependency, you are ready to learn some higher normal forms.

Once again, consider the  `sport` table.

```
mysql> select * from sport;
+-----------------+--------+--------+
| name            | gender | season |
+-----------------+--------+--------+
| Basketball      | Men    | Fall   |
| Basketball      | Women  | Fall   |
| Cross country   | Men    | Fall   |
| Cross country   | Women  | Fall   |
| Soccer          | Men    | Fall   |
| Soccer          | Women  | Fall   |
| Swimming        | Men    | Fall   |
| Swimming        | Women  | Fall   |
| Track and field | Men    | Fall   |
| Track and field | Women  | Fall   |
| Golf            | Men    | Fall   |
| Volleyball      | Women  | Fall   |
| Baseball        | Men    | Spring |
| Softball        | Women  | Spring |
| Lacrosse        | Men    | Spring |
| Lacrosse        | Women  | Spring |
| Tennis          | Men    | Spring |
| Tennis          | Women  | Spring |
+-----------------+--------+--------+
18 rows in set (0.06 sec)
```

As a quick review, recall that: 

- the table's primary key is $\lbrace$`name`, `gender`$\rbrace$, and
- the non-key column `season` tells a single fact about the key.

In other words, the table satisfies 1NF. But you can actually make a stronger, more detailed statement about the table.

Consider:

- Does `season` tell you anything about the `gender` of a sport(s team)? No.
- Does `season` tell you anything about the `name` of a sport? No.

These questions ask if the non-key columns tell you anything about the proper *subsets* of the key. When the answers are all negative, for all non-key columns and all candidate keys, you can make a stronger claim than 1NF. Not only does each non-key column tell you something about the key, it tells you something about *the whole* key.

It doesn't make sense to say that Men is played in the Fall. It isn't a fact that Golf is (necessarily) played in the Fall. It is a fact that $\lbrace$Men's Golf$\rbrace$ is played in the Fall.

A table is in **second normal form (2NF)** when it

1. is in first normal form, and
2. no non-key columns are determined by a proper subset of any *candidate* key.

A **proper subset** of the key is a subset that is not the entire key. (Example: because set theory states that every set is its own subset, $\lbrace$`Men`, `Golf`$\rbrace$ has three subsets: $\lbrace$`Men`$\rbrace$, $\lbrace$`Golf`$\rbrace$, and $\lbrace$`Men`, `Golf`$\rbrace$. But only the first two are *proper* subsets.)

Based on the observations above, the `sport` table satisfies 2NF. This is a simple example because the table has only one non-key column and only one candidate key. To better explore the 2NF requirements, consider a more complex example: the `visit1nf` table.

Earlier, you defined $\lbrace$`email`, `check_in_time`$\rbrace$ to be the primary key because values for that set would "uniquely identify a single row." In more formal terms, this means that all non-key columns are functionally dependent on the set $\lbrace$`email`, `check_in_time`$\rbrace$. Again, that is the only candidate key for the table.

So, 2NF asks if any non-key columns are dependent on a proper subset of the key $\lbrace$`email`, `check_in_time`$\rbrace$. 

Yes. $\lbrace$`email`$\rbrace$ determines the non-key columns `first_name`, `last_name`, `academic_rank`, `slp_instructor_first_name`, and `slp_instructor_last_name`. 

Conclusion: `visit1nf` does not satisfy 2NF. 

The dependencies on $\lbrace$`email`$\rbrace$ are called **partial dependencies**, because the non-key values are dependent on *part* of the key. These non-key columns do not tell you something about the *whole* key. They tell you something about *part* of the key.

To normalize the design to 2NF, you must decompose `visit1nf` into two tables. Each subset of `visit1nf`'s primary key that was a determinant will become the primary key of a new table. 

- The first is a new table named `student`. Its key will be $\lbrace$`email`$\rbrace$, and it will contain all the columns from `visit1nf` that are dependent on `email` alone.
- The second will be a modified replacement for `visit1nf` called `visit2nf`. Its key will still be $\lbrace$`email`, `check_in_time`$\rbrace$, but it will no longer have the columns that are dependent on `email` alone.

This makes sense intuitively. It's pretty clear that `visit1nf` is "mixing apples and oranges". It contains facts about two distinct kinds of thing, or two different entities: visits and students.

This also makes sense from an application programming or user interface perspective. You do not have to enter your personal details each time that you post to a social media site. Instead, you have a "user profile" that you enter once, and update only as needed. Then you have multiple posts associated with your profile, which can draw on your profile information as appropriate. The Learning Center's attendance tracking Web application works in a similar way.

Create the `student` table, with the primary key $\lbrace$`email`$\rbrace$.

```
mysql> create table student (
    ->   first_name varchar(128) NOT NULL,
    ->   last_name varchar(128) NOT NULL,
    ->   email varchar(128) NOT NULL,
    ->   academic_rank varchar(128) NOT NULL,
    ->   residential_status varchar(128) NOT NULL,
    ->   slp_instructor_first_name varchar(128) DEFAULT NULL,
    ->   slp_instructor_last_name varchar(128) DEFAULT NULL,
    ->   constraint primary key(email)
    -> );
Query OK, 0 rows affected (0.18 sec)
```

Now create the `visit2nf` table.

```
mysql> create table visit2nf (
    ->   email varchar(128) NOT NULL,
    ->   check_in_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ->   check_out_time timestamp NULL DEFAULT NULL,
    ->   location varchar(128) NOT NULL,
    ->   purpose varchar(255) NOT NULL,
    ->   purpose_achieved char(1) DEFAULT NULL,
    ->   tutoring varchar(255) DEFAULT NULL,
    ->   comments varchar(255) DEFAULT NULL,
    ->   constraint primary key(email, check_in_time),
    ->   constraint foreign key(email) references student(email)
    ->     on update no action
    ->     on delete no action
    -> );
Query OK, 0 rows affected (0.15 sec)
```

The primary key of $\lbrace$`email`, `check_in_time`$\rbrace$ tells the DBMS to enforce entity integrity for visits.

A **foreign key** is a set of columns that contains values drawn from the same domain as a different table's primary key. This is a way of "linking" rows in different tables. The `FOREIGN KEY` constraint tells the DBMS that `email` column values in this table refer to `email` column values in the `student` table. (This tutorial will use the name `fk_<other table>` for all foreign key constraints, where `<other table>` names the referenced table.) In other words, both columns have the same set of possible values (the same domain). This allows the DBMS to enforce **referential integrity** by ensuring that, for every `email` value that appears in `visit2nf`, there is a `student` table row with the same value in its `email` column. This has several implications.

- MySQL will reject attempts to `INSERT` a `visit2nf` row with an `email` address that does not appear in the `student` table. In other words, a student's information must be in the database first, and then they can log visits. This ensures that a "link" or reference to an existing student is present when the visit is logged.
- MySQL will reject attempts to `UPDATE` `student` table `email` values when there are `visit2nf` rows containing the same `email` values. This prevents breaking the reference by changing data.
- MySQL will reject attempts to `DELETE` `student` table rows when there are `visit2nf` rows containing the same `email` values. This prevents breaking the reference by deleting rows.

Note that the last two points discuss constraints on the `student` table, which is not the table defined in the statement. 

There are other possible actions for referential integrity enforcement besides rejecting the attempted operation, but the details vary by DBMS. MySQL's default action is to reject operations as described above, but you can specify other actions. You can even specify different actions for different operations and for different foreign keys. 

- **Cascading** updates and/or deletes. This means that the operation's effect "flows" from the "parent" table (`student` in this case) to the "child" table (`visit2nf` in this case). With cascading updates, your command `UPDATE student SET email = 'bbooth2@dewv.net' WHERE email = 'bbooth@dewv.net'` the DBMS would automatically perform an identical update on the `visit2nf` table. With cascading deletes, when you `DELETE FROM student WHERE email = 'bbooth@dewv.net';` the DBMS would automatically delete all `visit2nf` rows with that `email` value.
- Set to `NULL`. For example, when you `DELETE FROM student WHERE email = 'bbooth@dewv.net';` the DBMS would eliminate broken references by automatically executing `UPDATE visit2nf SET email to NULL where email = 'bbooth@dewv.net';` .

Both `student` and `visit2nf` satisfy second normal form, because:

1. they are in 1NF (all single values), and
2. no non-key columns are determined by a proper subset of any candidate key.

This design, along with enforcement of entity and referential integrity, prevents many types of data anomalies.

For complete referential integrity, you should add appropriate foreign keys to existing tables using the `ALTER TABLE` statement. 

```
mysql> alter table student_sport
    -> add constraint foreign key(email) references student(email);
Query OK, 6 rows affected (0.06 sec)
Records: 6  Duplicates: 0  Warnings: 0
```

#### Exercise set 7

Where relevant, use the `tee <filename>;` and `notee;` commands to capture your solutions to the following exercises. Otherwise, type your response in a text file. Use the filename `exercise7-1.txt` for the first exercise, and so on.

1. Write and execute SQL statements to populate the `student` and `visit2nf` tables by `INSERT`ing data that is `SELECT`ed from `visit1nf`.
2. Is `email` truly the only candidate key for `student`? Explain.
3. Are there other candidate keys for `visit2nf`? Explain.
4. There is a problem with the specific example given for the `SET TO NULL` referential integrity option above. What is it?
5. An experienced database professional needs only a glance at `student`'s `CREATE TABLE` statement to know that it must be 2NF (as long as it contains no multi-valued entries). Why is that?
6. Write and execute one or more statements that are rejected by the enforcement of referential integrity. 
7. Following the `ALTER TABLE` example, modify the `student_sport` and `student_major` tables by adding appropriate foreign key constraints. 
8. Explain why each of the following tables is, or is not, in 2NF. `sport`, `student_sport`,  `major`,`student_major`. 

### Third normal form and Boyce-Codd normal form

Naylor Learning Center locations have computers available for student use. Suppose each computer cubicle is identified by a letter and each computer is attached to a printer-- some color printers, some not.

Create and populate the following table.

```
mysql> create table computer(
    ->   location varchar(128) NOT NULL,
    ->   cubicle varchar(16) NOT NULL,
    ->   memory int, 
    ->   printer varchar(16),
    ->   color varchar(3),
    ->   constraint primary key(location, cubicle) 
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> insert into computer(location, cubicle, memory, printer, color) values
    ->   ('NLC', 'A', 4, 'P1', 'No'),
    ->   ('NLC', 'B', 8, 'P2', 'Yes'),
    ->   ('NLC', 'C', 8, 'P2', 'Yes'),
    ->   ('Writing center', 'A', 4, 'P3', 'Yes'),
    ->   ('Writing center', 'B', 4, 'P4', 'No')
    -> ;
Query OK, 5 rows affected (0.00 sec)
Records: 5  Duplicates: 0  Warnings: 0
```

Notice the `INT` datatype for the `memory` column, which will store the size of the computer's RAM in gigabytes.

This table satisfies 1NF.

The only candidate key and therefore the primary key is $\lbrace$`location`, `cubicle`$\rbrace$. None of the non-key fields `memory`,  `printer`, or `color` are determined by `location` or `cubicle` alone, so the table satisfies 2NF.

But consider the dependency from $\lbrace$`location`, `cubicle`$\rbrace$ to $\lbrace$`color`$\rbrace$. What happens if you imagine that the `printer` column is removed from the table?

 ```
+----------------+---------+-------+
| location       | cubicle | color |
+----------------+---------+-------+
| NLC            | A       | No    |
| NLC            | B       | Yes   |
| NLC            | C       | Yes   |
| Writing center | A       | Yes   |
| Writing center | B       | No    |
+----------------+---------+-------+
 ```

Does a location and cubicle ID truly tell you if the PC installed there has color printing? (No fair looking back to the full table, or relying on your memory. The question applies just to the data in the three columns.)

Not really. Color printing ability is not a fact about a certain location and a certain cubicle ID. It's not *really* a fact about a computer, either. It is a fact about a printer. Returning to the four-column table, it is best to say that: 

1. $\lbrace$`location`, `cubicle`$\rbrace$ determines $\lbrace$`printer`$\rbrace$, and 
2. $\lbrace$`printer`$\rbrace$ determines $\lbrace$`color`$\rbrace$.

The dependency from $\lbrace$`location`, `cubicle`$\rbrace$ to $\lbrace$`color`$\rbrace$ is **transitive**: it "passes through" $\lbrace$`printer`$\rbrace$ as an intermediary. Removing the intermediary removes the dependency. Transitive dependencies are "weaker," and the focus of third normal form.

A table that satisfies **third normal form (3NF)**:

1. satisfies second normal form, and
2. has no transitive dependencies from key columns to non-key columns.

So the `computer` table above satisfies 2NF but not 3NF, due to the transitive dependency. To normalize to 3NF, you would relocate the problematic dependency to a new table. This is left as an exercise.

After 3NF was defined, various experts noticed a loophole in the definition. Among them were the creators of **Boyce-Codd normal form (BCNF)**. BCNF is a stricter definition that closes the loophole in 3NF. A table is in BCNF when it:

1. is in second normal form, and
2. all determinants are candidate keys.

BCNF is occasionally called 3.5NF. In practice, a table that satisfies 3NF usually satisfies BCNF as well. But here is a 3NF table that violates BCNF. Create and populate the following table.

```
mysql> create table staff (
    ->   first_name varchar(128) NOT NULL,
    ->   last_name varchar(128) NOT NULL,
    ->   email varchar(128) NOT NULL,
    ->   assistant_email varchar(128) NOT NULL,
    ->   slp_instructor_yn char(1) DEFAULT 'N',
    ->   location varchar(15) NOT NULL,
    ->   constraint primary key(email)
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql> insert into staff (first_name, last_name, email, assistant_email, slp_instructor_yn,         -> location) values
    -> ('Chris', 'Calendar', 'ccalendar@dewv.net', 'ccalendar@dewv.net', 'Y', 'Albert Hall'),
    -> ('Edna', 'Editor', 'eeditor@dewv.net', 'gguardian@dewv.net', 'N', 'Writing Center'),
    -> ('Greg', 'Guardian', 'gguardian@dewv.net', 'gguardian@dewv.net', 'N', 'Writing Center'),
    -> ('Sam', 'Studybuddy', 'sstudybuddy@dewv.net', 'ccalendar@dewv.net', 'Y', 'Albert Hall'),
    -> ('Terry', 'Tutor', 'ttutor@dewv.net', 'ccalendar@dewv.net', 'Y', 'Albert Hall')
    -> ;
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0
```

This table contains information about Learning Center staff: name, email, their assistant's email, a flag indicating if they are an Supported Learning Program instructor, and their location. Notice that some employees are listed as their own assistant.

This table is in 3NF, but not BCNF, because there is a determinant that is not a candidate key. Try to find the functional dependency where the determinant is not a candidate key.

```
mysql> select * from staff;
+------------+------------+----------------------+--------------------+-------------------+----------------+
| first_name | last_name  | email                | assistant_email    | slp_instructor_yn | location       |
+------------+------------+----------------------+--------------------+-------------------+----------------+
| Chris      | Calendar   | ccalendar@dewv.net   | ccalendar@dewv.net | Y                 | Albert Hall    |
| Edna       | Editor     | eeditor@dewv.net     | gguardian@dewv.net | N                 | Writing Center |
| Greg       | Guardian   | gguardian@dewv.net   | gguardian@dewv.net | N                 | Writing Center |
| Sam        | Studybuddy | sstudybuddy@dewv.net | ccalendar@dewv.net | Y                 | Albert Hall    |
| Terry      | Tutor      | ttutor@dewv.net      | ccalendar@dewv.net | Y                 | Albert Hall    |
+------------+------------+----------------------+--------------------+-------------------+----------------+
5 rows in set (0.00 sec)
```

If you think that $\lbrace$`assistant_email`$\rbrace$ determines $\lbrace$`location`$\rbrace$ then you are on the right track.

However, it would be better to turn this around and say that $\lbrace$`location`$\rbrace$ determines  $\lbrace$`assistant_email`$\rbrace$. This fits with common sense: often a person's professional assistant is assigned based on common location. For this discussion, assume that is a business rule, and the dependency will always hold.

Since $\lbrace$`location`$\rbrace$ is a determinant that is not a candidate key for the `staff` table, the table is not in BCNF.

---

Tables that satisfy 3NF/BCNF are generally safe from insert, update, and delete anomalies. Although there are several still-higher normal forms, they are of less practical importance.

There is an old mnemonic among database designers that echoes the oath taken by witnesses in United States courts.

> Each non-key value must tell a single fact about
>
> - the key (1NF),
> - the whole key (2NF), 
> - and nothing but the key (3NF/BCNF),
>
> so help me [Codd](https://en.wikipedia.org/wiki/Edgar_F._Codd).

#### Exercise set 8

Where relevant, use the `tee <filename>;` and `notee;` commands to capture your solutions to the following exercises. Otherwise, type your response in a text file. Use the filename `exercise8-1.txt` for the first exercise, and so on.

1. Normalize the `computer` table to 3NF. Some hints:
   - Use `ALTER TABLE <table name> DROP COLUMN <column name>;` to remove the problematic dependency.
   - Create and populate a new table named `printer`, with appropriate column(s) and primary key.
   - What additional change should you make to the modified `computer` table? (Hint: referential integrity)
2. Are the modified `computer` table and the new `printer` table in BCNF?
3. Decompose the `staff` table to satisfy BCNF. The process is similar to the first exercise above. The new table is named `location`, and has two columns: `name`, and `assistant` which respectively hold the name of the location and the staff assistant who is located there.
4. Explain why each of the following tables is, or is not, in 3NF. `visit2nf`, `student`,  `sport` , `major`, `student_sport`, `student_major`.
5. Explain why each of the following tables is, or is not, in BCNF. `visit2nf`, `student`,  `sport` , `major`, `student_sport`, `student_major`, `computer`, `printer`.

# Contents

[TOC]
