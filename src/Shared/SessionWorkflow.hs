module Shared.SessionWorkflow
    ( SessionEnvironment (..)
    , SessionState (..)
    ) where

data SessionEnvironment = SessionEnvironment
    { sessionRequiredDomain :: String
    , sessionWelcomePrefix :: String
    , sessionAuditFilePath :: FilePath
    }
    deriving (Eq, Show)

data SessionState = SessionState
    { sessionProcessedCount :: Int
    , sessionAuditTrail :: [String]
    }
    deriving (Eq, Show)
