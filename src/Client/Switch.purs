module WorkoutBuilder.Client.Switch where

import WorkoutBuilder.Client.UiPrelude

import Data.Maybe (Maybe(..))
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

type SwitchOption a =
  { label :: String
  , value :: a }

type Selected a =
  { isActive :: Boolean
  , value :: a }

switch :: forall a action w
          . Eq a
          => Array (SwitchOption a)
          -> (Selected a -> action)
          -> Maybe a
          -> HTML w action
switch options onClick activeOption =
  div [cls "switch"]
    (option <$> options)
  where
    option :: SwitchOption a -> HTML w action
    option {label, value} =
      div [ cls (switchCls value)
             , HE.onClick (const $ onClick {isActive: Just value == activeOption, value})]
        [text label]

    switchCls :: a -> String
    switchCls opt | Just opt == activeOption = "switch__option--active"
    switchCls opt = "switch__option"
