module Shared.FeaturePasswordReset
    ( PasswordResetEnvironment (..)
    , PasswordResetState (..)
    , PasswordResetCommand (..)
    , PasswordResetResult (..)
    ) where

import Shared.Registration (UserRecord)

data PasswordResetEnvironment = PasswordResetEnvironment
    { resetRequiredDomain :: String
    , resetLinkBase :: String
    , resetAuditFilePath :: FilePath
    , resetEmailFilePath :: FilePath
    }
    deriving (Eq, Show)

data PasswordResetState = PasswordResetState
    { resetKnownUsers :: [UserRecord]
    , resetNextTokenNumber :: Int
    }
    deriving (Eq, Show)

data PasswordResetCommand
    = AppendResetAudit String
    | AppendResetEmail String
    deriving (Eq, Show)

data PasswordResetResult = PasswordResetResult
    { resetUserEmail :: String
    , resetToken :: String
    , resetLink :: String
    , resetAuditLine :: String
    , resetCommands :: [PasswordResetCommand]
    }
    deriving (Eq, Show)
