# json2sqlite3

A utility script to convert JSON objects into SQLite3 records.

# Setup

You need to have the following tools to be available in your `$PATH`.

* `bash (>= 3)`
* `jq`
* `sqlite3 (>= 3.38.0)`

## Installation

Just `make install` with custom `PREFIX` if you prefer.

```sh
% make PREFIX=/path/to/somewhere install
```

You can also install via [Homebrew](https://brew.sh/) like follows.

```sh
% brew tap yyuu/json2sqlite3 https://github.com/yyuu/json2sqlite3
% brew install yyuu/json2sqlite3/json2sqlite3
```

# Usage

Presume that JSON document is formatted in `array<object>`. Then, pass it to `json2sqlite3` along with filename and table name.

```sh
% cat <<JSON | json2sqlite3 test.db tbl1
[
  {"id": 1, "foo": "FOO1", "bar": "BAR1", "baz": "BAZ1"},
  {"id": 2, "foo": "FOO2", "bar": "BAR2", "baz": "BAZ2"},
  {"id": 3, "foo": "FOO3", "bar": "BAR3", "baz": "BAZ3"}
]
JSON
json2sqlite3: creating new table 'tbl1'
json2sqlite3: imported 3 record(s) into 'tbl1' table (new table).
```

Now you can query records from the table.

```sh
% sqlite3 -json test.db "SELECT * FROM tbl1;"
[{"id":1,"foo":"FOO1","bar":"BAR1","baz":"BAZ1"},
{"id":2,"foo":"FOO2","bar":"BAR2","baz":"BAZ2"},
{"id":3,"foo":"FOO3","bar":"BAR3","baz":"BAZ3"}]
```

You can append records further into the existing table.
By default `json2sqlite3` will modify table schema in case it detects schema drifts between existing table and importing table.

```sh
% cat <<JSON | json2sqlite3 test.db tbl1
[
  {"id": 4, "foo": "FOO4", "bar": "BAR4", "baz": "BAZ4"},
  {"id": 5, "foo": "FOO5", "bar": "BAR5", "baz": "BAZ5"},
  {"id": 6, "foo": "FOO6", "bar": "BAR6", "baz": "BAZ6"}
]
JSON
json2sqlite3: existing table 'tbl1' has schema compatible with columns detected in importing data.
json2sqlite3: imported 3 record(s) into 'tbl1' table (existing table).
```

You can also dump then load records into another table.

```sh
% sqlite3 -json test.db "SELECT * FROM tbl1;" | json2sqlite3 test.db tbl2
json2sqlite3: creating new table 'tbl2'
json2sqlite3: imported 6 record(s) into 'tbl2' table (new table).
% sqlite3 -json test.db "SELECT * FROM tbl2;"
[{"id":1,"foo":"FOO1","bar":"BAR1","baz":"BAZ1"},
{"id":2,"foo":"FOO2","bar":"BAR2","baz":"BAZ2"},
{"id":3,"foo":"FOO3","bar":"BAR3","baz":"BAZ3"},
{"id":4,"foo":"FOO4","bar":"BAR4","baz":"BAZ4"},
{"id":5,"foo":"FOO5","bar":"BAR5","baz":"BAZ5"},
{"id":6,"foo":"FOO6","bar":"BAR6","baz":"BAZ6"}]
```
