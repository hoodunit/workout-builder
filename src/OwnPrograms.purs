module WorkoutBuilder.OwnPrograms where

import Prelude
import WorkoutBuilder.OwnPrelude

import WorkoutBuilder.Programming (defaults)
import WorkoutBuilder.Types
import WorkoutBuilder.Exercises

ownPrograms :: Array ProgramParams
ownPrograms =
  [ previousStrength
  , currentHypertrophy
  ]

previousStrength :: ProgramParams
previousStrength =
  defaults
    { name = "Last Strength Routine"
    , days = 
      [ workoutDay (set ["push","pull","squat", "hinge"])
      , ScheduleRest
      , workoutDay (set ["push","pull","grip", "mobility"])
      , ScheduleRest
      , workoutDay (set ["push","pull","grip", "mobility"])
      , ScheduleRest
      , ScheduleRest
      ]
    , groups =
        [ { name: "push"
          , exercises: [pikePushUp, pseudoPlanchePushUp]
          , periodization: DailyUndulating { schedule: [L,M,H] }
          , targetSets: 20 }
        , { name: "pull"
          , exercises: [weightedPullUp, weightedHorizontalRow]
          , periodization: DailyUndulating { schedule: [H,L,M] }
          , targetSets: 20 }
        , { name: "squat"
          , exercises: [bulgarianSplitSquat]
          , periodization: DailyUndulating { schedule: [M] }
          , targetSets: 3 }
        , { name: "hinge"
          , exercises: [singleLegRdl]
          , periodization: DailyUndulating { schedule: [M] }
          , targetSets: 3 }
        , { name: "grip"
          , exercises: [weightedHang]
          , periodization: NoPeriodization
          , targetSets: 10 }
        , { name: "mobility"
          , exercises: [pancakeStretch, straddleSplits]
          , periodization: NoPeriodization
          , targetSets: 20 }
        ]
    }

currentHypertrophy :: ProgramParams
currentHypertrophy =
  defaults
    { name = "Hypertrophy routine"
    , days = 
      [ workoutDay (set ["push","mobility"])
      , workoutDay (set ["pull","grip","mobility"])
      , ScheduleRest
      , ScheduleRest
      , workoutDay (set ["push","squat"])
      , workoutDay (set ["pull","hinge","grip"])
      , ScheduleRest
      ]
    , groups =
        [ { name: "push"
          , exercises: [pikePushUp, weightedRingPushUp]
          , periodization: DailyUndulating { schedule: [L] }
          , targetSets: 20 }
        , { name: "pull"
          , exercises: [weightedPullUp, weightedHorizontalRow]
          , periodization: DailyUndulating { schedule: [L] }
          , targetSets: 20 }
        , { name: "squat"
          , exercises: [bulgarianSplitSquat]
          , periodization: DailyUndulating { schedule: [L] }
          , targetSets: 3 }
        , { name: "hinge"
          , exercises: [singleLegRdl]
          , periodization: DailyUndulating { schedule: [L] }
          , targetSets: 3 }
        , { name: "grip"
          , exercises: [weightedHang]
          , periodization: NoPeriodization
          , targetSets: 10 }
        , { name: "mobility"
          , exercises: [pancakeStretch, straddleSplits]
          , periodization: NoPeriodization
          , targetSets: 20 }
        ]
    }
