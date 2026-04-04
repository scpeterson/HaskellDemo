module HaskellStyle.EitherValidation
    ( validateRegistration
    ) where

import Shared.Registration (RegistrationInput (..), UserRecord (UserRecord))

validateRegistration :: RegistrationInput -> Either String UserRecord
validateRegistration input = do
    validName <- requireName (registrationName input)
    validEmail <- requireEmail (registrationEmail input)
    pure (UserRecord validName validEmail)

requireName :: String -> Either String String
requireName rawName
    | null rawName = Left "Name is required."
    | otherwise = Right rawName

requireEmail :: String -> Either String String
requireEmail rawEmail
    | '@' `notElem` rawEmail = Left "Email must contain @."
    | otherwise = Right rawEmail
