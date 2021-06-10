module WorkoutBuilder.Client.References where

import Prelude

type Reference =
  { tag :: String
  , title :: String
  , author :: String
  , publishYear :: String
  , link :: String }

low :: Reference
low =
  { tag: "low"
  , title: "Overcoming Gravity: A Systematic Approach to Gymnastics and Bodyweight Strength"
  , author: "Steven Low"
  , publishYear: "2016"
  , link: "https://stevenlow.org/overcoming-gravity/"
  }

str :: Reference
str =
  { tag: "str"
  , title: "Scientific Principles of Strength Training"
  , author: "Mike Israetel, James Hoffmann, and Chad Wesley Smith"
  , publishYear: "2015"
  , link: "https://www.jtsstrength.com/product/scientific-principles-of-strength-training/"
  }

hyp :: Reference
hyp =
  { tag: "hyp"
  , title: "Scientific Principles of Hypertrophy Training"
  , author: "James Hoffmann, Melissa Davis, Jared Feather, and Mike Israetel"
  , publishYear: "2015"
  , link: "https://renaissanceperiodization.com/the-scientific-principles-of-hypertrophy-training"
  }

land :: Reference
land =
  { tag: "land"
  , title: "Training Volume Landmarks For Muscle Growth"
  , author: "Dr. Mike Israetel, Chief Sport Scientist, Dr. James Hoffmann, and Jared Feather, MS"
  , publishYear: "2017"
  , link: "https://renaissanceperiodization.com/hypertrophy-training-guide-central-hub"
  -- https://renaissanceperiodization.com/training-volume-landmarks-muscle-growth
  }

sch :: Reference
sch =
  { tag: "sch"
  , title: "Science and Development of Muscle Hypertrophy"
  , author: "Brad Schoenfeld"
  , publishYear: "2021"
  , link: "https://www.amazon.com/Science-Development-Muscle-Hypertrophy-Schoenfeld/dp/1492597678"
  }

sbsPeriodization :: Reference
sbsPeriodization =
  { tag: "sbsPeriod"
  , title: "Periodization: What the Data Say"
  , author: "Greg Nuckols"
  , publishYear: "2018"
  , link: "https://www.strongerbyscience.com/periodization-data"
  }
