module Baseline.ValidationAccumulation
    ( validateRegistrationFirstError
    ) where

import Shared.Registration (RegistrationInput (..), UserRecord (UserRecord))

validateRegistrationFirstError :: RegistrationInput -> Either String UserRecord
validateRegistrationFirstError input
    | null (registrationName input) = Left "Name is required."
    | '@' `notElem` registrationEmail input = Left "Email must contain @."
    | length (registrationEmail input) < 6 = Left "Email must be at least 6 characters."
    | otherwise = Right (UserRecord (registrationName input) (registrationEmail input))
