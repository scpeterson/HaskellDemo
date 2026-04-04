module Baseline.StreamingNumbers
    ( firstThreeLargeEvenSquaresFromRange
    ) where

firstThreeLargeEvenSquaresFromRange :: Int -> [Int]
firstThreeLargeEvenSquaresFromRange upperBound = takeFirstThree [] [1 .. upperBound]
  where
    takeFirstThree collected [] = reverse collected
    takeFirstThree collected _ | length collected == 3 = reverse collected
    takeFirstThree collected (value : rest)
        | even value && square value > 50 = takeFirstThree (square value : collected) rest
        | otherwise = takeFirstThree collected rest

square :: Int -> Int
square value = value * value
