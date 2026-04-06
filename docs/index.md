# HaskellDemo

`HaskellDemo` is a companion project to `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads`.

It keeps the same teaching intent as the C# and LanguageExt repository, but shows what those ideas look like in a purely functional language.

## What This Site Covers

- how the current Haskell examples map back to the C# ADRs
- how the same ideas shift when `Maybe`, `Either`, `Reader`, `State`, and `IO` are native tools
- one deeper feature-level triad that goes beyond small function examples

## Start Here First

If you want the strongest feature-level comparison right away, begin with [End-to-End Registration](triads/end-to-end-registration.md). It is the deepest triad in the project and the best bridge back to the full C# mini-feature material.

## Best First Code Files To Read

If you want to move from the docs into the code quickly, start with these files:

- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Shared/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Baseline/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/HaskellStyle/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/test/Spec.hs`

Those four files give you the clearest view of the deepest triad in the project: shared domain, baseline implementation, Haskell-style implementation, and test expectations.

## Good Starting Points

- [Getting Started](getting-started.md)
- [End-to-End Registration](triads/end-to-end-registration.md)
- [Comparing With C#](architecture/comparing-with-csharp.md)
