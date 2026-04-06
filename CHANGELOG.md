# Revision history for HaskellDemo

This changelog follows a simple project convention:

- create a new unreleased section as work accumulates
- group entries under `Added`, `Changed`, `Fixed`, and `Docs` when helpful
- when running the manual `Release` workflow, turn the unreleased heading into the release version and date
- keep entries short and oriented around what changed for readers of the repo

## Unreleased

No unreleased changes yet.

## v0.1.0 -- 2026-04-06

### Added

- Initial Haskell companion project with runnable `Maybe`, `Either`, `Reader`, `State`, `IO`, async, streaming, and validation examples.
- Deep feature-level triads for end-to-end registration, password reset, and configuration startup.
- Lightweight test harness covering pure planning, side-effect boundaries, and feature workflows.
- GitHub Actions workflows for Haskell CI, docs validation, Pages publishing, and manual releases.
- Contributor guidance, issue templates, PR template, and generated runnable-comparisons docs.

### Changed

- Docs site now includes a learning path, architecture notes, runnable comparisons, and feature-triad pages.
- Runnable comparisons are generated from `app/Main.hs` and checked in CI for drift.
- Workflow actions were updated to Node 24-compatible versions and patterns.

### Docs

- Published docs site for the Haskell companion project is now live on GitHub Pages.
- Release checklist, proposal guidance, contributing docs, and cross-repo mapping are now part of the docs surface.
