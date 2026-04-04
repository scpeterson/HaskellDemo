module Shared.BatchSessionWorkflow
    ( BatchResult (..)
    ) where

import Shared.Registration (RegistrationInput)

data BatchResult = BatchResult
    { successfulRegistrations :: [String]
    , failedRegistrations :: [(RegistrationInput, String)]
    }
    deriving (Eq, Show)
