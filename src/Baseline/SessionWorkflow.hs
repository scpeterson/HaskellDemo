module Baseline.SessionWorkflow
    ( processRegistrationInline
    ) where

import Shared.Registration (RegistrationInput (..))
import Shared.SessionWorkflow (SessionEnvironment (..), SessionState (..))

processRegistrationInline :: SessionEnvironment -> SessionState -> RegistrationInput -> IO (Either String (SessionState, String))
processRegistrationInline environment state input
    | null (registrationName input) = pure (Left "Name is required.")
    | not (matchesRequiredDomain (sessionRequiredDomain environment) (registrationEmail input)) =
        pure (Left ("Email must use the " ++ sessionRequiredDomain environment ++ " domain."))
    | otherwise = do
        let newCount = sessionProcessedCount state + 1
        let welcomeMessage = sessionWelcomePrefix environment ++ ", " ++ registrationName input ++ "!"
        let auditEntry = "processed #" ++ show newCount ++ ": " ++ registrationEmail input
        appendFile (sessionAuditFilePath environment) (auditEntry ++ "\n")
        let nextState =
                SessionState
                    { sessionProcessedCount = newCount
                    , sessionAuditTrail = sessionAuditTrail state ++ [auditEntry]
                    }
        pure (Right (nextState, welcomeMessage))

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
