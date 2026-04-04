module Baseline.EffectsBoundary
    ( saveGreetingInline
    ) where

import Shared.GreetingStore (renderGreeting)

saveGreetingInline :: FilePath -> String -> IO (Either String String)
saveGreetingInline path rawName =
    if null rawName
        then pure (Left "Name is required.")
        else do
            writeFile path (renderGreeting rawName)
            pure (Right ("Wrote greeting file to " ++ path))
