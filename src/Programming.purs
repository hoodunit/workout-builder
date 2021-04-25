module WorkoutBuilder.Programming where

import Prelude
import WorkoutBuilder.Types

import Data.Array as Array
import Data.Foldable (foldMap, foldl)
import Data.Int (toNumber)
import Data.Int as Int
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Set (Set)
import Data.Set as Set

defaults :: ProgramParams
defaults =
  { name: "New Program"
  , days: []
  , groups: []
  , defaults: programParamDefaults }

programParamDefaults :: ProgramParamDefaults 
programParamDefaults = 
  { targetSets: 20
  , minSets: 1
  , repScheme: {sets: 3, reps: {min: 5, max: 8}} }
  
buildProgram :: ProgramParams -> Program
buildProgram params =
  resultState.program { days = adjustVolume params resultState.program.days }
  where

    resultState :: ProgramState
    resultState = Array.foldl (buildDay params) emptyState fullDays

    minNumWeeks :: Int
    minNumWeeks = 12

    numCycles :: Int
    numCycles = Int.ceil (7.0 * (toNumber minNumWeeks) / (toNumber $ Array.length params.days))

    fullDays :: Array ScheduleDay
    fullDays = params.days
               # Array.replicate numCycles
               # join

    emptyState :: ProgramState
    emptyState =
      { program: {days: []}
      , workoutsForGroup: Map.empty }

type ProgramState =
  { program :: Program
  , workoutsForGroup :: Map GroupName Int }

buildDay :: ProgramParams -> ProgramState -> ScheduleDay -> ProgramState
buildDay params state ScheduleRest =
  state {program {days = state.program.days <> [RestDay] }}
buildDay params {program, workoutsForGroup} (ScheduleWorkout {groups}) =
  { program: program { days = program.days <> [WorkoutDay {exercises: resultState.exercises}] }
  , workoutsForGroup: resultState.workoutsForGroup }
  where
    groupsToAdd :: Set GroupName
    groupsToAdd = if Set.isEmpty groups
                      then allExerciseGroups params
                      else groups

    groupsToAdd_ :: Set Group
    groupsToAdd_ = groupsToAdd
                   # Set.mapMaybe (groupWithName params.groups)

    resultState = foldl (addGroupToDay params) {exercises: [], workoutsForGroup} groupsToAdd_

groupWithName :: Array Group -> GroupName -> Maybe Group
groupWithName groups name = Array.find (\g -> g.name == name) groups

allExerciseGroups :: ProgramParams -> Set GroupName
allExerciseGroups {groups} = groups
  # foldMap (_.name >>> Set.singleton) 

type DayState =
  { exercises :: Array WorkoutExercise
  , workoutsForGroup :: Map GroupName Int }

addGroupToDay :: ProgramParams -> DayState -> Group -> DayState
addGroupToDay params {exercises, workoutsForGroup} group =
  { exercises: exercises <> groupExercises
  , workoutsForGroup: Map.insert group.name (numWorkouts + 1) workoutsForGroup }
  where
    groupExercises = group.exercises
      # map (\exercise -> {group: group.name, exercise, repScheme: exerciseRepScheme exercise})

    numWorkouts :: Int
    numWorkouts = Map.lookup group.name workoutsForGroup
                  # fromMaybe 0

    schedule :: Maybe (Array Intensity)
    schedule = case group.periodization of
                 NoPeriodization -> Nothing
                 DailyUndulating {schedule: s} -> Just s

    intensity :: Intensity
    intensity = schedule
      >>= (\arr -> Array.index arr (numWorkouts `mod` (Array.length arr)))
      # fromMaybe M

    exerciseRepScheme :: Exercise -> RepScheme
    exerciseRepScheme ex = Map.lookup intensity ex.scheme
                         # fromMaybe params.defaults.repScheme

-- Count num workouts with muscle in x weeks
-- Divide by number of weeks to get avg per week
-- Adjust set numbers based on this average
adjustVolume :: ProgramParams -> Array DayPlan -> Array DayPlan
adjustVolume params days = adjustDaySets <$> days
  where
    groupSetsPerProg :: Map GroupName Int
    groupSetsPerProg =
      params.groups
      # map (\g -> Map.singleton g.name (setsPerProg params g))
      # foldl Map.union Map.empty

    adjustDaySets :: DayPlan -> DayPlan
    adjustDaySets RestDay = RestDay
    adjustDaySets (WorkoutDay w) = (WorkoutDay w {exercises = adjustExercise <$> w.exercises})

    adjustExercise :: WorkoutExercise -> WorkoutExercise
    adjustExercise e = Map.lookup e.group groupSetsPerProg
                       # setExerciseSets e

    setExerciseSets :: WorkoutExercise -> Maybe Int -> WorkoutExercise
    setExerciseSets ex Nothing = ex { repScheme { sets = max ex.repScheme.sets params.defaults.minSets } }
    setExerciseSets ex (Just sets) = ex { repScheme { sets = max ex.repScheme.sets sets } }

setsPerProg :: ProgramParams -> Group -> Int
setsPerProg params group =
  Int.round (targetSets / (workoutsPerWeek * numExercises))
  where
    targetSets = toNumber group.targetSets
    numWorkouts = workoutsForMuscleGroup params group # toNumber
    numWeeks = (Array.length params.days # toNumber) / 7.0
    workoutsPerWeek = numWorkouts / numWeeks
    numExercises = Array.length group.exercises # toNumber

workoutsForMuscleGroup :: ProgramParams -> Group -> Int
workoutsForMuscleGroup {days} group =
  days
  # Array.filter (dayHasGroup group)
  # Array.length

dayHasGroup :: Group -> ScheduleDay -> Boolean
dayHasGroup _ ScheduleRest = false
dayHasGroup group (ScheduleWorkout {groups}) =
  Set.isEmpty groups || Set.member group.name groups
