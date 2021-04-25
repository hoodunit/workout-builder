module WorkoutBuilder.Client.UiPrelude
  ( cls
  , module HalogenExports
  , module Prelude
  ) where

import Prelude hiding (div) as Prelude

import Halogen.HTML as HH
import Halogen as H
import Halogen.HTML.Properties as HP

import Halogen.HTML (HTML, button, div, img, input, li, span, table, tbody, text, thead, td, th, tr, ul) as HalogenExports
import Halogen.HTML.Events (onClick, onValueInput) as HalogenExports

cls :: forall r i. String -> HH.IProp (class :: String | r) i
cls name = HP.class_ (H.ClassName name)
