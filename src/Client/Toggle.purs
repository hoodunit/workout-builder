module WorkoutBuilder.Client.Toggle where

import WorkoutBuilder.Client.UiPrelude

import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import WorkoutBuilder.Client.Images (images)

toggle :: forall w a. String -> a -> Boolean -> HTML w a
toggle label action active =
  div [ cls ("toggle" <> toggledClass)
         , HE.onClick \_ -> action ]
    [ img [ HP.src images.check ]
    , text label ]
  where
    toggledClass = if active then " toggle--active" else ""
