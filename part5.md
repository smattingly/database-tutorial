# Databases in Context: A Just-in-Time Tutorial, Part 5

[Steve Mattingly](https://www.linkedin.com/in/steve-mattingly-aab8064a), Assistant Professor of Computer Science, [Davis & Elkins College](https://www.dewv.edu).

*Databases in Context: A Just-in-Time Tutorial* by Stephen S. Mattingly is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/). ![Creative Commons Attribution-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)

------

Learn more about Open Educational Resources at [UNESCO](http://www.unesco.org/new/en/communication-and-information/access-to-knowledge/open-educational-resources/). ![UNESCO Open Educational Resources logo](http://www.unesco.org/new/typo3temp/pics/5d3118e041.jpg)

------

[Contents](#Contents)

------

## Accessing databases from application code

Now that the Learning Center's MySQL database is in good shape, consider applications software that makes use of that database.

### Embedded SQL

In one common approach, applications software uses database connection libraries to embed SQL statements within the application's code. These libraries are programming language specific, but exist for nearly ever language. Often they are specific to a single DBMS as well, but some will support multiple database products.

Here is an example of Node.js code (server-side JavaScript) that uses such a library. It is taken from an early version of the Web application that students use to check in and out of the Learning Center. You don't need to understand all the code; just note the following.

- This function reads a single record from the database's `student` table by looking up a specified student email address.
- It uses `db`, an object provided by a database connectivity library which allows the application to communicate with the MySQL database using the `db.query()` function.
- The `db.query()` function expects two arguments.
  - The first is a string that contains an SQL statement.
  - The second is a function that will be called to process the results after the SQL statement has executed.
- The rows returned by the SQL statement are provided to the application code in an array named `rows`. 
  - Each element of the array is an object with properties that match the columns in the database table.
- The `read` function modifies the current object `student` so that it contains all of the student data from the database lookup. The property names of this JavaScript object are somewhat different from the database column names. 

```javascript
   /** Reads the database record for a specified student.
     * @argument callback - A function to be called when this async operation completes.
     */
    read(callback) {
        var student = this;

        // Execute the query
        db.query('SELECT * FROM student WHERE email = "' + student.email + '";',
            // Process the results
            function(error, rows) {
                // Check for problems
            	if (error) {
                    return callback(new Error('Unable to read Student ' + student.email + ' from database.'));
                }
                if (rows.length === 0) {
                    return callback(new Error('Student ' + student.email + ' does not exist.'));
                }
                
                // No problems; copy the first result row's data into the student object
                that.id = rows[0].id;
                that.username = rows[0].username;
                student.firstName = rows[0].first_name;
                student.lastName = rows[0].last_name;
                student.academicRank = rows[0].academic_rank;
                student.residentialStatus = rows[0].residential_status;
                student.slpInstructorFirstName = rows[0].slp_instructor_first_name;
            	student.slpInstructorLastName = rows[0].slp_instructor_last_name;
                return callback(student);
            }
        );
    }
```

#### SQL injection attacks

As shown, this code is vulnerable to **SQL injection attacks**, where an attacker types SQL into data forms in an attempt to gain unauthorized access.

Before reading further, earn more about SQL injection attacks, work through the online tutorial at https://www.hacksplaining.com/exercises/sql-injection. 

The basic attack shown in the Web tutorial is based on the truth table for the Boolean `OR` operation. Recall that the result of any `OR` expression is true if *either* of its inputs is true. 

By creating an `OR TRUE` expression (using `1=1` for "true"), the hacker gains access without knowing the password. Notice the submitted text, `' or 1=1--` , starts with a single quote to "cheat" and terminate the code's string value early. However, that leaves the code's closing single quote at the end of the query, which would cause a syntax error. But the hacker cleverly comments it out by ending the input with a double dash.

This trick can be used for more than bypassing passwords. Because it can "disable" an embedded `WHERE` clause, it will often cause a vulnerable application to display rows to a user that the user was not authorized to see

There are many other types of SQL injection attacks, including:

- using the `UNION` operator to run any union-compatible query that the attacker chooses, and
- using `;` to terminate the entire embedded query early, and following it with a second SQL statement of the attacker's choice.

As you have seen with your homework, most DBMS products provide "queries" that allow you to write to and read from the OS file system. This means that an SQL injection attack can be the first step to an intruder gaining much more extensive access to the server.

#### Eliminating SQL injection vulnerabilities

To prevent these kinds of attacks, use a combination of techniques, both in the application's code and in the DBMS server.

In simplest terms, Web application developers cannot trust any information entered by a user-- it may be the type of malicious input shown above. The application must test all user input to avoid processing malicious inputs. In early Web apps, these tests were written directly into the applications code-- scanning for dangerous symbols, etc. But modern Web programming tools provide prewritten data tests.

For example, a better way to write the Learning Center app's insecure `db.query()` call is:

```javascript
...
// Execute the query
        db.query('SELECT * FROM student WHERE email = ?;', [student.email],
            // Process the results
            function(error, rows) {
...    
```

Notice the question mark in the string of embedded SQL. That is not valid SQL. The `db.query()` function treats it as a placeholder that it will replace with some data. The data to replace it is given by the next argument, an array of values to substitute. (In this case there is only one placeholder and one replacement value, but the array allows for multiple placeholders in the embedded query.)

This is more secure because `db.query()` "knows" that the query string from the programmer is trustworthy but the student email value is data that can't be trusted. Before inserting the email value, it tests it for safety. For example, if the value contained semicolons, dashes, or quotes, those characters would be "escaped" to make them harmless.

This trick of "parameterizing" SQL statements and safety-testing the argument values is also used by a DBMS feature called **prepared statements**. These statements are stored as part of the server's definition for the database-- along with definitions for tables, views, and indexes. SQL queries can then use the parameterized prepared statement, somewhat like calling a function. However, there is no SQL standard for this and the details are DBMS specific.

Finally, it is important to follow the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege). Often, application software will use a single dedicated username and password to access a DBMS server. The privileges for that account should be reduced to only those that are needed for the application to work correctly. Pay particular attention to operations that allow a query to "get outside" of the DBMS, like reading and writing to the filesystem, or executing OS commands.

#### Exercise set 19

Suppose that the Learning Center application included a form where staff could enter a student email to see that student's full name. The underlying query might be coded as follows.

```javascript
db.query('SELECT first_name, last_name FROM visit WHERE email = "' + student.email + '";' ...
```

Assume that the text you type into the form becomes the value of `student.email`, and the user sees a page showing the query results.

Type your response in a text file. Use the filename `exercise19-1.txt` for the first exercise, and so on.

1. What could you enter into the form to see *all* student names in the output?
2. What could you enter into the form to see all staff and student names in the output? (Hint: review the concept of union-compatible queries.)
3. What could you enter into the form to get a list of sports (sport name and gender), along with the student data?
4. What could you enter into the form to delete all student records?

### Object Request Brokers

The JavaScript `read` function in the previous section used embedded SQL to retrieve a database record, then transformed it into a JavaScript object. This required an assignment for each object property/database column, which produces some tedious code.

An object request broker (ORB) or object request manager (ORM) is a layer of software that eliminates this kind of tedium. For most object-oriented programming languages, the goal of an ORB is to add database storage capabilities to a class or object.

A sophisticated ORB can eliminate the need for application programmers to embed any SQL at all. The ORB provides an application programming interface (API)-- a set of functions to call-- that abstract away the underlying database details. The app programmer can focus on their familiar objects without worrying about how they are stored and manipulated in terms of databases, tables, columns, etc.

This allows the application code to be "database agnostic". The application only "knows" about the ORB's API. One advantage of this is that an application can easily switch from (say) MySQL to (say) Microsoft SQLServer for its database server. Neither the application nor the main ORB code contains any code specific to MySQL or SQLServer. Where DBMS-specific code is absolutely necessary, the ORB will isolate it as an "adapter" that it uses for connecting to a specific product.

Both MySQL and Microsoft SQLServer-- as well as PostgresQL, Oracle products, and many others-- are designed around the relational database model, and support standard SQL. The details are in the differences of internal storage, utility commands not standardized by SQL, and minor syntax.

However, an ORB can also make it possible to move from a relational DBMS to a DBMS that is not relational. In the past decade, a number of DBMS products based on very different models have become popular.

# Contents

[TOC]

<!-- After using Typora to export HTML, manually fix the top-of-page link to this contents section, and also the page <title>. -->