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

## Current Focus Areas

- small expression-level comparisons with `Maybe` and `Either`
- state and environment handling with `State` and `Reader`
- effect boundaries with `IO`
- a deeper end-to-end registration workflow that mirrors the feature-level triad in the C# repo
