module Shared.AsyncPipeline
    ( PipelineRequest (..)
    , UserProfile (..)
    , PipelineResult (..)
    ) where

data PipelineRequest = PipelineRequest
    { pipelineUserId :: String
    }
    deriving (Eq, Show)

data UserProfile = UserProfile
    { profileUserId :: String
    , profileDisplayName :: String
    }
    deriving (Eq, Show)

data PipelineResult = PipelineResult
    { pipelineSummary :: String
    }
    deriving (Eq, Show)
