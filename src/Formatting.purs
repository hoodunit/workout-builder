module WorkoutBuilder.Formatting where

import Prelude

import Data.Int (floor, toNumber)
import Data.Int as Int
import Math as Math

minutesToHourMinutes :: Number -> String
minutesToHourMinutes minutes =
  if minutes < 60.0
     then mins
     else hours <> mins
  where
    hours = show (floor (minutes / 60.0)) <> " hr "
    mins = show ((floor minutes) `mod` 60) <> " min"

round :: Number -> String
round val =
  if Math.round val == val
     then show (Int.round val)
     else let rounded = (Math.round (val * 10.0)) / 10.0
          in if rounded == (toNumber $ Int.round val)
                then show (Int.round val)
                else show rounded
