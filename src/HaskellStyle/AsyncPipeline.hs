module HaskellStyle.AsyncPipeline
    ( PipelinePlan (..)
    , planUserPipeline
    , fetchProfile
    , renderPipelineResult
    , runUserPipeline
    ) where

import Control.Concurrent (threadDelay)
import Shared.AsyncPipeline (PipelineRequest (..), PipelineResult (PipelineResult), UserProfile (..))

data PipelinePlan = PipelinePlan
    { plannedUserId :: String
    }
    deriving (Eq, Show)

planUserPipeline :: PipelineRequest -> Either String PipelinePlan
planUserPipeline request
    | null (pipelineUserId request) = Left "User id is required."
    | otherwise = Right (PipelinePlan (pipelineUserId request))

fetchProfile :: PipelinePlan -> IO UserProfile
fetchProfile plan = do
    threadDelay 1000
    pure (UserProfile (plannedUserId plan) ("User-" ++ plannedUserId plan))

renderPipelineResult :: UserProfile -> IO PipelineResult
renderPipelineResult profile = do
    threadDelay 1000
    pure (PipelineResult ("Loaded profile for " ++ profileDisplayName profile))

runUserPipeline :: PipelineRequest -> IO (Either String PipelineResult)
runUserPipeline request =
    case planUserPipeline request of
        Left err -> pure (Left err)
        Right plan -> do
            profile <- fetchProfile plan
            result <- renderPipelineResult profile
            pure (Right result)
