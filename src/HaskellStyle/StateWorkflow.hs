module HaskellStyle.StateWorkflow
    ( applyCommand
    , applyProgram
    ) where

import Shared.CounterState (CounterCommand (..), CounterReport (CounterReport), CounterState (..))

applyCommand :: CounterCommand -> CounterState -> (CounterState, String)
applyCommand Increment state =
    let newValue = counterValue state + 1
     in (CounterState newValue, "Increment -> " ++ show newValue)
applyCommand (Add amount) state =
    let newValue = counterValue state + amount
     in (CounterState newValue, "Add " ++ show amount ++ " -> " ++ show newValue)

applyProgram :: [CounterCommand] -> CounterReport
applyProgram commands =
    let (state, steps) = foldl step (CounterState 0, []) commands
     in CounterReport state (reverse steps)
  where
    step (state, steps) command =
        let (nextState, message) = applyCommand command state
         in (nextState, message : steps)
