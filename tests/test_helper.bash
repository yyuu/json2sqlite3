if command -v brew 1>/dev/null 2>&1; then
  # appending Homebrew's prefix at the last to avoid using Homebrew's bash 5
  PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:$(brew --prefix)/bin"
else
  PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
fi
PATH="${BATS_TEST_DIRNAME%/*}/bin:$PATH"
export PATH

setup() {
  mkdir -p "${BATS_TEST_DIRNAME}/tmp"
}

teardown() {
# rm -fr "${BATS_TEST_DIRNAME}/tmp"
  :
}

generate_table_name() {
  local base="${1:-tbl}"
  echo "__test__${base//[^0-9A-Z_a-z]/_}_$(openssl rand -hex 8)"
}

generate_database_file() {
  local base="${1:-db}"
  echo "${BATS_TEST_DIRNAME}/tmp/__test__${base//[^0-9A-Z_a-z]/_}_$(openssl rand -hex 8).sqlite"
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${BATS_TEST_DIRNAME}:\${BATS_TEST_DIRNAME}:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_match() {
  if ! [[ "$2" =~ "$1" ]]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_output_match() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_match "$expected" "$output"
}
