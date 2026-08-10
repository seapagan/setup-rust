#!/usr/bin/env bash
set -euo pipefail

if (($# < 1)); then
  printf 'Usage: bash tests/integration/verify-state.sh <toolchain> [component ...]\n' >&2
  exit 2
fi

readonly test_toolchain=$1
shift
readonly -a requested_components=("$@")
readonly state_file="${RUNNER_TEMP:?RUNNER_TEMP must be set}/rustup-default-before"

if [[ ! -r "$state_file" ]]; then
  printf 'Captured rustup state is not readable: %s\n' "$state_file" >&2
  exit 1
fi

persistent_default_before=$(<"$state_file")
persistent_default_after=$(rustup default)
if [[ "$persistent_default_after" != "$persistent_default_before" ]]; then
  printf 'Persistent rustup default changed from %s to %s\n' \
    "$persistent_default_before" "$persistent_default_after" >&2
  exit 1
fi
printf 'Persistent rustup default after action: %s\n' "$persistent_default_after"

if [[ ${RUSTUP_TOOLCHAIN:-} != "$test_toolchain" ]]; then
  printf 'RUSTUP_TOOLCHAIN is %s; expected %s\n' \
    "${RUSTUP_TOOLCHAIN:-<unset>}" "$test_toolchain" >&2
  exit 1
fi

rustc_release=$(rustc --version --verbose | sed -n 's/^release: //p')
cargo_release=$(cargo --version --verbose | sed -n 's/^release: //p')
if [[ "$rustc_release" != "$test_toolchain" ]]; then
  printf 'Rustc release is %s; expected %s\n' \
    "$rustc_release" "$test_toolchain" >&2
  exit 1
fi
if [[ "$cargo_release" != "$test_toolchain" ]]; then
  printf 'Cargo release is %s; expected %s\n' \
    "$cargo_release" "$test_toolchain" >&2
  exit 1
fi

if ((${#requested_components[@]} > 0)); then
  installed=$(rustup component list --toolchain "$test_toolchain" --installed)
  for component in "${requested_components[@]}"; do
    if ! grep -Eq "^${component}(-|$)" <<<"$installed"; then
      printf 'Rustup component is not installed for %s: %s\n' \
        "$test_toolchain" "$component" >&2
      exit 1
    fi
  done
fi
