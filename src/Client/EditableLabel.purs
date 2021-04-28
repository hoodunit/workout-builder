module WorkoutBuilder.Client.EditableLabel where

import WorkoutBuilder.Client.UiPrelude

import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect)
import Halogen as H
import Halogen.HTML.Properties as HP
import Halogen.HTML.Events as HE
import Web.UIEvent.KeyboardEvent as KeyboardEvent
import WorkoutBuilder.Client.Images (images)

data Action =
  OpenEdit
  | CloseWithoutSave
  | CloseWithSave
  | OnEdit {label :: String}
  | Receive Input
  | Noop

type State =
  { editing :: Boolean
  , label :: String
  , extraClass :: Maybe String }

type Input =
  { label :: String
  , extraClass :: Maybe String }
  
data Output = Saved { label :: String }

editableLabel :: forall q i o m
                 . MonadEffect m
                 => H.Component q Input Output m
editableLabel =
  H.mkComponent
    { initialState: \{label, extraClass} ->
       { editing: false
       , label
       , extraClass }
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction
                                   , receive = Just <<< Receive }
    }

render :: forall cs m. State -> H.ComponentHTML Action cs m
render {label, editing, extraClass} =
  div [cls ("editable-label" <> extraClass_)]
    case editing of
      true -> [ input [ cls "editable-label__input"
                      , HP.value label
                      , onValueInput (\newLabel -> OnEdit {label: newLabel})
                      , HE.onKeyUp (KeyboardEvent.key >>> case _ of
                                       "Enter" -> CloseWithSave
                                       _ -> Noop)]
              , div [ cls "button--light icon-button"
                    , onClick \_ -> CloseWithSave ]
                [ img [ cls "btn-check", HP.src images.check ] ]
              , div [ cls "editable-label__button button--light icon-button"
                    , onClick \_ -> CloseWithoutSave ]
                [ img [ cls "btn-close", HP.src images.close ] ]
              ]
      false -> [ div [cls "editable-label__label"] [text label]
               , div [ cls "button--light icon-button"
                     , onClick \_ -> OpenEdit]
                 [ img [ cls "btn-edit", HP.src images.edit ] ]
               ]
  where
    extraClass_ :: String
    extraClass_ = case extraClass of
                   Just c -> " " <> c
                   Nothing -> ""

handleAction :: forall cs o m. MonadEffect m => Action → H.HalogenM State Action cs Output m Unit
handleAction action = case action of
  Noop -> pure unit
  OpenEdit -> H.modify_ \s -> s { editing = true }
  OnEdit {label} -> H.modify_ \s -> s { label = label }
  CloseWithoutSave -> H.modify_ \s -> s { editing = false }
  CloseWithSave -> do
    {label} <- H.get
    H.modify_ \s -> s { editing = false }
    H.raise (Saved {label})
  Receive props -> do
    H.modify_ \s -> s { label = props.label, extraClass = props.extraClass }
