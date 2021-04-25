module WorkoutBuilder.Client.Charts.Charts where

import WorkoutBuilder.Client.UiPrelude

import Data.Array as Array
import Data.Map (Map)
import Data.Map as Map
import Data.Set (Set)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Foreign.Object (Object)
import Foreign.Object as Object
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import WorkoutBuilder.Analysis (MuscleExercises, exercisesByMuscle, muscleVolumeByPushPull)
import WorkoutBuilder.Muscles (PushPullMap)
import WorkoutBuilder.Types (WorkoutExercise, Muscle, MuscleExerciseVolume, Program)

type ChartParams =
  { program :: Program
  , muscleVolume :: Map Muscle MuscleExerciseVolume }

type ChartData =
  { muscles :: Object ChartMuscleExercises
  , barData :: Object (Array BarData)
  }

type ChartMuscleExercises =
  { targetCompound :: Array String
  , targetIsolation :: Array String
  , synergists :: Array String
  , stabilizers :: Array String }

type BarData =
  { name :: String
  , targetCompound :: Number
  , targetIsolation :: Number
  , synergists :: Number
  , stabilizers :: Number }

foreign import render :: forall a. String -> ChartData -> a -> a

stackedBarChart :: forall w i. String -> ChartParams -> HTML w i
stackedBarChart id chartParams =
  div [cls "chart", HP.id id] []
  # render id (mkChartData chartParams)

mkChartData :: ChartParams -> ChartData
mkChartData {program, muscleVolume} =
  { muscles: exercisesByMuscle program
    # map toChartMuscleExercises
    # mapToObject
  , barData: muscleVolToChartData muscleVolume }

toChartMuscleExercises :: MuscleExercises -> ChartMuscleExercises
toChartMuscleExercises exs =
  { targetCompound: toArray exs.targetCompound
  , targetIsolation: toArray exs.targetIsolation
  , synergists: toArray exs.synergists
  , stabilizers: toArray exs.stabilizers }
  where
    toArray :: Set WorkoutExercise -> Array String
    toArray = Set.map _.exercise.name
              >>> Array.fromFoldable

mapToObject :: forall a. Map String a -> Object a
mapToObject m = Object.fromFoldable mapArr
  where
    mapArr :: Array (Tuple String a)
    mapArr = Map.toUnfoldable m

muscleVolToChartData :: Map Muscle MuscleExerciseVolume -> Object (Array BarData)
muscleVolToChartData musclesVol =
  musclesVol
  # muscleVolumeByPushPull
  # \byPushPull -> { push: asBarDataArray byPushPull.push
                   , pull: asBarDataArray byPushPull.pull 
                   , legs: asBarDataArray byPushPull.legs 
                   , core: asBarDataArray byPushPull.core }
  # Object.fromHomogeneous

asBarDataArray :: Map Muscle MuscleExerciseVolume -> Array BarData
asBarDataArray muscles = muscles
  # Map.toUnfoldable
  # map (\(Tuple muscle vols) ->
          { name: muscle
          , targetCompound: vols.targetCompound.sets
          , targetIsolation: vols.targetIsolation.sets
          , synergists: vols.synergists.sets
          , stabilizers: vols.stabilizers.sets
          })
