#!/usr/bin/env bats

load test_helper

@test "insert negative cache records" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --insert-if-empty=13 \
    --verbose \
    "${database_file}" \
    "${table_name}" \
    < <(
    jq --compact-output --null-input '[
    ]'
  )
  assert_success
  run --separate-stderr sqlite3 -init "/dev/null" "${database_file}" <<SQL
SELECT _Id FROM "${table_name}" WHERE 0 < _DeletedAt ORDER BY _Id;
SQL
  assert_output <<EOS
13
EOS
  assert_success
}

@test "insert negative cache records w/ after query" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --insert-if-empty=13 \
    --verbose \
    --after-query="SELECT 'after importing, there are ' || COUNT(1) ||' record(s).' FROM \"${table_name}\";" \
    "${database_file}" \
    "${table_name}" \
    < <(
      jq --compact-output --null-input '[
    ]'
  )
  assert_output_match "json2sqlite3: existing table '${table_name}' has schema compatible with columns detected in importing data."
  assert_output_match "json2sqlite3: empty file. attempt inserting negative cache record: ${table_name}: _Id=13"
  assert_output_match "after importing, there are 1 record(s)."
  assert_success
}

@test "insert negative cache records w/ before query" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --insert-if-empty=13 \
    --verbose \
    --before-query="SELECT 'before importing, there were ' || COUNT(1) || ' record(s).' FROM \"${table_name}\";" \
    "${database_file}" \
    "${table_name}" \
    < <(
      jq --compact-output --null-input '[
    ]'
  )
  assert_output_match "json2sqlite3: existing table '${table_name}' has schema compatible with columns detected in importing data."
  assert_output_match "json2sqlite3: empty file. attempt inserting negative cache record: ${table_name}: _Id=13"
  assert_output_match "before importing, there were 0 record(s)."
  assert_success
}

@test "insert records into existing table" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (1, 'FOO1', 1234567890, 1234567893, -1);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (2, 'FOO2', -1, -1, -1);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --verbose \
    "${database_file}" \
    "${table_name}" \
    < <(
    jq --compact-output --null-input '[
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2", "_CreatedAt":1234567891, "_UpdatedAt": 1234567894, "_DeletedAt": 1234567897},
      {"_Id": 3, "foo": "FOO3", "bar": "BAR3", "_CreatedAt":1234567892, "_UpdatedAt": 1234567895, "_DeletedAt": -1}
    ]'
  )
  assert_success
  run --separate-stderr sqlite3 -init "/dev/null" "${database_file}" <<SQL
SELECT * FROM "${table_name}" ORDER BY _Id;
SQL
  assert_output <<EOS
1|FOO1||1234567890|1234567893|-1
2|FOO2|BAR2|1234567891|1234567894|1234567897
3|FOO3|BAR3|1234567892|1234567895|-1
EOS
  assert_success
}

@test "insert records into existing table w/ after query" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (1, 'FOO1', 1234567890, 1234567893, -1);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (2, 'FOO2', -1, -1, -1);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --verbose \
    --after-query="SELECT 'after importing, there are ' || COUNT(1) || ' record(s).' FROM \"${table_name}\";" \
    "${database_file}" \
    "${table_name}" \
    < <(
    jq --compact-output --null-input '[
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2", "_CreatedAt":1234567891, "_UpdatedAt": 1234567894, "_DeletedAt": 1234567897},
      {"_Id": 3, "foo": "FOO3", "bar": "BAR3", "_CreatedAt":1234567892, "_UpdatedAt": 1234567895, "_DeletedAt": -1}
    ]'
  )
  assert_output_match "json2sqlite3: existing table '${table_name}' has schema compatible with columns detected in importing data."
  assert_output_match "json2sqlite3: imported 2 record(s) into '${table_name}' table (existing table)."
  assert_output_match "after importing, there are 3 record(s)."
  assert_output_match "json2sqlite3: mutated 2 record(s) on after-query#1."
  assert_success
}

