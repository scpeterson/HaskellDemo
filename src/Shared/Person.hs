module Shared.Person
    ( Person (..)
    , prettyPerson
    ) where

data Person = Person
    { name :: String
    , email :: Maybe String
    }
    deriving (Eq, Show)

prettyPerson :: Person -> String
prettyPerson person =
    name person ++ " -> " ++ maybe "<missing email>" id (email person)
