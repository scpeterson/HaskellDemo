module Main where

import Baseline.AsyncPipeline (runUserPipelineInline)
import Baseline.AsyncWorkflow (runAsyncWorkflowInline)
import Baseline.BatchSessionWorkflow (processRegistrationBatchInline)
import Baseline.EffectsBoundary (saveGreetingInline)
import Baseline.FeatureConfigurationStartup (startApplicationInline)
import Baseline.FeaturePasswordReset (requestPasswordResetInline)
import Baseline.FeatureRegistration (registerFeatureInline)
import Baseline.OptionLike (imperativeFindEmail)
import Baseline.ReaderWorkflow (renderWelcomeExplicit)
import Baseline.RegistrationWorkflow (registerUserStepByStep)
import Baseline.SessionWorkflow (processRegistrationInline)
import Baseline.StateWorkflow (runCounterProgramStepByStep)
import Baseline.StreamingNumbers (firstThreeLargeEvenSquaresFromRange)
import Baseline.ValidationAccumulation (validateRegistrationFirstError)
import Baseline.ValidationFlow (validateRegistrationStepByStep)
import HaskellStyle.AsyncPipeline (runUserPipeline)
import HaskellStyle.AsyncWorkflow (runAsyncWorkflow)
import HaskellStyle.BatchSessionWorkflow (runBatchSessionWorkflow)
import HaskellStyle.EffectsBoundary (saveGreetingWithBoundary)
import HaskellStyle.EitherValidation (validateRegistration)
import HaskellStyle.FeatureConfigurationStartup (runStartup)
import HaskellStyle.FeaturePasswordReset (runPasswordReset)
import HaskellStyle.FeatureRegistration (runFeatureRegistration)
import HaskellStyle.MaybePipeline (findEmail)
import HaskellStyle.ReaderWorkflow (runWelcome)
import HaskellStyle.RegistrationWorkflow (registerUser)
import HaskellStyle.SessionWorkflow (runSessionWorkflow)
import HaskellStyle.StateMonadWorkflow (applyProgramWithState)
import HaskellStyle.StateWorkflow (applyProgram)
import HaskellStyle.StreamingNumbers (firstThreeLargeEvenSquares)
import HaskellStyle.ValidationAccumulation (validateRegistrationAllErrors)
import Shared.AppEnvironment (AppEnvironment (AppEnvironment))
import Shared.AsyncPipeline (PipelineRequest (PipelineRequest), PipelineResult (..))
import Shared.AsyncWorkflow (AsyncRequest (AsyncRequest), AsyncResult (..))
import Shared.BatchSessionWorkflow (BatchResult (..))
import Shared.CounterState (CounterCommand (Add, Increment), CounterReport (..), CounterState (..))
import Shared.FeatureConfigurationStartup
    ( RawStartupConfig (..)
    , StartupCommand (..)
    , StartupEnvironment (StartupEnvironment)
    , StartupResult (..)
    , StartupState (..)
    , ValidatedStartupConfig (..)
    )
import Shared.FeaturePasswordReset
    ( PasswordResetCommand (..)
    , PasswordResetEnvironment (PasswordResetEnvironment)
    , PasswordResetResult (..)
    , PasswordResetState (..)
    )
import Shared.FeatureRegistration
    ( FeatureCommand (..)
    , FeatureEnvironment (FeatureEnvironment)
    , FeatureResult (..)
    , FeatureState (..)
    )
import Shared.Person (Person (Person), prettyPerson)
import Shared.Registration (RegistrationInput (RegistrationInput), UserRecord (UserRecord))
import Shared.SessionWorkflow (SessionEnvironment (SessionEnvironment), SessionState (..))

samplePeople :: [Person]
samplePeople =
    [ Person "Alice" (Just "alice@example.com")
    , Person "Bob" Nothing
    , Person "Cara" (Just "cara@example.com")
    ]

validRegistration :: RegistrationInput
validRegistration = RegistrationInput "Dora" "dora@example.com"

invalidRegistration :: RegistrationInput
invalidRegistration = RegistrationInput "" "broken-email"

existingUsers :: [UserRecord]
existingUsers =
    [ UserRecord "Alice" "alice@example.com"
    , UserRecord "Bob" "bob@example.com"
    ]

duplicateRegistration :: RegistrationInput
duplicateRegistration = RegistrationInput "Alice Again" "alice@example.com"

badAccumulationInput :: RegistrationInput
badAccumulationInput = RegistrationInput "" "x"

inlineGreetingPath :: FilePath
inlineGreetingPath = "/tmp/haskelldemo-inline-greeting.txt"

