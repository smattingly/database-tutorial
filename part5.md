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

```
"email","sport_name","gender"
"bbooth@dewv.net","Golf","Men"
"ccadillac@dewv.net","Baseball","Men"
"ccadillac@dewv.net","Soccer","Men"
"ddavis@dewv.net","Soccer","Women"
"ddavis@dewv.net","Softball","Women"
"eelkins@dewv.net","Baseball","Men"
```

Comma-separated values (.CSV) files might be called the "least common denominator" of data formats. They are plain ASCII text files, which means that they can be read by nearly any software on any computing platform. They capture data in a tabular format: the first line typically gives "column" names, separated by commas. Each remaining line is one table "row", with commas separating the column values. Often, quotation marks will be used to enclose the values, which makes it safe for the fields to contain internal comma characters.

The explosion of the Web and its documents (or pages) built with Hypertext Markup Language (HTML) inspired lots of other work with markup languages. In particular, eXtensible Markup Language (XML) is a format that replaces CSV in many Web-oriented settings. XML fits the "Web way" of doing things, and provides some advantages over CSV.

```xml
<?xml version="1.0"?>

<resultset statement="select * from learning_center.student_sport" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <row>
        <field name="email">ccadillac@dewv.net</field>
        <field name="sport_name">Baseball</field>
        <field name="gender">Men</field>
  </row>

  <row>
        <field name="email">eelkins@dewv.net</field>
        <field name="sport_name">Baseball</field>
        <field name="gender">Men</field>
  </row>

  <row>
        <field name="email">bbooth@dewv.net</field>
        <field name="sport_name">Golf</field>
        <field name="gender">Men</field>
  </row>

  <row>
        <field name="email">ccadillac@dewv.net</field>
        <field name="sport_name">Soccer</field>
        <field name="gender">Men</field>
  </row>

  <row>
        <field name="email">ddavis@dewv.net</field>
        <field name="sport_name">Soccer</field>
        <field name="gender">Women</field>
  </row>

  <row>
        <field name="email">ddavis@dewv.net</field>
        <field name="sport_name">Softball</field>
        <field name="gender">Women</field>
  </row>
</resultset>
```

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

```json
[
    {
        "email": "ccadillac@dewv.net", 
     	"gender": "Men", 
     	"sport_name": "Baseball"}, 
    {
        "email": "eelkins@dewv.net", 
        "gender": "Men", 
        "sport_name": "Baseball"
    }, 
    {
        "email": "bbooth@dewv.net", 
        "gender": "Men", 
        "sport_name": "Golf"
    }, 
    {
        "email": "ccadillac@dewv.net", 
        "gender": "Men", 
        "sport_name": "Soccer"
    }, 
    {
        "email": "ddavis@dewv.net", 
        "gender": "Women", 
        "sport_name": "Soccer"
    }, 
    {
        "email": "ddavis@dewv.net", 
        "gender": "Women", 
        "sport_name": "Softball"
    }
]
```

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
...		_id: 1,
...     first_name: 'Gary', 
...     last_name: 'Gatehouse', 
...     email: 'ggatehouse@dewv.net', 
...     academic_rank: 'Sophomore', 
...     residential_status: 'On campus', 
...     majors: ['Math', 'Computer Science'], 
...     slp_instructor_first_name: 'Terry', 
...     slp_instructor_last_name: 'Tutor'
... })
```

The response should be:

```
{ "acknowledged" : true, "insertedId" : 1 }
```

The preceding command inserted one document into the current database, in a collection named `students`.

A MongoDB **collection** is a named group of documents. Since the `students` collection did not already exist, it was created. 

The inserted document is a JSON-format object literal that contains eight fields representing Gary's student information, plus a field `_id` with value of 1. Every MongoDB document has an `_id` field, with a value that is unique to its collection. It acts as a primary key, and the value cannot be changed. If you do not provide an `_id` value when creating the document, MongoDB will automatically generate one. However, those ID values are hard to type and arbitrary (you would get different results than examples shown to you.) Often, simple MongoDB examples will just use sequential numbers. 

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
...             sports: [
...                 { 
...                     name: 'Soccer', 
...                     gender: 'Men'
...                 },
...                 {
...                     name: 'Baseball',
...                     gender: 'Men'
...                 }
...             ], 
...             slp_instructor_first_name: 'Terry', 
...             slp_instructor_last_name: 'Tutor'
...         },
...         {
...	            _id: 3,
...             first_name: 'Irving', 
...             last_name: 'Icehouse', 
...             email: 'iicehouse@dewv.net', 
...             academic_rank: 'Sophomore', 
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
{ "acknowledged" : true, "insertedIds" : [ 2, 3 ] }
```

