# org-macros - Project Guidelines

## Context and sources

Reusable Org macros for HTML, LaTeX, and ODT exports.

`README.org` contains the macro source tangled into `org/setup/org-macros.setup`; update the source and run `make tangle`. Keep examples under `tests/` aligned with macro behavior.

## Changes and precautions

- Keep changes focused and preserve unrelated working-tree edits.
- If a file is generated from an Org/Babel source, edit that source and
  regenerate only the affected output; inspect tangle directives first.
- Use `make test` for ERT regressions and `make check` for source checks. Inspect affected HTML/LaTeX exports when changing backend-specific output; avoid broad clean targets that remove tracked exports.

## Org mode headers

- Recursively scan this Git repository's `.txt` files and prepend the
  following exact first line when missing:

  ```text
  # Hey Emacs, this is a -*- org -*- file ...
  ```

- Preserve the rest of the file and its line endings. Do not follow
  symbolic links, scan `.git`, or cross into nested Git repositories.
- For `.org` files, omit this redundant header; remove it only when it
  matches the exact first line above.

## Validation

- Inspect `Makefile` for prerequisites and side effects before
  choosing a target; do not assume `all` is a safe test command.
- For shell changes, `make lint-shell` runs the repository's
  ShellCheck checks; it requires ShellCheck to be installed.
- `make test` is available; inspect its recipe and referenced files
  before running it, and prefer the smallest relevant checks.
- For documentation-only changes, review the diff and affected local
  links; run an export only when rendering is part of the change.
- Never report an unrun or unavailable validation as successful. Do not
  install new tooling solely to validate an instructions-file change.
