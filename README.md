# Set up Rust

Install an exact Rust toolchain and optional rustup components in a GitHub Actions workflow.

## Requirements

Use a runner with Bash and rustup available.

## Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `toolchain` | Yes | — | Exact toolchain supplied to rustup. |
| `components` | No | `""` | Whitespace-separated rustup component names. |

## Usage

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

The action runs `rustup toolchain install` with `--profile minimal`, makes the selected toolchain the default with `rustup default`, and installs requested components for that toolchain.
