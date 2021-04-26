module WorkoutBuilder.Client.EditExerciseModal where

import WorkoutBuilder.Client.UiPrelude
import WorkoutBuilder.Types

import Data.Array ((!!))
import Data.Array as Array
import Data.Int as Int
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import WorkoutBuilder.Client.Images (images)
import WorkoutBuilder.Client.State (Action(..))
import WorkoutBuilder.Client.Switch (Selected, switch)
import WorkoutBuilder.Muscles (allMuscles)

editExerciseModal :: forall w
                     . {group :: Group, index :: Int, exercise :: Exercise }
                     -> HTML w Action
editExerciseModal {group, index, exercise: exercise@{name, scheme, muscles, category}} =
  div [cls "modal-content"]
    [ div [cls "modal-title-bar"]
      [ div [cls "modal-title-bar__left"]
        [ div [cls "modal-title"]
          [ text $ "Edit " <> name ]
        , button ([cls (if saveEnabled then "" else "btn--disabled")] <> saveOnClick)
          [ text "Save" ]
        ]
      , div [ cls "icon-button", HE.onClick (const CloseModal)]
        [ img [ cls "btn-close", HP.src images.close ] ]
      ]
    , div [cls "modal-body"]
      [ formInput "Name:" (input [ HP.value name
                                 , onValueInput \value -> EditExerciseSetName { name: value } ])
      , formInput "Exercise type:" (categorySwitch category)
      , div [cls "form-label"] [text "Rep ranges:"]
      , div [cls "rep-range-inputs"] (repRangeInput scheme <$> allIntensities)
      , div [cls "form-label"] [text "Muscles used in exercise:"]
      , musclesList muscles
      , button [onClick (const $ RemoveExercise {group, index})] [text "Delete Exercise"]
      ]
    ]
  where
    saveEnabled = (group.exercises !! index) /= Just exercise
    saveOnClick = if saveEnabled
                  then [HE.onClick (const (SaveEditedExercise {group, index, exercise}))]
                  else []

formInput :: forall w i. String -> HTML w i -> HTML w i
formInput label content =
 div [cls "form-input"]
   [ div [cls "form-input__label"] [text label]
   , div [cls "form-input__input"] [content] ]

categorySwitch :: forall w. ExerciseCategory -> HTML w Action
categorySwitch category = switch options setCategory (Just category)
  where
    options = [ { label: "Compound", value: Compound }
              , { label: "Isolation", value: Isolation} ]
    setCategory {isActive: _, value} = EditExerciseSetCategory {category: value}

repRangeInput :: forall w. Map Intensity RepScheme -> Intensity -> HTML w Action
repRangeInput schemes intensity =
  div [cls "rep-range-input"]
    [ div [cls "rep-range-input__label"] [text title]
    , div [cls "rep-range-input__inputs"]
      [ input [ HP.value (show repScheme.reps.min)
              , onValueInput (Int.fromString
                              >>> fromMaybe repScheme.reps.min
                              >>> \val -> EditExerciseSetRepScheme {intensity, scheme: repScheme { reps { min = val }}}) ]
      , text "-"
      , input [ HP.value (show repScheme.reps.max)
              , onValueInput (Int.fromString
                              >>> fromMaybe repScheme.reps.max
                              >>> \val -> EditExerciseSetRepScheme {intensity, scheme: repScheme { reps { max = val }}}) ]
      , text "reps"
      ]
    , div [cls "rep-range-input__inputs"]
      [ text "Min sets:"
      , input [ HP.value (show repScheme.sets)
              , onValueInput (Int.fromString
                              >>> fromMaybe repScheme.sets
                              >>> \val -> EditExerciseSetRepScheme {intensity, scheme: repScheme { sets = val }} ) ]
      ]
    ]
  where
    title :: String
    title = intensityName intensity

    repScheme :: RepScheme
    repScheme = Map.lookup intensity schemes
                # fromMaybe {sets: 1, reps: {min: 5, max: 8}}

intensityName :: Intensity -> String
intensityName VH = "Very Heavy"
intensityName H = "Heavy"
intensityName M = "Moderate"
intensityName L = "Light"
intensityName VL = "Very Light"

musclesList :: forall w. ExerciseMuscles -> HTML w Action
musclesList {target, synergists, stabilizers} =
  div [cls "muscle-list"]
    (allMuscles
     # Array.sort
     # map addMuscleRole
     # map muscleListItem)
  where
    addMuscleRole :: Muscle -> Tuple (Maybe MuscleRole) Muscle
    addMuscleRole m | Set.member m target = Tuple (Just TargetMuscle) m
    addMuscleRole m | Set.member m synergists = Tuple (Just SynergistMuscle) m
    addMuscleRole m | Set.member m stabilizers = Tuple (Just StabilizerMuscle) m
    addMuscleRole m = Tuple Nothing m

muscleListItem :: forall w. Tuple (Maybe MuscleRole) Muscle -> HTML w Action
muscleListItem (Tuple role muscle) =
  div [cls "muscle-list__item"]
    [ div [cls $ "muscle-list__cell muscle-list__item__label" <> fontClass] [text muscle]
    , switch switchOptions setRole role ]
  where
    switchOptions =
      [ { label: "Target", value: TargetMuscle }
      , { label: "Supporting", value: SynergistMuscle }
      , { label: "Stabilizer", value: StabilizerMuscle }
      ]
    fontClass = case role of
      Just _ -> " label--medium--green"
      Nothing -> " label--medium--faded"

    setRole :: Selected MuscleRole -> Action
    setRole {isActive: false, value} = EditExerciseSetMuscleRole {muscle, role: Just value}
    setRole {isActive: true, value} = EditExerciseSetMuscleRole {muscle, role: Nothing}
