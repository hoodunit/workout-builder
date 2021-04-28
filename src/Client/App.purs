module WorkoutBuilder.Client.App where

import WorkoutBuilder.Client.UiPrelude
import WorkoutBuilder.Types

import Data.Array as Array
import Data.Foldable (foldl)
import Data.Int as Int
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Set (Set)
import Data.Set as Set
import Data.String as String
import Data.Tuple (Tuple(..))
import Debug as Debug
import Effect.Class (class MonadEffect)
import Effect.Class.Console (log)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Type.Proxy (Proxy(..))
import Web.Event.Event (Event, stopPropagation)
import Web.UIEvent.MouseEvent (MouseEvent, toEvent)
import WorkoutBuilder.Analysis (programVolume, volumeWorkoutTime, workoutTimeInMinutes)
import WorkoutBuilder.Client.AddExerciseModal (addExerciseModal)
import WorkoutBuilder.Client.Charts.Charts as Charts
import WorkoutBuilder.Client.EditExerciseModal (editExerciseModal)
import WorkoutBuilder.Client.EditableLabel (editableLabel)
import WorkoutBuilder.Client.EditableLabel as EditableLabel
import WorkoutBuilder.Client.Images (images)
import WorkoutBuilder.Client.InfoBar (infoBar)
import WorkoutBuilder.Client.State (Action(..), ModalState(..), State, nameLabel)
import WorkoutBuilder.Client.State as State
import WorkoutBuilder.Client.Toggle (toggle)
import WorkoutBuilder.Exercises (allExercises)
import WorkoutBuilder.Formatting (minutesToHourMinutes)
import WorkoutBuilder.Formatting as Fmt
import WorkoutBuilder.Muscles (allMuscles)
import WorkoutBuilder.Programming (allExerciseGroups, buildProgram, groupWithName)
import WorkoutBuilder.Samples (samplePrograms)
import WorkoutBuilder.Samples as Samples
import WorkoutBuilder.Types as Types

type Slots = (programTitle :: forall q. H.Slot q EditableLabel.Output Unit)

component :: forall q i o m. MonadEffect m => ProgramParams -> H.Component q i o m
component workoutParams =
  H.mkComponent
    { initialState: \_ -> { workoutParams
                          , lastPeriodization: Map.empty
                          , infoBar: { isOpen: true }
                          , modal: ModalClosed }
    , render: HH.lazy render
    , eval: H.mkEval H.defaultEval { handleAction = State.handleAction }
    }

render :: forall cs m. MonadEffect m => State -> H.ComponentHTML Action Slots m
render state = div [cls ("content" <> modalClass)]
               [ infoBar state.infoBar
               , HH.lazy mkContent state.workoutParams
               , mkModal state
               ]
  where
    modalClass = case state.modal of
      ModalClosed -> " content--modal-closed"
      _ -> ""

mkModal :: forall w. State -> HTML w Action
mkModal {modal} =
  div [cls modalWrapperClass]
    [ div [cls "modal-overlay", onClick (const CloseModal)] []
    , div [cls "modal"]
      case modal of
        ModalAddingExerciseForGroup {group} -> [addExerciseModal group]
        ModalEditingExercise props -> [editExerciseModal props]
        _ -> []
    ]
  where
    modalWrapperClass =
      case modal of
        ModalClosed -> "modal-wrapper--closed"
        _ -> "modal-wrapper"

mkContent :: forall cs m
             . MonadEffect m
             => ProgramParams
             -> H.ComponentHTML Action Slots m
