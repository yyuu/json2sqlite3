#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${BATS_TEST_DIRNAME}/tmp"
}

@test "display version information" {
  run json2sqlite3 --version
  assert_success
}

@test "display help message" {
  run json2sqlite3 --help
  assert_success
}

@test "import JSON with CREATE TABLE" {
  jq --compact-output --null-input '[
    {"id": 1, "foo":"FOO1", "bar":"BAR1"},
    {"id": 2, "foo":"FOO2", "bar":"BAR2"},
    {"id": 3, "foo":"FOO3", "bar":"BAR3"}
  ]' > "${BATS_TEST_DIRNAME}/tmp/test1.json"
  DBFILE="${BATS_TEST_DIRNAME}/tmp/test1.sqlite"
  run json2sqlite3 "${DBFILE}:test1" < "${BATS_TEST_DIRNAME}/tmp/test1.json"
  assert_success
  run sqlite3 "${DBFILE}" "SELECT * FROM test1;"
  assert_output <<EOS
1|FOO1|BAR1
2|FOO2|BAR2
3|FOO3|BAR3
EOS
  assert_success
}
