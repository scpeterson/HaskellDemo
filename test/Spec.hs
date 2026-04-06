module Main where

import Control.Monad.Reader (runReaderT)
import Control.Monad.State.Strict (runState)
import Baseline.AsyncPipeline (runUserPipelineInline)
import Baseline.AsyncWorkflow (runAsyncWorkflowInline)
import Baseline.BatchSessionWorkflow (processRegistrationBatchInline)
import Baseline.EffectsBoundary (saveGreetingInline)
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
import HaskellStyle.AsyncPipeline (PipelinePlan (PipelinePlan), planUserPipeline, runUserPipeline)
import HaskellStyle.AsyncWorkflow (planAsyncWorkflow, runAsyncWorkflow)
import HaskellStyle.BatchSessionWorkflow (runBatchSessionWorkflow)
import HaskellStyle.EffectsBoundary (planGreetingWrite, saveGreetingWithBoundary)
import HaskellStyle.EitherValidation (validateRegistration)
import HaskellStyle.FeaturePasswordReset (planPasswordReset, runPasswordReset)
import HaskellStyle.FeatureRegistration (planFeatureRegistration, runFeatureRegistration)
import HaskellStyle.MaybePipeline (findEmail)
import HaskellStyle.ReaderWorkflow (runWelcome)
import HaskellStyle.RegistrationWorkflow (registerUser)
import HaskellStyle.SessionWorkflow (runSessionWorkflow)
import HaskellStyle.StateMonadWorkflow (applyProgramWithState)
import HaskellStyle.StateWorkflow (applyProgram)
import HaskellStyle.StreamingNumbers (firstThreeLargeEvenSquares)
import HaskellStyle.ValidationAccumulation (validateRegistrationAllErrors)
import Shared.AppEnvironment (AppEnvironment (AppEnvironment))
import Shared.AsyncPipeline (PipelineRequest (PipelineRequest), PipelineResult (PipelineResult))
import Shared.AsyncWorkflow (AsyncRequest (AsyncRequest), AsyncResult (AsyncResult))
import Shared.BatchSessionWorkflow (BatchResult (..))
import Shared.CounterState (CounterCommand (Add, Increment), CounterReport (CounterReport), CounterState (CounterState))
import Shared.FeaturePasswordReset
    ( PasswordResetCommand (AppendResetAudit, AppendResetEmail)
    , PasswordResetEnvironment (PasswordResetEnvironment)
    , PasswordResetResult (..)
    , PasswordResetState (..)
    )
import Shared.FeatureRegistration (FeatureCommand (..), FeatureEnvironment (FeatureEnvironment), FeatureResult (..), FeatureState (FeatureState))
import Shared.GreetingStore (FileCommand (WriteGreetingFile))
import Shared.Person (Person (Person))
import Shared.Registration (RegistrationInput (RegistrationInput), UserRecord (UserRecord))
import Shared.SessionWorkflow (SessionEnvironment (SessionEnvironment), SessionState (SessionState))
import System.Directory (doesFileExist, removeFile)
import System.Exit (exitFailure, exitSuccess)

samplePeople :: [Person]
samplePeople =
    [ Person "Alice" (Just "alice@example.com")
    , Person "Bob" Nothing
    ]

validRegistration :: RegistrationInput
validRegistration = RegistrationInput "Alice" "alice@example.com"

missingNameRegistration :: RegistrationInput
missingNameRegistration = RegistrationInput "" "alice@example.com"

invalidEmailRegistration :: RegistrationInput
invalidEmailRegistration = RegistrationInput "Alice" "alice.example.com"

existingUsers :: [UserRecord]
existingUsers =
    [ UserRecord "Existing" "existing@example.com"
    ]

duplicateRegistration :: RegistrationInput
duplicateRegistration = RegistrationInput "Another" "existing@example.com"

badAccumulationInput :: RegistrationInput
badAccumulationInput = RegistrationInput "" "x"

inlineTestPath :: FilePath
inlineTestPath = "/tmp/haskelldemo-inline-test.txt"

boundaryTestPath :: FilePath
boundaryTestPath = "/tmp/haskelldemo-boundary-test.txt"

baselineSessionAuditPath :: FilePath
baselineSessionAuditPath = "/tmp/haskelldemo-session-baseline-test.txt"

haskellSessionAuditPath :: FilePath
haskellSessionAuditPath = "/tmp/haskelldemo-session-haskell-test.txt"

baselineBatchAuditPath :: FilePath
baselineBatchAuditPath = "/tmp/haskelldemo-session-batch-baseline-test.txt"

