module WorkoutBuilder.Analysis where

import Prelude
import WorkoutBuilder.Types

import Data.Array as Array
import Data.Foldable (fold, foldMap, foldl, sum)
import Data.Int (toNumber)
import Data.Int as Int
import Data.Map (Map)
import Data.Map as Map
import Data.Monoid.Additive (Additive(..))
import Data.Newtype (unwrap)
import Data.Set (Set)
import Data.Set as Set
import Data.Symbol (class IsSymbol, SProxy(..))
import Data.Tuple (Tuple(..))
import Prim.Row as Row
import Record as Record
import WorkoutBuilder.Muscles (PushPullMap, allMuscles, byPushPull)
import WorkoutBuilder.OwnPrelude

type MuscleExercises =
  { targetCompound :: Set WorkoutExercise
  , targetIsolation :: Set WorkoutExercise
  , synergists :: Set WorkoutExercise
  , stabilizers :: Set WorkoutExercise }

minutesPerSet :: Number
minutesPerSet = 3.5

programVolume :: Program -> ProgramVolume
programVolume program =
  { total: toWeeklyVol total
  , groups: fullGroups
             # Array.fromFoldable
             # map (\group -> { group, volume: toWeeklyVol (sumGroup group) })
  , day: dayVol
  , muscles: muscleVolume program
             # map muscleVolToWeeklyVol }
  where
    fullGroups :: Set GroupName
    fullGroups = foldMap dayGroups program.days

    dayVol :: Array Volume
    dayVol = sumDayVolume <$> program.days

    total :: Volume
    total = sum dayVol

    toWeeklyVol :: Volume -> Volume
    toWeeklyVol vol = { sets: toWeeklyTotal vol.sets
                      , reps: { min: toWeeklyTotal vol.reps.min
                              , max: toWeeklyTotal vol.reps.max}}

    muscleVolToWeeklyVol :: MuscleExerciseVolume -> MuscleExerciseVolume
    muscleVolToWeeklyVol { targetCompound, targetIsolation, synergists, stabilizers } =
      { targetCompound: toWeeklyVol targetCompound
      , targetIsolation: toWeeklyVol targetIsolation
      , synergists: toWeeklyVol synergists
      , stabilizers: toWeeklyVol stabilizers }

    toWeeklyTotal :: Number -> Number
    toWeeklyTotal val =
      val * 7.0 / (toNumber $ Array.length program.days)

    sumGroup :: GroupName -> Volume
    sumGroup group = sum ((sumDayIf (\ex -> ex.group == group)) <$> program.days)

muscleVolume :: Program -> Map Muscle MuscleExerciseVolume
muscleVolume {days} =
  days
  # map dayMuscleVolume
  # foldl (Map.unionWith addMuscleExerciseVolume) emptyMuscleMap

dayMuscleVolume :: DayPlan -> Map Muscle MuscleExerciseVolume
dayMuscleVolume RestDay = Map.empty
dayMuscleVolume (WorkoutDay {exercises}) =
  exercises
  # map exerciseMuscleVolume
  # foldl (Map.unionWith addMuscleExerciseVolume) Map.empty

exerciseMuscleVolume :: WorkoutExercise -> Map Muscle MuscleExerciseVolume
exerciseMuscleVolume {exercise: {category, muscles}, repScheme} =
  [ getVolume muscles.target TargetMuscle
  , getVolume muscles.synergists SynergistMuscle
  , getVolume muscles.stabilizers StabilizerMuscle ]
  # foldl (Map.unionWith addMuscleExerciseVolume) Map.empty
  where
    getVolume :: Set Muscle -> MuscleRole -> Map Muscle MuscleExerciseVolume
    getVolume ms role = ms
      # Array.fromFoldable
      # map (\m -> Map.singleton m (mkVol category role))
      # foldl (Map.unionWith addMuscleExerciseVolume) Map.empty

    vol :: Volume
    vol = repSchemeVolume repScheme

    mkVol :: ExerciseCategory -> MuscleRole -> MuscleExerciseVolume
    mkVol Compound TargetMuscle = emptyMuscleExerciseVol { targetCompound = vol }
    mkVol Compound SynergistMuscle = emptyMuscleExerciseVol { synergists = vol }
    mkVol Compound StabilizerMuscle = emptyMuscleExerciseVol { stabilizers = vol }
    mkVol Isolation TargetMuscle = emptyMuscleExerciseVol { targetIsolation = vol }
    mkVol Isolation SynergistMuscle = emptyMuscleExerciseVol { synergists = vol }
    mkVol Isolation StabilizerMuscle = emptyMuscleExerciseVol { stabilizers = vol }

repSchemeVolume :: RepScheme -> Volume
repSchemeVolume {sets, reps} =
  { sets: toNumber sets, reps: {min: toNumber (sets * reps.min), max: toNumber (sets * reps.max)} }

emptyMuscleMap :: Map Muscle MuscleExerciseVolume
emptyMuscleMap =
  allMuscles
  # map (\m -> Tuple m emptyMuscleExerciseVol)
  # Map.fromFoldable

emptyMuscleExerciseVol :: MuscleExerciseVolume
emptyMuscleExerciseVol =
  { targetCompound: emptyVol
  , targetIsolation: emptyVol
  , synergists: emptyVol
  , stabilizers: emptyVol }

emptyVol :: Volume
emptyVol = {sets: 0.0, reps: {min: 0.0, max: 0.0}}

addMuscleExerciseVolume :: MuscleExerciseVolume -> MuscleExerciseVolume -> MuscleExerciseVolume
addMuscleExerciseVolume volA volB =
  { targetCompound: addVolume volA.targetCompound volB.targetCompound
  , targetIsolation: addVolume volA.targetIsolation volB.targetIsolation
  , synergists: addVolume volA.synergists volB.synergists
  , stabilizers: addVolume volA.stabilizers volB.stabilizers }

addVolume :: Volume -> Volume -> Volume
addVolume volA volB =
  { sets: volA.sets + volB.sets
  , reps: { min: volA.reps.min + volB.reps.min
          , max: volA.reps.max + volB.reps.max }}

sumDayVolume :: DayPlan -> Volume
sumDayVolume day =
 { sets: sumSets day
  , reps: { min: sumRepsMin day
          , max: sumRepsMax day}}

sumDayVolume_ :: DayPlan -> Volume
sumDayVolume_ day = unwrapIt $ foldDayField foldIt day
  where
    foldIt = (\ex -> { sets: Additive (toNumber ex.repScheme.sets)
                     , reps: { min: Additive (toNumber ex.repScheme.reps.min)
                             , max: Additive (toNumber ex.repScheme.reps.max)}})
    unwrapIt v = { sets: unwrap v.sets, reps: {min: unwrap v.reps.min, max: unwrap v.reps.max}}

sumDayIf :: (WorkoutExercise -> Boolean) -> DayPlan -> Volume
sumDayIf pred day = unwrapIt $ foldDayField foldIt day
  where
    foldIt ex | not (pred ex) = { sets: Additive 0.0, reps: { min: Additive 0.0, max: Additive 0.0}}
    foldIt ex = { sets: Additive (toNumber ex.repScheme.sets)
                , reps: { min: Additive (toNumber $ ex.repScheme.reps.min * ex.repScheme.sets)
                        , max: Additive (toNumber $ ex.repScheme.reps.max * ex.repScheme.sets) }}
    unwrapIt v = { sets: unwrap v.sets, reps: {min: unwrap v.reps.min, max: unwrap v.reps.max}}

sumSets :: DayPlan -> Number
sumSets day = unwrap $ foldDayField (_.repScheme.sets >>> toNumber >>> Additive) day

sumRepsMin :: DayPlan -> Number
sumRepsMin day = unwrap $ foldDayField (\{repScheme: {sets, reps: {min}}} -> Additive (toNumber (sets * min))) day

sumRepsMax :: DayPlan -> Number
sumRepsMax day = unwrap $ foldDayField (\{repScheme: {sets, reps: {max}}} -> Additive (toNumber (sets * max))) day

dayGroups :: DayPlan -> Set GroupName
dayGroups = foldDayField (_.group >>> Set.singleton)

foldDayField :: forall a. Monoid a => (WorkoutExercise -> a) -> DayPlan -> a
foldDayField fn RestDay = mempty
foldDayField fn (WorkoutDay {exercises}) =
  exercises
  # map fn
  # fold

workoutTimeInMinutes :: DayPlan -> Number
workoutTimeInMinutes plan = sumSets plan * minutesPerSet

-- in minutes
volumeWorkoutTime :: Volume -> Number
volumeWorkoutTime {sets} = sets * minutesPerSet

muscleVolumeByPushPull :: Map Muscle MuscleExerciseVolume -> PushPullMap (Map Muscle MuscleExerciseVolume)
muscleVolumeByPushPull muscles =
  { push: inSet byPushPull.push
  , pull: inSet byPushPull.pull
  , legs: inSet byPushPull.legs
  , core: inSet byPushPull.core}
  where
    inSet :: Set Muscle -> Map Muscle MuscleExerciseVolume
    inSet toMatch = muscles
                    # Map.filterKeys (\muscle -> Set.member muscle toMatch)

exercisesByMuscle :: Program -> Map Muscle MuscleExercises
exercisesByMuscle {days} =
  allExercises
  # Array.fromFoldable
  # map musclesForExercise
  # foldl (Map.unionWith muscleExercisesUnion) Map.empty
  where
    allExercises :: Set WorkoutExercise
    allExercises = days
                   # map dayExercises
                   # foldl Set.union Set.empty

musclesForExercise :: WorkoutExercise -> Map Muscle MuscleExercises
musclesForExercise ex@{exercise: prog@{muscles}} =
  [ getMuscles muscles.target TargetMuscle
  , getMuscles muscles.synergists SynergistMuscle
  , getMuscles muscles.stabilizers StabilizerMuscle ]
  # foldl (Map.unionWith muscleExercisesUnion) Map.empty
  where
    getMuscles :: Set Muscle -> MuscleRole -> Map Muscle MuscleExercises
    getMuscles ms role =
      ms
      # Array.fromFoldable
      # map (\m -> Map.singleton m (mkExs prog.category role))
      # foldl (Map.unionWith muscleExercisesUnion) Map.empty

    mkExs :: ExerciseCategory -> MuscleRole -> MuscleExercises
    mkExs Compound TargetMuscle = emptyMuscleExercises { targetCompound = set [ex] }
    mkExs Compound SynergistMuscle = emptyMuscleExercises { synergists = set [ex] }
    mkExs Compound StabilizerMuscle = emptyMuscleExercises { stabilizers = set [ex] }
    mkExs Isolation TargetMuscle = emptyMuscleExercises { targetIsolation = set [ex] }
    mkExs Isolation SynergistMuscle = emptyMuscleExercises { synergists = set [ex] }
    mkExs Isolation StabilizerMuscle = emptyMuscleExercises { stabilizers = set [ex] }

emptyMuscleExercises :: MuscleExercises
emptyMuscleExercises =
  { targetCompound: Set.empty
  , targetIsolation: Set.empty
  , synergists: Set.empty
  , stabilizers: Set.empty }

muscleExercisesUnion :: MuscleExercises -> MuscleExercises -> MuscleExercises
muscleExercisesUnion exs1 exs2 =
  { targetCompound: Set.union exs1.targetCompound exs2.targetCompound
  , targetIsolation: Set.union exs1.targetIsolation exs2.targetIsolation
  , synergists: Set.union exs1.synergists exs2.synergists
  , stabilizers: Set.union exs1.stabilizers exs2.stabilizers }

dayExercises :: DayPlan -> Set WorkoutExercise
dayExercises RestDay = Set.empty
dayExercises (WorkoutDay {exercises}) = Set.fromFoldable exercises
