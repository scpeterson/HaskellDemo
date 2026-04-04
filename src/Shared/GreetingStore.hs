module Shared.GreetingStore
    ( FileCommand (..)
    , renderGreeting
    ) where

data FileCommand = WriteGreetingFile FilePath String
    deriving (Eq, Show)

renderGreeting :: String -> String
renderGreeting name = "Hello, " ++ name ++ "!\n"