haskellBatchAuditPath :: FilePath
haskellBatchAuditPath = "/tmp/haskelldemo-session-batch-haskell-test.txt"

baselineFeatureAuditPath :: FilePath
baselineFeatureAuditPath = "/tmp/haskelldemo-feature-baseline-audit-test.txt"

baselineFeatureWelcomePath :: FilePath
baselineFeatureWelcomePath = "/tmp/haskelldemo-feature-baseline-welcome-test.txt"

haskellFeatureAuditPath :: FilePath
haskellFeatureAuditPath = "/tmp/haskelldemo-feature-haskell-audit-test.txt"

haskellFeatureWelcomePath :: FilePath
haskellFeatureWelcomePath = "/tmp/haskelldemo-feature-haskell-welcome-test.txt"

baselineResetAuditPath :: FilePath
baselineResetAuditPath = "/tmp/haskelldemo-password-reset-baseline-audit-test.txt"

baselineResetEmailPath :: FilePath
baselineResetEmailPath = "/tmp/haskelldemo-password-reset-baseline-email-test.txt"

haskellResetAuditPath :: FilePath
haskellResetAuditPath = "/tmp/haskelldemo-password-reset-haskell-audit-test.txt"

haskellResetEmailPath :: FilePath
haskellResetEmailPath = "/tmp/haskelldemo-password-reset-haskell-email-test.txt"

asyncRequest :: AsyncRequest
asyncRequest = AsyncRequest "Alice"

emptyAsyncRequest :: AsyncRequest
emptyAsyncRequest = AsyncRequest ""

pipelineRequest :: PipelineRequest
pipelineRequest = PipelineRequest "42"

emptyPipelineRequest :: PipelineRequest
emptyPipelineRequest = PipelineRequest ""

counterCommands :: [CounterCommand]
counterCommands = [Increment, Add 4, Increment]

expectedCounterReport :: CounterReport
expectedCounterReport = CounterReport (CounterState 6) ["Increment -> 1", "Add 4 -> 5", "Increment -> 6"]

appEnvironment :: AppEnvironment
appEnvironment = AppEnvironment "example.com" "Welcome"

wrongDomainRegistration :: RegistrationInput
wrongDomainRegistration = RegistrationInput "Alice" "alice@other.com"

baselineSessionEnvironment :: SessionEnvironment
baselineSessionEnvironment = SessionEnvironment "example.com" "Welcome" baselineSessionAuditPath

haskellSessionEnvironment :: SessionEnvironment
haskellSessionEnvironment = SessionEnvironment "example.com" "Welcome" haskellSessionAuditPath

baselineBatchEnvironment :: SessionEnvironment
baselineBatchEnvironment = SessionEnvironment "example.com" "Welcome" baselineBatchAuditPath

haskellBatchEnvironment :: SessionEnvironment
haskellBatchEnvironment = SessionEnvironment "example.com" "Welcome" haskellBatchAuditPath

baselineFeatureEnvironment :: FeatureEnvironment
baselineFeatureEnvironment = FeatureEnvironment "example.com" "Welcome" baselineFeatureAuditPath baselineFeatureWelcomePath

haskellFeatureEnvironment :: FeatureEnvironment
haskellFeatureEnvironment = FeatureEnvironment "example.com" "Welcome" haskellFeatureAuditPath haskellFeatureWelcomePath

baselinePasswordResetEnvironment :: PasswordResetEnvironment
baselinePasswordResetEnvironment =
    PasswordResetEnvironment "example.com" "https://example.com/reset" baselineResetAuditPath baselineResetEmailPath

haskellPasswordResetEnvironment :: PasswordResetEnvironment
haskellPasswordResetEnvironment =
    PasswordResetEnvironment "example.com" "https://example.com/reset" haskellResetAuditPath haskellResetEmailPath

initialSessionState :: SessionState
initialSessionState = SessionState 0 []

expectedSessionState :: SessionState
expectedSessionState = SessionState 1 ["processed #1: alice@example.com"]

batchRegistrations :: [RegistrationInput]
batchRegistrations =
    [ RegistrationInput "Alice" "alice@example.com"
    , RegistrationInput "" "broken@example.com"
    , RegistrationInput "Evan" "evan@example.com"
    ]

expectedBatchResult :: BatchResult
expectedBatchResult =
    BatchResult
        { successfulRegistrations = ["Welcome, Alice!", "Welcome, Evan!"]
        , failedRegistrations = [(RegistrationInput "" "broken@example.com", "Name is required.")]
        }

