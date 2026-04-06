module HaskellStyle.FeaturePasswordReset
    ( PasswordResetApp
    , planPasswordReset
    , executePasswordResetCommands
    , runPasswordReset
    ) where

import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Control.Monad.State.Strict (State, get, modify', runState)
import Shared.FeaturePasswordReset
    ( PasswordResetCommand (AppendResetAudit, AppendResetEmail)
    , PasswordResetEnvironment (..)
    , PasswordResetResult (..)
    , PasswordResetState (..)
    )
import Shared.Registration (UserRecord (..))

type PasswordResetApp = ReaderT PasswordResetEnvironment (State PasswordResetState)

planPasswordReset :: String -> PasswordResetApp (Either String PasswordResetResult)
planPasswordReset email = do
    environment <- ask
    currentState <- get
    case validateRequest environment currentState email of
        Left errorMessage -> pure (Left errorMessage)
        Right _user -> do
            let tokenNumber = resetNextTokenNumber currentState
            let token = "reset-" ++ show tokenNumber
            let link = resetLinkBase environment ++ "/" ++ token
            let auditLine = "password-reset #" ++ show tokenNumber ++ ": " ++ email
            let emailBody = "Reset link for " ++ email ++ ": " ++ link
            let commands =
                    [ AppendResetAudit auditLine
                    , AppendResetEmail emailBody
                    ]
            modify' (\state -> state { resetNextTokenNumber = resetNextTokenNumber state + 1 })
            pure (Right (PasswordResetResult email token link auditLine commands))

executePasswordResetCommands :: PasswordResetEnvironment -> [PasswordResetCommand] -> IO ()
executePasswordResetCommands environment = mapM_ (executeCommand environment)

executeCommand :: PasswordResetEnvironment -> PasswordResetCommand -> IO ()
executeCommand environment command =
    case command of
        AppendResetAudit line -> appendFile (resetAuditFilePath environment) (line ++ "\n")
        AppendResetEmail message -> appendFile (resetEmailFilePath environment) (message ++ "\n")

runPasswordReset :: PasswordResetEnvironment -> PasswordResetState -> String -> IO (Either String PasswordResetResult, PasswordResetState)
runPasswordReset environment initialState email = do
    let (plannedResult, updatedState) = runState (runReaderT (planPasswordReset email) environment) initialState
    case plannedResult of
        Left errorMessage -> pure (Left errorMessage, updatedState)
        Right resetResult -> do
            executePasswordResetCommands environment (resetCommands resetResult)
            pure (Right resetResult, updatedState)

validateRequest :: PasswordResetEnvironment -> PasswordResetState -> String -> Either String UserRecord
validateRequest environment currentState email
    | null email = Left "Email is required."
    | '@' `notElem` email = Left "Email must contain @."
    | not (matchesRequiredDomain (resetRequiredDomain environment) email) =
        Left ("Email must use the " ++ resetRequiredDomain environment ++ " domain.")
    | otherwise =
        case lookupUser email (resetKnownUsers currentState) of
            Nothing -> Left "User was not found."
            Just user -> Right user

lookupUser :: String -> [UserRecord] -> Maybe UserRecord
lookupUser email = go
  where
    go [] = Nothing
    go (user : users)
        | userEmail user == email = Just user
        | otherwise = go users

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
