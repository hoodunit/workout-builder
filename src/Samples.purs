module WorkoutBuilder.Samples where

import Prelude
import WorkoutBuilder.Exercises
import WorkoutBuilder.OwnPrelude
import WorkoutBuilder.Types

import Data.Map (Map)
import Data.Map as Map
import Data.Set as Set
import Data.Tuple (Tuple(..))
import WorkoutBuilder.Programming (defaults, programParamDefaults)

samplePrograms :: Array ProgramParams
samplePrograms =
  [ rrParams
  , rrSplit
  , rrNoCore
  , minimalist
  , fiveThreeOne
  , strongLifts
  ]

rrParams :: ProgramParams
rrParams =
  defaults
    { name = "r/bodyweightfitness Recommended Routine"
    , days = 
      [ ScheduleWorkout emptyScheduleWorkoutDay
      , ScheduleRest
      , ScheduleWorkout emptyScheduleWorkoutDay
      , ScheduleRest
      , ScheduleWorkout emptyScheduleWorkoutDay
      , ScheduleRest
      , ScheduleRest
      ]
    , groups =
        [ { name: "push"
          , exercises: [pushUp, weightedDip]
          , periodization: NoPeriodization
          , targetSets: 18 }
        , { name: "pull"
          , exercises: [pullUp, frontLeverRow]
          , periodization: NoPeriodization
          , targetSets: 18 }
        , { name: "core"
          , exercises: [hangingLegRaise, copenhagenPlank, hyperextension]
          , periodization: NoPeriodization
          , targetSets: 27 }
        , { name: "legs"
          , exercises: [shrimpSquat, nordicCurl]
          , periodization: NoPeriodization
          , targetSets: 18 }
        ]
    }

rrSplit :: ProgramParams
rrSplit =
  rrParams
    { name = "r/bodyweightfitness Recommended Routine Split"
    , days = 
      [ workoutDay (set ["pull", "legs"])
      , workoutDay (set ["push", "core"])
      , ScheduleRest
      , workoutDay (set ["pull", "legs"])
      , workoutDay (set ["push", "core"])
      , ScheduleRest
      , ScheduleRest
      ]
    }

rrNoCore :: ProgramParams
rrNoCore =
  defaults
    { name = "r/bodyweightfitness Recommended Routine - No Core"
    , days = 
      [ workoutDay (set [])
      , ScheduleRest
      , workoutDay (set [])
      , ScheduleRest
      , workoutDay (set [])
      , ScheduleRest
      , ScheduleRest
      ]
    , groups =
        [ { name: "push"
          , exercises: [pushUp, weightedDip]
          , periodization: NoPeriodization
          , targetSets: 18 }
        , { name: "pull"
          , exercises: [pullUp, frontLeverRow]
          , periodization: NoPeriodization
          , targetSets: 18 }
        , { name: "legs"
          , exercises: [shrimpSquat, nordicCurl]
          , periodization: NoPeriodization
          , targetSets: 18 }
        ]
    }

minimalist :: ProgramParams
minimalist =
  defaults
    { name = "Minimalist Bodyweight"
    , days = 
      [ workoutDay (set [])
      , ScheduleRest
      ]
    , groups =
        [ { name: "push"
          , exercises: [pushUp]
          , periodization: NoPeriodization
          , targetSets: 18 }
        , { name: "pull"
          , exercises: [pullUp]
          , periodization: NoPeriodization
          , targetSets: 18 }
        , { name: "legs"
          , exercises: [shrimpSquat]
          , periodization: NoPeriodization
          , targetSets: 18 }
        ]
    }