boundaryGreetingPath :: FilePath
boundaryGreetingPath = "/tmp/haskelldemo-boundary-greeting.txt"

sessionAuditPath :: FilePath
sessionAuditPath = "/tmp/haskelldemo-session-audit.txt"

batchSessionAuditPath :: FilePath
batchSessionAuditPath = "/tmp/haskelldemo-session-batch-audit.txt"

featureAuditPath :: FilePath
featureAuditPath = "/tmp/haskelldemo-feature-audit.txt"

featureWelcomePath :: FilePath
featureWelcomePath = "/tmp/haskelldemo-feature-welcome.txt"

passwordResetAuditPath :: FilePath
passwordResetAuditPath = "/tmp/haskelldemo-password-reset-audit.txt"

passwordResetEmailPath :: FilePath
passwordResetEmailPath = "/tmp/haskelldemo-password-reset-email.txt"

startupAuditPath :: FilePath
startupAuditPath = "/tmp/haskelldemo-startup-audit.txt"

asyncRequest :: AsyncRequest
asyncRequest = AsyncRequest "Dora"

pipelineRequest :: PipelineRequest
pipelineRequest = PipelineRequest "42"

counterCommands :: [CounterCommand]
counterCommands = [Increment, Add 4, Increment]

appEnvironment :: AppEnvironment
appEnvironment = AppEnvironment "example.com" "Welcome"

sessionEnvironment :: SessionEnvironment
sessionEnvironment = SessionEnvironment "example.com" "Welcome" sessionAuditPath

batchSessionEnvironment :: SessionEnvironment
batchSessionEnvironment = SessionEnvironment "example.com" "Welcome" batchSessionAuditPath

initialSessionState :: SessionState
initialSessionState = SessionState 0 []

batchRegistrations :: [RegistrationInput]
batchRegistrations =
    [ RegistrationInput "Dora" "dora@example.com"
    , RegistrationInput "" "broken@example.com"
    , RegistrationInput "Evan" "evan@example.com"
    ]

featureEnvironment :: FeatureEnvironment
featureEnvironment = FeatureEnvironment "example.com" "Welcome" featureAuditPath featureWelcomePath

initialFeatureState :: FeatureState
initialFeatureState = FeatureState existingUsers 3

passwordResetEnvironment :: PasswordResetEnvironment
passwordResetEnvironment = PasswordResetEnvironment "example.com" "https://example.com/reset" passwordResetAuditPath passwordResetEmailPath

initialPasswordResetState :: PasswordResetState
initialPasswordResetState = PasswordResetState existingUsers 5

startupEnvironment :: StartupEnvironment
startupEnvironment = StartupEnvironment "production" startupAuditPath

initialStartupState :: StartupState
initialStartupState = StartupState [] 7

validStartupConfig :: RawStartupConfig
validStartupConfig =
    RawStartupConfig
        { rawAppName = "haskelldemo-service"
        , rawEnvironmentName = "production"
        , rawDatabaseUrl = "postgres://db.example.com/haskelldemo"
        , rawPortText = "8080"
        , rawLogLevel = "info"
        }

