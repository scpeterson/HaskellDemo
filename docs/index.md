# HaskellDemo

`HaskellDemo` is a companion project to `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads`.

It keeps the same teaching intent as the C# and LanguageExt repository, but shows what those ideas look like in a purely functional language.

## Live Docs

Published site:

- [https://scpeterson.github.io/HaskellDemo/](https://scpeterson.github.io/HaskellDemo/)

## What This Site Covers

- how the current Haskell examples map back to the C# ADRs
- how the same ideas shift when `Maybe`, `Either`, `Reader`, `State`, and `IO` are native tools
- two deeper feature-level triads that go beyond small function examples

## Start Here First

If you want the strongest feature-level comparison right away, begin with [End-to-End Registration](triads/end-to-end-registration.md). Then follow it with [Password Reset Feature](triads/password-reset.md) to see the same architectural ideas in a recovery-style workflow.

## Best First Code Files To Read

If you want to move from the docs into the code quickly, start with these files:

- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Shared/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Baseline/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/HaskellStyle/FeatureRegistration.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/test/Spec.hs`

Those four files give you the clearest view of the deepest triad in the project: shared domain, baseline implementation, Haskell-style implementation, and test expectations. After that, the password reset triad is the best second feature to read.

## Compare With The C# Repo

| HaskellDemo focus | Main counterpart in `Scott.FunctionalProgrammingTriads` | Best starting point |
| --- | --- | --- |
| Feature-level workflow | ADR 0043 end-to-end registration triad | [End-to-End Registration](triads/end-to-end-registration.md) |
| Recovery-style workflow | Feature-level effect-boundary and composition concerns | [Password Reset Feature](triads/password-reset.md) |
| Composition and environment flow | ADR 0046 composition root triad | [Comparing With C#](architecture/comparing-with-csharp.md) |
| Effect boundaries | ADR 0008 effect boundaries | [Comparing With C#](architecture/comparing-with-csharp.md) |
| New contributor workflow | Repo workflow and CI checks | [Contributing](contributing.md) |

## Good Starting Points

- [Getting Started](getting-started.md)
- [Runnable Comparisons](runnable-comparisons.md)
- [Propose A Triad](triads/propose-a-triad.md)
- [End-to-End Registration](triads/end-to-end-registration.md)
- [Password Reset Feature](triads/password-reset.md)
- [Comparing With C#](architecture/comparing-with-csharp.md)
