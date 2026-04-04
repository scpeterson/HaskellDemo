module Baseline.BatchSessionWorkflow
    ( processRegistrationBatchInline
    ) where

import Baseline.SessionWorkflow (processRegistrationInline)
import Shared.BatchSessionWorkflow (BatchResult (..))
import Shared.Registration (RegistrationInput)
import Shared.SessionWorkflow (SessionEnvironment, SessionState)

processRegistrationBatchInline :: SessionEnvironment -> SessionState -> [RegistrationInput] -> IO (BatchResult, SessionState)
processRegistrationBatchInline environment initialState inputs = go initialState (BatchResult [] []) inputs
  where
    go state result [] = pure (finalize result, state)
    go state result (input : rest) = do
        outcome <- processRegistrationInline environment state input
        case outcome of
            Left err -> go state (result {failedRegistrations = (input, err) : failedRegistrations result}) rest
            Right (nextState, message) -> go nextState (result {successfulRegistrations = message : successfulRegistrations result}) rest

    finalize result =
        result
            { successfulRegistrations = reverse (successfulRegistrations result)
            , failedRegistrations = reverse (failedRegistrations result)
            }
