# End-to-End Registration

This is the first intentionally deeper Haskell counterpart to a full feature-level triad in `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads`.

Related C# ADR:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0043-end-to-end-registration-triad-comparison.md`

## Why This Example Exists

The smaller examples in this project are useful for individual ideas, but the C# repo also teaches how functional thinking scales to a feature-level workflow.

This Haskell version makes the same comparison more explicit:

- `Baseline.FeatureRegistration.registerFeatureInline`
- `HaskellStyle.FeatureRegistration.planFeatureRegistration`
- `HaskellStyle.FeatureRegistration.runFeatureRegistration`

## What The Workflow Does

Given a registration request, it:

- validates the name and email
- enforces a required email domain
- rejects duplicate email addresses
- creates a user record
- prepares a welcome message
- appends an audit line
- updates feature state

## Baseline Version

The baseline version keeps validation, state changes, and file writes together.

That is useful because it stays easy to read, but the tradeoff is that planning and effects are interleaved.

## Haskell-Style Version

The Haskell-style version separates the workflow into two parts:

1. `planFeatureRegistration`
   - pure `Reader` + `State`
   - validates input and updates in-memory state
   - returns explicit commands to interpret
2. `executeFeatureCommands`
   - runs the `IO` side effects
   - writes audit and welcome output at the edge

This keeps the decision-making portion of the feature easier to test and reason about.

## Files To Read

- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Shared/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Baseline/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/HaskellStyle/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/test/Spec.hs`
