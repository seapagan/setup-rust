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

default_release=$(rustc --version --verbose | sed -n 's/^release: //p')
printf 'Runner default Rust release: %s\n' "$default_release"

if [[ "$default_release" == "$test_toolchain" ]]; then
  printf 'Requested Rust release unexpectedly matches the runner default: %s\n' \
    "$test_toolchain" >&2
  exit 1
fi
