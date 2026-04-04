module HaskellStyle.StateMonadWorkflow
    ( applyCommandState
    , applyProgramWithState
    ) where

import Control.Monad.State.Strict (State, get, modify', runState)
import Shared.CounterState (CounterCommand (..), CounterReport (CounterReport), CounterState (..))

applyCommandState :: CounterCommand -> State CounterState String
applyCommandState Increment = do
    modify' (\state -> state {counterValue = counterValue state + 1})
    pure . renderStep "Increment" =<< currentValue
applyCommandState (Add amount) = do
    modify' (\state -> state {counterValue = counterValue state + amount})
    pure . renderStep ("Add " ++ show amount) =<< currentValue

applyProgramWithState :: [CounterCommand] -> CounterReport
applyProgramWithState commands =
    let (steps, finalCounter) = runState (traverse applyCommandState commands) (CounterState 0)
     in CounterReport finalCounter steps

currentValue :: State CounterState Int
currentValue = do
    state <- get
    pure (counterValue state)

renderStep :: String -> Int -> String
renderStep action value = action ++ " -> " ++ show value
