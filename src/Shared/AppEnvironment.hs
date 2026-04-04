module Shared.AppEnvironment
    ( AppEnvironment (..)
    ) where

data AppEnvironment = AppEnvironment
    { requiredEmailDomain :: String
    , welcomePrefix :: String
    }
    deriving (Eq, Show)
