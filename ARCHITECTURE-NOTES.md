# Architecture Notes

## Haskell-Native Composition vs C# Composition Root

This note explains one of the biggest cross-project differences between this Haskell companion project and:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads`

## Explicit State Threading vs `State`

Use explicit state threading when the passing itself is part of what we want learners to see.

Use `State` when the state plumbing starts to dominate the code more than the transition logic.

## Explicit Environment vs `Reader`

Use explicit environment passing when there are only a few dependencies and direct parameters still read clearly.

Use `Reader` when repeating the same environment value through many functions starts to hide the actual business input.

## Combining `Reader`, `State`, and `IO`

The project now has two layers for this story:

- single-step combined flow:
  - `src/Baseline/SessionWorkflow.hs`
  - `src/HaskellStyle/SessionWorkflow.hs`
- multi-step batch combined flow:
  - `src/Baseline/BatchSessionWorkflow.hs`
  - `src/HaskellStyle/BatchSessionWorkflow.hs`

That second layer matters because it shows when the abstractions start to pay off more clearly. A single action can often stay direct without much pain. A batch of actions that must keep environment, evolving state, successes, failures, and effects aligned is where the structured Haskell version starts to earn its keep.

## Laziness and Streaming

The streaming example is intentionally small, but it highlights a real language-level difference:

- the baseline version works over a finite range explicitly
- the Haskell version starts from an infinite source and only evaluates the demanded prefix

That makes laziness a useful teaching topic here because it is not just a library style difference. It changes what has to be modeled explicitly in the first place.
