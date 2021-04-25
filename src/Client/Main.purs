module WorkoutBuilder.Client.Main where

import Prelude
import WorkoutBuilder.Types

import Data.Map as Map
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import WorkoutBuilder.Client.App as App
import WorkoutBuilder.Samples as Samples

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  _ <- runUI (App.component Samples.rrParams) unit body
  pure unit
