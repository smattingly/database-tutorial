# Databases in Context: A Just-in-Time Tutorial, Part 5

[Steve Mattingly](https://www.linkedin.com/in/steve-mattingly), Associate Professor of Computer Science, [Davis & Elkins College](https://www.dewv.edu/).

*Databases in Context: A Just-in-Time Tutorial* by Stephen S. Mattingly is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/). ![Creative Commons Attribution-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-sa/4.0/80x15.png)

------

Learn more about Open Educational Resources at [UNESCO](http://www.unesco.org/new/en/communication-and-information/access-to-knowledge/open-educational-resources/). ![UNESCO Open Educational Resources logo](http://www.unesco.org/new/typo3temp/pics/5d3118e041.jpg)

------

[Contents](#Contents)

------

## NoSQL databases

From the early 1970s to about 2000, SQL dominated the database market. For most practical discussions, "SQL" and "relational model" are considered synonymous, although relational theorists and purists point out that SQL is not a full and faithful implementation of the model.

More recently, alternative database models have become popular, too. There are models based on objects, documents, graphs, and other structures. Sometimes these models overlap or are difficult to distinguish cleanly. Hybrid approaches that draw on multiple non-relational models are common. The loose umbrella term **NoSQL** was originally used to refer to these post-relational approaches. Since hybrids of non-relational and relational models have also appeared, the term NoSQL is now frequently defined as "Not *Only* SQL".

## Document databases 

The second DBMS covered in this tutorial is classified as a **document database**.

To transition from relational model thinking to document model thinking, begin by considering the humble .CSV file.

TBD show CSV of relational table.

Comma-separated values (.CSV) files might be called the "least common denominator" of data formats. They are plain ASCII text files, which means that they can be read by nearly any software on any computing platform. They capture data in a tabular format: the first line typically gives "column" names, separated by commas. Each remaining line is one table "row", with commas separating the column values. Often, quotation marks will be used to enclose the values, which makes it safe for the fields to contain internal comma characters.

The explosion of the Web and its documents (or pages) built with Hypertext Markup Language (HTML) inspired lots of other work with markup languages. In particular, eXtensible Markup Language (XML) is a format that replaces CSV in many Web-oriented settings. XML fits the "Web way" of doing things, and provides some advantages over CSV.

TBD show same data as XML

XML is the basis for many document-oriented database tools, though not the one that you will study.

The Web also drove the popularity of the JavaScript programming language. Here's some JavaScript code.

```javascript
let n = 1; 
let s = "hello";
let o = { name: "Alice", age: 20 };
let o2 = { name: "Bob", age: 19 };
```

Nearly every programming language supports something like the first two statements. In the first, the assigned value is a numeric literal. In the second, the assigned value is a string literal.

But the third statement's assigned value is an *object literal*. In most object-oriented languages, this is impossible because you must first define a datatype (a "class") and then use that class definition as a template or blueprint for creating objects. The class defines the structure or "shape" of its instances (objects).

The final statement assigns another object literal to another variable. Clearly the two objects have the same structure (the same two properties or "fields"), and you could write code to handle that structure. But there is no `Person` class that defines this structure, as there would be in most OO languages.

Since JavaScript objects don't need to have a pre-defined structure, they can be flexible. For example, we could continue the code above with the following statement.

```javascript
o.nickname = "Ally";
```

This modifies the "shape" of the object by adding a third field that did not exist before. 

This is not a JavaScript tutorial, but these concepts are relevant to the document-oriented DBMS you will study. In that case, why is it called a document DBMS instead of an object DBMS?

Probably because of a data format called JSON. Pronounced "Jason", it stands for JavaScript Object Notation. Just as HTML Web work inspired the XML data format, JavaScript Web work inspired the JSON data format.

TBD show same data in JSON.

The text above is essentially valid JavaScript code. It is not a statement, because it does not "do" anything; it is an expression because it defines a value. If a JavaScript program read that text from a file, it would have one long text string. But JavaScript provides easy ways to "parse" that string so that it is transformed into real JavaScript objects with named properties and associated values. It is also easy to go the other direction: "serializing" runtime JavaScript objects into a JSON-format string that is just text-- easy to write to a file or send across a network.

The JSON format is so useful that it has transcended JavaScript. Many popular programming languages now provide similar parse and serialize functions for the JSON format.

## Getting started with MongoDB

MongoDB is a popular document DBMS that uses JSON.

This tutorial assumes that you are already set up with: 

1. a running instance of the MongoDB server (daemon), 
2. an operating system where you can open a terminal (bash, PowerShell, etc.),
3. the command line client software, `mongo`

If that is not the case, contact your instructor for help with setting up a work environment.

### Starting the `mongo` shell

In your terminal, launch the `mongo` shell.  

When you have successfully connected to the server, your operating system's terminal prompt will be replaced with a `>` prompt. The shell is waiting for your command.

### Creating/selecting the initial  database

In the mongo shell, execute the following command. (Note: the `>` symbol is the `mongo` shell's prompt; you do not type it.)

```
> use learning_center
```
The `learning_center` database did not exist, so MongoDB created it. You are now working within that database.

With MongoDB, you will often see this kind of dynamic flexibility. SQL required you predefine table formats, which were tricky to change. This reflected the static, relatively strong typing found in many programming languages. 

In contrast, MongoDB resembles JavaScript's dynamic typing, allowing you to create elements of your database without predefined structure, and modify them flexibly.

---

Each time you sit down to work with MongoDB, you will need to repeat the preceding steps to:

2. start the `mongo` shell (client), and
3. select the database that you want to work on.

---

The remainder of this tutorial will leverage MongoDB's flexibility to build a document database that meets the same data requirements as the relational database you studied earlier.

## Creating new documents with MongoDB

When you have open, unmatched grouping symbols (parenthesis, braces, brackets), the mongo shell knows that your command is not complete. Press Enter at the end of each line in the following command; the `...` will automatically appear at the start of each continuation line. Like the prompt symbol, these ellipses are not actually part of the command syntax.

```
> db.students.insertOne({
...		_id: 'ggatehouse',
...     first_name: 'Gary', 
...     last_name: 'Gatehouse', 
...     email: 'ggatehouse@dewv.net', 
...     academic_rank: 'Sophomore', 
...     residential_stats: 'On campus', 
...     majors: ['Math', 'Computer Science'], 
...     slp_instructor_first_name: 'Terry', 
...     slp_instructor_last_name: 'Tutor'
... })
```

The response should be:

```
{ "acknowledged" : true, "insertedId" : "ggatehouse" }
```

The preceding command inserted one document into the current database, in a collection named `students`.

A MongoDB **collection** is a named group of documents. Since the `students` collection did not already exist, it was created. 

The inserted document is a JSON-format object literal that contains eight fields representing Gary's student information, plus a field `_id` with value of `ggatehouse`. Every MongoDB document has an `_id` field, with a value that is unique to its collection. It acts as a primary key, and the value cannot be changed. If you do not provide an `_id` value when creating the document, MongoDB will automatically generate one. However, those ID values are hard to type and arbitrary (you would get different results than examples shown to you.) Often, simple MongoDB examples will just use sequential numbers. Here, you will use student usernames for `_id` values (the first part of their email addresses). That may not be a great design decision for a production database, but will be convenient for learning.

Look at the information on Gary's majors. Where all the other values are quoted strings, the `majors` value is an array of quoted strings. In JSON, square brackets `[ ]` are used to group an array of comma-separated values. This is one way that MongoDB can model a one-to-many relationship: one student has multiple majors.

The following command uses array syntax in a different way to insert multiple documents at one time. (To clearly show the syntax of elaborate MongoDB queries, examples like the following will use multi-level indentation. It is awkward to do this directly in the mongo shell. You might prefer to edit your queries in a text editor, the paste them into the mongo shell.)

```
> db.students.insertMany(
...     [
...         {
...	            _id: 2,
...             first_name: 'Charlie', 
...             last_name: 'Cadillac', 
...             email: 'ccadillac@dewv.net', 
...             academic_rank: 'Junior', 
...             residential_status: 'Off campus', 
...             majors: ['English'], 
...             sports: ['Men\'s soccer', 'Baseball'], 
...             slp_instructor_first_name: 'Terry', 
...             slp_instructor_last_name: 'Tutor'
...         },
...         {
...	            _id: 3,
...             first_name: 'Irving', 
...             last_name: 'Icehouse', 
...             email: 'iicehouse@dewv.net', 
...             class_rank: 'Sophomore', 
...             residential_status: 'On campus', 
...             majors: ['Chemistry'], 
...             slp_instructor_last_name: 'Sam', 
...             slp_instructor_last_name: 'Studybuddy'
...         }
...     ]
... )
```

The response should be:

```
{ "acknowledged" : true, "insertedIds" : ["ccadillac", "iicehouse"] }
```

Where the `insertOne()` command processed a single object enclosed with `{ }`, the `insertMany()` command processes an array enclosed with `[ ]`. The elements of the array are separated by commas; each is an object enclosed with `{ }`.

You can retrieve all the documents that you have inserted like this. 

```
> db.student.find({})
```

The empty braces `{ }` define an object that acts as a filter on the query. Since the filter object is empty, all documents will be returned.

```
{ "_id" : "ggatehouse", "first_name" : "Gary", "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net", "academic_rank" : "Sophomore", "residential_stats" : "On campus", "majors" : [ "Math", "Computer Science" ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }
{ "_id" : "ccadillac", "first_name" : "Charlie", "last_name" : "Cadillac", "email" : "ccadillac@dewv.net", "academic_rank" : "Junior", "residential_status" : "Off campus", "majors" : [ "English" ], "sports" : [ "Men's soccer", "Baseball" ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }
{ "_id" : "iicehouse", "first_name" : "Irving", "last_name" : "Icehouse", "email" : "iicehouse@dewv.net", "class_rank" : "Sophomore", "residential_status" : "On campus", "majors" : [ "Chemistry" ], "slp_instructor_last_name" : "Studybuddy" }
```

You can count the number of documents in the collection as follows.

```
> db.students.count()
3
```

### Exercise set 20

MongoDB does not have a convenient way to selectively write shell contents to a file. You will need to copy and paste your work for the following exercises using a text editor. Be sure to copy both the MongoDB command(s) and the results that are returned. Use the filename `exerciseTBD-1.txt` for the first exercise, and so on.

1. Insert documents into the `students` collection for each of the six remaining students. Use the `insertOne()` command at least once, and the `insertMany()` command at least once.
2. Write a query that returns all nine student documents.

## Retrieving data with MongoDB

### All collection documents and fields

You have already seen the MongoDB equivalent of `SELECT * FROM table_name;`

```
db.collection_name.find({});
```

### Selected fields

To return only selected fields in your query, pass a second object to `find()`. Use field names with values of `1` to indicate which fields you want. The special `_id` field is included by default.

```
> db.visits.find({}, { student_id: 1, check_in_time: 1})
{ "_id" : 1, "student_id" : "ggatehouse", "check_in_time" : ISODate("2016-08-30T18:35:55Z") }
{ "_id" : 2, "student_id" : "ccadillac", "check_in_time" : ISODate("2016-08-30T18:55:55Z") }
{ "_id" : 3, "student_id" : ccadillac", "check_in_time" : ISODate("2016-08-31T15:53:44Z") }
{ "_id" : 4, "student_id" : "iicehouse", "check_in_time" : ISODate("2016-08-30T19:56:56Z") }
{ "_id" : 5, "student_id" : "aalbert", "check_in_time" : ISODate("2016-08-30T20:15:05Z") }
{ "_id" : 6, "student_id" : "ddavis", "check_in_time" : ISODate("2016-08-30T20:36:56Z") }
{ "_id" : 7, "student_id" : "bbooth", "check_in_time" : ISODate("2016-08-30T20:44:54Z") }
{ "_id" : 8, "student_id" : "eelkins", "check_in_time" : ISODate("2016-08-30T20:49:59Z") }
{ "_id" : 9, "student_id" : "hhermanson", "check_in_time" : ISODate("2016-08-30T20:55:55Z") }
{ "_id" : 10, "student_id" : "fforest", "check_in_time" : ISODate("2016-08-30T20:59:05Z") }
{ "_id" : 11, "student_id" : "fforest", "check_in_time" : ISODate("2016-08-31T15:19:15Z") }
{ "_id" : 12, "student_id" : "ddavis", "check_in_time" : ISODate("2016-08-31T17:36:36Z") }
{ "_id" : 13, "student_id" : "ggatehouse", "check_in_time" : ISODate("2016-08-31T18:36:56Z") }
{ "_id" : 14, "student_id" : "ddavis", "check_in_time" : ISODate("2016-08-31T20:00:06Z") }
```

Alternatively, use zeroes to indicate which fields to *exclude*.

```
> db.visits.find({}, { _id: 0, check_in_time: 0, check_out_time: 0, location: 0, purpose_achieved: 0})
{ "student_id" : "ggatehouse", "purpose" : "study hall", "comments" : "New year, fresh start!" }
{ "student_id" : "ccadillac", "purpose" : "baseball meeting" }
{ "student_id" : "ccadillac", "purpose" : "get form signature" }
{ "student_id" : "iicehouse", "purpose" : "Meet SLP instructor", "comments" : "Cubicle B computer is not working." }
{ "student_id" : "aalbert", "purpose" : "Study hall" }
{ "student_id" : "ddavis", "purpose" : "Tour of learning center" }
{ "student_id" : "bbooth", "purpose" : "study hall", "comments" : "New year, fresh start!" }
{ "student_id" : "eelkins", "purpose" : "Team Meeting", "comments" : "Sorry coach i had wrong time. my bad" }
{ "student_id" : "hhermanson", "purpose" : "study hall" }
{ "student_id" : "fforest", "purpose" : "math help", "tutoring" : "Math 101" }
{ "student_id" : "fforest", "purpose" : "math help", "tutoring" : "MATH 101" }
{ "student_id" : "ddavis", "purpose" : "Help with paper" }
{ "student_id" : "ggatehouse", "purpose" : "study hall" }
{ "student_id" : "ddavis", "purpose" : "MATH 101" }
```

You cannot combine includes and excludes in the same statement. The `_id` field is an exception to that rule.

### Selected documents

As mentioned earlier, the first document passed to `find()` is a filter. It corresponds to an SQL `WHERE` clause.

```
> db.visits.find({ student_id: 'ggatehouse'})
{ "_id" : 1, "student_id" : "ggatehouse", "check_in_time" : ISODate("2016-08-30T18:35:55Z"), "check_out_time" : ISODate("2016-08-30T19:53:44Z"), "location" : "Albert Hall", "purpose" : "study hall", "purpose_achieved" : "Y", "comments" : "New year, fresh start!" }
{ "_id" : 13, "student_id" : "ggatehouse", "check_in_time" : ISODate("2016-08-31T18:36:56Z"), "location" : "Albert Hall", "purpose" : "study hall" }
```

You can write the kind of compound Boolean expressions that your programming experience would lead you to expect. Here are several examples. (Each begins with a comment. The DBMS ignores anything following a double slash `//`.)

```
> // Example: AND
> db.students.find(
...     {
...         $and: [
...             { first_name: 'Gary'}, {last_name: 'Gatehouse'}
...         ]
...     }
... )
{ "_id" : "ggatehouse", "first_name" : "Gary", "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net", "academic_rank" : "Sophomore", "residential_stats" : "On campus", "majors" : [ "Math", "Computer Science" ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }

> db.students.find(
...     {
...         $or: [
...             {first_name: 'Gary'}, {first_name: 'Alice'}
...         ]
...     }
... )
{ "_id" : "ggatehouse", "first_name" : "Gary", "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net", "academic_rank" : "Sophomore", "residential_stats" : "On campus", "majors" : [ "Math", "Computer Science" ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }
{ "_id" : "aalbert", "first_name" : "Alice", "last_name" : "Albert", "email" : "aalbert@dewv.net", "academic_rank" : "Junior", "residential_status" : "On campus", "majors" : [ "Computer Science" ], "slp_instructor_first_name" : "Sam", "slp_instructor_last_name" : "Studybuddy" }

> // Example: "less than" operator with timestamp data
> db.visits.find(
...     {
...         check_in_time: { 
...             $lt: ISODate('2016-08-31T00:00:00-04') 
...         }
...     },
...     {
...         student_id: 1,
...         check_in_time: 1
...     }
... )
{ "_id" : 1, "student_id" : "ggatehouse", "check_in_time" : ISODate("2016-08-30T18:35:55Z") }
{ "_id" : 2, "student_id" : "ccadillac", "check_in_time" : ISODate("2016-08-30T18:55:55Z") }
{ "_id" : 4, "student_id" : "iicehouse", "check_in_time" : ISODate("2016-08-30T19:56:56Z") }
{ "_id" : 5, "student_id" : "aalbert", "check_in_time" : ISODate("2016-08-30T20:15:05Z") }
{ "_id" : 6, "student_id" : "ddavis", "check_in_time" : ISODate("2016-08-30T20:36:56Z") }
{ "_id" : 7, "student_id" : "bbooth", "check_in_time" : ISODate("2016-08-30T20:44:54Z") }
{ "_id" : 8, "student_id" : "eelkins", "check_in_time" : ISODate("2016-08-30T20:49:59Z") }
{ "_id" : 9, "student_id" : "hhermanson", "check_in_time" : ISODate("2016-08-30T20:55:55Z") }
{ "_id" : 10, "student_id" : "fforest", "check_in_time" : ISODate("2016-08-30T20:59:05Z") }

> // Example: "greater than" operator with character data
> db.students.find(
...     {
...         last_name: { 
...             $gt: 'H' 
...         }
...     },
...     {
...         last_name: 1
...     }
... )
{ "_id" : "iicehouse", "last_name" : "Icehouse" }
{ "_id" : "hhermanson", "last_name" : "Hermanson" }
```

Other comparison operators are shown below.

| SQL      | MongoDB |
| -------- | ------- |
| `=`      | `$eq`   |
| `<>`     | `$ne`   |
| `<=`     | `$lte`  |
| `>=`     | `$gte`  |
| `IN`     | `$in`   |
| `NOT IN` | `$nin`  |

You may recall that special SQL syntax was needed to match `NULL` values.

```sql
mysql> select first_name, last_name, check_in_time, check_out_time from visit where check_out_time is NULL;
+------------+-----------+---------------------+----------------+
| first_name | last_name | check_in_time       | check_out_time |
+------------+-----------+---------------------+----------------+
| Gary       | Gatehouse | 2016-08-31 14:36:56 | NULL           |
| Debra      | Davis     | 2016-08-31 16:00:06 | NULL           |
+------------+-----------+---------------------+----------------+
2 rows in set (0.00 sec)
```

Here is the MongoDB equivalent.

```
> db.visits.find(
...     { 
...         check_out_time: { $exists: false }
...     },
...     {
...         student_id: 1,
...         check_out_time: 1
...     }
... )
{ "_id" : 13, "student_id" : "ggatehouse" }
{ "_id" : 14, "student_id" : "ddavis" }
```

### Sorting results

You can sort results by following the `find()` call with a call to `sort()`. Here is an ascending sort on last name.

```
> db.students.find(
...     { last_name: { $gt: 'H' }},
...     { last_name: 1}
... ).sort({ last_name: 1})
{ "_id" : "hhermanson", "last_name" : "Hermanson" }
{ "_id" : "iicehouse", "last_name" : "Icehouse" }
```

Here is the same query with a descending sort.

```
> db.students.find(
...     { last_name: { $gt: 'H' }},
...     { last_name: 1}
... ).sort({ last_name: -1})
{ "_id" : "iicehouse", "last_name" : "Icehouse" }
{ "_id" : "hhermanson", "last_name" : "Hermanson" }
```

Finally, here is a primary and secondary sort in different directions. It sorts first by student ID, in ascending order. Where records have the same student ID, they are sorted by check in time, in descending order. 

```
> db.visits.find({}, { student_id: 1, check_in_time: 1}).sort(
...     { student_id: 1, check_in_time: -1}
... )
{ "_id" : 5, "student_id" : "aalbert", "check_in_time" : ISODate("2016-08-30T20:15:05Z") }
{ "_id" : 7, "student_id" : "bbooth", "check_in_time" : ISODate("2016-08-30T20:44:54Z") }
{ "_id" : 3, "student_id" : "ccadillac", "check_in_time" : ISODate("2016-08-31T15:51:15Z") }
{ "_id" : 2, "student_id" : "ccadillac", "check_in_time" : ISODate("2016-08-30T18:55:55Z") }
{ "_id" : 14, "student_id" : "ddavis", "check_in_time" : ISODate("2016-08-31T20:00:06Z") }
{ "_id" : 12, "student_id" : "ddavis", "check_in_time" : ISODate("2016-08-31T17:36:36Z") }
{ "_id" : 6, "student_id" : "ddavis", "check_in_time" : ISODate("2016-08-30T20:36:56Z") }
{ "_id" : 8, "student_id" : "eelkins", "check_in_time" : ISODate("2016-08-30T20:49:59Z") }
{ "_id" : 11, "student_id" : "fforest", "check_in_time" : ISODate("2016-08-31T15:19:15Z") }
{ "_id" : 10, "student_id" : "fforest", "check_in_time" : ISODate("2016-08-30T20:59:05Z") }
{ "_id" : 13, "student_id" : "ggatehouse", "check_in_time" : ISODate("2016-08-31T18:36:56Z") }
{ "_id" : 1, "student_id" : "ggatehouse", "check_in_time" : ISODate("2016-08-30T18:35:55Z") }
{ "_id" : 9, "student_id" : "hhermanson", "check_in_time" : ISODate("2016-08-30T20:55:55Z") }
{ "_id" : 4, "student_id" : "iicehouse", "check_in_time" : ISODate("2016-08-30T19:56:56Z") }
```

## Updating data with MongoDB

Suppose the Learning Center staff are checking which courses have the most demand for tutoring services.

```
> db.visits.find({}, { student_id: 1, tutoring: 1}).sort({tutoring: 1})
{ "_id" : 1, "student_id" : "ggatehouse" }
{ "_id" : 2, "student_id" : "ccadillac" }
{ "_id" : 3, "student_id" : "ccadillac" }
{ "_id" : 4, "student_id" : "iicehouse" }
{ "_id" : 5, "student_id" : "aalbert" }
{ "_id" : 6, "student_id" : "ddavis" }
{ "_id" : 7, "student_id" : "bbooth" }
{ "_id" : 8, "student_id" : "eelkins" }
{ "_id" : 9, "student_id" : "hhermanson" }
{ "_id" : 12, "student_id" : "ddavis" }
{ "_id" : 13, "student_id" : "ggatehouse" }
{ "_id" : 14, "student_id" : "ddavis" }
{ "_id" : 11, "student_id" : "fforest", "tutoring" : "MATH 101" }
{ "_id" : 10, "student_id" : "fforest", "tutoring" : "Math 101" }
```

First, you might clean up the inconsistent values for the introductory math course.

```
> db.visits.updateOne(
...     { _id: 10 },
...     { $set: { tutoring: 'MATH 101'} }
... )
{ "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }
```

The `updateOne()` function uses its first argument as a filter, which matches a single document. Turning to the second argument, it sets the value of the `tutoring` field to `'MATH 101'`.

Next suppose you discover that some tutoring information was not entered. For example, Charlie Cadillac says that he received Chemistry 101 tutoring at all of his visits.

```
> db.visits.updateMany(
...     { student_id: 'ccadillac' },
...     { $set: { tutoring: 'CHEM 101'} }
... )
{ "acknowledged" : true, "matchedCount" : 2, "modifiedCount" : 2 }
```

The response shows that two documents matched the filter, and both were modified.

The `updateOne()` function processes only the first document matching the filter. So it will always update zero or one documents. As its name suggests, `updateMany()` will process all matching documents. But "process" here does not necessarily mean changes are made, as shown below.

```
> // Example: repeat the query run earlier. 
> // One document is matched, but none modified.
> // No modification because the field already has that value.
> db.visits.updateOne(
...     { _id: 10 },
...     { $set: { tutoring: 'MATH 101'} }
... )
{ "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 0 }

> // Example: 3 documents matched and modified.
> db.visits.updateMany(
...     { student_id: 'ddavis' },
...     { $set: { tutoring: 'CS 200'} }
... )
{ "acknowledged" : true, "matchedCount" : 3, "modifiedCount" : 3 }

> // Example: updateOne matches at most 1 document.
> db.visits.updateOne(
...     { student_id: 'ddavis' },
...     { $set: { tutoring: 'CS 201'} }
... )
{ "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }
```

the first updateOne above is similar to RDBMS. All the other updateOnes and Manys are different because the change shape, analogous to updating NULLs.

$unset goes the other direction: sets values to NULL

MongoDB defines other field update operators in addition to `$set` and `$unset`. These operators modify a field to hold the current date, an incremented value, a specified value only if it is less than the current value, and so forth.

TBD array updates

### Exercise set TBD

reverse the changes made in the previous section. Use both One and Many

## Deleting data with MongoDB

First, execute the following command.

```
db.visits.aggregate([ { $match: {} }, { $out: 'temp_visits' } ]);
```

You will learn more about the `aggregate()` function later. Here, it is used to make a copy of the `visits` collection, named `temp_visits`. You will use the `temp_visits` collection to practice deleting data.

You might have guessed that MongoDB defines functions named `deleteOne()` and `deleteMany()`. They use the same filtering as other commands.

```
> // Don't forget to use the temporary collection!
> db.temp_visits.deleteOne( { student_id: 'ddavis'})
{ "acknowledged" : true, "deletedCount" : 1 }

> db.temp_visits.deleteMany( { student_id: 'ddavis'})
{ "acknowledged" : true, "deletedCount" : 2 }

> db.temp_visits.count( { student_id: 'ddavis' })
0
```



## (De)normalizing data in MongoDB

You have seen one way to model one-to-many relationships in MongoDB: one student has many majors, and those majors can be modeled as an array embedded within the student document. This is a denormalized approach. The equivalent structure in a relational database would be a repeating group, which fails to meet first normal form.

MongoDB supports a second, more normalized approach to modeling one-to-many relationships.

Use this command to create a document in a new collection to represent visit data.

```
> db.visits.insert(
...     {
...         _id: 1,
...         student_id: 'ggatehouse',
...         check_in_time: ISODate('2016-08-30T14:35:55-04'),
...         check_out_time: ISODate('2016-08-30T15:53:44-04'),
...         location: 'Albert Hall',
...         purpose: 'study hall',
...         purpose_achieved: 'Y',
...         comments: 'New year, fresh start!'
...     }
... )
WriteResult({ "nInserted" : 1 })
```

This creates a collection named `visits` and a document in that collection. The `student_id` field is a **reference** that indicates this visit is for the `students` document with `_id: 'ggatehouse'`. In other words, your old friend Gary.

Unlike MySQL, MongoDB strictly follows [ISO 6801 format]( https://www.iso.org/iso-8601-date-and-time-format.html ) by using a capital `T` to separate date and time. Here, the quoted values end with `-04` to indicate [Eastern Daylight Time]( https://www.timeanddate.com/time/zones/edt ). The quoted value is passed to a helper function called `ISODate()`, which handles date/time values in ISO 8601 format. 

Next, create visit documents for Charlie Cadillac.

```
> db.visits.insertMany(
...     [
...         {
...             _id: 2,
...             student_id: 'ccadillac',
...             check_in_time: ISODate('2016-08-30T14:55:55-04'),
...             check_out_time: ISODate('2016-08-30T16:53:44-04'),
...             location: 'Albert Hall',
...             purpose: 'baseball meeting',
...             purpose_achieved: '?'
...         },
...         {
...             _id: 3, 
...             student_id: 'ccadillac',
...             check_in_time: ISODate('2016-08-31T11:51:15-04'),
...             check_out_time: ISODate('2016-08-31T11:53:44-04'),
...             location: 'Albert Hall',
...             purpose: 'get form signature',
...             purpose_achieved: 'Y'   
...         }
...     ]
... )
{ "acknowledged" : true, "insertedIds" : [ 2, 3 ] }
```



### Exercise set TBD

MongoDB does not have a convenient way to selectively write shell contents to a file. You will need to copy and paste your work for the following exercises using a text editor. Be sure to copy both the MongoDB command(s) and the results that are returned. Use the filename `exerciseTBD-1.txt` for the first exercise, and so on.

1. Insert documents into the `visits` collection for each of the eleven remaining visits. Continue to use sequential numbers for `_id` values.
2. Write a query that returns all fourteen visit documents.



## Aggregating data

MongoDB supports several forms of aggregation. 

There is a small number of "single purpose aggregation operations", which aggregate data from a single collection. One example you have already seen is `count()`.

```
> db.visits.count()
14
```

Another is `distinct()`.

```
> db.visits.distinct('student_id')
[
        "aalbert",
        "bbooth",
        "ccadillac",
        "ddavis",
        "eelkins",
        "fforest",
        "ggatehouse",
        "hhermanson",
        "iicehouse"
]
```

More advanced aggregation can be performed using MongoDB's "multi-stage aggregation pipeline." Each stage or step in the pipeline transforms its input to an aggregate that can, optionally, become the input to another stage.

Suppose you want to know how many visits were made by *each* student. 

```
> db.visits.aggregate(
...     [
...         {'$group': {_id: '$student_id', visits: {$sum: 1}}}
...     ]
... )
{ "_id" : "bbooth", "visits" : 1 }
{ "_id" : "fforest", "visits" : 2 }
{ "_id" : "hhermanson", "visits" : 1 }
{ "_id" : "ddavis", "visits" : 3 }
{ "_id" : "eelkins", "visits" : 1 }
{ "_id" : "ccadillac", "visits" : 2 }
{ "_id" : "ggatehouse", "visits" : 2 }
{ "_id" : "iicehouse", "visits" : 1 }
{ "_id" : "aalbert", "visits" : 1 }
```

The `aggregate()` function's argument is an array whose elements are stages in the aggregation pipeline. Here, there is only one stage. The `$group` stage is similar to an SQL `GROUP BY` clause. It takes its inputs (here, all the documents in the `visits` collection) and outputs a document for each distinct `student_id` value. The output documents have two fields: one for the student id, and one for that student's number of visits. The second field's value is calculated as a sum of the constant expression `1` across all the documents.

Now suppose that you were asked to list all students who have visited more than once. You can expand the preceding query by adding a second stage to the aggregation pipeline. The nine documents generated by the preceding query become the inputs to this second stage, which filters for documents that match a condition.

```
> db.visits.aggregate(
...     [
...         {'$group': {_id: '$student_id', visits: {$sum: 1}}},
...         {'$match': {visits: { $gt: 1}}}
...     ]
... )
{ "_id" : "fforest", "visits" : 2 }
{ "_id" : "ddavis", "visits" : 3 }
{ "_id" : "ccadillac", "visits" : 2 }
{ "_id" : "ggatehouse", "visits" : 2 }
```

This computes the number of visits for each `student_id`, then displays only the documents with a sum greater than one.

### Exercise set 12

1. Write a single query that lists each gender and how many sports exist for that gender.
2. Write a single query to list major names and the number of students who have that major. (It is okay if majors with no students are not in the results.)
3. Write a single query to answer this question: how many computers have less than 8GB of memory?
4. Write a single query to list the locations that have more than one SLP instructor.

---

explain
  no schema enforcement
​    no nulls
​    possible to mistake data and field names (residential_stats?)
​    denormalization

change sports to be array of embedded docs with gender, season, name

example of embedded doc that is not in array? printer?

upsert?

lookup/join

constraints?

# Contents

[TOC]

<!-- After using Typora to export HTML, use vi or Notepad (not VS Code) to fix the top-of-page link to this contents section, and also the page <title>. -->