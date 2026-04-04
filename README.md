# HaskellDemo

This project is a small Haskell companion to `Scott.FunctionalProgrammingTriads`.

The goal is to show how selected C# and LanguageExt examples translate into a purely functional language, starting with small comparisons and growing into richer workflows over time.

## Initial Layout

- `src/Shared/`
  Shared domain types used by examples.
- `src/Baseline/`
  Simpler, direct implementations that feel closer to step-by-step logic.
- `src/HaskellStyle/`
  More idiomatic functional versions.
- `app/Main.hs`
  Small executable that runs the current comparisons.
- `test/Spec.hs`
  Lightweight test harness for the current examples.
- `docs/`
  Small MkDocs site for onboarding and triad writeups.

## Implemented Topics

### 1. Option-style lookup with `Maybe`

- `Baseline.OptionLike.imperativeFindEmail`
- `HaskellStyle.MaybePipeline.findEmail`

### 2. Validation with `Either`

- `Baseline.ValidationFlow.validateRegistrationStepByStep`
- `HaskellStyle.EitherValidation.validateRegistration`

### 3. Registration workflow composition

- `Baseline.RegistrationWorkflow.registerUserStepByStep`
- `HaskellStyle.RegistrationWorkflow.registerUser`

### 4. Validation accumulation

- `Baseline.ValidationAccumulation.validateRegistrationFirstError`
- `HaskellStyle.ValidationAccumulation.validateRegistrationAllErrors`

### 5. Effects and IO boundaries

- `Baseline.EffectsBoundary.saveGreetingInline`
- `HaskellStyle.EffectsBoundary.planGreetingWrite`
- `HaskellStyle.EffectsBoundary.saveGreetingWithBoundary`

### 6. Async workflow composition

- `Baseline.AsyncWorkflow.runAsyncWorkflowInline`
- `HaskellStyle.AsyncWorkflow.planAsyncWorkflow`
- `HaskellStyle.AsyncWorkflow.runAsyncWorkflow`

### 7. Richer async pipeline

- `Baseline.AsyncPipeline.runUserPipelineInline`
- `HaskellStyle.AsyncPipeline.planUserPipeline`
- `HaskellStyle.AsyncPipeline.runUserPipeline`

### 8. Stateful transitions

- `Baseline.StateWorkflow.runCounterProgramStepByStep`
- `HaskellStyle.StateWorkflow.applyProgram`
- `HaskellStyle.StateMonadWorkflow.applyProgramWithState`

### 9. Environment-style dependency passing

- `Baseline.ReaderWorkflow.renderWelcomeExplicit`
- `HaskellStyle.ReaderWorkflow.renderWelcome`
- `HaskellStyle.ReaderWorkflow.runWelcome`

### 10. Combined `Reader` + `State` + `IO` workflow

- `Baseline.SessionWorkflow.processRegistrationInline`
- `HaskellStyle.SessionWorkflow.processRegistration`
- `HaskellStyle.SessionWorkflow.runSessionWorkflow`

### 11. Laziness and streaming

- `Baseline.StreamingNumbers.firstThreeLargeEvenSquaresFromRange`
- `HaskellStyle.StreamingNumbers.firstThreeLargeEvenSquares`

### 12. Multi-step batch `Reader` + `State` + `IO` workflow

- `Baseline.BatchSessionWorkflow.processRegistrationBatchInline`
- `HaskellStyle.BatchSessionWorkflow.processRegistrationBatch`
- `HaskellStyle.BatchSessionWorkflow.runBatchSessionWorkflow`

### 13. Deeper end-to-end registration triad

- `Baseline.FeatureRegistration.registerFeatureInline`
- `HaskellStyle.FeatureRegistration.planFeatureRegistration`
- `HaskellStyle.FeatureRegistration.runFeatureRegistration`

This is the first example in the project that is meant to feel like a full mini-feature rather than a focused language exercise.

## Working In IntelliJ IDEA

1. Open `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo` in IntelliJ IDEA.
2. Use the built-in terminal for the commands below.
3. If you experiment with a Haskell plugin, treat it as optional; the project is set up to work with normal terminal-based Cabal commands either way.
4. Prebuilt shell-based run configs live under `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/.run/`.
5. This folder is a Git repository, so the `.run/` files and Haskell sources can be versioned directly here.

## Commands

Build:

```bash
cabal build
```

Run:

```bash
cabal run HaskellDemo
```

Test:

```bash
cabal test
```

Open a REPL:

```bash
cabal repl
```

## Documentation Site

The project now includes a small MkDocs site.

Set it up with:

```bash
python3 -m venv .venv-docs
source .venv-docs/bin/activate
pip install -r requirements-docs.txt
mkdocs serve
```

## IntelliJ Run Configurations

The project includes these shell-based run configs:

- `HaskellDemo - build`
- `HaskellDemo - run`
- `HaskellDemo - test`
- `HaskellDemo - repl`

## Cross-Project Mapping

- `ADR-MAPPING.md`
- `ARCHITECTURE-NOTES.md`
- `docs/triads/end-to-end-registration.md`
