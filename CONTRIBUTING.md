# Contributing

Thanks for working on `HaskellDemo`.

## Branching And Pull Requests

`main` is protected and requires the `build-and-test` GitHub Actions check before merges.

A straightforward working flow is:

1. create a feature branch from `main`
2. make the change locally
3. run `cabal test`
4. if docs changed, run `mkdocs build --strict`
5. push the branch and open a pull request
6. wait for `Haskell CI` to pass before merging

If a change touches docs, the `Docs` and `Pages` workflows will also run from GitHub.

## Local Commands

Build:

```bash
cabal build
```

Run tests:

```bash
cabal test
```

Preview docs locally:

```bash
python3 -m venv .venv-docs
source .venv-docs/bin/activate
pip install -r requirements-docs.txt
mkdocs serve
```

## Scope

This repo is intentionally educational.

When making changes, prefer:

- examples that teach one idea clearly
- explicit code over clever code when the tradeoff improves readability
- comments and docs that strengthen the bridge back to `Scott.FunctionalProgrammingTriads`
