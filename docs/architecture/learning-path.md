# Learning Path

This page gives a practical order for exploring the Haskell companion project.

## First Hour Path

If you want the fastest path to understanding the repo, use this sequence:

1. [Getting Started](../getting-started.md)
2. [End-to-End Registration](../triads/end-to-end-registration.md)
3. [Comparing With C#](comparing-with-csharp.md)
4. [Contributing](../contributing.md)

## Recommended Code Walkthrough

After that, read the code in this order:

1. `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Shared/FeatureRegistration.hs`
2. `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Baseline/FeatureRegistration.hs`
3. `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/HaskellStyle/FeatureRegistration.hs`
4. `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/test/Spec.hs`

That sequence keeps the learning flow stable:

- shared domain first
- direct baseline implementation second
- Haskell-style implementation third
- tests last, so you can see the expected behavior clearly

## Broader Follow-Up Path

Once the end-to-end triad makes sense, a good follow-up route is:

1. `Maybe` and `Either` examples in the executable
2. state examples
3. `Reader` examples
4. combined `Reader` + `State` + `IO` workflows
5. streaming/laziness examples

## Live Docs

Published site:

- [https://scpeterson.github.io/HaskellDemo/](https://scpeterson.github.io/HaskellDemo/)
