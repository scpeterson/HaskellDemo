module Shared.CounterState
    ( CounterCommand (..)
    , CounterState (..)
    , CounterReport (..)
    ) where

data CounterCommand
    = Increment
    | Add Int
    deriving (Eq, Show)

data CounterState = CounterState
    { counterValue :: Int
    }
    deriving (Eq, Show)

data CounterReport = CounterReport
    { finalState :: CounterState
    , appliedSteps :: [String]
    }
    deriving (Eq, Show)
