#!/usr/bin/env bats

load test_helper

@test "alter existing table" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER);
SQL
  run json2sqlite3 "${database_file}:${table_name}" < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo": "FOO1", "bar": "BAR1"},
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2"},
      {"_Id": 3, "foo": "FOO3", "bar": "BAR3"}
    ]'
  )
  assert_success
  run sqlite3 "${database_file}" <<SQL
SELECT * FROM "${table_name}" ORDER BY _Id;
SQL
  assert_output <<EOS
1|FOO1|BAR1
2|FOO2|BAR2
3|FOO3|BAR3
EOS
  assert_success
}

@test "alter existing table with primary key" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT);
SQL
  run json2sqlite3 --primary-key-column=_Id "${database_file}:${table_name}" < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo": "FOO1", "bar": "BAR1"},
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2"},
      {"_Id": 1, "foo": "FOO3", "bar": "BAR3"}
    ]'
  )
  assert_success
  run sqlite3 "${database_file}" <<SQL
SELECT * FROM "${table_name}" ORDER BY _Id;
SQL
  assert_output <<EOS
1|FOO3|BAR3
2|FOO2|BAR2
EOS
  assert_success
}

@test "alter existing table with primary key and timestamp columns" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT);
SQL
  run json2sqlite3 --primary-key-column=_Id --created-column=_CreatedAt --updated-column=_UpdatedAt --deleted-column=_DeletedAt "${database_file}:${table_name}" < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo": "FOO1", "bar": "BAR1", "_CreatedAt": 1234567890, "_UpdatedAt": 1234567893, "_DeletedAt": 1234567896},
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2", "_CreatedAt": 1234567891, "_UpdatedAt": 1234567894, "_DeletedAt": 1234567897},
      {"_Id": 1, "foo": "FOO3", "bar": "BAR3", "_CreatedAt": 1234567892, "_UpdatedAt": 1234567895, "_DeletedAt": -1}
    ]'
  )
  assert_success
  run sqlite3 "${database_file}" <<SQL
SELECT * FROM "${table_name}" ORDER BY _Id;
SQL
  assert_output <<EOS
1|FOO3|BAR3|1234567892|1234567895|-1
2|FOO2|BAR2|1234567891|1234567894|1234567897
EOS
  assert_success
}
