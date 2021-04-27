module WorkoutBuilder.Types where

import Prelude

import Control.Monad.Except (throwError)
import Data.Eq.Generic (genericEq)
import Data.Generic.Rep (class Generic)
import Data.Map (Map)
import Data.Map as Map
import Data.Ord.Generic (genericCompare)
import Data.Set (Set)
import Data.Set as Set
import Data.Show.Generic (genericShow)
import Data.Tuple (Tuple(..))
import Foreign (F, ForeignError(..), unsafeToForeign)
import Simple.JSON as SimpleJson

type ProgramParams =
  { name :: String
  , days :: Array ScheduleDay
  , groups :: Array Group
  , defaults :: ProgramParamDefaults
  }

type Group =
  { name :: GroupName
  , exercises :: Array Exercise
  , periodization :: Periodization
  , targetSets :: Int }

type GroupName = String

type ProgramParamDefaults =
  { targetSets :: Int
  , repScheme :: RepScheme
  , minSets :: Int }

data ScheduleDay = ScheduleWorkout ScheduleWorkoutDay | ScheduleRest
derive instance genericScheduleDay :: Generic ScheduleDay _
instance showScheduleDay :: Show ScheduleDay where
  show = genericShow

type ScheduleWorkoutDay =
  -- Exercises with these groups are allowed to be schedule on this day.
  -- Empty set == full body/all muscles
  { groups :: Set GroupName }

workoutDay :: Set GroupName -> ScheduleDay
workoutDay groups = ScheduleWorkout { groups }

emptyScheduleWorkoutDay :: ScheduleWorkoutDay
emptyScheduleWorkoutDay = { groups: Set.empty }

type PeriodizationPlan = Map Group Periodization

data Periodization = NoPeriodization | DailyUndulating { schedule :: DupSchedule }
type DupSchedule = Array Intensity

derive instance genericPeriodization :: Generic Periodization _
instance eqPeriodization :: Eq Periodization where
  eq = genericEq
instance ordPeriodization :: Ord Periodization where
  compare = genericCompare
instance showPeriodization :: Show Periodization where
  show = genericShow

-- Program: sequence of days that repeats
type Program =
  { days :: Array DayPlan }

data DayPlan = WorkoutDay Workout | RestDay

instance showDayPlan :: Show DayPlan where
  show RestDay = "RestDay"
  show (WorkoutDay workout) = "WorkoutDay (" <> show workout <> ")"

emptyWorkout :: Workout
emptyWorkout = { exercises: [] }

type Workout =
  { exercises :: Array WorkoutExercise }

type WorkoutExercise =
  { exercise :: Exercise
  , group :: GroupName
  -- Here rep scheme sets = min sets
  , repScheme :: RepScheme }

type RepScheme =
  { sets :: Int
  , reps :: RepRange }

type RepRange = {min :: Int, max :: Int}

type Exercise =
  { name :: String
  , scheme :: Map Intensity RepScheme
  , muscles :: ExerciseMuscles
  , category :: ExerciseCategory
  }

type ExerciseMuscles =
  -- Primary mover/agonist - typically only one
  { target :: Set Muscle
  -- Assisting muscles in primary movement
  , synergists :: Set Muscle
  , stabilizers :: Set Muscle }

data MuscleRole = TargetMuscle | SynergistMuscle | StabilizerMuscle
derive instance genericMuscleRole :: Generic MuscleRole _
instance showMuscleRole :: Show MuscleRole where
  show = genericShow
instance ordMuscleRole :: Ord MuscleRole where
  compare = genericCompare
instance eqMuscleRole :: Eq MuscleRole where
  eq = genericEq

data ExerciseCategory = Compound | Isolation

derive instance genericExerciseCategory :: Generic ExerciseCategory _
instance showExerciseCategory :: Show ExerciseCategory where
  show = genericShow
instance ordExerciseCategory :: Ord ExerciseCategory where
  compare = genericCompare
instance eqExerciseCategory :: Eq ExerciseCategory where
  eq = genericEq
instance writeForeignExerciseCategory :: SimpleJson.WriteForeign ExerciseCategory where
  writeImpl Compound = unsafeToForeign "compound"
  writeImpl Isolation = unsafeToForeign "isolation"
instance readForeignExerciseCategory :: SimpleJson.ReadForeign ExerciseCategory where
  readImpl val = do
    str <- SimpleJson.readImpl val
    case (str :: String) of
      "compound" -> pure Compound
      "isolation" -> pure Compound
      other -> err $ "Could not parse '" <> other <> "' as exercise category"
    where
      err = throwError <<< pure <<< ForeignError

exercise :: String -> ExerciseCategory -> Exercise
exercise name category =
  { name
  , scheme: defaultRepSchemes
  , muscles: emptyMuscles
  , category }

emptyMuscles :: ExerciseMuscles
emptyMuscles =
  { target: Set.empty
  , synergists: Set.empty
  , stabilizers: Set.empty }

type Muscle = String

data Intensity
  =
    VH -- Very heavy
  | H  -- Heavy
  | M  -- Moderate
  | L  -- Light
  | VL  -- Very Light

allIntensities :: Array Intensity
allIntensities = [VH, H, M, L, VL]

derive instance genericIntensity :: Generic Intensity _
instance showIntensity :: Show Intensity where
  show = genericShow
instance ordIntensity :: Ord Intensity where
  compare = genericCompare
instance eqIntensity :: Eq Intensity where
  eq = genericEq
instance writeForeignIntensity :: SimpleJson.WriteForeign Intensity where
  writeImpl VH = unsafeToForeign "VH"
  writeImpl H = unsafeToForeign "H"
  writeImpl M = unsafeToForeign "M"
  writeImpl L = unsafeToForeign "L"
  writeImpl VL = unsafeToForeign "VL"
instance readForeignIntensity :: SimpleJson.ReadForeign Intensity where
  readImpl val = do
    str <- SimpleJson.readImpl val
    case (str :: String) of
      "VH" -> pure VH
      "H" -> pure H
      "M" -> pure M
      "L" -> pure L
      "VL" -> pure VL
      other -> err $ "Could not parse '" <> other <> "' as intensity"
    where
      err = throwError <<< pure <<< ForeignError

defaultRepSchemes :: Map Intensity RepScheme
defaultRepSchemes =
  Map.fromFoldable
  [ Tuple VH {sets: 5, reps: {min: 1, max: 3}}
  , Tuple H {sets: 4, reps: {min: 3, max: 4}}
  , Tuple M {sets: 1, reps: {min: 5, max: 8}}
  , Tuple L {sets: 1, reps: {min: 8, max: 12}}
  , Tuple VL {sets: 1, reps: {min: 12, max: 15}}
  ]

type ProgramVolume =
  { total :: Volume
  , groups :: Array GroupVolume
  , day :: Array Volume
  , muscles :: Map Muscle MuscleExerciseVolume}

type MuscleExerciseVolume =
  { targetCompound :: Volume
  , targetIsolation :: Volume
  , synergists :: Volume
  , stabilizers :: Volume }

type PlanVolume =
  { total :: Volume
  , groups :: Array GroupVolume
  , day :: WeekMap Volume }

type WeekMap a = Record (WeekPlanRows a)

type WeekPlanRows a = 
  ( mo :: a
  , tu :: a
  , we :: a
  , th :: a
  , fr :: a
  , sa :: a
  , su :: a
  )

type GroupVolume =
  { group :: GroupName, volume :: Volume }

type Volume =
  { sets :: Number
  , reps :: Range }

type Range =
  { min :: Number
  , max :: Number }
