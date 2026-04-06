module HaskellStyle.FeatureConfigurationStartup
    ( StartupApp
    , planStartup
    , executeStartupCommands
    , runStartup
    ) where

import Control.Monad.Reader (ReaderT, ask, runReaderT)
import Control.Monad.State.Strict (State, get, modify', runState)
import Shared.FeatureConfigurationStartup
    ( RawStartupConfig (..)
    , StartupCommand (AppendStartupAudit)
    , StartupEnvironment (..)
    , StartupResult (..)
    , StartupState (..)
    , ValidatedStartupConfig (..)
    )
import Text.Read (readMaybe)

type StartupApp = ReaderT StartupEnvironment (State StartupState)

planStartup :: RawStartupConfig -> StartupApp (Either [String] StartupResult)
planStartup rawConfig = do
    environment <- ask
    currentState <- get
    case validateStartup environment currentState rawConfig of
        Left errors -> pure (Left errors)
        Right validatedConfig -> do
            let auditNumber = startupNextAuditNumber currentState
            let appKey = buildAppKey validatedConfig
            let auditLine =
                    "startup #" ++ show auditNumber
                        ++ ": " ++ validatedAppName validatedConfig
                        ++ " on " ++ validatedEnvironmentName validatedConfig
                        ++ " port " ++ show (validatedPort validatedConfig)
            let commands = [AppendStartupAudit auditLine]
            modify'
                (\state ->
                    state
                        { startedApplications = startedApplications state ++ [appKey]
                        , startupNextAuditNumber = startupNextAuditNumber state + 1
                        })
            pure (Right (StartupResult validatedConfig auditLine commands))

runStartup :: StartupEnvironment -> StartupState -> RawStartupConfig -> IO (Either [String] StartupResult, StartupState)
runStartup environment initialState rawConfig = do
    let (plannedResult, updatedState) = runState (runReaderT (planStartup rawConfig) environment) initialState
    case plannedResult of
        Left errors -> pure (Left errors, updatedState)
        Right startupResult -> do
            executeStartupCommands environment (startupCommands startupResult)
            pure (Right startupResult, updatedState)

executeStartupCommands :: StartupEnvironment -> [StartupCommand] -> IO ()
executeStartupCommands environment = mapM_ (executeCommand environment)

executeCommand :: StartupEnvironment -> StartupCommand -> IO ()
executeCommand environment command =
    case command of
        AppendStartupAudit line -> appendFile (startupAuditFilePath environment) (line ++ "\n")

validateStartup :: StartupEnvironment -> StartupState -> RawStartupConfig -> Either [String] ValidatedStartupConfig
validateStartup environment currentState rawConfig =
    let errors =
            concat
                [ validateAppName rawConfig
                , validateEnvironment environment rawConfig
                , validateDatabaseUrl rawConfig
                , validatePort rawConfig
                , validateLogLevel rawConfig
                , validateDuplicateStartup currentState rawConfig
                ]
     in case (errors, parsePort (rawPortText rawConfig)) of
            ([], Just portNumber) ->
                Right
                    (ValidatedStartupConfig
                        { validatedAppName = rawAppName rawConfig
                        , validatedEnvironmentName = rawEnvironmentName rawConfig
                        , validatedDatabaseUrl = rawDatabaseUrl rawConfig
                        , validatedPort = portNumber
                        , validatedLogLevel = rawLogLevel rawConfig
                        })
            _ -> Left errors

validateAppName :: RawStartupConfig -> [String]
validateAppName rawConfig
    | null (rawAppName rawConfig) = ["Application name is required."]
    | otherwise = []

validateEnvironment :: StartupEnvironment -> RawStartupConfig -> [String]
validateEnvironment environment rawConfig
    | null (rawEnvironmentName rawConfig) = ["Environment name is required."]
    | rawEnvironmentName rawConfig /= startupExpectedEnvironment environment =
        ["Environment must be " ++ startupExpectedEnvironment environment ++ "."]
    | otherwise = []

validateDatabaseUrl :: RawStartupConfig -> [String]
validateDatabaseUrl rawConfig
    | null (rawDatabaseUrl rawConfig) = ["Database URL is required."]
    | not (startsWith "postgres://" (rawDatabaseUrl rawConfig)) = ["Database URL must start with postgres://."]
    | otherwise = []

validatePort :: RawStartupConfig -> [String]
validatePort rawConfig =
    case parsePort (rawPortText rawConfig) of
        Nothing -> ["Port must be an integer."]
        Just portNumber
            | portNumber < 1024 || portNumber > 65535 -> ["Port must be between 1024 and 65535."]
            | otherwise -> []

validateLogLevel :: RawStartupConfig -> [String]
validateLogLevel rawConfig
    | rawLogLevel rawConfig `elem` ["debug", "info", "warn", "error"] = []
    | otherwise = ["Log level must be debug, info, warn, or error."]

validateDuplicateStartup :: StartupState -> RawStartupConfig -> [String]
validateDuplicateStartup currentState rawConfig
    | buildRawAppKey rawConfig `elem` startedApplications currentState = ["Application has already been started for this environment."]
    | otherwise = []

parsePort :: String -> Maybe Int
parsePort = readMaybe

buildRawAppKey :: RawStartupConfig -> String
buildRawAppKey rawConfig = rawAppName rawConfig ++ "@" ++ rawEnvironmentName rawConfig

buildAppKey :: ValidatedStartupConfig -> String
buildAppKey validatedConfig = validatedAppName validatedConfig ++ "@" ++ validatedEnvironmentName validatedConfig

startsWith :: Eq a => [a] -> [a] -> Bool
startsWith [] _ = True
startsWith _ [] = False
startsWith (x : xs) (y : ys) = x == y && startsWith xs ys
