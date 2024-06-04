#!/usr/bin/env bats

load test_helper

@test "insert array records" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"id": 1, "col1": ["e1", "e2", "e3"]}
    ]'
  )
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT json_type(col1) FROM \"${table_name}\";"
  assert_output <<EOS
-- Loading resources from /dev/null
array
EOS
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT type FROM pragma_table_info(\"${table_name}\") WHERE name = 'col1';"
  assert_output <<EOS
-- Loading resources from /dev/null
JSON
EOS
  assert_success
}

@test "insert boolean records" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"id": 1, "col1": true},
      {"id": 2, "col1": false}
    ]'
  )
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT sum(col1) FROM \"${table_name}\";"
  assert_output <<EOS
-- Loading resources from /dev/null
1
EOS
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT type FROM pragma_table_info(\"${table_name}\") WHERE name = 'col1';"
  assert_output <<EOS
-- Loading resources from /dev/null
INTEGER
EOS
  assert_success
}

@test "insert null records" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"id": 1, "col1": null},
      {"id": 2, "col1": 123},
      {"id": 3, "col1": null}
    ]'
  )
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT COUNT(1) FROM \"${table_name}\" WHERE col1 IS NULL;"
  assert_output <<EOS
-- Loading resources from /dev/null
2
EOS
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT type FROM pragma_table_info(\"${table_name}\") WHERE name = 'col1';"
  assert_output <<EOS
-- Loading resources from /dev/null
JSON
EOS
  assert_success
}

@test "insert integer records" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"id": 1, "col1": 100},
      {"id": 2, "col1": 20},
      {"id": 3, "col1": 3}
    ]'
  )
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT sum(col1) FROM \"${table_name}\";"
  assert_output <<EOS
-- Loading resources from /dev/null
123
EOS
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT type FROM pragma_table_info(\"${table_name}\") WHERE name = 'col1';"
  assert_output <<EOS
-- Loading resources from /dev/null
NUMERIC
EOS
  assert_success
}

@test "insert float records" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"id": 1, "col1": 1.1},
      {"id": 2, "col1": 2.2},
      {"id": 2, "col1": 3.3}
    ]'
  )
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT sum(col1) FROM \"${table_name}\";"
  assert_output <<EOS
-- Loading resources from /dev/null
6.6
EOS
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT type FROM pragma_table_info(\"${table_name}\") WHERE name = 'col1';"
  assert_output <<EOS
-- Loading resources from /dev/null
NUMERIC
EOS
  assert_success
}

@test "insert object records" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"id": 1, "col1": {"foo":"FOO1"}},
      {"id": 2, "col1": {"foo":"FOO2"}},
      {"id": 3, "col1": {"foo":"FOO3"}}
    ]'
  )
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT json_group_array(json_extract(col1, '$.foo')) FROM \"${table_name}\" ORDER BY id;"
  assert_output <<EOS
-- Loading resources from /dev/null
["FOO1","FOO2","FOO3"]
EOS
  assert_success
  run sqlite3 -init "/dev/null"  "${database_file}" "SELECT type FROM pragma_table_info(\"${table_name}\") WHERE name = 'col1';"
  assert_output <<EOS
-- Loading resources from /dev/null
JSON
EOS
  assert_success
}

@test "insert string records" {
  database_file="$(generate_database_file "${BATS_TEST_FILENAME##*/}")"
  table_name="$(generate_table_name "${BATS_TEST_FILENAME##*/}")"
  run json2sqlite3 "${database_file}" "${table_name}" < <(
    jq --compact-output --null-input '[
      {"id": 1, "col1": "something contains X"},
      {"id": 2, "col1": "something contains  X"},
      {"id": 3, "col1": "something contains   X"}
    ]'
  )
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT sum(instr(col1, 'X')) FROM \"${table_name}\";"
  assert_output <<EOS
-- Loading resources from /dev/null
63
EOS
  assert_success
  run sqlite3 -init "/dev/null" "${database_file}" "SELECT type FROM pragma_table_info(\"${table_name}\") WHERE name = 'col1';"
  assert_output <<EOS
-- Loading resources from /dev/null
TEXT
EOS
  assert_success
}
