module HaskellStyle.AsyncWorkflow
    ( planAsyncWorkflow
    , runPlannedAsyncWorkflow
    , runAsyncWorkflow
    ) where

import Control.Concurrent (threadDelay)
import Shared.AsyncWorkflow (AsyncRequest (..), AsyncResult (AsyncResult))

planAsyncWorkflow :: AsyncRequest -> Either String String
planAsyncWorkflow request
    | null (asyncName request) = Left "Name is required."
    | otherwise = Right (asyncName request)

runPlannedAsyncWorkflow :: String -> IO AsyncResult
runPlannedAsyncWorkflow validName = do
    threadDelay 1000
    pure (AsyncResult ("Async hello, " ++ validName ++ "!"))

runAsyncWorkflow :: AsyncRequest -> IO (Either String AsyncResult)
runAsyncWorkflow request =
    case planAsyncWorkflow request of
        Left err -> pure (Left err)
        Right validName -> Right <$> runPlannedAsyncWorkflow validName
