module WorkoutBuilder.OwnPrelude where

import Prelude
import Data.Foldable (class Foldable)
import Data.Set (Set)
import Data.Set as Set

set :: forall f a. Foldable f => Ord a => f a -> Set a
set = Set.fromFoldable
