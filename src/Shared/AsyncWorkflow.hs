module Shared.AsyncWorkflow
    ( AsyncRequest (..)
    , AsyncResult (..)
    ) where

data AsyncRequest = AsyncRequest
    { asyncName :: String
    }
    deriving (Eq, Show)

data AsyncResult = AsyncResult
    { asyncMessage :: String
    }
    deriving (Eq, Show)
