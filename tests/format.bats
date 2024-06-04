#!/usr/bin/env bats

load test_helper

@test "insert with json format" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT);
SQL
  run json2sqlite3 --primary-key-column=_Id --format=json "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo": "FOO1", "bar": "BAR1"},
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2"}
    ]'
  )
  assert_success
  run --separate-stderr sqlite3 -init "/dev/null" "${database_file}" <<SQL
SELECT _Id, foo, bar FROM "${table_name}" ORDER BY _Id;
SQL
  assert_output <<EOS
1|FOO1|BAR1
2|FOO2|BAR2
EOS
  assert_success
}

@test "insert with jsonl format" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT);
SQL
  run json2sqlite3 --primary-key-column=_Id --format=jsonl "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo": "FOO1", "bar": "BAR1"},
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2"}
    ][]'
  )
  assert_success
  run --separate-stderr sqlite3 -init "/dev/null" "${database_file}" <<SQL
SELECT _Id, foo, bar FROM "${table_name}" ORDER BY _Id;
SQL
  assert_output <<EOS
1|FOO1|BAR1
2|FOO2|BAR2
EOS
  assert_success
}

@test "insert with unsupported format" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  sqlite3 -init "/dev/null" "${database_file}" <<SQL
CREATE TABLE "${table_name}" (_Id INTEGER PRIMARY KEY, foo TEXT, bar TEXT);
SQL
  run json2sqlite3 --primary-key-column=_Id --format=unsupported "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo": "FOO1", "bar": "BAR1"},
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2"}
    ]'
  )
  assert_failure
}