main :: IO ()
main = do
    putStrLn "HaskellDemo"
    putStrLn "==========="
    printComparisonHeader "Comparison 1: option-style lookup using Maybe"

    mapM_ (putStrLn . prettyPerson) samplePeople
    putStrLn ""
    putStrLn $ "imperative-style Bob lookup: " ++ show (imperativeFindEmail "Bob" samplePeople)
    putStrLn $ "haskell-style Alice lookup:  " ++ show (findEmail "Alice" samplePeople)
    putStrLn $ "haskell-style Dana lookup:   " ++ show (findEmail "Dana" samplePeople)
    printComparisonHeader "Comparison 2: validation using Either"
    printBlock "baseline valid registration" (formatUserValidationResult (validateRegistrationStepByStep validRegistration))
    printBlock "haskell valid registration" (formatUserValidationResult (validateRegistration validRegistration))
    printBlock "haskell invalid registration" (formatUserValidationResult (validateRegistration invalidRegistration))
    printComparisonHeader "Comparison 3: registration workflow"
    printBlock "baseline new user registration" (formatRegistrationWorkflowResult (registerUserStepByStep existingUsers validRegistration))
    printBlock "haskell new user registration" (formatRegistrationWorkflowResult (registerUser existingUsers validRegistration))
    printBlock "haskell duplicate rejection" (formatRegistrationWorkflowResult (registerUser existingUsers duplicateRegistration))
    printComparisonHeader "Comparison 4: validation accumulation"
    putStrLn $ "baseline first error:       " ++ show (validateRegistrationFirstError badAccumulationInput)
    putStrLn $ "haskell accumulated errors: " ++ show (validateRegistrationAllErrors badAccumulationInput)
    printComparisonHeader "Comparison 5: effects and IO boundaries"
    inlineResult <- saveGreetingInline inlineGreetingPath "Dora"
    boundaryResult <- saveGreetingWithBoundary boundaryGreetingPath "Dora"
    putStrLn $ "baseline inline IO:       " ++ show inlineResult
    putStrLn $ "haskell IO boundary flow: " ++ show boundaryResult
    printComparisonHeader "Comparison 6: async workflow"
    baselineAsync <- runAsyncWorkflowInline asyncRequest
    haskellAsync <- runAsyncWorkflow asyncRequest
    printBlock "baseline async flow" (formatAsyncResult baselineAsync)
    printBlock "haskell async composition" (formatAsyncResult haskellAsync)
    printComparisonHeader "Comparison 7: richer async pipeline"
    baselinePipeline <- runUserPipelineInline pipelineRequest
    haskellPipeline <- runUserPipeline pipelineRequest
    printBlock "baseline pipeline" (formatPipelineResult baselinePipeline)
    printBlock "haskell pipeline" (formatPipelineResult haskellPipeline)
    printComparisonHeader "Comparison 8: state threading"
    printBlock "baseline state program" (formatCounterReport (runCounterProgramStepByStep counterCommands))
    printBlock "haskell state program" (formatCounterReport (applyProgram counterCommands))
    printBlock "state monad program" (formatCounterReport (applyProgramWithState counterCommands))
    printComparisonHeader "Comparison 9: environment-style dependency passing"
    putStrLn $ "baseline explicit env:     " ++ show (renderWelcomeExplicit appEnvironment validRegistration)
    putStrLn $ "haskell reader workflow:   " ++ show (runWelcome appEnvironment validRegistration)
    printComparisonHeader "Comparison 10: Reader + State + IO workflow"
    baselineSession <- processRegistrationInline sessionEnvironment initialSessionState validRegistration
    haskellSession <- runSessionWorkflow sessionEnvironment initialSessionState validRegistration
    printBlock "baseline combined flow" (formatInlineSessionResult baselineSession)
    printBlock "haskell combined flow" (formatStateSessionResult haskellSession)
    printComparisonHeader "Comparison 11: laziness and streaming"
    putStrLn $ "baseline finite range:     " ++ show (firstThreeLargeEvenSquaresFromRange 20)
    putStrLn $ "haskell lazy stream:       " ++ show firstThreeLargeEvenSquares
    printComparisonHeader "Comparison 12: batch Reader + State + IO workflow"
    baselineBatch <- processRegistrationBatchInline batchSessionEnvironment initialSessionState batchRegistrations
    haskellBatch <- runBatchSessionWorkflow batchSessionEnvironment initialSessionState batchRegistrations
    printBlock "baseline batch flow" (formatBatchWorkflow baselineBatch)
    printBlock "haskell batch flow" (formatBatchWorkflow haskellBatch)
    printComparisonHeader "Comparison 13: deeper end-to-end registration triad"
    baselineFeature <- registerFeatureInline featureEnvironment initialFeatureState validRegistration
    haskellFeature <- runFeatureRegistration featureEnvironment initialFeatureState validRegistration
    printBlock "baseline mini-feature" (formatInlineFeatureResult baselineFeature)
    printBlock "haskell mini-feature" (formatStateFeatureResult haskellFeature)
    printComparisonHeader "Comparison 14: password reset feature triad"
    baselineReset <- requestPasswordResetInline passwordResetEnvironment initialPasswordResetState "alice@example.com"
    haskellReset <- runPasswordReset passwordResetEnvironment initialPasswordResetState "alice@example.com"
    printBlock "baseline reset feature" (formatInlinePasswordResetResult baselineReset)
    printBlock "haskell reset feature" (formatStatePasswordResetResult haskellReset)
    printComparisonHeader "Comparison 15: configuration startup feature triad"
    baselineStartup <- startApplicationInline startupEnvironment initialStartupState validStartupConfig
    haskellStartup <- runStartup startupEnvironment initialStartupState validStartupConfig
    printBlock "baseline startup feature" (formatInlineStartupResult baselineStartup)
    printBlock "haskell startup feature" (formatStateStartupResult haskellStartup)

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
