module Baseline.ReaderWorkflow
    ( renderWelcomeExplicit
    ) where

import Shared.AppEnvironment (AppEnvironment (..))
import Shared.Registration (RegistrationInput (..))

renderWelcomeExplicit :: AppEnvironment -> RegistrationInput -> Either String String
renderWelcomeExplicit environment input
    | null (registrationName input) = Left "Name is required."
    | not (matchesRequiredDomain environment (registrationEmail input)) =
        Left ("Email must use the " ++ requiredEmailDomain environment ++ " domain.")
    | otherwise = Right (welcomePrefix environment ++ ", " ++ registrationName input ++ "!")

matchesRequiredDomain :: AppEnvironment -> String -> Bool
matchesRequiredDomain environment email =
    let domain = "@" ++ requiredEmailDomain environment
     in domain `suffixOf` email

suffixOf :: Eq a => [a] -> [a] -> Bool
suffixOf suffix value = reverse suffix `prefixOf` reverse value

prefixOf :: Eq a => [a] -> [a] -> Bool
prefixOf [] _ = True
prefixOf _ [] = False
prefixOf (x : xs) (y : ys) = x == y && prefixOf xs ys
