# Contributing

This page mirrors the contributor workflow for the repository and gives the docs-site version of the same guidance in `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/CONTRIBUTING.md`.

## Branch And Pull Request Flow

`main` is protected and expects the `build-and-test` GitHub Actions check before merges.

Recommended flow:

1. create a feature branch from `main`
2. make the change locally
3. run `cabal test`
4. if docs changed, run `mkdocs build --strict`
5. push the branch and open a pull request
6. wait for `Haskell CI` before merging

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

Preview docs:

```bash
python3 -m venv .venv-docs
source .venv-docs/bin/activate
pip install -r requirements-docs.txt
mkdocs serve
```

## What Makes A Good Change Here

Prefer changes that:

- teach one idea clearly
- keep the bridge back to `Scott.FunctionalProgrammingTriads` visible
- favor readable examples over compact but harder-to-teach abstractions
