module WorkoutBuilder.Client.LZString where

foreign import compressToEncodedURIComponent :: String -> String
foreign import decompressFromEncodedURIComponent :: String -> String
