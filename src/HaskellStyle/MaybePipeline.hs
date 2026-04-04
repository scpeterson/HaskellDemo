module HaskellStyle.MaybePipeline
    ( findEmail
    ) where

import Shared.Person (Person (..))

findEmail :: String -> [Person] -> Maybe String
findEmail target =
    foldr step Nothing
  where
    step person fallback
        | name person == target = email person
        | otherwise = fallback
