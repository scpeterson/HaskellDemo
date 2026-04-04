module Shared.Registration
    ( RegistrationInput (..)
    , UserRecord (..)
    ) where

data RegistrationInput = RegistrationInput
    { registrationName :: String
    , registrationEmail :: String
    }
    deriving (Eq, Show)

data UserRecord = UserRecord
    { userName :: String
    , userEmail :: String
    }
    deriving (Eq, Show)
