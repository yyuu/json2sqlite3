#!/usr/bin/env bats

load test_helper

@test "load, dump then load again" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name1="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  table_name2="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 --primary-key-column=_Id:INTEGER --created-column=_CreatedAt:INTEGER --updated-column=_UpdatedAt:INTEGER --deleted-column=_DeletedAt:INTEGER "${database_file}" "${table_name1}" < <(
    jq --compact-output --null-input '[
      {"_Id": 1, "foo": "FOO1", "bar": "BAR1", "_CreatedAt": 1234567890, "_UpdatedAt": 1234567893, "_DeletedAt": -1},
      {"_Id": 2, "foo": "FOO2", "bar": "BAR2", "_CreatedAt": 1234567891, "_UpdatedAt": 1234567894, "_DeletedAt": -1},
      {"_Id": 3, "foo": "FOO3", "bar": "BAR3", "_CreatedAt": 1234567892, "_UpdatedAt": 1234567895, "_DeletedAt": -1}
    ]'
  )
  assert_success
  sqlite3 -init "/dev/null" "${database_file}" ".mode json" "SELECT * FROM \"${table_name1}\" ORDER BY _Id;" | run json2sqlite3 --primary-key-column=_Id:INTEGER --created-column=_CreatedAt:INTEGER --updated-column=_UpdatedAt:INTEGER --deleted-column=_DeletedAt:INTEGER "${database_file}" "${table_name2}"
  run --separate-stderr sqlite3 -init "/dev/null" "${database_file}" <<SQL
SELECT COUNT(1) FROM "${table_name2}";
SQL
  assert_output "3"
  assert_success
}
