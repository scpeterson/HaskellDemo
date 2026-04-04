module HaskellStyle.BatchSessionWorkflow
    ( processRegistrationBatch
    , runBatchSessionWorkflow
    ) where

import Control.Monad.Reader (runReaderT)
import Control.Monad.State.Strict (runStateT)
import HaskellStyle.SessionWorkflow (SessionApp, processRegistration)
import Shared.BatchSessionWorkflow (BatchResult (..))
import Shared.Registration (RegistrationInput)
import Shared.SessionWorkflow (SessionEnvironment, SessionState)

processRegistrationBatch :: [RegistrationInput] -> SessionApp BatchResult
processRegistrationBatch inputs = finalize <$> traverse step inputs
  where
    step input = do
        outcome <- processRegistration input
        pure (input, outcome)

    finalize results =
        BatchResult
            { successfulRegistrations = [message | (_, Right message) <- results]
            , failedRegistrations = [(input, err) | (input, Left err) <- results]
            }

runBatchSessionWorkflow :: SessionEnvironment -> SessionState -> [RegistrationInput] -> IO (BatchResult, SessionState)
runBatchSessionWorkflow environment initialState inputs =
    runStateT (runReaderT (processRegistrationBatch inputs) environment) initialState
