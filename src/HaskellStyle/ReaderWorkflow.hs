module HaskellStyle.ReaderWorkflow
    ( renderWelcome
    , runWelcome
    ) where

import Control.Monad.Reader (Reader, asks, runReader)
import Shared.AppEnvironment (AppEnvironment (..))
import Shared.Registration (RegistrationInput (..))

renderWelcome :: RegistrationInput -> Reader AppEnvironment (Either String String)
renderWelcome input
    | null (registrationName input) = pure (Left "Name is required.")
    | otherwise = do
        requiredDomain <- asks requiredEmailDomain
        prefix <- asks welcomePrefix
        pure $
            if matchesRequiredDomain requiredDomain (registrationEmail input)
                then Right (prefix ++ ", " ++ registrationName input ++ "!")
                else Left ("Email must use the " ++ requiredDomain ++ " domain.")

runWelcome :: AppEnvironment -> RegistrationInput -> Either String String
runWelcome environment input = runReader (renderWelcome input) environment

matchesRequiredDomain :: String -> String -> Bool
matchesRequiredDomain requiredDomain email =
    let domain = "@" ++ requiredDomain
     in domain `suffixOf` email

suffixOf :: Eq a => [a] -> [a] -> Bool
suffixOf suffix value = reverse suffix `prefixOf` reverse value

prefixOf :: Eq a => [a] -> [a] -> Bool
prefixOf [] _ = True
prefixOf _ [] = False
prefixOf (x : xs) (y : ys) = x == y && prefixOf xs ys