@test "insert records into existing table w/ before query" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (1, 'FOO1', 1234567890, 1234567893, -1);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (2, 'FOO2', -1, -1, -1);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --verbose \
    --before-query="SELECT 'before importing, there were ' || COUNT(1) || ' record(s).' FROM \"${table_name}\";" \
    "${database_file}" \
    "${table_name}" \
    < <(
    jq --compact-output --null-input '[
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2", "_CreatedAt":1234567891, "_UpdatedAt": 1234567894, "_DeletedAt": 1234567897},
      {"_Id": 3, "foo": "FOO3", "bar": "BAR3", "_CreatedAt":1234567892, "_UpdatedAt": 1234567895, "_DeletedAt": -1}
    ]'
  )
  assert_output_match "json2sqlite3: existing table '${table_name}' has schema compatible with columns detected in importing data."
  assert_output_match "before importing, there were 2 record(s)."
  assert_output_match "json2sqlite3: mutated 1 record(s) on before-query#1."
  assert_output_match "json2sqlite3: imported 2 record(s) into '${table_name}' table (existing table)."
  assert_success
}

@test "insert records with preserving created timestamp" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (1, 'FOO1', 1234567890, 1234567893, -1);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (2, 'FOO2', 1234567891, 1234567894, -1);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (3, 'FOO3', 1234567892, 1234567895, -1);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --preserve-created \
    --verbose \
    "${database_file}" \
    "${table_name}" \
    < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo": "FOO1.1", "bar": "BAR1.1", "_CreatedAt":1334567890, "_UpdatedAt": 1334567893, "_DeletedAt": -1},
      {"_Id": 2, "foo": "FOO2.1", "bar": "BAR2.1", "_CreatedAt":1334567891, "_UpdatedAt": 1334567894, "_DeletedAt": -1},
      {"_Id": 3, "foo": "FOO3.1", "bar": "BAR3.1", "_CreatedAt":1334567892, "_UpdatedAt": 1334567895, "_DeletedAt": -1}
    ]'
  )
  assert_success
  run --separate-stderr sqlite3 -init "/dev/null" "${database_file}" <<SQL
SELECT * FROM "${table_name}" ORDER BY _Id;
SQL
  assert_output <<EOS
1|FOO1.1|BAR1.1|1234567890|1334567893|-1
2|FOO2.1|BAR2.1|1234567891|1334567894|-1
3|FOO3.1|BAR3.1|1234567892|1334567895|-1
EOS
  assert_success
}

@test "insert records with marking soft deleted" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (1, 'FOO1', 1234567890, 1234567893, -1);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (2, 'FOO2', 1234567891, 1234567894, -1);
INSERT INTO "${table_name}" (_Id, foo, _CreatedAt, _UpdatedAt, _DeletedAt) VALUES (3, 'FOO3', 1234567892, 1234567895, -1);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --soft-delete \
    --verbose \
    "${database_file}" \
    "${table_name}" \
    < <(
      jq --compact-output --null-input '[
        {"_Id": 2, "foo": "FOO2.1", "bar": "BAR2.1", "_CreatedAt":1334567891, "_UpdatedAt": 1334567894, "_DeletedAt": -1}
      ]'
    )
  assert_success
  run --separate-stderr sqlite3 -init "/dev/null" "${database_file}" <<SQL
SELECT * FROM "${table_name}" WHERE _DeletedAt < 0 ORDER BY _Id;
SQL
  assert_output <<EOS
2|FOO2.1|BAR2.1|1334567891|1334567894|-1
EOS
  assert_success
}

@test "insert records with invalid column names in importing data" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo_column TEXT, bar_column TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --soft-delete \
    --verbose \
    "${database_file}" \
    "${table_name}" \
    < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo-column": "FOO1", "bar-column": "BAR1"},
      {"_Id": 2, "foo-column": "FOO2", "bar-column": "BAR2"},
      {"_Id": 3, "foo-column": "FOO3", "bar-column": "BAR3"}
    ]'
  )
  assert_output_match "invalid identifier for SQLite3 column name"
  assert_failure
}

@test "insert records with invalid column names in command line arguments" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo_column TEXT, bar_column TEXT, _CreatedAt INTEGER, _UpdatedAt INTEGER, _DeletedAt INTEGER);
SQL
  run json2sqlite3 \
    --primary-key-column=_Id \
    --created-column=_CreatedAt \
    --updated-column=_UpdatedAt \
    --deleted-column=_DeletedAt \
    --generic-column=foo-column:TEXT \
    --generic-column=bar-column:TEXT \
    --soft-delete \
    --verbose \
    "${database_file}" \
    "${table_name}" \
    < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo-column": "FOO1", "bar-column": "BAR1"},
      {"_Id": 2, "foo-column": "FOO2", "bar-column": "BAR2"},
      {"_Id": 3, "foo-column": "FOO3", "bar-column": "BAR3"}
    ]'
  )
  assert_output_match "invalid identifier for SQLite3 table/column name"
  assert_failure
}
