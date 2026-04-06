# Password Reset Feature

This is the second deep feature-level triad in the Haskell companion project.

It broadens the repo beyond registration by showing a different feature shape: a request that validates input, checks existing state, plans side effects, and produces externally visible output.

## Why This Exists

The first deep triad is registration. This one answers a different question:

> What does a recovery-style workflow look like when the feature mostly coordinates validation, existing state, generated tokens, and notifications?

That makes it a good second feature-level comparison because it still fits the same architectural themes while giving the reader a distinct scenario.

## Files To Read

- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Shared/FeaturePasswordReset.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Baseline/FeaturePasswordReset.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/HaskellStyle/FeaturePasswordReset.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/test/Spec.hs`

## What The Workflow Does

Given an email address, it:

- validates format and required domain
- confirms the user exists in the current state
- generates a reset token and reset link
- appends an audit line
- appends a reset-email payload
- advances the reset token counter

## Baseline Version

The baseline version keeps validation, token creation, state changes, and file writes together.

That makes the whole workflow easy to follow top-to-bottom, but it also means planning and effects are interleaved.

## Haskell-Style Version

The Haskell-style version separates the workflow into:

1. `planPasswordReset`
   - `Reader` + `State`
   - validates the request and produces explicit commands
2. `executePasswordResetCommands`
   - interprets those commands in `IO`

That keeps the feature logic testable while still ending in a real effect boundary.
