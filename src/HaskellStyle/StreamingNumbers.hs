module HaskellStyle.StreamingNumbers
    ( firstThreeLargeEvenSquares
    ) where

import Shared.StreamingNumbers (naturalNumbers)

firstThreeLargeEvenSquares :: [Int]
firstThreeLargeEvenSquares =
    take 3
        . map square
        . filter even
        . filter ((> 50) . square)
        $ naturalNumbers

square :: Int -> Int
square value = value * value
