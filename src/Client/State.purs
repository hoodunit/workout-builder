module WorkoutBuilder.Client.State where

import Prelude
import WorkoutBuilder.Types

import Data.Array as Array
import Data.Int as Int
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromJust, fromMaybe)
import Data.Set (Set)
import Data.Set as Set
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (log)
import Halogen as H
import JSURI as Uri
import Partial.Unsafe (unsafePartial)
import Simple.JSON as SimpleJson
import Unsafe.Coerce (unsafeCoerce)
import Web.Event.Event (Event, stopPropagation)
import Web.HTML as WebHTML
import Web.HTML.HTMLInputElement as HTMLInputElement
import Web.HTML.Location as Location
import Web.HTML.Window as Window
import WorkoutBuilder.Client.EditableLabel as EditableLabel
import WorkoutBuilder.Client.UrlCodecs as UrlCodecs
import WorkoutBuilder.Programming (groupWithName, programParamDefaults)

nameLabel :: H.RefLabel
nameLabel = H.RefLabel "program-name"

type State
  = { workoutParams :: ProgramParams
    , lastPeriodization :: Map GroupName Periodization
    , infoBar :: InfoBarState
    , modal :: ModalState }

data ModalState
  = ModalAddingExerciseForGroup { group :: Group }
  | ModalEditingExercise { group :: Group, exercise :: Exercise, index :: Int }
  | ModalClosed

type InfoBarState =
  { isOpen :: Boolean }

data Action
  = SetParams ProgramParams
  | SetTargetSets { group :: GroupName, sets :: String }
  | SetGroupName { index :: Int, name :: String }
  | SetDupSchedule { group :: GroupName, schedule :: String }
  | TogglePeriodization { group :: GroupName }
  | AddDupDay { group :: GroupName, intensity :: Intensity }
  | SetDupDay { group :: GroupName, index :: Int, intensity :: Intensity }
  | RemoveDupDay { group :: GroupName, index :: Int }
  | SetDayGroups { index :: Int, groups :: Set GroupName }
  | AddScheduleDay
  | AddGroup
  | RemoveGroup { index :: Int }
  | RemoveScheduleDay { index :: Int }
  | SetScheduleDays { days :: Array ScheduleDay }
  | StopPropagation Event Action
  | ShowAddExerciseModal { group :: Group }
  | CloseModal
  | AddExercise { group :: Group, exercise :: Exercise }
  | RemoveExercise { group :: Group, index :: Int }
  | SetInfoBarIsOpen { isOpen :: Boolean }
  | ShowExerciseInfo { group :: Group, exercise :: Exercise, index :: Int }
  | EditExerciseSetMuscleRole { muscle :: Muscle, role :: Maybe MuscleRole }
  | EditExerciseSetCategory { category :: ExerciseCategory }
  | EditExerciseSetName { name :: String }
  | EditExerciseSetRepScheme { intensity :: Intensity, scheme :: RepScheme }
  | SaveEditedExercise { group :: Group, exercise :: Exercise, index :: Int }
  | SetProgramName EditableLabel.Output

handleAction :: forall cs o m. MonadEffect m => Action → H.HalogenM State Action cs o m Unit
handleAction action_ = do
  handleAction_ action_
  {workoutParams} <- H.get
  H.liftEffect $ UrlCodecs.writeParamsToUrlHash workoutParams