Where the `insertOne()` command processed a single object enclosed with `{ }`, the `insertMany()` command processes an array enclosed with `[ ]`. The elements of the array are separated by commas; each is an object enclosed with `{ }`.

Notice that one student may play many sports, so the `sport` field is an array (if it is present). Each array item is a (sub-)document with fields of its own. If a student plays no sports, then the `sport` field will not be present for that student document; this is the equivalent of a `NULL` in a relational database.

You can retrieve all the documents that you have inserted like this. 

```
> db.students.find({})
```

The empty braces `{ }` define an object that acts as a filter on the query. Since the filter object is empty, all documents will be returned.

```
{ "_id" : 1, "first_name" : "Gary", "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net", "academic_rank" : "Sophomore", "residential_status" : "On campus", "majors" : [ "Math", "Computer Science" ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }
{ "_id" : 2, "first_name" : "Charlie", "last_name" : "Cadillac", "email" : "ccadillac@dewv.net", "academic_rank" : "Junior", "residential_status" : "Off campus", "majors" : [ "English" ], "sports" : [ { "name" : "Soccer", "gender" : "Men" }, { "name" : "Baseball", "gender" : "Men" } ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }
{ "_id" : 3, "first_name" : "Irving", "last_name" : "Icehouse", "email" : "iicehouse@dewv.net", "academic_rank" : "Sophomore", "residential_status" : "On campus", "majors" : [ "Chemistry" ], "slp_instructor_last_name" : "Studybuddy" }
```

You can count the number of documents in the collection as follows.

```
> db.students.count()
3
```

### Exercise set 20

MongoDB does not have a convenient way to selectively write shell contents to a file. You will need to copy and paste your work for the following exercises using a text editor. Be sure to copy both the MongoDB command(s) and the results that are returned. Use the filename `exercise20-1.txt` for the first exercise, and so on.

