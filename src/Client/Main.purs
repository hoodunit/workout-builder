module WorkoutBuilder.Client.Main where

import Prelude
import WorkoutBuilder.Types

import Data.Either (Either(..), fromRight)
import Data.Map as Map
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import WorkoutBuilder.Client.App as App
import WorkoutBuilder.Client.UrlCodecs (writeParamsToUrlHash, readParamsFromUrlHash)
import WorkoutBuilder.Samples as Samples

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  hashParams <- liftEffect readParamsFromUrlHash
  case hashParams of
    Left err -> log err
    Right _ -> pure unit
  let params = fromRight Samples.rrParams hashParams
  liftEffect $ writeParamsToUrlHash params
  _ <- runUI (App.component params) unit body
  pure unit
