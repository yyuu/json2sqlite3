#!/usr/bin/env bats

load test_helper

@test "import JSON with creating new table" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 "${database_file}:${table_name}" < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo":"FOO1", "bar":"BAR1"},
      {"_Id": 2, "foo":"FOO2", "bar":"BAR2"},
      {"_Id": 3, "foo":"FOO3", "bar":"BAR3"}
    ]'
  )
  assert_success
  run sqlite3 "${database_file}" <<SQL
SELECT * FROM "${table_name}";
SQL
  assert_output <<EOS
1|FOO1|BAR1
2|FOO2|BAR2
3|FOO3|BAR3
EOS
  assert_success
}
