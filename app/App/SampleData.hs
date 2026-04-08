module App.SampleData
    ( samplePeople
    , validRegistration
    , invalidRegistration
    , existingUsers
    , duplicateRegistration
    , badAccumulationInput
    , inlineGreetingPath
    , boundaryGreetingPath
    , sessionAuditPath
    , batchSessionAuditPath
    , featureAuditPath
    , featureWelcomePath
    , passwordResetAuditPath
    , passwordResetEmailPath
    , startupAuditPath
    , asyncRequest
    , pipelineRequest
    , counterCommands
    , appEnvironment
    , sessionEnvironment
    , batchSessionEnvironment
    , initialSessionState
    , batchRegistrations
    , featureEnvironment
    , initialFeatureState
    , passwordResetEnvironment
    , initialPasswordResetState
    , startupEnvironment
    , initialStartupState
    , validStartupConfig
    ) where

import Shared.AppEnvironment (AppEnvironment (AppEnvironment))
import Shared.AsyncPipeline (PipelineRequest (PipelineRequest))
import Shared.AsyncWorkflow (AsyncRequest (AsyncRequest))
import Shared.CounterState (CounterCommand (Add, Increment))
import Shared.FeatureConfigurationStartup
    ( RawStartupConfig (..)
    , StartupEnvironment (StartupEnvironment)
    , StartupState (StartupState)
    )
import Shared.FeaturePasswordReset (PasswordResetEnvironment (PasswordResetEnvironment), PasswordResetState (PasswordResetState))
import Shared.FeatureRegistration (FeatureEnvironment (FeatureEnvironment), FeatureState (FeatureState))
import Shared.Person (Person (Person))
import Shared.Registration (RegistrationInput (RegistrationInput), UserRecord (UserRecord))
import Shared.SessionWorkflow (SessionEnvironment (SessionEnvironment), SessionState (SessionState))

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