-- -- Using Boring But Big assistance work
-- -- Not 100% accurate - that would require specifying intensity separate
-- -- from rep range - but fairly close.
fiveThreeOne :: ProgramParams
fiveThreeOne =
  defaults
    { name = "5/3/1 Boring But Big"
    , days = 
      [ workoutDay (set ["press", "press (assistance)"])
      , workoutDay (set ["deadlift", "deadlift (assistance)"])
      , ScheduleRest
      , workoutDay (set ["bench", "bench (assistance)"])
      , ScheduleRest
      , workoutDay (set ["squat", "squat (assistance)"])
      , ScheduleRest
      ]
    , groups =
        [ { name: "squat"
          , exercises: [squat { scheme = fiveThreeOneSchemes }]
          , periodization: fiveThreeOnePeriods
          , targetSets: 3 }
        , { name: "bench"
          , exercises: [benchPress { scheme = fiveThreeOneSchemes }]
          , periodization: fiveThreeOnePeriods
          , targetSets: 3 }
        , { name: "deadlift"
          , exercises: [deadlift { scheme = fiveThreeOneSchemes }]
          , periodization: fiveThreeOnePeriods
          , targetSets: 3 }
        , { name: "press"
          , exercises: [militaryPress { scheme = fiveThreeOneSchemes }]
          , periodization: fiveThreeOnePeriods
          , targetSets: 3 }

        , { name: "squat (assistance)"
          , exercises: [ squat { scheme = fiveThreeOneLight }
                       , legCurl { scheme = fiveThreeOneLight } ]
          , periodization: NoPeriodization
          , targetSets: 10 }
        , { name: "bench (assistance)"
          , exercises: [ benchPress { scheme = fiveThreeOneLight }
                       , dumbbellRow { scheme = fiveThreeOneLight } ]
          , periodization: NoPeriodization
          , targetSets: 10 }
        , { name: "deadlift (assistance)"
          , exercises: [ deadlift { scheme = fiveThreeOneLight }
                       , hangingLegRaise { scheme = fiveThreeOneLighter } ]
          , periodization: NoPeriodization
          , targetSets: 10 }
        , { name: "press (assistance)"
          , exercises: [ militaryPress { scheme = fiveThreeOneLight }
                       , chinUp { scheme = fiveThreeOneLight } ]
          , periodization: NoPeriodization
          , targetSets: 10 }
        ]
    }

fiveThreeOnePeriods :: Periodization
fiveThreeOnePeriods =
  DailyUndulating {schedule: [L, M, H]}

fiveThreeOneSchemes :: Map Intensity RepScheme
fiveThreeOneSchemes =
  Map.fromFoldable
  [ Tuple H {sets: 5, reps: {min: 1, max: 5} } -- @75-95% 1RM
  , Tuple M {sets: 1, reps: {min: 3, max: 3} } -- @70-90% 1RM
  , Tuple L {sets: 1, reps: {min: 5, max: 5} } -- @65-85% 1RM
  , Tuple VL {sets: 1, reps: {min: 5, max: 5} } -- @40-60% 1RM
  ]

fiveThreeOneLight :: Map Intensity RepScheme
fiveThreeOneLight =
  Map.fromFoldable
  [ Tuple M {sets: 1, reps: {min: 10, max: 10} }
  ]

fiveThreeOneLighter :: Map Intensity RepScheme
fiveThreeOneLighter =
  Map.fromFoldable
  [ Tuple M {sets: 1, reps: {min: 15, max: 15} } ]


strongLifts :: ProgramParams
strongLifts =
  defaults
    { name = "StrongLifts"
    , days = 
      [ workoutDay (set ["squat", "bench", "row"])
      , ScheduleRest
      , workoutDay (set ["deadlift", "press"])
      , ScheduleRest
      , workoutDay (set ["squat", "bench", "row"])
      , ScheduleRest
      , ScheduleRest
      , workoutDay (set ["deadlift", "press"])
      , ScheduleRest
      , workoutDay (set ["squat", "bench", "row"])
      , ScheduleRest
      , workoutDay (set ["deadlift", "press"])
      , ScheduleRest
      , ScheduleRest
      ]
    , groups =
        [ { name: "squat"
          , exercises: [squat { scheme = fiveByFive }]
          , periodization: NoPeriodization
          , targetSets: 8 }
        , { name: "bench"
          , exercises: [benchPress { scheme = fiveByFive }]
          , periodization: NoPeriodization
          , targetSets: 8 }
        , { name: "row"
          , exercises: [dumbbellRow { scheme = fiveByFive }]
          , periodization: NoPeriodization
          , targetSets: 8 }
        , { name: "deadlift"
          , exercises: [deadlift { scheme = fiveByFive }]
          , periodization: NoPeriodization
          , targetSets: 1 }
        , { name: "press"
          , exercises: [militaryPress { scheme = fiveByFive }]
          , periodization: NoPeriodization
          , targetSets: 8 }
        ]
    }

fiveByFive =
  defaultRepSchemes
  # Map.insert M {sets: 1, reps: {min: 5, max: 5}}
