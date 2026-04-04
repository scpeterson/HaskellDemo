# Comparing With C#

The goal of this project is not to claim that Haskell is simply "C# but more functional."

Instead, it helps answer a narrower question:

> If the C# repo is teaching a concept with plain C# and LanguageExt, what does that same concept look like in a language where those abstractions are native?

## Useful Translation Heuristics

### Option / Maybe

- C# null checks and `Option<T>` examples usually map to `Maybe`

### Either / Validation

- fail-fast error channels map naturally to `Either`
- accumulated validation often becomes `Either [String] a` or a dedicated validation type

### Reader

- composition-root or dependency-threading discussions often map to explicit environment passing or `Reader`

### State

- explicit immutable state threading in C# maps naturally to pure state transitions in Haskell
- once the workflow grows, `State` can express the same idea more compactly

### IO boundaries

- what the C# repo frames as "push effects to the edge" is still the right idea here
- the difference is that Haskell has a language-level effect boundary in `IO`

## Where To Start

If you want the strongest feature-level comparison first, go to:

- [End-to-End Registration](../triads/end-to-end-registration.md)