expectedBatchState :: SessionState
expectedBatchState =
    SessionState 2 ["processed #1: alice@example.com", "processed #2: evan@example.com"]

initialFeatureState :: FeatureState
initialFeatureState = FeatureState existingUsers 2

expectedFeatureResult :: FeatureResult
expectedFeatureResult =
    FeatureResult
        { featureRegisteredUser = UserRecord "Alice" "alice@example.com"
        , featureWelcomeMessage = "Welcome, Alice!"
        , featureAuditLine = "registered #2: alice@example.com"
        , featureCommands =
            [ AppendAuditLine "registered #2: alice@example.com"
            , AppendWelcomeEmail "Welcome, Alice!"
            ]
        }

expectedFeatureState :: FeatureState
expectedFeatureState =
    FeatureState
        [ UserRecord "Existing" "existing@example.com"
        , UserRecord "Alice" "alice@example.com"
        ]
        3

initialPasswordResetState :: PasswordResetState
initialPasswordResetState = PasswordResetState existingUsers 5

expectedPasswordResetResult :: PasswordResetResult
expectedPasswordResetResult =
    PasswordResetResult
        { resetUserEmail = "existing@example.com"
        , resetToken = "reset-5"
        , resetLink = "https://example.com/reset/reset-5"
        , resetAuditLine = "password-reset #5: existing@example.com"
        , resetCommands =
            [ AppendResetAudit "password-reset #5: existing@example.com"
            , AppendResetEmail "Reset link for existing@example.com: https://example.com/reset/reset-5"
            ]
        }

expectedPasswordResetState :: PasswordResetState
expectedPasswordResetState = PasswordResetState existingUsers 6

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEqual label expected actual =
    if expected == actual
        then putStrLn ("[PASS] " ++ label)
        else do
            putStrLn ("[FAIL] " ++ label)
            putStrLn ("  expected: " ++ show expected)
            putStrLn ("  actual:   " ++ show actual)
            exitFailure

removeIfPresent :: FilePath -> IO ()
removeIfPresent path = do
    exists <- doesFileExist path
    if exists then removeFile path else pure ()

