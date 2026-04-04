module HaskellStyle.FeatureRegistration
    ( FeatureApp
    , planFeatureRegistration
    , executeFeatureCommands
    , runFeatureRegistration
    ) where

import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Control.Monad.State.Strict (State, get, modify', runState)
import Shared.FeatureRegistration
    ( FeatureCommand (AppendAuditLine, AppendWelcomeEmail)
    , FeatureEnvironment (..)
    , FeatureResult (..)
    , FeatureState (..)
    )
import Shared.Registration
    ( RegistrationInput (..)
    , UserRecord (..)
    )

type FeatureApp = ReaderT FeatureEnvironment (State FeatureState)

planFeatureRegistration :: RegistrationInput -> FeatureApp (Either String FeatureResult)
planFeatureRegistration input = do
    environment <- ask
    currentState <- get
    case validateInput environment currentState input of
        Left errorMessage -> pure (Left errorMessage)
        Right user -> do
            let auditNumber = featureNextAuditNumber currentState
            let auditLine = "registered #" ++ show auditNumber ++ ": " ++ userEmail user
            let welcomeMessage = featureWelcomePrefix environment ++ ", " ++ userName user ++ "!"
            let commands =
                    [ AppendAuditLine auditLine
                    , AppendWelcomeEmail welcomeMessage
                    ]
            modify'
                (\state ->
                    state
                        { featureRegisteredUsers = featureRegisteredUsers state ++ [user]
                        , featureNextAuditNumber = featureNextAuditNumber state + 1
                        })
            pure (Right (FeatureResult user welcomeMessage auditLine commands))

executeFeatureCommands :: FeatureEnvironment -> [FeatureCommand] -> IO ()
executeFeatureCommands environment = mapM_ (executeCommand environment)

executeCommand :: FeatureEnvironment -> FeatureCommand -> IO ()
executeCommand environment command =
    case command of
        AppendAuditLine line -> appendFile (featureAuditFilePath environment) (line ++ "\n")
        AppendWelcomeEmail message -> appendFile (featureWelcomeFilePath environment) (message ++ "\n")

runFeatureRegistration :: FeatureEnvironment -> FeatureState -> RegistrationInput -> IO (Either String FeatureResult, FeatureState)
runFeatureRegistration environment initialState input = do
    let (plannedResult, updatedState) = runState (runReaderT (planFeatureRegistration input) environment) initialState
    case plannedResult of
        Left errorMessage -> pure (Left errorMessage, updatedState)
        Right featureResult -> do
            executeFeatureCommands environment (featureCommands featureResult)
            pure (Right featureResult, updatedState)

validateInput :: FeatureEnvironment -> FeatureState -> RegistrationInput -> Either String UserRecord
validateInput environment currentState input
    | null (registrationName input) = Left "Name is required."
    | null (registrationEmail input) = Left "Email is required."
    | '@' `notElem` registrationEmail input = Left "Email must contain @."
    | not (matchesRequiredDomain (featureRequiredDomain environment) (registrationEmail input)) =
        Left ("Email must use the " ++ featureRequiredDomain environment ++ " domain.")
    | any ((== registrationEmail input) . userEmail) (featureRegisteredUsers currentState) =
        Left "Email already exists."
    | otherwise = Right (UserRecord (registrationName input) (registrationEmail input))

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
