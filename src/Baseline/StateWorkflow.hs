module Baseline.StateWorkflow
    ( runCounterProgramStepByStep
    ) where

import Shared.CounterState (CounterCommand (..), CounterReport (CounterReport), CounterState (..))

runCounterProgramStepByStep :: [CounterCommand] -> CounterReport
runCounterProgramStepByStep commands = go (CounterState 0) [] commands
  where
    go state steps [] = CounterReport state (reverse steps)
    go state steps (command : rest) =
        let (nextState, stepDescription) = applyCommand state command
         in go nextState (stepDescription : steps) rest

applyCommand :: CounterState -> CounterCommand -> (CounterState, String)
applyCommand state Increment =
    let newValue = counterValue state + 1
     in (CounterState newValue, "Increment -> " ++ show newValue)
applyCommand state (Add amount) =
    let newValue = counterValue state + amount
     in (CounterState newValue, "Add " ++ show amount ++ " -> " ++ show newValue)
