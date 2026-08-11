#!/usr/bin/env bash
set -euo pipefail

if (($# < 1)); then
  printf 'Usage: bash tests/integration/verify-state.sh <toolchain> [component ...] [--targets target ...]\n' >&2
  exit 2
fi

readonly test_toolchain=$1
shift
requested_components=()
requested_targets=()
parsing_targets=false
for argument in "$@"; do
  if [[ "$argument" == "--targets" ]]; then
    parsing_targets=true
  elif [[ "$parsing_targets" == true ]]; then
    requested_targets+=("$argument")
  else
    requested_components+=("$argument")
  fi
done
readonly -a requested_components requested_targets
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
expected_rustc_release=$(rustup run "$test_toolchain" rustc --version --verbose | sed -n 's/^release: //p')
if [[ "$rustc_release" != "$expected_rustc_release" ]]; then
  printf 'Rustc release is %s; %s resolves to %s\n' \
    "$rustc_release" "$test_toolchain" "$expected_rustc_release" >&2
  exit 1
fi

cargo_release=$(cargo --version --verbose | sed -n 's/^release: //p')
expected_cargo_release=$(rustup run "$test_toolchain" cargo --version --verbose | sed -n 's/^release: //p')
if [[ "$cargo_release" != "$expected_cargo_release" ]]; then
  printf 'Cargo release is %s; %s resolves to %s\n' \
    "$cargo_release" "$test_toolchain" "$expected_cargo_release" >&2
  exit 1
fi

if [[ "$test_toolchain" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  if [[ "$rustc_release" != "$test_toolchain" ]]; then
    printf 'Rustc release is %s; expected explicit release %s\n' \
      "$rustc_release" "$test_toolchain" >&2
    exit 1
  fi
  if [[ "$cargo_release" != "$test_toolchain" ]]; then
    printf 'Cargo release is %s; expected explicit release %s\n' \
      "$cargo_release" "$test_toolchain" >&2
    exit 1
  fi
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

if ((${#requested_targets[@]} > 0)); then
  installed=$(rustup target list --toolchain "$test_toolchain" --installed)
  for target in "${requested_targets[@]}"; do
    if ! grep -Fxq "$target" <<<"$installed"; then
      printf 'Rustup target is not installed for %s: %s\n' \
        "$test_toolchain" "$target" >&2
      exit 1
    fi
  done
fi
