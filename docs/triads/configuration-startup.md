# Configuration Startup Feature

This is the third deep feature-level triad in the Haskell companion project.

It focuses on startup configuration rather than user-facing request flow. That makes it a good complement to registration and password reset because the feature is still real, but the domain pressure is different: validating raw inputs, normalizing configuration, rejecting bad startup state, and recording a startup audit trail.

## Why This Exists

This triad shows how a richer startup path can still follow the same core pattern:

- validate the raw input
- produce a normalized domain value
- keep state updates explicit
- push file effects to the edge

It also gives us a deeper place to use validation accumulation inside a feature instead of only in small isolated helpers.

## Files To Read

- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Shared/FeatureConfigurationStartup.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/Baseline/FeatureConfigurationStartup.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/src/HaskellStyle/FeatureConfigurationStartup.hs`
- `/Users/scottpeterson/Dev/PurelyFunctional/HaskellDemo/test/Spec.hs`

## What The Workflow Does

Given a raw startup configuration, it:

- validates the application name
- validates the expected environment name
- validates the database URL shape
- parses and validates the port
- validates the log level
- rejects duplicate startup for the same app/environment pair
- appends an audit line when startup succeeds

## Baseline Version

The baseline version keeps validation, normalization, duplicate detection, state updates, and audit-file writing together in one flow.

That makes the path easy to trace, but planning and side effects remain interleaved.

## Haskell-Style Version

The Haskell-style version splits the feature into:

1. `planStartup`
   - `Reader` + `State`
   - validates the input and produces a normalized startup result plus commands
2. `executeStartupCommands`
   - interprets those commands in `IO`

That keeps the startup decision path pure and easier to test in isolation.
