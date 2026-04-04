module HaskellStyle.RegistrationWorkflow
    ( registerUser
    ) where

import HaskellStyle.EitherValidation (validateRegistration)
import Shared.Registration (RegistrationInput, UserRecord (..))

registerUser :: [UserRecord] -> RegistrationInput -> Either String ([UserRecord], String)
registerUser existingUsers input = do
    user <- validateRegistration input
    ensureUniqueEmail existingUsers user
    let updatedUsers = existingUsers ++ [user]
    pure (updatedUsers, welcomeMessage user)

ensureUniqueEmail :: [UserRecord] -> UserRecord -> Either String ()
ensureUniqueEmail existingUsers user
    | any ((== userEmail user) . userEmail) existingUsers = Left "Email already exists."
    | otherwise = Right ()

welcomeMessage :: UserRecord -> String
welcomeMessage user = "Registered user " ++ userName user
