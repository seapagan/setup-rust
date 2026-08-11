#!/usr/bin/env bash
set -euo pipefail

if (($# != 1)); then
  printf 'Usage: bash tests/integration/capture-state.sh <toolchain>\n' >&2
  exit 2
fi

readonly test_toolchain=$1
readonly state_file="${RUNNER_TEMP:?RUNNER_TEMP must be set}/rustup-default-before"

persistent_default=$(rustup default)
printf '%s\n' "$persistent_default" >"$state_file"
printf 'Persistent rustup default before action: %s\n' "$persistent_default"

default_toolchain=${persistent_default%% *}
if [[ "$default_toolchain" == "$test_toolchain" ||
  "$default_toolchain" == "$test_toolchain"-* ]]; then
  printf 'Requested Rust toolchain unexpectedly matches the persistent default: %s\n' \
    "$test_toolchain" >&2
  exit 1
fi
