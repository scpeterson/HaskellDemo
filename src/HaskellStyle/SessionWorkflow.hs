module HaskellStyle.SessionWorkflow
    ( SessionApp
    , processRegistration
    , runSessionWorkflow
    ) where

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Control.Monad.State.Strict (StateT, get, modify', runStateT)
import Shared.Registration (RegistrationInput (..))
import Shared.SessionWorkflow (SessionEnvironment (..), SessionState (..))

type SessionApp = ReaderT SessionEnvironment (StateT SessionState IO)

processRegistration :: RegistrationInput -> SessionApp (Either String String)
processRegistration input
    | null (registrationName input) = pure (Left "Name is required.")
    | otherwise = do
        environment <- ask
        if not (matchesRequiredDomain (sessionRequiredDomain environment) (registrationEmail input))
            then pure (Left ("Email must use the " ++ sessionRequiredDomain environment ++ " domain."))
            else do
                currentState <- get
                let newCount = sessionProcessedCount currentState + 1
                let welcomeMessage = sessionWelcomePrefix environment ++ ", " ++ registrationName input ++ "!"
                let auditEntry = "processed #" ++ show newCount ++ ": " ++ registrationEmail input
                liftIO (appendFile (sessionAuditFilePath environment) (auditEntry ++ "\n"))
                modify' (\state ->
                    state
                        { sessionProcessedCount = newCount
                        , sessionAuditTrail = sessionAuditTrail state ++ [auditEntry]
                        })
                pure (Right welcomeMessage)

runSessionWorkflow :: SessionEnvironment -> SessionState -> RegistrationInput -> IO (Either String String, SessionState)
runSessionWorkflow environment initialState input = runStateT (runReaderT (processRegistration input) environment) initialState

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
