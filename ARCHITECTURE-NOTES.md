# Architecture Notes

These notes explain the biggest structural differences between the Haskell project and `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads`.

## Haskell-Native Composition vs C# Composition Root

In the C# repo, composition is often framed around wiring dependencies and making effect boundaries visible.

In this Haskell project, we still care about the same concerns, but they usually show up as:

- explicit data flow
- explicit environment passing
- pure state transitions
- a narrow `IO` boundary

That means the architectural concern is the same even though the implementation style looks different.

## Explicit State vs `State`

You can see both styles in this project:

- explicit immutable state threading:
  - `src/Baseline/StateWorkflow.hs`
  - `src/HaskellStyle/StateWorkflow.hs`
- `State` abstraction:
  - `src/HaskellStyle/StateMonadWorkflow.hs`

The useful teaching pattern is to start with explicit state first, then introduce `State` once the repetition becomes obvious.

## Explicit Environment vs `Reader`

You can see the same progression with configuration and dependency access:

- explicit environment passing:
  - `src/Baseline/ReaderWorkflow.hs`
- `Reader`-based flow:
  - `src/HaskellStyle/ReaderWorkflow.hs`

This lines up with the composition-root discussion in the C# repo, but it feels lighter because the environment is usually just ordinary data.

## Combining `Reader`, `State`, and `IO`

The project now has two layers of examples here:

- smaller combined workflow:
  - `src/HaskellStyle/SessionWorkflow.hs`
- deeper feature-level workflow:
  - `src/HaskellStyle/FeatureRegistration.hs`

The second one is more important architecturally because it starts to look like a real mini-feature instead of a toy example.

It shows a useful pattern:

1. plan the workflow with `Reader` + `State`
2. return explicit commands
3. interpret those commands in `IO`

That is very close in spirit to the C# repo's emphasis on keeping business decisions separate from side effects.

## Laziness and Streaming

The streaming example highlights a difference that is more language-native than library-native:

- `src/Baseline/StreamingNumbers.hs`
- `src/HaskellStyle/StreamingNumbers.hs`

In C#, lazy or streaming behavior often needs to be highlighted intentionally through enumerables, async streams, or effect types.

In Haskell, laziness is already part of the language model, so the code can stay very small while still demonstrating demand-driven computation.
