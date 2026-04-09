module App.TerminalOutput
    ( printComparisonHeader
    , printBlock
    , formatUserValidationResult
    , formatRegistrationWorkflowResult
    , formatAsyncResult
    , formatPipelineResult
    , formatCounterReport
    , formatInlineSessionResult
    , formatStateSessionResult
    , formatBatchWorkflow
    , formatInlineFeatureResult
    , formatStateFeatureResult
    , formatInlinePasswordResetResult
    , formatStatePasswordResetResult
    , formatInlineStartupResult
    , formatStateStartupResult
    , formatRetryOutcome
    ) where

import Shared.AsyncPipeline (PipelineResult (..))
import Shared.AsyncWorkflow (AsyncResult (..))
import Shared.BatchSessionWorkflow (BatchResult (..))
import Shared.CounterState (CounterReport (..), CounterState (..))
import Shared.FeatureConfigurationStartup
    ( StartupCommand (..)
    , StartupResult (..)
    , StartupState (..)
    , ValidatedStartupConfig (..)
    )
import Shared.FeaturePasswordReset
    ( PasswordResetCommand (..)
    , PasswordResetResult (..)
    , PasswordResetState (..)
    )
import Shared.FeatureRegistration
    ( FeatureCommand (..)
    , FeatureResult (..)
    , FeatureState (..)
    )
import Shared.Registration (RegistrationInput (RegistrationInput), UserRecord (UserRecord))
import Shared.RetryBackoff (RetryOutcome (..))
import Shared.SessionWorkflow (SessionState (..))

printComparisonHeader :: String -> IO ()
printComparisonHeader title = do
    putStrLn ""
    putStrLn comparisonDivider
    putStrLn title
    putStrLn comparisonDivider
    putStrLn ""

comparisonDivider :: String
comparisonDivider = replicate 58 '='

printBlock :: String -> [String] -> IO ()
printBlock label linesToPrint = do
    putStrLn $ label ++ ":"
    mapM_ (putStrLn . ("  " ++)) linesToPrint

formatUserValidationResult :: Either String UserRecord -> [String]
formatUserValidationResult (Left err) = ["status: error", "reason: " ++ err]
formatUserValidationResult (Right user) = ["status: success", "user: " ++ formatUserRecord user]

formatRegistrationWorkflowResult :: Either String ([UserRecord], String) -> [String]
formatRegistrationWorkflowResult (Left err) = ["status: error", "reason: " ++ err]
formatRegistrationWorkflowResult (Right (users, message)) =
    [ "status: success"
    , "message: " ++ message
    , "registered users:"
    ] ++ indent (map formatUserRecord users)

formatAsyncResult :: Either String AsyncResult -> [String]
formatAsyncResult (Left err) = ["status: error", "reason: " ++ err]
formatAsyncResult (Right result) = ["status: success", "message: " ++ asyncMessage result]

formatPipelineResult :: Either String PipelineResult -> [String]
formatPipelineResult (Left err) = ["status: error", "reason: " ++ err]
formatPipelineResult (Right result) = ["status: success", "summary: " ++ pipelineSummary result]

formatCounterReport :: CounterReport -> [String]
formatCounterReport report =
    [ "final value: " ++ show (counterValue (finalState report))
    , "applied steps:"
    ] ++ indent (formatStringList (appliedSteps report))

formatInlineSessionResult :: Either String (SessionState, String) -> [String]
formatInlineSessionResult (Left err) = ["status: error", "reason: " ++ err]
formatInlineSessionResult (Right (state, message)) =
    [ "status: success"
    , "message: " ++ message
    ] ++ formatSessionStateBlock state

formatStateSessionResult :: (Either String String, SessionState) -> [String]
formatStateSessionResult (result, state) =
    case result of
        Left err ->
            [ "status: error"
            , "reason: " ++ err
            ] ++ formatSessionStateBlock state
        Right message ->
            [ "status: success"
            , "message: " ++ message
            ] ++ formatSessionStateBlock state

