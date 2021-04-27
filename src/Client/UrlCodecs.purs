module WorkoutBuilder.Client.UrlCodecs where

import Prelude
import WorkoutBuilder.OwnPrelude
import WorkoutBuilder.Types

import Control.Monad.Except (except, runExcept)
import Data.Array as Array
import Data.Either (Either(..), either)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromJust, fromMaybe)
import Data.String (Pattern(..))
import Data.String as String
import Data.Traversable (sequence)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Foreign (F)
import Foreign.Object (Object)
import Foreign.Object as Object
import JSURI as Uri
import Partial.Unsafe (unsafePartial)
import Simple.JSON as SimpleJson
import Web.HTML as WebHTML
import Web.HTML.Location as Location
import Web.HTML.Window as Window
import WorkoutBuilder.Client.LZString as LZString

type RawProgramParams =
  { name :: String
  , days :: Array (Maybe RawDay)
  , groups :: Array RawGroup
  , defaults :: ProgramParamDefaults
  }

type RawDay =
  { groups :: Array String }

type RawGroup =
  { name :: GroupName
  , exercises :: Array RawExercise
  , periodization :: RawPeriodization
  , targetSets :: Int }

type RawExercise =
  { name :: String
  , scheme :: Object RepScheme
  , muscles :: RawExerciseMuscles
  , category :: ExerciseCategory
  }

type RawPeriodization = Maybe {schedule :: Array Intensity}

type RawExerciseMuscles =
  { target :: Array String
  , synergists :: Array String
  , stabilizers :: Array String
  }

writeParamsToUrlHash :: ProgramParams -> Effect Unit
writeParamsToUrlHash params = do
  loc <- WebHTML.window >>= Window.location
  let encodedParams = encodeProgramParams params
  Location.setHash encodedParams loc

readParamsFromUrlHash :: Effect (Either String ProgramParams)
readParamsFromUrlHash = do
  hash <- WebHTML.window >>= Window.location >>= Location.hash
  let strippedHash = String.stripPrefix (Pattern "#") hash
                     # fromMaybe hash
  pure (decodeProgramParams strippedHash)

encodeProgramParams :: ProgramParams -> String
encodeProgramParams =
  programToRaw
  >>> SimpleJson.writeJSON
  >>> LZString.compressToEncodedURIComponent

decodeProgramParams :: String -> Either String ProgramParams
decodeProgramParams str =
  str
  # LZString.decompressFromEncodedURIComponent
  # SimpleJson.readJSON
  # except
  >>= programFromRaw
  # runExcept
  # either (Left <<< show) Right

encodeURIComponent :: String -> String
encodeURIComponent val = unsafePartial (fromJust (Uri.encodeURIComponent val))

decodeURIComponent :: String -> String
decodeURIComponent val = unsafePartial (fromJust (Uri.decodeURIComponent val))

programToRaw :: ProgramParams -> RawProgramParams
programToRaw {name, days, groups, defaults} =
  { name
  , days: dayToRaw <$> days
  , groups: groupToRaw <$> groups
  , defaults }

programFromRaw :: RawProgramParams -> F ProgramParams
programFromRaw {name, days, groups, defaults} = do
  groups_ <- sequence $ groupFromRaw <$> groups
  pure $
    { name
    , days: dayFromRaw <$> days
    , groups: groups_
    , defaults }

dayToRaw :: ScheduleDay -> Maybe RawDay
dayToRaw ScheduleRest = Nothing
dayToRaw (ScheduleWorkout {groups}) = Just {groups: Array.fromFoldable groups}

dayFromRaw :: Maybe RawDay -> ScheduleDay
dayFromRaw Nothing = ScheduleRest
dayFromRaw (Just {groups}) = ScheduleWorkout {groups: set groups}

groupToRaw :: Group -> RawGroup
groupToRaw {name, exercises, periodization, targetSets} =
  { name
  , exercises: exerciseToRaw <$> exercises
  , periodization: periodizationToRaw periodization
  , targetSets }

groupFromRaw :: RawGroup -> F Group
groupFromRaw {name, exercises, periodization, targetSets} = do
  exercises_ <- exercises
                # map exerciseFromRaw
                # sequence
  pure
    { name
    , exercises: exercises_
    , periodization: periodizationFromRaw periodization
    , targetSets
    }

periodizationToRaw :: Periodization -> RawPeriodization
periodizationToRaw NoPeriodization = Nothing
periodizationToRaw (DailyUndulating {schedule}) = Just {schedule}

periodizationFromRaw :: RawPeriodization -> Periodization
periodizationFromRaw Nothing = NoPeriodization
periodizationFromRaw (Just {schedule}) = DailyUndulating {schedule}

exerciseToRaw :: Exercise -> RawExercise
exerciseToRaw {name, scheme, muscles, category} =
  { name
  , scheme: schemeToRaw scheme
  , muscles: exerciseMusclesToRaw muscles
  , category
  }

exerciseFromRaw :: RawExercise -> F Exercise
exerciseFromRaw {name, scheme, muscles, category} = do
  scheme_ <- schemeFromRaw scheme
  pure
    { name
    , scheme: scheme_
    , muscles: exerciseMusclesFromRaw muscles
    , category }

schemeToRaw :: Map Intensity RepScheme -> Object RepScheme
schemeToRaw scheme =
  (Map.toUnfoldable scheme :: Array (Tuple Intensity RepScheme))
  # map (\(Tuple i s) -> Tuple (SimpleJson.writeJSON i) s)
  # Object.fromFoldable

schemeFromRaw :: Object RepScheme -> F (Map Intensity RepScheme)
schemeFromRaw scheme = do
  let (arr :: Array (Tuple String RepScheme)) = Object.toUnfoldable scheme
  readVals <- arr
              # map (\(Tuple i s) -> SimpleJson.readJSON i
                                     # map (\intens -> Tuple intens s))
              # sequence
              # except
  pure (Map.fromFoldable readVals)

mapToObject :: forall a. Map String a -> Object a
mapToObject m =
  (Map.toUnfoldable m :: Array (Tuple String a))
  # Object.fromFoldable

exerciseMusclesToRaw :: ExerciseMuscles -> RawExerciseMuscles
exerciseMusclesToRaw {target, synergists, stabilizers} =
  { target: Array.fromFoldable target
  , synergists: Array.fromFoldable synergists
  , stabilizers: Array.fromFoldable stabilizers
  }

exerciseMusclesFromRaw :: RawExerciseMuscles -> ExerciseMuscles
exerciseMusclesFromRaw {target, synergists, stabilizers} =
  { target: set target
  , synergists: set synergists
  , stabilizers: set stabilizers
  }