1. Insert documents into the `students` collection for each of the six remaining students. Use the `insertOne()` command at least once, and the `insertMany()` command at least once. Include information for student majors and (where applicable) student sports, following the examples given above. Assign `_id` values as follows.
   - Alice: 4
   - Bob: 5
   - Debbie: 6
   - Eric: 7
   - Frank: 8
   - Hannah: 9
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
> db.students.find({}, { last_name: 1, email: 1 })
{ "_id" : 1, "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net" }
{ "_id" : 2, "last_name" : "Cadillac", "email" : "ccadillac@dewv.net" }
{ "_id" : 3, "last_name" : "Icehouse", "email" : "iicehouse@dewv.net" }
{ "_id" : 4, "last_name" : "Albert", "email" : "aalbert@dewv.net" }
{ "_id" : 5, "last_name" : "Booth", "email" : "bbooth@dewv.net" }
{ "_id" : 6, "last_name" : "Davis", "email" : "ddavis@dewv.net" }
{ "_id" : 7, "last_name" : "Elkins", "email" : "eelkins@dewv.net" }
{ "_id" : 8, "last_name" : "Forest", "email" : "fforest@dewv.net" }
{ "_id" : 9, "last_name" : "Hermanson", "email" : "hhermanson@dewv.net" }
```

Alternatively, use zeroes to indicate which fields to *exclude*.

```
> db.students.find({}, { email: 0, first_name: 0, majors: 0, sports: 0 })
{ "_id" : 1, "last_name" : "Gatehouse", "academic_rank" : "Sophomore", "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor", "residential_status" : "On campus" }
{ "_id" : 2, "last_name" : "Cadillac", "academic_rank" : "Junior", "residential_status" : "Off campus", "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }
{ "_id" : 3, "last_name" : "Icehouse", "residential_status" : "On campus", "slp_instructor_last_name" : "Studybuddy", "academic_rank" : "Sophomore" }
{ "_id" : 4, "last_name" : "Albert", "academic_rank" : "Senior", "residential_status" : "On campus", "slp_instructor_first_name" : "Sam", "slp_instructor_last_name" : "Studybuddy" }
{ "_id" : 5, "last_name" : "Booth", "academic_rank" : "Junior", "residential_status" : "On campus" }
{ "_id" : 6, "last_name" : "Davis", "academic_rank" : "Sophomore", "residential_status" : "On campus" }
{ "_id" : 7, "last_name" : "Elkins", "academic_rank" : "Senior", "residential_status" : "Off campus" }
{ "_id" : 8, "last_name" : "Forest", "academic_rank" : "Sophomore", "residential_status" : "On campus" }
{ "_id" : 9, "last_name" : "Hermanson", "academic_rank" : "Senior", "residential_status" : "On campus" }
```

You cannot combine includes and excludes in the same statement. The `_id` field is an exception to that rule.

### Selected documents

As mentioned earlier, the first document passed to `find()` is a filter. It corresponds to an SQL `WHERE` clause.

```
> db.students.find({ email: 'ggatehouse@dewv.net' })
{ "_id" : 1, "first_name" : "Gary", "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net", "academic_rank" : "Sophomore", "residential_status" : "On campus", "majors" : [ "Math", "Computer Science" ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }
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
{ "_id" : 1, "first_name" : "Gary", "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net", "academic_rank" : "Sophomore", "residential_status" : "On campus", "majors" : [ "Math", "Computer Science" ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }

> db.students.find(
...     {
...         $or: [
...             {first_name: 'Gary'}, {first_name: 'Irving'}
...         ]
...     }
... )
{ "_id" : 1, "first_name" : "Gary", "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net", "academic_rank" : "Sophomore", "residential_status" : "On campus", "majors" : [ "Math", "Computer Science" ], "slp_instructor_first_name" : "Terry", "slp_instructor_last_name" : "Tutor" }
{ "_id" : 3, "first_name" : "Irving", "last_name" : "Icehouse", "email" : "iicehouse@dewv.net", "academic_rank" : "Sophomore", "residential_status" : "On campus", "majors" : [ "Chemistry" ], "slp_instructor_last_name" : "Studybuddy" }

> // Example: "greater than" operator with character data
> db.students.find(
...     {
...         last_name: { 
...             $gt: 'G'
...         }
...     },
...     {
...         last_name: 1
...     }
... )
{ "_id" : 1, "last_name" : "Gatehouse" }
{ "_id" : 3, "last_name" : "Icehouse" }
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
mysql> select email from student where slp_instructor_last_name IS NULL;
+---------------------+
| email               |
+---------------------+
| bbooth@dewv.net     |
| ddavis@dewv.net     |
| eelkins@dewv.net    |
| fforest@dewv.net    |
| hhermanson@dewv.net |
+---------------------+
5 rows in set (0.00 sec)
```

Here is the MongoDB equivalent.

```
> db.students.find(
...     { 
...         slp_instructor_last_name: { $exists: false }
...     },
...     {
...         email: 1
...     }
... )
{ "_id" : 5, "email" : "bbooth@dewv.net" }
{ "_id" : 6, "email" : "ddavis@dewv.net" }
{ "_id" : 7, "email" : "eelkins@dewv.net" }
{ "_id" : 8, "email" : "fforest@dewv.net" }
{ "_id" : 9, "email" : "hhermanson@dewv.net" }
```

### Sorting results

You can sort results by following the `find()` call with a call to `sort()`. Here is an ascending sort on last name.

```
> db.students.find(
...     {
...         last_name: { 
...             $gt: 'G'
...         }
...     },
...     {
...         last_name: 1
...     }
... ).sort({ last_name: 1})
{ "_id" : 1, "last_name" : "Gatehouse" }
{ "_id" : 3, "last_name" : "Icehouse" }
```

Here is the same query with a descending sort.

```
> db.students.find(
...     {
...         last_name: { 
...             $gt: 'G'
...         }
...     },
...     {
...         last_name: 1
...     }
... ).sort({ last_name: -1})
{ "_id" : 3, "last_name" : "Icehouse" }
{ "_id" : 1, "last_name" : "Gatehouse" }
```

Finally, here is a primary and secondary sort in different directions. It sorts first by residential status, in ascending order. Where records have the same residential status, they are sorted by SLP instructor last name, in descending order. 

```
> db.students.find({}, { email: 1, residential_status: 1, slp_instructor_last_name
: 1 }).sort({residential_status: 1, slp_instructor_last_name: -1})
{ "_id" : 2, "email" : "ccadillac@dewv.net", "residential_status" : "Off campus", "slp_instructor_last_name" : "Tutor" }
{ "_id" : 1, "email" : "ggatehouse@dewv.net", "residential_status" : "On campus", "slp_instructor_last_name" : "Tutor" }
{ "_id" : 3, "email" : "iicehouse@dewv.net", "residential_status" : "On campus", "slp_instructor_last_name" : "Studybuddy" }
```

### Exercise set 21

1. List the first and last names for all Seniors.
2. List the first and last names for all Freshmen and Sophomores.
3. List the first and last names for all students who are *not* Seniors.
4. List the first and last names of every student, and the sports they play, if any. Sort the results by last name.
5. List the first and last names of every athlete, and the sport(s) they play. Sort the results by last name.

## Updating data with MongoDB

Suppose that Sam Studybuddy wins the lottery and is no longer working as an SLP instructor. This will affect only one student.

```
> db.students.find( 
... { $and: [ 
...   { slp_instructor_first_name: "Sam" }, 
...   { slp_instructor_last_name: "Studybuddy" } 
...   ] 
... }, 
... { email: 1 } 
... )
{ "_id" : 4, "email" : "aalbert@dewv.net" }
```

The `updateOne()` function uses its first argument as a filter. In the example below, the second argument changes the values of SLP instructor name properties for the affected student.

```
> db.students.updateOne(
... { _id: 4 },
... { $set: { slp_instructor_first_name: "Terry", slp_instructor_last_name: "Tutor" }}
... )
{ "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }
```

The response shows that one document matched the filter, and one document was modified. 

Now suppose that a new college policy requires all students to live on campus. So, you want to update off campus students to be on campus. As with SQL, it is a good idea to first `SELECT`/`find` the proper data. This verifies that the filter is correct.

```
> db.students.find({ residential_status: "Off campus" }, { email: 1, residential_status: 1 })
{ "_id" : 2, "email" : "ccadillac@dewv.net", "residential_status" : "Off campus" }
{ "_id" : 7, "email" : "eelkins@dewv.net", "residential_status" : "Off campus" }
```

To modify both documents at once, pass the same filter as the first argument to `updateMany()`. The second argument sets a new value for the residential status property.

```
> db.students.updateMany(
...     { residential_status: "Off campus" }, 
...     { $set: { residential_status: "On campus" } }
...     )
{ "acknowledged" : true, "matchedCount" : 2, "modifiedCount" : 2 }
```

The response shows that two documents matched the filter, and both were modified.

The `updateOne()` function always modifies zero or one document. If more than one document matches the filter, only one will be modified. (At this point, we will assume that we can't control which, and will take care to ensure that the filters passed to `updateOne()` match at most one document.) In contrast, `updateMany()` will process all matching documents. But "process" here does not necessarily mean changes are made. The modified count will exclude documents that match the filter but would not be modified by the second argument (because they already have those values).

The examples above replace the values of existing properties. The `$set` operator can also define a value for a document property that did not previously exist. 

```
> db.students.updateOne(
... { _id: 3 },
... { $set: { sports: [ { name: "Basketball", gender: "Men" } ] } }
... )
{ "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }
```

The `$unset` operator does the opposite. It removes the value for a property, like setting a `NULL` in SQL. The following example reverses the change just made.

```
> db.students.updateOne( { _id: 3 }, { $unset: { sports: undefined } } )
{ "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }
```

The value specified for properties that are being `$unset` is ignored. The example uses the JavaScript `undefined` value, but any value would have the same effect.

Because some documents already have sports data, the example that adds Irving to the Men's Basketball team is analogous to replacing a `NULL` value in SQL. However, the `$set` operator is more powerful than this suggests. MongoDB is not constrained by pre-existing tabular formats as in a relational database. The following example alters the "shape" or format of all student documents, except the first, by setting a value for a new property that did not previously exist on any of the documents.

```
> db.students.updateMany(
... { _id: { $ne: 1 } },
... { $set: { someFieldThatWasJustDreamedUp: "just because" } }
... )
{ "acknowledged" : true, "matchedCount" : 8, "modifiedCount" : 8 }
```

MongoDB defines other field update operators in addition to `$set` and `$unset`. These include operators that:

- modify a field to hold the current date, 
- increment a field's value, 
- set a specified value only if it is less than the fields current value, and
- modify the contents of array-valued fields without requiring you to re`$set` the entire array.

### Exercise set 22

1. Many lottery winners later end up broke-- including Sam. Since Sam is back, update Albert's record so that Sam is again his SLP instructor.
2. Use *two* `updateOne()` statements to reverse the changes from the college's altered residence policy.
3.  Use `updateMany()` to remove the dreamed up property from all documents.

## Deleting data with MongoDB

First, execute the following command.

```
db.students.aggregate([ { $match: {} }, { $out: 'temp_students' } ]);
```

You will learn more about the `aggregate()` function later. Here, it is used to make a copy of the `students` collection, named `temp_students`. You will use the `temp_students` collection to practice deleting data.

You might have guessed that MongoDB defines functions named `deleteOne()` and `deleteMany()`. They use the same filtering as other commands.

```
> // Don't forget to use the temporary collection!
> db.temp_students.deleteOne( { email: 'ddavis@dewv.net'})
{ "acknowledged" : true, "deletedCount" : 1 }

> db.temp_students.deleteMany( { academic_rank: 'Sophomore'})
{ "acknowledged" : true, "deletedCount" : 3 }

> db.students.count({ academic_rank: 'Sophomore' }
0
```

### Exercise set 23

Be sure to use the temporary collection!

1. Use `deleteOne()` to delete any single document from the temporary collection.
2. Use `deleteMany()` to delete *all* the remaining documents from the temporary collection.

## Normalizing data with MongoDB references

You have seen one way to model one-to-many relationships in MongoDB: one student has many majors, and those majors can be modeled as an array embedded within the student document. This is a denormalized approach. The equivalent structure in a relational database would be a repeating group, which fails to meet first normal form.

MongoDB supports a second, more normalized approach to modeling one-to-many relationships.

Use this command to create a document in a new collection to represent visit data.

```
> db.visits.insertOne(
...   {
...     _id: 1,
...     students_id: 1,
...     check_in_time: "2016-08-30 14:35:55",
...     check_out_time: "2016-08-30 15:53:44",
...     location: "Albert Hall",
...     purpose: "study hall",
...     purpose_achieved: "Y",
...     comments: "New year, fresh start!",
...   }
... )
{ "acknowledged" : true, "insertedId" : 1 }
```

This creates a collection named `visits` and a document in that collection. The `students_id` field is a **reference** that indicates this visit is for the `students` document with `_id: 1`. In other words, your old friend Gary Gatehouse.

Gary's visit has the earliest check in on record. Here are the next two.

```
> db.visits.insertMany([
...   {
...     _id: 2,
...     students_id: 2,
...     check_in_time: "2016-08-30 14:55:55",
...     check_out_time: "2016-08-30 16:53:44",
...     location: "Albert Hall",
...     purpose: "baseball meeting",
...     purpose_achieved: "?",
...   },
...   {
...     _id: 3,
...     students_id: 3,
...     check_in_time: "2016-08-30 15:56:56",
...     check_out_time: "2016-08-30 16:56:46",
...     location: "Albert Hall",
...     purpose: "Meet SLP instructor",
...     purpose_achieved: "Y",
...     comments: "Cubicle B computer is not working.",
...   },
... ]);
{ "acknowledged" : true, "insertedIds" : [ 2, 3 ] }
```

The `students_id` references can be used with the `aggregate()` function to "join" the two collections.

```
> db.students.aggregate([
... {
...    $lookup:
...      {
...        from: "visits",
...        localField: "_id",
...        foreignField: "students_id",
...        as: "visits_array"
...      }
... }
... ])
{ "_id" : 1, "first_name" : "Gary", "last_name" : "Gatehouse", "email" : "ggatehouse@dewv.net", ... "visits_array" : [ { "_id" : 1, "students_id" : 1, "check_in_time" : "2016-08-30 14:35:55", "check_out_time" : "2016-08-30 15:53:44", "location" : "Albert Hall", "purpose" : "study hall", "purpose_achieved" : "Y", "comments" : "New year, fresh start!" } ] }
{ "_id" : 2, "first_name" : "Charlie", "last_name" : "Cadillac", "email" : "ccadillac@dewv.net", ... "visits_array" : [ { "_id" : 2, "students_id" : 2, "check_in_time" : "2016-08-30 14:55:55", "check_out_time" : "2016-08-30 16:53:44", "location" : "Albert Hall", "purpose" : "baseball meeting", "purpose_achieved" : "?" } ] }
...
{ "_id" : 9, "first_name" : "Hannah", "last_name" : "Hermanson", "email" : "hhermanson@dewv.net", ... "visits_array" : [ ] }
```

To save space, only partial results are shown.

The statement above processes all `students` documents; for each, it uses the `_id` field value to look up  `visits` documents with the same value in `students_id`. The matching `visits` documents are inserted into the results as a field named `visits_array`.

So, results for both Gary and Charlie have a `visits_array` field containing their `visits` documents. Notice that Hannah's results have an empty `visits_array`. The actual results include all `students` documents (although the output shown has been condensed to save space). So the `$lookup` aggregator is like a left outer join.

### Exercise set 24

1. The `$lookup` query shown above is the equivalent of `students LEFT OUTER JOIN visits` in SQL. Write a `$lookup` query that is the equivalent of `visits LEFT OUTER JOIN students`. Before you run it, predict the number of result documents. Run the query, to see if you were correct, and explain the result count.
2. Insert documents into the `visits` collection for each of the eleven remaining visits. Use the data values from the MySQL table `visit2nf`, with the rows sorted by ascending check in time. Continue to use sequential `_id` values.
3. To verify results of the previous exercise, write a query that returns all fourteen visit documents.
4. Repeat the `$lookup` query shown above to produce full results of `students` "joined" with (the now expanded collection) `visits`.

## Aggregating data

The MongoDB syntax for "joins" is the `aggregate()` function with a `$lookup` operator.

But as the name suggests, most  `aggregate()` operators have nothing to do with joins.

There is a small number of "single purpose aggregation operations", which aggregate data from a single collection. One example you have already seen is `count()`.

```
> db.visits.count()
14
```

Another example is `distinct()`.

```
> db.visits.distinct("location")
[ "Albert Hall", "Writing center" ]
```

More advanced aggregation can be performed using MongoDB's "multi-stage aggregation pipeline." Each stage or step in the pipeline transforms its input to an aggregate that can, optionally, become the input to another stage.

Suppose you want to know how many visits were made by *each* student. 

```
> db.visits.aggregate(
...     [
...         {'$group': {_id: '$students_id', visits: {$sum: 1}}}
...     ]
... )
{ "_id" : 8, "visits" : 2 }
{ "_id" : 9, "visits" : 1 }
{ "_id" : 5, "visits" : 1 }
{ "_id" : 6, "visits" : 3 }
{ "_id" : 7, "visits" : 1 }
{ "_id" : 1, "visits" : 2 }
{ "_id" : 2, "visits" : 2 }
{ "_id" : 3, "visits" : 1 }
{ "_id" : 4, "visits" : 1 }
```

The `aggregate()` function's argument is an array whose elements are stages in the aggregation pipeline. Here, there is only one stage. The `$group` stage is similar to an SQL `GROUP BY` clause. It takes its inputs (here, all the documents in the `visits` collection) and outputs a document for each distinct `students_id` value. The output documents have two fields: one for a student's id, and one for that student's number of visits. The second field's value is calculated as a sum of the constant expression `1` across all the documents.

Now suppose that you were asked to list all students who have visited more than once. You can expand the preceding query by adding a second stage to the aggregation pipeline. The nine documents generated by the preceding query become the inputs to this second stage, which filters for documents that match a condition.

```
> db.visits.aggregate(
...     [
...         {'$group': {_id: '$students_id', visits: {$sum: 1}}},
...         {'$match': {visits: { $gt: 1}}}
...     ]
... )
{ "_id" : 8, "visits" : 2 }
{ "_id" : 6, "visits" : 3 }
{ "_id" : 1, "visits" : 2 }
{ "_id" : 2, "visits" : 2 }
```

This computes the number of visits for each `students_id`, then displays only the documents with a sum greater than one.

### Exercise set 25

1. Write a single query that lists each gender and how many sports exist for that gender.
2. Write a single query to list major names and the number of students who have that major. (It is okay if majors with no students are not in the results.)
3. Create a new collection, `computers` and insert documents with the data from the MySQL table `computer`. Then write a single query to answer this question: how many computers have less than 8GB of memory?
4. Write a single query to list the locations that have more than one SLP instructor.

---

example of embedded doc that is not in array? printer?

upsert?

constraints?

# Contents

[TOC]

<!-- After using Typora to export HTML, use vi or Notepad (not VS Code) to fix the top-of-page link to this contents section, and also the page <title>. -->