formatBatchWorkflow :: (BatchResult, SessionState) -> [String]
formatBatchWorkflow (batchResult, state) =
    [ "successful registrations:"
    ] ++ indent (formatSuccessfulRegistrations (successfulRegistrations batchResult))
        ++ [ "failed registrations:" ]
        ++ indent (formatFailedRegistrations (failedRegistrations batchResult))
        ++ formatSessionStateBlock state

formatInlineFeatureResult :: Either String (FeatureResult, FeatureState) -> [String]
formatInlineFeatureResult (Left err) = ["status: error", "reason: " ++ err]
formatInlineFeatureResult (Right (result, state)) =
    ["status: success"]
        ++ formatFeatureResultBlock result
        ++ formatFeatureStateBlock state

formatStateFeatureResult :: (Either String FeatureResult, FeatureState) -> [String]
formatStateFeatureResult (result, state) =
    case result of
        Left err -> ["status: error", "reason: " ++ err] ++ formatFeatureStateBlock state
        Right success -> ["status: success"] ++ formatFeatureResultBlock success ++ formatFeatureStateBlock state

formatInlinePasswordResetResult :: Either String (PasswordResetResult, PasswordResetState) -> [String]
formatInlinePasswordResetResult (Left err) = ["status: error", "reason: " ++ err]
formatInlinePasswordResetResult (Right (result, state)) =
    ["status: success"]
        ++ formatPasswordResetResultBlock result
        ++ formatPasswordResetStateBlock state

formatStatePasswordResetResult :: (Either String PasswordResetResult, PasswordResetState) -> [String]
formatStatePasswordResetResult (result, state) =
    case result of
        Left err -> ["status: error", "reason: " ++ err] ++ formatPasswordResetStateBlock state
        Right success -> ["status: success"] ++ formatPasswordResetResultBlock success ++ formatPasswordResetStateBlock state

formatInlineStartupResult :: Either [String] (StartupResult, StartupState) -> [String]
formatInlineStartupResult (Left errs) = ["status: error", "reasons:"] ++ indent (formatStringList errs)
formatInlineStartupResult (Right (result, state)) =
    ["status: success"]
        ++ formatStartupResultBlock result
        ++ formatStartupStateBlock state

formatStateStartupResult :: (Either [String] StartupResult, StartupState) -> [String]
formatStateStartupResult (result, state) =
    case result of
        Left errs -> ["status: error", "reasons:"] ++ indent (formatStringList errs) ++ formatStartupStateBlock state
        Right success -> ["status: success"] ++ formatStartupResultBlock success ++ formatStartupStateBlock state

formatRetryOutcome :: RetryOutcome -> [String]
formatRetryOutcome outcome =
    [ "status: " ++ retryStatus outcome
    , "message: " ++ retryMessage outcome
    , "attempts used: " ++ show (retryAttemptsUsed outcome)
    , "delay history:"
    ] ++ indent (formatDelayHistory (retryDelayHistoryUsed outcome))
        ++ [ "failure log:" ]
        ++ indent (formatStringList (retryFailureLogUsed outcome))

formatDelayHistory :: [Int] -> [String]
formatDelayHistory [] = ["(none)"]
formatDelayHistory values = map (<> "ms") (map show values)

formatSessionStateBlock :: SessionState -> [String]
formatSessionStateBlock state =
    [ "state:"
    ] ++ indent
        [ "processed count: " ++ show (sessionProcessedCount state)
        , "audit trail:"
        ]
        ++ indent (indent (formatStringList (sessionAuditTrail state)))

formatFeatureResultBlock :: FeatureResult -> [String]
formatFeatureResultBlock result =
    [ "result:"
    ] ++ indent
        [ "registered user: " ++ formatUserRecord (featureRegisteredUser result)
        , "welcome message: " ++ featureWelcomeMessage result
        , "audit line: " ++ featureAuditLine result
        , "commands:"
        ]
        ++ indent (indent (formatFeatureCommands (featureCommands result)))

formatFeatureStateBlock :: FeatureState -> [String]
formatFeatureStateBlock state =
    [ "state:"
    ] ++ indent
        [ "registered users:"
        ]
        ++ indent (indent (map formatUserRecord (featureRegisteredUsers state)))
        ++ indent ["next audit number: " ++ show (featureNextAuditNumber state)]

