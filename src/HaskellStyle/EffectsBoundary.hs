module HaskellStyle.EffectsBoundary
    ( planGreetingWrite
    , executeFileCommand
    , saveGreetingWithBoundary
    ) where

import Shared.GreetingStore (FileCommand (WriteGreetingFile), renderGreeting)

planGreetingWrite :: FilePath -> String -> Either String FileCommand
planGreetingWrite path rawName
    | null rawName = Left "Name is required."
    | otherwise = Right (WriteGreetingFile path (renderGreeting rawName))

executeFileCommand :: FileCommand -> IO String
executeFileCommand (WriteGreetingFile path contents) = do
    writeFile path contents
    pure ("Wrote greeting file to " ++ path)

saveGreetingWithBoundary :: FilePath -> String -> IO (Either String String)
saveGreetingWithBoundary path rawName =
    case planGreetingWrite path rawName of
        Left err -> pure (Left err)
        Right command -> Right <$> executeFileCommand command
