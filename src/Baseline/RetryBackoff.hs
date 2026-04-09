module Baseline.RetryBackoff
    ( runRetryBackoffInline
    ) where

import Shared.RetryBackoff
    ( OperationError (PermanentFailure, TemporaryFailure)
    , RetryOutcome
    , RetryRequest
    , RetryState (..)
    , advanceAttempt
    , failureOutcome
    , initialRetryState
    , recordDelay
    , recordFailure
    , simulateProfileFetch
    , successOutcome
    )

runRetryBackoffInline :: RetryRequest -> IO RetryOutcome
runRetryBackoffInline = go initialRetryState
  where
    go state request =
        let attempt = retryNextAttemptNumber state
         in case simulateProfileFetch request attempt of
                Right message -> pure (successOutcome state attempt message)
                Left errorValue ->
                    case errorValue of
                        PermanentFailure _ ->
                            pure (failureOutcome (recordFailure errorValue state) attempt errorValue)
                        TemporaryFailure _
                            | attempt >= 3 ->
                                pure (failureOutcome (recordFailure errorValue state) attempt errorValue)
                            | otherwise -> do
                                let delayMs = attempt * 200
                                let nextState = advanceAttempt (recordDelay delayMs (recordFailure errorValue state))
                                executeDelay delayMs
                                go nextState request

    executeDelay :: Int -> IO ()
    executeDelay _ = pure ()
