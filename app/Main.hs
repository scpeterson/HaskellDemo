module Main where

import Baseline.AsyncPipeline (runUserPipelineInline)
import Baseline.AsyncWorkflow (runAsyncWorkflowInline)
import Baseline.BatchSessionWorkflow (processRegistrationBatchInline)
import Baseline.EffectsBoundary (saveGreetingInline)
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
import HaskellStyle.MaybePipeline (findEmail)
import HaskellStyle.ReaderWorkflow (runWelcome)
import HaskellStyle.RegistrationWorkflow (registerUser)
import HaskellStyle.SessionWorkflow (runSessionWorkflow)
import HaskellStyle.StateMonadWorkflow (applyProgramWithState)
import HaskellStyle.StateWorkflow (applyProgram)
import HaskellStyle.StreamingNumbers (firstThreeLargeEvenSquares)
import HaskellStyle.ValidationAccumulation (validateRegistrationAllErrors)
import Shared.AppEnvironment (AppEnvironment (AppEnvironment))
import Shared.AsyncPipeline (PipelineRequest (PipelineRequest))
import Shared.AsyncWorkflow (AsyncRequest (AsyncRequest))
import Shared.CounterState (CounterCommand (Add, Increment))
import Shared.Registration (RegistrationInput (RegistrationInput), UserRecord (UserRecord))
import Shared.SessionWorkflow (SessionEnvironment (SessionEnvironment), SessionState (SessionState))
import Shared.Person (Person (Person), prettyPerson)

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

main :: IO ()
main = do
    putStrLn "HaskellDemo"
    putStrLn "==========="
    putStrLn "Comparison 1: option-style lookup using Maybe"
    putStrLn ""
    mapM_ (putStrLn . prettyPerson) samplePeople
    putStrLn ""
    putStrLn $ "imperative-style Bob lookup: " ++ show (imperativeFindEmail "Bob" samplePeople)
    putStrLn $ "haskell-style Alice lookup:  " ++ show (findEmail "Alice" samplePeople)
    putStrLn $ "haskell-style Dana lookup:   " ++ show (findEmail "Dana" samplePeople)
    putStrLn ""
    putStrLn "Comparison 2: validation using Either"
    putStrLn $ "baseline valid registration:  " ++ show (validateRegistrationStepByStep validRegistration)
    putStrLn $ "haskell valid registration:   " ++ show (validateRegistration validRegistration)
    putStrLn $ "haskell invalid registration: " ++ show (validateRegistration invalidRegistration)
    putStrLn ""
    putStrLn "Comparison 3: registration workflow"
    putStrLn $ "baseline new user registration: " ++ show (registerUserStepByStep existingUsers validRegistration)
    putStrLn $ "haskell new user registration:  " ++ show (registerUser existingUsers validRegistration)
    putStrLn $ "haskell duplicate rejection:    " ++ show (registerUser existingUsers duplicateRegistration)
    putStrLn ""
    putStrLn "Comparison 4: validation accumulation"
    putStrLn $ "baseline first error:       " ++ show (validateRegistrationFirstError badAccumulationInput)
    putStrLn $ "haskell accumulated errors: " ++ show (validateRegistrationAllErrors badAccumulationInput)
    putStrLn ""
    putStrLn "Comparison 5: effects and IO boundaries"
    inlineResult <- saveGreetingInline inlineGreetingPath "Dora"
    boundaryResult <- saveGreetingWithBoundary boundaryGreetingPath "Dora"
    putStrLn $ "baseline inline IO:       " ++ show inlineResult
    putStrLn $ "haskell IO boundary flow: " ++ show boundaryResult
    putStrLn ""
    putStrLn "Comparison 6: async workflow"
    baselineAsync <- runAsyncWorkflowInline asyncRequest
    haskellAsync <- runAsyncWorkflow asyncRequest
    putStrLn $ "baseline async flow:       " ++ show baselineAsync
    putStrLn $ "haskell async composition: " ++ show haskellAsync
    putStrLn ""
    putStrLn "Comparison 7: richer async pipeline"
    baselinePipeline <- runUserPipelineInline pipelineRequest
    haskellPipeline <- runUserPipeline pipelineRequest
    putStrLn $ "baseline pipeline:         " ++ show baselinePipeline
    putStrLn $ "haskell pipeline:          " ++ show haskellPipeline
    putStrLn ""
    putStrLn "Comparison 8: state threading"
    putStrLn $ "baseline state program:    " ++ show (runCounterProgramStepByStep counterCommands)
    putStrLn $ "haskell state program:     " ++ show (applyProgram counterCommands)
    putStrLn $ "state monad program:       " ++ show (applyProgramWithState counterCommands)
    putStrLn ""
    putStrLn "Comparison 9: environment-style dependency passing"
    putStrLn $ "baseline explicit env:     " ++ show (renderWelcomeExplicit appEnvironment validRegistration)
    putStrLn $ "haskell reader workflow:   " ++ show (runWelcome appEnvironment validRegistration)
    putStrLn ""
    putStrLn "Comparison 10: Reader + State + IO workflow"
    baselineSession <- processRegistrationInline sessionEnvironment initialSessionState validRegistration
    haskellSession <- runSessionWorkflow sessionEnvironment initialSessionState validRegistration
    putStrLn $ "baseline combined flow:    " ++ show baselineSession
    putStrLn $ "haskell combined flow:     " ++ show haskellSession
    putStrLn ""
    putStrLn "Comparison 11: laziness and streaming"
    putStrLn $ "baseline finite range:     " ++ show (firstThreeLargeEvenSquaresFromRange 20)
    putStrLn $ "haskell lazy stream:       " ++ show firstThreeLargeEvenSquares
    putStrLn ""
    putStrLn "Comparison 12: batch Reader + State + IO workflow"
    baselineBatch <- processRegistrationBatchInline batchSessionEnvironment initialSessionState batchRegistrations
    haskellBatch <- runBatchSessionWorkflow batchSessionEnvironment initialSessionState batchRegistrations
    putStrLn $ "baseline batch flow:       " ++ show baselineBatch
    putStrLn $ "haskell batch flow:        " ++ show haskellBatch
