module Shared.RetryBackoff
    ( RetryRequest (..)
    , OperationError (..)
    , RetryDecision (..)
    , RetryState (..)
    , RetryOutcome (..)
    , RetryStep (..)
    , initialRetryState
    , operationErrorMessage
    , simulateProfileFetch
    , recordFailure
    , recordDelay
    , advanceAttempt
    , successOutcome
    , failureOutcome
    ) where

data RetryRequest = RetryRequest
    { retryUserId :: String
    }
    deriving (Eq, Show)

data OperationError
    = TemporaryFailure String
    | PermanentFailure String
    deriving (Eq, Show)

data RetryDecision
    = RetryAfter Int
    | StopRetrying
    deriving (Eq, Show)

data RetryState = RetryState
    { retryNextAttemptNumber :: Int
    , retryDelayHistory :: [Int]
    , retryFailureLog :: [String]
    }
    deriving (Eq, Show)

data RetryOutcome = RetryOutcome
    { retryStatus :: String
    , retryMessage :: String
    , retryAttemptsUsed :: Int
    , retryDelayHistoryUsed :: [Int]
    , retryFailureLogUsed :: [String]
    }
    deriving (Eq, Show)

data RetryStep
    = RetrySucceeded RetryOutcome
    | RetryPlanned Int
    | RetryStopped RetryOutcome
    deriving (Eq, Show)

initialRetryState :: RetryState
initialRetryState = RetryState 1 [] []

operationErrorMessage :: OperationError -> String
operationErrorMessage (TemporaryFailure message) = "temporary: " ++ message
operationErrorMessage (PermanentFailure message) = "permanent: " ++ message

simulateProfileFetch :: RetryRequest -> Int -> Either OperationError String
simulateProfileFetch request attempt
    | null (retryUserId request) = Left (PermanentFailure "user id is required")
    | retryUserId request == "bad-user" = Left (PermanentFailure "user is blocked for retries")
    | retryUserId request == "always-busy" = Left (TemporaryFailure "profile service unavailable")
    | attempt < 3 = Left (TemporaryFailure "profile service unavailable")
    | otherwise = Right ("Loaded profile for " ++ retryUserId request)

recordFailure :: OperationError -> RetryState -> RetryState
recordFailure errorValue state =
    state { retryFailureLog = retryFailureLog state ++ [operationErrorMessage errorValue] }

recordDelay :: Int -> RetryState -> RetryState
recordDelay delayMs state =
    state { retryDelayHistory = retryDelayHistory state ++ [delayMs] }

advanceAttempt :: RetryState -> RetryState
advanceAttempt state =
    state { retryNextAttemptNumber = retryNextAttemptNumber state + 1 }

successOutcome :: RetryState -> Int -> String -> RetryOutcome
successOutcome state attemptsUsed message =
    RetryOutcome
        { retryStatus = "success"
        , retryMessage = message
        , retryAttemptsUsed = attemptsUsed
        , retryDelayHistoryUsed = retryDelayHistory state
        , retryFailureLogUsed = retryFailureLog state
        }

failureOutcome :: RetryState -> Int -> OperationError -> RetryOutcome
failureOutcome state attemptsUsed errorValue =
    RetryOutcome
        { retryStatus = "failure"
        , retryMessage = operationErrorMessage errorValue
        , retryAttemptsUsed = attemptsUsed
        , retryDelayHistoryUsed = retryDelayHistory state
        , retryFailureLogUsed = retryFailureLog state
        }
