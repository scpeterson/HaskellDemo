module Baseline.FeaturePasswordReset
    ( requestPasswordResetInline
    ) where

import Shared.FeaturePasswordReset
    ( PasswordResetCommand (AppendResetAudit, AppendResetEmail)
    , PasswordResetEnvironment (..)
    , PasswordResetResult (..)
    , PasswordResetState (..)
    )
import Shared.Registration (UserRecord (..))

requestPasswordResetInline :: PasswordResetEnvironment -> PasswordResetState -> String -> IO (Either String (PasswordResetResult, PasswordResetState))
requestPasswordResetInline environment currentState email =
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
            executeCommands environment commands
            let updatedState =
                    currentState
                        { resetNextTokenNumber = tokenNumber + 1
                        }
            pure
                ( Right
                    ( PasswordResetResult email token link auditLine commands
                    , updatedState
                    )
                )

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

executeCommands :: PasswordResetEnvironment -> [PasswordResetCommand] -> IO ()
executeCommands environment = mapM_ (executeCommand environment)

executeCommand :: PasswordResetEnvironment -> PasswordResetCommand -> IO ()
executeCommand environment command =
    case command of
        AppendResetAudit line -> appendFile (resetAuditFilePath environment) (line ++ "\n")
        AppendResetEmail message -> appendFile (resetEmailFilePath environment) (message ++ "\n")

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