formatPasswordResetResultBlock :: PasswordResetResult -> [String]
formatPasswordResetResultBlock result =
    [ "result:"
    ] ++ indent
        [ "user email: " ++ resetUserEmail result
        , "token: " ++ resetToken result
        , "reset link: " ++ resetLink result
        , "audit line: " ++ resetAuditLine result
        , "commands:"
        ]
        ++ indent (indent (formatPasswordResetCommands (resetCommands result)))

formatPasswordResetStateBlock :: PasswordResetState -> [String]
formatPasswordResetStateBlock state =
    [ "state:"
    ] ++ indent
        [ "known users:"
        ]
        ++ indent (indent (map formatUserRecord (resetKnownUsers state)))
        ++ indent ["next token number: " ++ show (resetNextTokenNumber state)]

formatStartupResultBlock :: StartupResult -> [String]
formatStartupResultBlock result =
    [ "result:"
    ] ++ indent
        [ "validated config:"
        ]
        ++ indent (indent (formatValidatedStartupConfig (startupConfig result)))
        ++ indent
            [ "audit line: " ++ startupAuditLine result
            , "commands:"
            ]
        ++ indent (indent (formatStartupCommands (startupCommands result)))

formatStartupStateBlock :: StartupState -> [String]
formatStartupStateBlock state =
    [ "state:"
    ] ++ indent
        [ "started applications:"
        ]
        ++ indent (indent (formatStringList (startedApplications state)))
        ++ indent ["next audit number: " ++ show (startupNextAuditNumber state)]

formatValidatedStartupConfig :: ValidatedStartupConfig -> [String]
formatValidatedStartupConfig config =
    [ "app name: " ++ validatedAppName config
    , "environment: " ++ validatedEnvironmentName config
    , "database url: " ++ validatedDatabaseUrl config
    , "port: " ++ show (validatedPort config)
    , "log level: " ++ validatedLogLevel config
    ]

formatFeatureCommands :: [FeatureCommand] -> [String]
formatFeatureCommands [] = ["(none)"]
formatFeatureCommands commands = map formatFeatureCommand commands

formatFeatureCommand :: FeatureCommand -> String
formatFeatureCommand (AppendAuditLine line) = "AppendAuditLine: " ++ line
formatFeatureCommand (AppendWelcomeEmail message) = "AppendWelcomeEmail: " ++ message

formatPasswordResetCommands :: [PasswordResetCommand] -> [String]
formatPasswordResetCommands [] = ["(none)"]
formatPasswordResetCommands commands = map formatPasswordResetCommand commands

formatPasswordResetCommand :: PasswordResetCommand -> String
formatPasswordResetCommand (AppendResetAudit line) = "AppendResetAudit: " ++ line
formatPasswordResetCommand (AppendResetEmail body) = "AppendResetEmail: " ++ body

formatStartupCommands :: [StartupCommand] -> [String]
formatStartupCommands [] = ["(none)"]
formatStartupCommands commands = map formatStartupCommand commands

formatStartupCommand :: StartupCommand -> String
formatStartupCommand (AppendStartupAudit line) = "AppendStartupAudit: " ++ line

formatSuccessfulRegistrations :: [String] -> [String]
formatSuccessfulRegistrations [] = ["(none)"]
formatSuccessfulRegistrations values = values

formatFailedRegistrations :: [(RegistrationInput, String)] -> [String]
formatFailedRegistrations [] = ["(none)"]
formatFailedRegistrations failures = map formatFailedRegistration failures

formatFailedRegistration :: (RegistrationInput, String) -> String
formatFailedRegistration (RegistrationInput name email, reason) =
    displayName ++ " <" ++ email ++ "> -> " ++ reason
  where
    displayName = if null name then "(blank name)" else name

formatStringList :: [String] -> [String]
formatStringList [] = ["(none)"]
formatStringList values = values

formatUserRecord :: UserRecord -> String
formatUserRecord (UserRecord name email) = name ++ " <" ++ email ++ ">"

indent :: [String] -> [String]
indent = map ("  " ++)
