module Shared.FeatureConfigurationStartup
    ( StartupEnvironment (..)
    , RawStartupConfig (..)
    , ValidatedStartupConfig (..)
    , StartupState (..)
    , StartupCommand (..)
    , StartupResult (..)
    ) where

data StartupEnvironment = StartupEnvironment
    { startupExpectedEnvironment :: String
    , startupAuditFilePath :: FilePath
    }
    deriving (Eq, Show)

data RawStartupConfig = RawStartupConfig
    { rawAppName :: String
    , rawEnvironmentName :: String
    , rawDatabaseUrl :: String
    , rawPortText :: String
    , rawLogLevel :: String
    }
    deriving (Eq, Show)

data ValidatedStartupConfig = ValidatedStartupConfig
    { validatedAppName :: String
    , validatedEnvironmentName :: String
    , validatedDatabaseUrl :: String
    , validatedPort :: Int
    , validatedLogLevel :: String
    }
    deriving (Eq, Show)

data StartupState = StartupState
    { startedApplications :: [String]
    , startupNextAuditNumber :: Int
    }
    deriving (Eq, Show)

data StartupCommand
    = AppendStartupAudit String
    deriving (Eq, Show)

data StartupResult = StartupResult
    { startupConfig :: ValidatedStartupConfig
    , startupAuditLine :: String
    , startupCommands :: [StartupCommand]
    }
    deriving (Eq, Show)
