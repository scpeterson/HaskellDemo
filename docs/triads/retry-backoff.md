# Retry And Backoff Policy

This triad adds a practical resilience example to the project.

The feature is intentionally small: we simulate a flaky profile fetch and compare two ways to handle retries, backoff, and failure tracking.

## What It Shows

- temporary vs permanent failure
- max-attempt stopping
- backoff delay history
- pure retry policy vs effectful execution

## Modules

- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Shared/RetryBackoff.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Baseline/RetryBackoff.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/HaskellStyle/RetryBackoff.hs`

## Baseline Shape

`Baseline.RetryBackoff.runRetryBackoffInline` keeps the retry loop close to the simulated operation.

That makes the control flow easy to follow, but the retry policy and execution details stay mixed together.

## Haskell-Style Shape

`HaskellStyle.RetryBackoff` separates the problem into clearer pieces:

- `decideRetry` is a pure retry-policy function
- `planRetryStep` is a pure planning step over explicit retry state
- `runRetryBackoff` executes the plan in `IO`

That split is the main teaching point. We can test policy and planning without needing a real network client or timer.

## Why It Fits This Repo

This example builds on earlier comparisons:

- async workflows
- effect boundaries
- state threading
- deeper feature-style orchestration

It is a good bridge between small functional examples and real resilience-oriented application behavior.