mkContent workoutParams =
  let
    program :: Program
    program = buildProgram workoutParams

    volume :: ProgramVolume
    volume = programVolume program

    days :: Array (Tuple DayPlan Volume)
    days = Array.zip program.days volume.day
  in
    div [cls "content__main"] $
      [ itemRow "Sample Programs" [] mkSamplePrograms
      , itemRow "Program" []
        [ HH.slot (Proxy :: _ "programTitle") unit editableLabel { label: workoutParams.name, extraClass: Nothing } SetProgramName ]
      , itemRow "Exercises (By Group)" [addGroup] (workoutParams.groups
                                                   # Array.mapWithIndex groupBox)
      , itemRow "Schedule" (scheduleOptions <> [addScheduleDay])
        (workoutParams.days
         # Array.mapWithIndex (dayProgrammingBox workoutParams))
      , itemRow "Program Overview" []
        ([ volumeBox "Overall" volume.total ]
        <> ( (\{group, volume: v} -> volumeBox group v) <$> volume.groups))
      , itemRow "Program Volume by Muscle" [] [ muscleChart program volume.muscles ]
      , itemRow "Program: Week 1" []
        (days
          # Array.take 7
          # Array.mapWithIndex (\i (Tuple day vol) -> dayBox (i+1) day vol))
      , itemRow "Program: Week 2" []
        (days
          # Array.drop 7
          # Array.take 7
          # Array.mapWithIndex (\i (Tuple day vol) -> dayBox (i+8) day vol))
      , itemRow "Program: Week 3" []
        (days
          # Array.drop 14
          # Array.take 7
          # Array.mapWithIndex (\i (Tuple day vol) -> dayBox (i+14+1) day vol))
      , itemRow "Program: Week 4" []
        (days
          # Array.drop 21
          # Array.take 7
          # Array.mapWithIndex (\i (Tuple day vol) -> dayBox (i+21+1) day vol) )
      ]

mkSamplePrograms :: forall w. Array (HTML w Action)
mkSamplePrograms =
  samplePrograms
  # map (\p -> paramsShortcut p.name p)

muscleChart :: forall w i. Program -> Map Muscle MuscleExerciseVolume -> HTML w i
muscleChart program muscleVolume =
  div [cls "box box--wide"]
    [Charts.stackedBarChart "musclesChart" {program, muscleVolume}]

scheduleOptions :: forall w. Array (HTML w Action)
scheduleOptions =
  [ scheduleOption "Empty week" [ rest, rest, rest, rest, rest, rest, rest ]
  , scheduleOption "3x Full Body" [ workout, rest, workout, rest, workout, rest, rest ]
  , scheduleOption "4x Full Body" [ workout, workout, rest, rest, workout, workout, rest ]
  , scheduleOption "6x Full Body" [ workout, workout, workout, workout, workout, workout, rest ]
  , scheduleOption "Every Other" [ workout, rest ] ]
  where
    workout = ScheduleWorkout emptyScheduleWorkoutDay
    rest = ScheduleRest

scheduleOption :: forall w. String -> Array ScheduleDay -> HTML w Action
scheduleOption label days =
  div [ cls "button button--light", onClick \_ -> SetScheduleDays {days}]
    [ text label ]

addScheduleDay :: forall w. HTML w Action
addScheduleDay =
  div [ cls "icon-button"
         , onClick \_ -> AddScheduleDay]
    [ img [ cls "btn-add", HP.src images.add ] ]

addGroup :: forall w. HTML w Action
addGroup =
  div [ cls "button--light icon-button"
         , onClick \_ -> AddGroup]
    [ img [ cls "btn-add", HP.src images.add ]
    , text "New Group" ]

itemRow :: forall w i. String -> Array (HTML w i) -> Array (HTML w i) -> HTML w i
itemRow title buttons content =
  div [cls "row-container"]
    [ div [cls "row-container__title-bar"]
      [ div [cls "row-container__title-bar__title title"] [text title]
      , div [cls "row-container__title-bar__buttons"] buttons ]
    , div [cls "row"] content ]

paramsShortcut :: forall w. String -> ProgramParams -> HTML w Action
paramsShortcut name params =
  button
   [ onClick \_ -> SetParams params ]
   [ text name ]

dayProgrammingBox :: forall w. ProgramParams -> Int -> ScheduleDay -> HTML w Action
dayProgrammingBox params index plan =
  div [cls "box box--large"]
    [ div [cls "box__section box__section--title"]
      [ div [cls "title-bar"]
        [ div [cls "label--medium"]
          [ text ("Day " <> show (index + 1) <> ": " <> titleText) ]
        , div [ cls "icon-button", onClick \_ -> RemoveScheduleDay {index}]
          [ img [ cls "btn-close", HP.src images.close ] ]]]
    , div [cls "box__section"]
      [ div [cls "toggle-list"] toggles ]]
  where
    allGroups = allExerciseGroups params
    titleText = case plan of
                 ScheduleRest -> "Rest Day"
                 ScheduleWorkout _ -> "Workout"
    allToggle groups =
      let active = groups == allGroups
          allAction = if active
                         then SetDayGroups {index, groups: Set.empty}
                         else SetDayGroups {index, groups: allGroups}
      in toggle "all" allAction active

    groupToggle :: Set GroupName -> GroupName -> HTML w Action
    groupToggle selected group =
      let toggleAction = if active
                           then SetDayGroups {index, groups: Set.delete group selected}
                           else SetDayGroups {index, groups: Set.insert group selected}
          active = Set.member group selected
      in toggle group toggleAction active

    selectedGroups :: Set GroupName
    selectedGroups = case plan of
      ScheduleRest -> Set.empty
      ScheduleWorkout { groups } -> if Set.isEmpty groups then allGroups else groups

    toggles = [allToggle selectedGroups] <>
              (groupToggle selectedGroups <$> (Array.fromFoldable allGroups))

groupBox :: forall w. Int -> Group -> HTML w Action
groupBox index group =
  div [cls "box box--large"]
   [ div [ cls "box__section box__section--title"]
     [ div [cls "title-bar"]
       [ input [ HP.value group.name
               , onValueInput \e -> SetGroupName { index, name: e } ]
       , div [ cls "icon-button", onClick \_ -> RemoveGroup {index}]
         [ img [ cls "btn-close", HP.src images.close ] ]]]
   , div [cls "box__section"]
     [ div [cls "title label--small--faded"] [text "Exercises"]
     , div []
       ((Array.mapWithIndex exerciseItem group.exercises) <> [addExercise])
     ]
   , div [cls "box__section"]
     [ div [cls "title label--small--faded"] [text "Target Weekly Sets"]
     , input [ HP.value (show group.targetSets)
             , onValueInput \e -> SetTargetSets { group: group.name, sets: e } ]
     ]
   , div [ cls "box__section box__section--clickable"
            , onClick \_ -> TogglePeriodization {group: group.name}]
     [ div [ cls "title label--small--faded"] [text "Periodization"]
     , case group.periodization of
         (DailyUndulating {schedule}) -> periodizationSelector group schedule
         _ -> div [cls "label--small"] [text "None"]
     ]
   ]
  where
    exerciseItem :: Int -> Exercise -> HTML w Action
    exerciseItem index exercise@{name, category} =
      div [ cls "exercise-entry--button"
          , onClick (const $ ShowExerciseInfo {group, exercise, index})]
      [ div [cls "exercise-entry__label"] [text name]
      , div [cls "icon-button"]
        [ img [cls "btn-settings", HP.src images.settings ] ]
      ]
    addExercise :: HTML w Action
    addExercise = div [ cls "exercise-entry--button--center"
                         , onClick (const $ ShowAddExerciseModal {group})]
      [ img [ cls "exercise-entry__btn btn-add", HP.src images.add ]
      , div [cls "exercise-entry__label"] [text "Add Exercise"] ]
      
                      

periodizationSelector :: forall w. Group -> DupSchedule -> HTML w Action
periodizationSelector group schedule =
  div [cls "tag-list"]
    ((Array.mapWithIndex (intensitySelector group) schedule)
     <> [addIntensity group])

intensitySelector :: forall w. Group -> Int -> Intensity -> HTML w Action
intensitySelector group index intensity =
  div [cls "tag-dropdown"]
   [ div [cls "tag tag--selected"] [text (show intensity)]
   , div [cls "tag-dropdown__dropdown"]
     ((intensitySel <$> allIntensities) <> [removeIntensity])
   ]
  where
    activeCls i = if i == intensity then " tag--active" else ""
    intensitySel i = div [ cls ("tag tag--selector" <> activeCls i)
                            , onClick (noPropagate (SetDupDay {group: group.name, index, intensity: i}))]
                       [text (show i)]
    removeIntensity = div [cls "tag tag--selector"
                             , onClick (noPropagate (RemoveDupDay {group: group.name, index}))]
                        [ img [ cls "btn-close", HP.src images.close ] ]

addIntensity :: forall w. Group -> HTML w Action
addIntensity group =
  div [cls "tag-dropdown tag-dropdown--add"]
   [ div [cls "tag tag--selected"]
     [ img [ cls "btn-add btn-add--small", HP.src images.add ] ]
   , div [cls "tag-dropdown__dropdown"]
     (intensitySel <$> allIntensities)
   ]
  where
    intensitySel i = div [ cls "tag tag--selector"
                         , onClick (noPropagate (AddDupDay {group: group.name, intensity: i})) ]
                       [ text (show i) ]

noPropagate :: Action -> MouseEvent -> Action
noPropagate action event = StopPropagation (toEvent event) action

volumeBox :: forall w i. String -> Volume -> HTML w i
volumeBox title vol@{sets, reps} =
  div [cls "box box--medium"]
   [ div [cls "box__section box__section--title"]
     [ div [cls "label--medium--heavy"] [text title]]
   , div [cls "box__section"]
    [ div [cls "title label--small--faded"] [text "Weekly Volume"]
    , div [] [text (Fmt.round sets <> " sets")]
    , div [] [text (showRepVol reps)]
    , div [] [text (volumeWorkoutTime vol # minutesToHourMinutes)]
    ]
   
]

dayBox :: forall w i. Int -> DayPlan -> Volume -> HTML w i
dayBox dayNum RestDay vol =
  div [cls "box box--large"]
   [ div [cls "box__section box__section--title"]
     [ div [cls "label--medium--light"] [text ("Day " <> show dayNum)]]
   , div [cls "box__section"]
     [ div [] [text "(Rest day)"]
     ]
   ]
dayBox dayNum day@(WorkoutDay workout) vol =
  div [cls "box box--large"]
   [ div [cls "box__section box__section--title"]
     [ div [cls "label--medium--light"] [text ("Day " <> show dayNum)]]
   , div [cls "box__section"]
     [ div [] [text ((show $ Array.length workout.exercises) <> " exercises")]
     , div [] [text (Fmt.round vol.sets <> " sets")]
     , div [] [text (showRepVol vol.reps)]
     , div [] [text (workoutTimeInMinutes day # minutesToHourMinutes)]
     ]
   , div [cls "box__section"]
     [ div [] [(workout.exercises
                   # map _.group
                   # Array.nubEq
                   # String.joinWith ", "
                   # text)]
     ]
   , div [cls "box__section"]
     [ table [cls "exercise-table"]
       [tbody [] (exerciseRow <$> workout.exercises)]
     ]
   ]

exerciseRow :: forall w i. WorkoutExercise -> HTML w i
exerciseRow {exercise, repScheme, group} =
  tr [cls "text--small"]
    [ td [cls "nowrap"] [text ("(" <> group <> ")")]
    , td [] [text exercise.name]
    , td [cls "nowrap"] [text (dumpRepScheme repScheme)]
    ]

dumpRepScheme :: RepScheme -> String
dumpRepScheme {sets: 0, reps: {min: 0, max: 0}} = ""
dumpRepScheme {sets, reps: {min, max}} | min == max = show sets <> "x" <> show min
dumpRepScheme {sets, reps: {min, max}} = show sets <> "x" <> show min <> "-" <> show max

showRepVol :: Range -> String
showRepVol reps | reps.min == reps.max = show (Int.round reps.min) <> " reps"
showRepVol reps = show (Int.round reps.min) <> " - " <> show (Int.round reps.max) <> " reps"
