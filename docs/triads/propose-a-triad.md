# Propose A Triad

This page explains how to propose a new Haskell comparison or cross-repo teaching example.

## Best Starting Point

Open a new GitHub issue using the `Triad idea` template.

That template is designed to keep the proposal grounded in three things:

- the teaching goal
- the main repo counterpart in `Scott.FunctionalProgrammingTriads`
- the expected validation or completion signal

## What Makes A Strong Triad Proposal

A strong proposal usually answers these questions clearly:

1. What concept should this teach?
2. Which area of the main C# repo does it connect back to?
3. What would the baseline version look like?
4. What would the Haskell-style version look like?
5. Why is this worth adding instead of just adding another small isolated example?

## Good Proposal Shape

A useful new triad often has:

- a shared domain model if the example needs one
- a baseline implementation that is direct and easy to read
- a Haskell-style implementation that highlights the language-native abstraction clearly
- tests that lock in the teaching claim
- a docs note or mapping update so readers can connect it back to the main repo

## When To Add A Triad

Add a new triad when it does at least one of these:

- deepens the bridge back to an ADR in `Scott.FunctionalProgrammingTriads`
- explains a Haskell-native abstraction that the current repo only hints at
- upgrades a small expression-level idea into a feature-level workflow
- fills a meaningful teaching gap in the current Haskell project

## Related Files

- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/.github/ISSUE_TEMPLATE/triad-idea.md`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/ADR-MAPPING.md`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/docs/runnable-comparisons.md`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/docs/triads/end-to-end-registration.md`
