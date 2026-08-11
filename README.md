# Set up Rust

Install a Rust toolchain specification and optional rustup components and targets
in a GitHub Actions workflow.

## Requirements

GitHub-hosted Linux, Windows, and macOS runners include Bash and rustup.
Self-hosted runners must provide both.

## Inputs

| Input        | Required | Default | Description                             |
| ------------ | -------- | ------- | --------------------------------------- |
| `toolchain`  | Yes      | —       | Rustup toolchain specification.         |
| `components` | No       | `""`    | Space-separated rustup component names. |
| `targets`    | No       | `""`    | Space-separated rustup target names.    |

`toolchain` accepts a standard
[rustup toolchain specification](https://rust-lang.github.io/rustup/concepts/toolchains.html),
including explicit releases such as `1.97.1`, the `stable`, `beta`, and
`nightly` channels, and dated nightlies such as `nightly-2025-06-26`.
Reproducible CI should generally prefer an explicit release or dated nightly
because the channel names move as new toolchains are published.

## Usage

Use an explicit Rust release:

```yaml
steps:
  - uses: seapagan/setup-rust@main
    with:
      toolchain: "1.97.1"
```

Channel names and other rustup toolchain specifications work through the same
input. For example, use the current stable channel:

```yaml
steps:
  - uses: seapagan/setup-rust@main
    with:
      toolchain: stable
```

Install optional components for the selected toolchain:

```yaml
steps:
  - uses: seapagan/setup-rust@main
    with:
      toolchain: "1.97.1"
      components: rustfmt clippy
```

Install optional Rust target support, including more than one target when
needed:

```yaml
steps:
  - uses: seapagan/setup-rust@main
    with:
      toolchain: nightly-2025-06-26
      targets: wasm32-unknown-unknown thumbv7em-none-eabihf
```

## Behavior

The action runs `rustup toolchain install` with `--profile minimal`, selects that
toolchain for subsequent steps in the job through `RUSTUP_TOOLCHAIN`, and installs
requested components and targets explicitly for that toolchain. It does not
change rustup's persistent default toolchain.

Installing a target adds Rust's standard library for that target. Cross-compiling
may also require a suitable linker, platform SDK, or other external tools; this
action does not install them.

## Development

Development requires [Task](https://taskfile.dev/installation/),
[Bash](https://www.gnu.org/software/bash/),
[ShellCheck](https://www.shellcheck.net/),
[shfmt](https://github.com/mvdan/sh/tree/master/cmd/shfmt#shfmt),
[actionlint](https://github.com/rhysd/actionlint#installation),
[zizmor](https://docs.zizmor.sh/installation/), and
[Git](https://git-scm.com/downloads). Follow each project's authoritative
installation guidance for your platform.

Run the complete mandatory local validation suite from the repository root:

```bash
task validate
```

Maintainers can generate or update CHANGELOG.md with:

```bash
task changelog
```

This uses [github-changelog-md](https://changelog.seapagan.net) which must be
installed and available on your PATH. To pass any other CLI options to the task,
place them after `--`:

```bash
task changelog -- -n v1.1.0
```

Run `task --list` to discover the individual checks. Local validation covers
static checks only. The hosted
[Integration workflow](.github/workflows/integration.yml) remains authoritative
for the action's behavior across GitHub-hosted Linux, Windows, and macOS runners.