handleAction_ :: forall cs o m. MonadEffect m => Action → H.HalogenM State Action cs o m Unit
handleAction_ action_ =
  case action_ of
    SetParams params -> H.modify_ \st -> st { workoutParams = params }
    SetDupSchedule {group, schedule} -> do
      { workoutParams: { groups } } <- H.get
      let oldGroup = groupWithName groups group
      let (lastSchedule :: Maybe DupSchedule) = oldGroup
                         # map _.periodization
                         >>= (case _ of
                                    NoPeriodization -> Nothing
                                    DailyUndulating {schedule} -> Just schedule)
      let parsed = parseSchedule schedule
      let newSchedule = case parsed, lastSchedule of
            Just new, _ -> new
            Nothing, Just old -> old
            Nothing, Nothing -> []
      H.modify_ (modifyStateGroup group (_ { periodization = DailyUndulating {schedule: newSchedule} } ))
      pure unit
    SetTargetSets {group, sets: setsStr} ->
      case Int.fromString setsStr of
        Just sets -> H.modify_ (modifyStateGroup group (_ { targetSets = sets }))
        Nothing -> do
          pure unit
    SetGroupName {index, name} ->
      H.modify_ \s -> s { workoutParams { groups = Array.modifyAt index (_ { name = name }) s.workoutParams.groups
                                                   # fromMaybe s.workoutParams.groups } }
    TogglePeriodization {group} -> do
      {workoutParams, lastPeriodization} <- H.get
      let currentPeriod = groupWithName workoutParams.groups group
                          # map _.periodization
      let defaultPeriod = DailyUndulating {schedule: [L, M, H]}
      let lastPeriodOrDefault = Map.lookup group lastPeriodization
            # fromMaybe defaultPeriod
      let {newPeriod, newLast} = case currentPeriod of
            Just NoPeriodization ->
              { newPeriod: lastPeriodOrDefault, newLast: lastPeriodOrDefault }
            Just (DailyUndulating {schedule}) ->
              { newPeriod: NoPeriodization, newLast: DailyUndulating {schedule} }
            Nothing ->
              { newPeriod: lastPeriodOrDefault, newLast: lastPeriodOrDefault }
      H.modify_ (modifyStateGroup group (_ { periodization = newPeriod })
                 >>> (\st -> st { lastPeriodization = Map.insert group newLast st.lastPeriodization }))
      pure unit
    AddDupDay {group, intensity} -> do
      H.modify_ (modifyStateGroup group (\g -> g { periodization = updatePeriod_ (appendIntensity intensity) g.periodization }))
    SetDupDay {group, index, intensity} -> do
      H.modify_ (modifyStateGroup group (\g -> g { periodization = updatePeriod_ (setIntensity index intensity) g.periodization }))
    RemoveDupDay {group, index} -> do
      H.modify_ (modifyStateGroup group (\g -> g { periodization = updatePeriod_ (removeIntensity index) g.periodization }))
    SetDayGroups {index, groups} -> do
      H.modify_ \s -> s { workoutParams { days = Array.modifyAt index (updateScheduleDay groups) s.workoutParams.days
                                                 # fromMaybe s.workoutParams.days } }
    AddScheduleDay -> do
      H.modify_ \s -> s { workoutParams { days = s.workoutParams.days <> [ScheduleRest] } }
    AddGroup -> do
      let newGroup =
            { name: "New group"
            , exercises: []
            , periodization: NoPeriodization
            , targetSets: programParamDefaults.targetSets
            }
      H.modify_ \s -> s { workoutParams { groups = s.workoutParams.groups <> [newGroup] } }
    RemoveGroup {index} -> do
      H.modify_ \s -> s { workoutParams { groups = Array.deleteAt index s.workoutParams.groups# fromMaybe s.workoutParams.groups } }
    RemoveScheduleDay {index} -> do
      H.modify_ \s -> s { workoutParams { days = Array.deleteAt index s.workoutParams.days
                                                 # fromMaybe s.workoutParams.days } }
    SetScheduleDays {days} -> do
      H.modify_ \s -> s { workoutParams { days = days } }
    StopPropagation event action -> do
      H.liftEffect $ stopPropagation event 
      handleAction action
    ShowAddExerciseModal {group} -> H.modify_ \s -> s { modal = ModalAddingExerciseForGroup {group} }
    CloseModal -> H.modify_ \s -> s { modal = ModalClosed }
    AddExercise {group, exercise} -> do
      H.modify_ (modifyStateGroup group.name (\g -> g { exercises = Array.cons exercise g.exercises })
                 >>> \s -> s { modal = ModalClosed })
    RemoveExercise {group, index} -> do
      H.modify_ (modifyStateGroup group.name (\g -> g { exercises = Array.deleteAt index g.exercises # fromMaybe g.exercises })
                 >>> \s -> s { modal = ModalClosed })
    SetInfoBarIsOpen {isOpen} -> H.modify_ \s -> s { infoBar { isOpen = isOpen } }
    ShowExerciseInfo {group, exercise, index} -> do
      H.modify_ \s -> s { modal = ModalEditingExercise {group, exercise, index} }
    EditExerciseSetMuscleRole {muscle, role} ->
      editExercise (\e -> e { muscles = setMuscle muscle role e.muscles })
    EditExerciseSetCategory {category} -> editExercise (_ { category = category })
    EditExerciseSetName {name} -> editExercise (_ { name = name })
    EditExerciseSetRepScheme {intensity, scheme} ->
      editExercise (\e -> e { scheme = Map.insert intensity scheme e.scheme })
    SaveEditedExercise {group, index, exercise} -> do
      {workoutParams} <- H.get
      H.modify_ (modifyStateGroup group.name (\g -> g { exercises = Array.updateAt index exercise g.exercises # fromMaybe g.exercises })
        >>> \s -> s { modal = ModalClosed })
    SetProgramName (EditableLabel.Saved {label})-> H.modify_ \s -> s { workoutParams { name = label } }

readInputValue :: forall cs o m
                  . MonadEffect m
                  => H.RefLabel -> H.HalogenM State Action cs o m (Maybe String)
readInputValue ref = do
  elem <- H.getRef ref
  case elem of
    Nothing -> pure Nothing
    Just elem_ -> do
      val <- liftEffect (HTMLInputElement.value (unsafeCoerce elem_))
      pure (Just val)

editExercise :: forall cs o m
. MonadEffect m => (Exercise -> Exercise) -> H.HalogenM State Action cs o m Unit
editExercise fn = do
  {modal} <- H.get
  case modal of
    ModalEditingExercise {group, exercise, index} -> do
      let newExercise = fn exercise
      H.modify_ \s -> s { modal = ModalEditingExercise {group, exercise: newExercise, index} }
    _ -> log "Error: attempted to edit muscle role but no exercise was being edited"

setMuscle :: Muscle -> Maybe MuscleRole -> ExerciseMuscles -> ExerciseMuscles
setMuscle muscle role {target, synergists, stabilizers} =
  case role of
    Just TargetMuscle -> { target: Set.insert muscle target
                         , synergists: Set.delete muscle synergists
                         , stabilizers: Set.delete muscle stabilizers }
    Just SynergistMuscle -> { target: Set.delete muscle target
                            , synergists: Set.insert muscle synergists
                            , stabilizers: Set.delete muscle stabilizers }
    Just StabilizerMuscle -> { target: Set.delete muscle target
                             , synergists: Set.delete muscle synergists
                             , stabilizers: Set.insert muscle stabilizers }
    Nothing -> { target: Set.delete muscle target
               , synergists: Set.delete muscle synergists
               , stabilizers: Set.delete muscle stabilizers }

modifyStateGroup :: GroupName -> (Group -> Group) -> State -> State
modifyStateGroup name fn state =
  state { workoutParams { groups = modifyGroup name fn state.workoutParams.groups } }

modifyGroup :: GroupName -> (Group -> Group) -> Array Group -> Array Group
modifyGroup name fn groups =
  (\g -> if g.name == name then fn g else g) <$> groups

appendIntensity :: Intensity -> DupSchedule -> DupSchedule
appendIntensity i schedule = (schedule <> [i])

removeIntensity :: Int -> DupSchedule -> DupSchedule
removeIntensity index schedule =
  case Array.deleteAt index schedule of
    (Just new) -> new
    Nothing -> schedule

setIntensity :: Int -> Intensity -> DupSchedule -> DupSchedule
setIntensity ind i schedule =
  case Array.updateAt ind i schedule of
    (Just new) -> new
    Nothing -> schedule

updatePeriod :: (DupSchedule -> DupSchedule) -> Maybe Periodization -> Maybe Periodization
updatePeriod fn = map (updatePeriod_ fn)

updatePeriod_ :: (DupSchedule -> DupSchedule) -> Periodization -> Periodization
updatePeriod_ fn NoPeriodization = NoPeriodization
updatePeriod_ fn (DailyUndulating {schedule}) = DailyUndulating {schedule: fn schedule}

parseSchedule :: String -> Maybe DupSchedule
parseSchedule str = Nothing

updateScheduleDay :: Set GroupName -> ScheduleDay -> ScheduleDay
updateScheduleDay newGroups _ =
  if Set.isEmpty newGroups
     then ScheduleRest
     else ScheduleWorkout {groups: newGroups}
