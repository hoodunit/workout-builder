module WorkoutBuilder.Client.AddExerciseModal where

import WorkoutBuilder.Client.UiPrelude
import WorkoutBuilder.Types

import Data.Array as Array
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import WorkoutBuilder.Client.Images (images)
import WorkoutBuilder.Client.State (Action(..))
import WorkoutBuilder.Exercises (allExercises)

addExerciseModal :: forall w. Group -> HTML w Action
addExerciseModal group =
  div [cls "modal-content"]
    [ div [cls "modal-title-bar"]
      [ div [cls "modal-title"]
        [ text $ "Add exercise to group '" <> group.name <> "'" ]
      , div [ cls "icon-button", HE.onClick (const CloseModal)]
        [ img [ cls "btn-close", HP.src images.close ] ]
      ]
    , div [cls "modal-body"]
      ([addNewExercise]
       <> (allExercises
       # Array.sortWith _.name
       # map (addExerciseRow group)))
    ]
  where
    addNewExercise =
      div [ cls "add-exercise-row"
          , HE.onClick (const $ AddExercise {group, exercise: newExercise})]
        [ div [cls "icon-button"] [img [cls "btn-add", HP.src images.add], text "New Exercise" ]
        ]
    newExercise = exercise "New exercise" Compound

addExerciseRow :: forall w. Group -> Exercise -> HTML w Action
addExerciseRow group exercise@{name} =
  div [ cls "add-exercise-row"
         , HE.onClick (const $ AddExercise {group, exercise})]
    [ text name ]
