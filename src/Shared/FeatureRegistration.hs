module Shared.FeatureRegistration
    ( FeatureEnvironment (..)
    , FeatureState (..)
    , FeatureCommand (..)
    , FeatureResult (..)
    ) where

import Shared.Registration (UserRecord)

data FeatureEnvironment = FeatureEnvironment
    { featureRequiredDomain :: String
    , featureWelcomePrefix :: String
    , featureAuditFilePath :: FilePath
    , featureWelcomeFilePath :: FilePath
    }
    deriving (Eq, Show)

data FeatureState = FeatureState
    { featureRegisteredUsers :: [UserRecord]
    , featureNextAuditNumber :: Int
    }
    deriving (Eq, Show)

data FeatureCommand
    = AppendAuditLine String
    | AppendWelcomeEmail String
    deriving (Eq, Show)

data FeatureResult = FeatureResult
    { featureRegisteredUser :: UserRecord
    , featureWelcomeMessage :: String
    , featureAuditLine :: String
    , featureCommands :: [FeatureCommand]
    }
    deriving (Eq, Show)
