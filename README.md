# Set up Rust

Install an exact Rust toolchain and optional rustup components in a GitHub Actions workflow.

## Requirements

GitHub-hosted Linux, Windows, and macOS runners include Bash and rustup.
Self-hosted runners must provide both.

## Inputs

| Input        | Required | Default | Description                                  |
| ------------ | -------- | ------- | -------------------------------------------- |
| `toolchain`  | Yes      | —       | Exact toolchain supplied to rustup.          |
| `components` | No       | `""`    | Space-separated rustup component names.      |

## Usage

Use an exact Rust toolchain version directly:

```yaml
steps:
  - uses: seapagan/setup-rust@main
    with:
      toolchain: "1.97.1"
      components: rustfmt clippy
```

Omit `components` when you need no extra components:

```yaml
steps:
  - uses: seapagan/setup-rust@main
    with:
      toolchain: "1.97.1"
```

You can also keep the Rust version in a GitHub repository variable and pass it
to the action:

```yaml
env:
  RUST_TOOLCHAIN: ${{ vars.RUST_TOOLCHAIN }}

steps:
  - uses: seapagan/setup-rust@main
    with:
      toolchain: ${{ env.RUST_TOOLCHAIN }}
      components: rustfmt clippy
```

Omit `components` when you need no extra components:

```yaml
- uses: seapagan/setup-rust@main
  with:
    toolchain: ${{ env.RUST_TOOLCHAIN }}
```

## Behavior

The action runs `rustup toolchain install` with `--profile minimal`, selects that
toolchain for subsequent steps in the job through `RUSTUP_TOOLCHAIN`, and installs
requested components for that toolchain. It does not change rustup's persistent
default toolchain.

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

Run `task --list` to discover the individual checks. Local validation covers
static checks only. The hosted
[Integration workflow](.github/workflows/integration.yml) remains authoritative
for the action's behavior across GitHub-hosted Linux, Windows, and macOS runners.
