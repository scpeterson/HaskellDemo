module Baseline.AsyncWorkflow
    ( runAsyncWorkflowInline
    ) where

import Control.Concurrent (threadDelay)
import Shared.AsyncWorkflow (AsyncRequest (..), AsyncResult (AsyncResult))

runAsyncWorkflowInline :: AsyncRequest -> IO (Either String AsyncResult)
runAsyncWorkflowInline request =
    if null (asyncName request)
        then pure (Left "Name is required.")
        else do
            threadDelay 1000
            pure (Right (AsyncResult ("Async hello, " ++ asyncName request ++ "!")))