main :: IO ()
main = do
    mapM_ removeIfPresent
        [ inlineTestPath
        , boundaryTestPath
        , baselineSessionAuditPath
        , haskellSessionAuditPath
        , baselineBatchAuditPath
        , haskellBatchAuditPath
        , baselineFeatureAuditPath
        , baselineFeatureWelcomePath
        , haskellFeatureAuditPath
        , haskellFeatureWelcomePath
        , baselineResetAuditPath
        , baselineResetEmailPath
        , haskellResetAuditPath
        , haskellResetEmailPath
        ]

    assertEqual "imperative-style lookup returns present email"
        (Just "alice@example.com")
        (imperativeFindEmail "Alice" samplePeople)

    assertEqual "haskell-style lookup returns Nothing when email missing"
        Nothing
        (findEmail "Bob" samplePeople)

    assertEqual "haskell-style lookup returns Nothing when person missing"
        Nothing
        (findEmail "Dana" samplePeople)

    assertEqual "baseline validation accepts a valid registration"
        (Right (UserRecord "Alice" "alice@example.com"))
        (validateRegistrationStepByStep validRegistration)

    assertEqual "haskell validation rejects a missing name"
        (Left "Name is required.")
        (validateRegistration missingNameRegistration)

    assertEqual "haskell validation rejects an invalid email"
        (Left "Email must contain @.")
        (validateRegistration invalidEmailRegistration)

    assertEqual "baseline workflow registers a new user"
        (Right ([UserRecord "Existing" "existing@example.com", UserRecord "Alice" "alice@example.com"], "Registered user Alice"))
        (registerUserStepByStep existingUsers validRegistration)

    assertEqual "haskell workflow registers a new user"
        (Right ([UserRecord "Existing" "existing@example.com", UserRecord "Alice" "alice@example.com"], "Registered user Alice"))
        (registerUser existingUsers validRegistration)

    assertEqual "haskell workflow rejects duplicate email"
        (Left "Email already exists.")
        (registerUser existingUsers duplicateRegistration)

    assertEqual "baseline accumulation variant returns the first error only"
        (Left "Name is required.")
        (validateRegistrationFirstError badAccumulationInput)

    assertEqual "haskell accumulation variant returns all relevant errors"
        (Left ["Name is required.", "Email must contain @.", "Email must be at least 6 characters."])
        (validateRegistrationAllErrors badAccumulationInput)

    assertEqual "haskell effect boundary builds a pure file command"
        (Right (WriteGreetingFile boundaryTestPath "Hello, Alice!\n"))
        (planGreetingWrite boundaryTestPath "Alice")

    inlineResult <- saveGreetingInline inlineTestPath "Alice"
    assertEqual "baseline inline IO writes a greeting"
        (Right ("Wrote greeting file to " ++ inlineTestPath))
        inlineResult

    inlineContents <- readFile inlineTestPath
    assertEqual "baseline inline IO writes expected contents"
        "Hello, Alice!\n"
        inlineContents

    boundaryResult <- saveGreetingWithBoundary boundaryTestPath "Alice"
    assertEqual "haskell IO boundary flow writes a greeting"
        (Right ("Wrote greeting file to " ++ boundaryTestPath))
        boundaryResult

    boundaryContents <- readFile boundaryTestPath
    assertEqual "haskell IO boundary flow writes expected contents"
        "Hello, Alice!\n"
        boundaryContents

    assertEqual "haskell async planning is pure"
        (Right "Alice")
        (planAsyncWorkflow asyncRequest)

    assertEqual "haskell async planning rejects empty input"
        (Left "Name is required.")
        (planAsyncWorkflow emptyAsyncRequest)

    baselineAsync <- runAsyncWorkflowInline asyncRequest
    assertEqual "baseline async workflow succeeds"
        (Right (AsyncResult "Async hello, Alice!"))
        baselineAsync

    haskellAsync <- runAsyncWorkflow asyncRequest
    assertEqual "haskell async workflow succeeds"
        (Right (AsyncResult "Async hello, Alice!"))
        haskellAsync

    assertEqual "haskell async pipeline planning is pure"
        (Right (PipelinePlan "42"))
        (planUserPipeline pipelineRequest)

    assertEqual "haskell async pipeline rejects empty id"
        (Left "User id is required.")
        (planUserPipeline emptyPipelineRequest)

    baselinePipeline <- runUserPipelineInline pipelineRequest
    assertEqual "baseline async pipeline succeeds"
        (Right (PipelineResult "Loaded profile for User-42"))
        baselinePipeline

    haskellPipeline <- runUserPipeline pipelineRequest
    assertEqual "haskell async pipeline succeeds"
        (Right (PipelineResult "Loaded profile for User-42"))
        haskellPipeline

    assertEqual "baseline state threading reaches the expected result"
        expectedCounterReport
        (runCounterProgramStepByStep counterCommands)

    assertEqual "haskell state threading reaches the expected result"
        expectedCounterReport
        (applyProgram counterCommands)

    assertEqual "state monad workflow reaches the expected result"
        expectedCounterReport
        (applyProgramWithState counterCommands)

    assertEqual "baseline explicit environment passes configuration directly"
        (Right "Welcome, Alice!")
        (renderWelcomeExplicit appEnvironment validRegistration)

    assertEqual "reader workflow reaches the same result"
        (Right "Welcome, Alice!")
        (runWelcome appEnvironment validRegistration)

    assertEqual "reader workflow rejects the wrong email domain"
        (Left "Email must use the example.com domain.")
        (runWelcome appEnvironment wrongDomainRegistration)

    baselineSession <- processRegistrationInline baselineSessionEnvironment initialSessionState validRegistration
    assertEqual "baseline combined workflow returns updated state and message"
        (Right (expectedSessionState, "Welcome, Alice!"))
        baselineSession

    baselineAudit <- readFile baselineSessionAuditPath
    assertEqual "baseline combined workflow writes an audit line"
        "processed #1: alice@example.com\n"
        baselineAudit

    haskellSession <- runSessionWorkflow haskellSessionEnvironment initialSessionState validRegistration
    assertEqual "reader-state-io workflow returns updated state and message"
        (Right "Welcome, Alice!", expectedSessionState)
        haskellSession

    haskellAudit <- readFile haskellSessionAuditPath
    assertEqual "reader-state-io workflow writes an audit line"
        "processed #1: alice@example.com\n"
        haskellAudit

    assertEqual "baseline finite streaming example reaches the expected values"
        [64, 100, 144]
        (firstThreeLargeEvenSquaresFromRange 20)

    assertEqual "lazy streaming example reaches the expected values"
        [64, 100, 144]
        firstThreeLargeEvenSquares

    baselineBatch <- processRegistrationBatchInline baselineBatchEnvironment initialSessionState batchRegistrations
    assertEqual "baseline batch workflow returns the expected results"
        (expectedBatchResult, expectedBatchState)
        baselineBatch

    baselineBatchAudit <- readFile baselineBatchAuditPath
    assertEqual "baseline batch workflow writes the expected audit trail"
        "processed #1: alice@example.com\nprocessed #2: evan@example.com\n"
        baselineBatchAudit

    haskellBatch <- runBatchSessionWorkflow haskellBatchEnvironment initialSessionState batchRegistrations
    assertEqual "haskell batch workflow returns the expected results"
        (expectedBatchResult, expectedBatchState)
        haskellBatch

    haskellBatchAudit <- readFile haskellBatchAuditPath
    assertEqual "haskell batch workflow writes the expected audit trail"
        "processed #1: alice@example.com\nprocessed #2: evan@example.com\n"
        haskellBatchAudit

    let plannedFeature = runState (runReaderT (planFeatureRegistration validRegistration) haskellFeatureEnvironment) initialFeatureState
    assertEqual "haskell feature planning stays pure before execution"
        (Right expectedFeatureResult, expectedFeatureState)
        plannedFeature

    baselineFeature <- registerFeatureInline baselineFeatureEnvironment initialFeatureState validRegistration
    assertEqual "baseline feature workflow returns the expected result and state"
        (Right (expectedFeatureResult, expectedFeatureState))
        baselineFeature

    baselineFeatureAudit <- readFile baselineFeatureAuditPath
    assertEqual "baseline feature workflow writes the expected audit line"
        "registered #2: alice@example.com\n"
        baselineFeatureAudit

    baselineFeatureWelcome <- readFile baselineFeatureWelcomePath
    assertEqual "baseline feature workflow writes the expected welcome message"
        "Welcome, Alice!\n"
        baselineFeatureWelcome

    haskellFeature <- runFeatureRegistration haskellFeatureEnvironment initialFeatureState validRegistration
    assertEqual "haskell feature workflow returns the expected result and state"
        (Right expectedFeatureResult, expectedFeatureState)
        haskellFeature

    haskellFeatureAudit <- readFile haskellFeatureAuditPath
    assertEqual "haskell feature workflow writes the expected audit line"
        "registered #2: alice@example.com\n"
        haskellFeatureAudit

    haskellFeatureWelcome <- readFile haskellFeatureWelcomePath
    assertEqual "haskell feature workflow writes the expected welcome message"
        "Welcome, Alice!\n"
        haskellFeatureWelcome

    assertEqual "haskell feature workflow rejects duplicate email"
        (Left "Email already exists.", initialFeatureState)
        =<< runFeatureRegistration haskellFeatureEnvironment initialFeatureState duplicateRegistration

    let plannedReset = runState (runReaderT (planPasswordReset "existing@example.com") haskellPasswordResetEnvironment) initialPasswordResetState
    assertEqual "haskell password reset planning stays pure before execution"
        (Right expectedPasswordResetResult, expectedPasswordResetState)
        plannedReset

    baselineReset <- requestPasswordResetInline baselinePasswordResetEnvironment initialPasswordResetState "existing@example.com"
    assertEqual "baseline password reset workflow returns the expected result and state"
        (Right (expectedPasswordResetResult, expectedPasswordResetState))
        baselineReset

    baselineResetAudit <- readFile baselineResetAuditPath
    assertEqual "baseline password reset workflow writes the expected audit line"
        "password-reset #5: existing@example.com\n"
        baselineResetAudit

    baselineResetEmail <- readFile baselineResetEmailPath
    assertEqual "baseline password reset workflow writes the expected email payload"
        "Reset link for existing@example.com: https://example.com/reset/reset-5\n"
        baselineResetEmail

    haskellReset <- runPasswordReset haskellPasswordResetEnvironment initialPasswordResetState "existing@example.com"
    assertEqual "haskell password reset workflow returns the expected result and state"
        (Right expectedPasswordResetResult, expectedPasswordResetState)
        haskellReset

    haskellResetAudit <- readFile haskellResetAuditPath
    assertEqual "haskell password reset workflow writes the expected audit line"
        "password-reset #5: existing@example.com\n"
        haskellResetAudit

    haskellResetEmail <- readFile haskellResetEmailPath
    assertEqual "haskell password reset workflow writes the expected email payload"
        "Reset link for existing@example.com: https://example.com/reset/reset-5\n"
        haskellResetEmail

    assertEqual "haskell password reset workflow rejects missing users"
        (Left "User was not found.", initialPasswordResetState)
        =<< runPasswordReset haskellPasswordResetEnvironment initialPasswordResetState "missing@example.com"

    exitSuccess
