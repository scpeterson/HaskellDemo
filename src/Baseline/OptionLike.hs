module Baseline.OptionLike
    ( imperativeFindEmail
    ) where

import Shared.Person (Person (..))

imperativeFindEmail :: String -> [Person] -> Maybe String
imperativeFindEmail target people = go people
  where
    go [] = Nothing
    go (person : rest)
        | name person == target = email person
        | otherwise = go rest
