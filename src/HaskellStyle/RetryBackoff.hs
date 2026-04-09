module HaskellStyle.RetryBackoff
    ( decideRetry
    , planRetryStep
    , runRetryBackoff
    ) where

import Control.Monad.State.Strict (State, get, put, runState)
import Shared.RetryBackoff
    ( OperationError (..)
    , RetryDecision (RetryAfter, StopRetrying)
    , RetryOutcome
    , RetryRequest
    , RetryState (..)
    , RetryStep (RetryPlanned, RetryStopped, RetrySucceeded)
    , advanceAttempt
    , failureOutcome
    , initialRetryState
    , recordDelay
    , recordFailure
    , simulateProfileFetch
    , successOutcome
    )

decideRetry :: Int -> OperationError -> RetryDecision
decideRetry attempt errorValue =
    case errorValue of
        PermanentFailure _ -> StopRetrying
        TemporaryFailure _
            | attempt >= 3 -> StopRetrying
            | otherwise -> RetryAfter (attempt * 200)

planRetryStep :: RetryRequest -> State RetryState RetryStep
planRetryStep request = do
    state <- get
    let attempt = retryNextAttemptNumber state
    case simulateProfileFetch request attempt of
        Right message -> pure (RetrySucceeded (successOutcome state attempt message))
        Left errorValue -> do
            let failedState = recordFailure errorValue state
            case decideRetry attempt errorValue of
                StopRetrying -> do
                    put failedState
                    pure (RetryStopped (failureOutcome failedState attempt errorValue))
                RetryAfter delayMs -> do
                    let nextState = advanceAttempt (recordDelay delayMs failedState)
                    put nextState
                    pure (RetryPlanned delayMs)

runRetryBackoff :: RetryRequest -> IO RetryOutcome
runRetryBackoff = go initialRetryState
  where
    go state request =
        case runState (planRetryStep request) state of
            (RetrySucceeded outcome, _nextState) -> pure outcome
            (RetryStopped outcome, _nextState) -> pure outcome
            (RetryPlanned delayMs, nextState) -> do
                executeDelay delayMs
                go nextState request

    executeDelay :: Int -> IO ()
    executeDelay _ = pure ()
