module Baseline.RegistrationWorkflow
    ( registerUserStepByStep
    ) where

import Baseline.ValidationFlow (validateRegistrationStepByStep)
import Shared.Registration (RegistrationInput (..), UserRecord (..))

registerUserStepByStep :: [UserRecord] -> RegistrationInput -> Either String ([UserRecord], String)
registerUserStepByStep existingUsers input =
    case validateRegistrationStepByStep input of
        Left err -> Left err
        Right user ->
            if emailAlreadyExists existingUsers (userEmail user)
                then Left "Email already exists."
                else
                    let updatedUsers = existingUsers ++ [user]
                        message = "Registered user " ++ userName user
                     in Right (updatedUsers, message)

emailAlreadyExists :: [UserRecord] -> String -> Bool
emailAlreadyExists users targetEmail = any ((== targetEmail) . userEmail) users
