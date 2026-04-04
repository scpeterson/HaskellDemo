module Baseline.AsyncPipeline
    ( runUserPipelineInline
    ) where

import Control.Concurrent (threadDelay)
import Shared.AsyncPipeline (PipelineRequest (..), PipelineResult (PipelineResult), UserProfile (..))

runUserPipelineInline :: PipelineRequest -> IO (Either String PipelineResult)
runUserPipelineInline request =
    if null (pipelineUserId request)
        then pure (Left "User id is required.")
        else do
            threadDelay 1000
            let profile = UserProfile (pipelineUserId request) ("User-" ++ pipelineUserId request)
            threadDelay 1000
            let summary = "Loaded profile for " ++ profileDisplayName profile
            pure (Right (PipelineResult summary))
