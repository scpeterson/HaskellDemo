# Mapping To Scott.FunctionalProgrammingTriads

This document links the Haskell examples in this project back to the corresponding areas of the C# and LanguageExt teaching repository:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads`

## Current Mappings

### Option-style lookup and optional values

- `src/Baseline/OptionLike.hs`
- `src/HaskellStyle/MaybePipeline.hs`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0037-null-option-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0009-option-monad-triad-comparison.md`

### Validation and fail-fast error channels

- `src/Baseline/ValidationFlow.hs`
- `src/HaskellStyle/EitherValidation.hs`
- `src/Shared/Registration.hs`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0038-parse-validate-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0010-either-monad-triad-comparison.md`

### Validation accumulation

- `src/Baseline/ValidationAccumulation.hs`
- `src/HaskellStyle/ValidationAccumulation.hs`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0039-validation-accumulation-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0011-validation-monad-triad-comparison.md`

### Registration workflow composition

- `src/Baseline/RegistrationWorkflow.hs`
- `src/HaskellStyle/RegistrationWorkflow.hs`

Related ADR:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0043-end-to-end-registration-triad-comparison.md`

### Effects and IO boundaries

- `src/Baseline/EffectsBoundary.hs`
- `src/HaskellStyle/EffectsBoundary.hs`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0044-database-text-store-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0008-languageext-eff-aff-effect-boundaries.md`

### Async workflow composition

- `src/Baseline/AsyncWorkflow.hs`
- `src/HaskellStyle/AsyncWorkflow.hs`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0042-async-eff-workflow-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0008-languageext-eff-aff-effect-boundaries.md`

### Richer async pipelines

- `src/Baseline/AsyncPipeline.hs`
- `src/HaskellStyle/AsyncPipeline.hs`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0042-async-eff-workflow-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0008-languageext-eff-aff-effect-boundaries.md`

### Stateful transitions

- `src/Baseline/StateWorkflow.hs`
- `src/HaskellStyle/StateWorkflow.hs`
- `src/HaskellStyle/StateMonadWorkflow.hs`

Related ADR:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0013-state-monad-triad-comparison.md`

### Environment-style dependency passing

- `src/Baseline/ReaderWorkflow.hs`
- `src/HaskellStyle/ReaderWorkflow.hs`

Related ADR:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0046-composition-root-triad-comparison.md`

### Combined `Reader` + `State` + `IO` workflow

- `src/Baseline/SessionWorkflow.hs`
- `src/HaskellStyle/SessionWorkflow.hs`
- `src/Shared/SessionWorkflow.hs`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0043-end-to-end-registration-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0008-languageext-eff-aff-effect-boundaries.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0046-composition-root-triad-comparison.md`

### Laziness and streaming

- `src/Baseline/StreamingNumbers.hs`
- `src/HaskellStyle/StreamingNumbers.hs`
- `src/Shared/StreamingNumbers.hs`

Related ADR:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0050-streaming-large-data-processing-triad-comparison.md`

### Multi-step batch `Reader` + `State` + `IO`

- `src/Baseline/BatchSessionWorkflow.hs`
- `src/HaskellStyle/BatchSessionWorkflow.hs`
- `src/Shared/BatchSessionWorkflow.hs`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0043-end-to-end-registration-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0008-languageext-eff-aff-effect-boundaries.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0046-composition-root-triad-comparison.md`

### Deeper end-to-end registration triad

- `src/Shared/FeatureRegistration.hs`
- `src/Baseline/FeatureRegistration.hs`
- `src/HaskellStyle/FeatureRegistration.hs`
- `docs/triads/end-to-end-registration.md`

Related ADRs:

- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0043-end-to-end-registration-triad-comparison.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0008-languageext-eff-aff-effect-boundaries.md`
- `/Users/scottpeterson/Dev/FunctionalProgrammingTriads/Scott.FunctionalProgrammingTriads/docs/architecture/adr/0046-composition-root-triad-comparison.md`
