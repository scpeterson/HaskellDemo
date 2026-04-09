module App.ComparisonRunner
    ( runAllComparisons
    ) where

import App.SampleData
import App.TerminalOutput
    ( formatAsyncResult
    , formatBatchWorkflow
    , formatCounterReport
    , formatInlineFeatureResult
    , formatInlinePasswordResetResult
    , formatInlineSessionResult
    , formatInlineStartupResult
    , formatPipelineResult
    , formatRegistrationWorkflowResult
    , formatStateFeatureResult
    , formatStatePasswordResetResult
    , formatStateSessionResult
    , formatStateStartupResult
    , formatRetryOutcome
    , formatUserValidationResult
    , printBlock
    , printComparisonHeader
    )
import Baseline.AsyncPipeline (runUserPipelineInline)
import Baseline.AsyncWorkflow (runAsyncWorkflowInline)
import Baseline.BatchSessionWorkflow (processRegistrationBatchInline)
import Baseline.RetryBackoff (runRetryBackoffInline)
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
import HaskellStyle.RetryBackoff (runRetryBackoff)
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
import Shared.Person (prettyPerson)

runAllComparisons :: IO ()
runAllComparisons = do
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

    printComparisonHeader "Comparison 16: retry and backoff policy triad"
    baselineRetry <- runRetryBackoffInline retrySuccessRequest
    haskellRetry <- runRetryBackoff retrySuccessRequest
    printBlock "baseline retry flow" (formatRetryOutcome baselineRetry)
    printBlock "haskell retry flow" (formatRetryOutcome haskellRetry)
