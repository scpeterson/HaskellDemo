# Release Checklist

Use this checklist before running the manual `Release` workflow from GitHub Actions.

## Before The Release

1. update `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/CHANGELOG.md`
2. move the important finished work from `Unreleased` into the release version section
3. make sure the release tag you plan to use starts with `v`, for example `v0.2.0`
4. run `cabal test`
5. if docs changed, run `mkdocs build --strict`
6. make sure `main` is in the state you want to tag

## Running The Workflow

Open the `Release` workflow in GitHub Actions and provide:

- `version`
- `title`
- optional `notes`

If `notes` is empty, the workflow will ask GitHub to generate release notes.

## After The Release

1. confirm the tag exists in GitHub
2. confirm the GitHub release was created
3. skim the release notes for obvious mistakes
4. if the release changed docs behavior, verify the published docs site again

## Related Files

- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/.github/workflows/release.yml`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/CHANGELOG.md`
