module Baseline.ValidationFlow
    ( validateRegistrationStepByStep
    ) where

import Shared.Registration (RegistrationInput (..), UserRecord (UserRecord))

validateRegistrationStepByStep :: RegistrationInput -> Either String UserRecord
validateRegistrationStepByStep input =
    let trimmedName = registrationName input
        trimmedEmail = registrationEmail input
     in if null trimmedName
            then Left "Name is required."
            else if '@' `notElem` trimmedEmail
                then Left "Email must contain @."
                else Right (UserRecord trimmedName trimmedEmail)
