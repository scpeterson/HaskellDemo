# Getting Started

## Open The Project

Open `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo` in IntelliJ IDEA.

## Core Commands

Build:

```bash
cabal build
```

Run:

```bash
cabal run HaskellDemo
```

Test:

```bash
cabal test
```

Serve docs locally after installing the docs dependency:

```bash
python3 -m venv .venv-docs
source .venv-docs/bin/activate
pip install -r requirements-docs.txt
mkdocs serve
```

## Pull Request Workflow

The recommended contribution flow is:

1. create a feature branch
2. make the change locally
3. run `cabal test`
4. if docs changed, run `mkdocs build --strict`
5. open a pull request and wait for `Haskell CI`

For the fuller repo workflow, see [`Contributing`](contributing.md).

## Current Focus Areas

- small expression-level comparisons with `Maybe` and `Either`
- state and environment handling with `State` and `Reader`
- effect boundaries with `IO`
- a deeper end-to-end registration workflow that mirrors the feature-level triad in the C# repo
