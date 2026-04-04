module HaskellStyle.ValidationAccumulation
    ( ValidationResult
    , validateRegistrationAllErrors
    ) where

import Shared.Registration (RegistrationInput (..), UserRecord (UserRecord))

type ValidationResult a = Either [String] a

validateRegistrationAllErrors :: RegistrationInput -> ValidationResult UserRecord
validateRegistrationAllErrors input =
    case collectErrors input of
        [] -> Right (UserRecord (registrationName input) (registrationEmail input))
        errs -> Left errs

collectErrors :: RegistrationInput -> [String]
collectErrors input =
    concat
        [ validateName (registrationName input)
        , validateEmailFormat (registrationEmail input)
        , validateEmailLength (registrationEmail input)
        ]

validateName :: String -> [String]
validateName rawName
    | null rawName = ["Name is required."]
    | otherwise = []

validateEmailFormat :: String -> [String]
validateEmailFormat rawEmail
    | '@' `notElem` rawEmail = ["Email must contain @."]
    | otherwise = []

validateEmailLength :: String -> [String]
validateEmailLength rawEmail
    | length rawEmail < 6 = ["Email must be at least 6 characters."]
    | otherwise = []
