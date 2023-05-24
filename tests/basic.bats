#!/usr/bin/env bats

load test_helper

@test "display version information" {
  run json2sqlite3 --version
  assert_success
}

@test "display help message" {
  run json2sqlite3 --help
  assert_success
}
