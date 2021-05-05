module WorkoutBuilder.Client.InfoBar where

import WorkoutBuilder.Client.UiPrelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import WorkoutBuilder.Client.Images (images)
import WorkoutBuilder.Client.References (Reference)
import WorkoutBuilder.Client.References as Refs
import WorkoutBuilder.Client.State (Action(..), InfoBarState)

infoBar :: forall w i. InfoBarState -> HTML w Action
infoBar _ =
  div [cls "content__sidebar"]
    [ div [cls "content__sidebar__content"] [infoContent] ]

infoContent :: forall w. HTML w Action
infoContent =
  div [cls "content__sidebar__content__wrapper"]
    [ div [cls "sidebar__title"] [text "Designing a Strength Training Program"]
    , par [text "This app provides tools and guideline for creating an optimal strength training program for your specific goals and schedule. The focus is on bodyweight strength training but the information can generally be applied to weight lifting as well. All advice is intended to be directly sourced from reputable sources such as Steven Low (bodyweight strength training), Brad Schoenfeld (hypertrophy), Mike Israetel (hypertrophy and strength/powerlifting training), and others."]
    , section "Goals and Specificity"
      [ par [text "Optimal training depends on your specific goals and will be different for specific strength, hypertrophy (muscle mass), and skill goals. Only choose exercises that advance your specific goals."]
      ]
    , section "Exercise selection"
      [ par [ text "Prefer compound exercises over isolation exercises for both strength and hypertrophy.", citePage Refs.low 73, citePage Refs.israetelStr 92, citePage Refs.israetelHyp 28 ]
      , par [ ref Refs.low, text " generally recommends choosing two exercise progressions from each of the following categories: push, pull, and legs. At intermediate or advanced levels a third exercise can be added to each category. In addition ", ref Refs.low, text " recommends balancing between horizontal and vertical pushing/pulling exercises (e.g. pull-ups vs bodyweight rows)." ]
      , par [ text "In bodyweight training we refer to bodyweight exercise ", HH.i_ [text "progressions"], text ", while weight lifting has specific exercises with varying weights." ]
      ]
    , section "Intensity and Progressive Overload"
      [ par [ text "All exercise sets should be performed to within a few reps of failure (5 reps in reserve or less ", citePage Refs.israetelHyp 56, text ")." ]
      , par [ text "Exercise intensity can be modulated by choosing exercise progressions or weights for which your max number of reps falls within a certain range. Intensity ranges for concentric exercises (standard reps, e.g. pull-ups), isometrics (static holds like planche), eccentrics (e.g. pull-up negatives), and percentages of a single rep max (1RM) can be roughly compared using the following table (based on ", refPage Refs.low 100, text "):" ]
      , intensityTable
      , par [ hi "Strength" "label--small--str", text " Work primarily at high intensity in the 1-8RM range close to failure with 3+ minute rest times.", cite Refs.low, text " Overload by increasing intensity (harder progressions or load) and adding volume where necessary.", cite Refs.low, cite Refs.israetelStr ]
      , par [ hi "Hypertrophy " "label--small--hyp", ref Refs.low, text " suggests working primarily at moderate intensity in the 5-15+ RM range close to failure.", cite Refs.low, text "Current research supports longer rest periods of 2+ minutes for compound exercises, though 60 to 90 second rest periods may be sufficient for isolation exercises.", citePage Refs.schoenfeld 114, text " Overload by increasing both set volume (number of weekly sets) and intensity (harder progressions or load).", cite Refs.israetelHyp ]
      , par [ text "It is worth also noting that bodyweight strength training in particular puts more stress on joints, tendons, and connective tissue. For developing connective tissue, ", ref Refs.low, text " recommends longer rests between sets, slower tempos, higher rep ranges (such as 15-40), and avoiding failure.", citePage Refs.low 141, ref Refs.israetelStr, text " recommends taking a break from training beyond 80% 1RM for at least one month every 4 months or so.", citePage Refs.israetelStr 209 ]
      ]
    , section "Volume"
      [ par [text "Strength training volume is often measured as the number of hard sets in a week."]
      , par [ hi "Strength" "label--small--str", text " Aim for 10-20 sets per week per muscle group", cite Refs.israetelStr ]
      , par [ hi "Hypertrophy" "label--small--hyp", text " Aim for 15-30 sets per week per muscle group", cite Refs.israetelStr ]
      , par [ text "Exercises count towards the overall weekly sets for a muscle based on the role of the muscle in the exercise:"]
      , ul []
        [ li [] [hi "Targeted muscle (isolation)" "label--small--isolation", text "/", hi "Targeted muscle (compound)" "label--small--compound", text " - the prime mover of the exercise. Performance of compound (multi-joint) and isolation (single-joint) exercises can produce similar increases in muscle size, though mixed evidence suggests isolation exercises may promote more growth in certain cases (such as targeting individual heads of a muscle).", cite Refs.schoenfeld]
        , li [] [hi "Supporting muscles" "label--small--synergist", text " - synergist muscles that assist in the movement. A recent meta-analysis found it justified to give equal weight to synergists and agonists [targeted muscles] when calculating volume for hypertrophy training, though other evidence suggests more targeted isolation work can promote even more growth.", cite Refs.schoenfeld]
        , li [] [hi "Stabilizer muscles" "label--small--stabilizer", text " - muscles that contract to maintain postural stability during a movement. Stabilizers muscles are unlikely to grow in strength or hypertrophy in the same way as targeted and supporting muscles, though they may develop."]
        ]
      ]
    , section "Frequency, scheduling, and splits"
      [ par [ ref Refs.low, text " strongly recommends a 3x weekly full-body routine with a focus on compound exercises for beginners and early intermediates, while intermediate and advanced athletes can consider other splits.", citePage Refs.low 71 ]
      , par [ hi "Strength" "label--small--str", text " As frequent as possible while allowing sufficient rest to avoid overtraining or injuries.", citePage Refs.low 25, text " Between 2 and 4 sessions per body part per week, on average.", citePage Refs.israetelStr 339 ]
      , par [ hi "Hypertrophy" "label--small--hyp", text " If total weekly set volume is held constant, anywhere between 2-4 sessions per muscle group per week should have the same results.", citePage Refs.israetelHyp 192, text " For very high volumes (>30 sets per muscle per week), a minimum of three training days per week may be advisable.", citePage Refs.schoenfeld 91 ]
      , par [ ref Refs.low, text " recommends a deload week every 4-8 weeks to remove accumulated fatigue and avoid injuries.", citePage Refs.low 151, ref Refs.israetelHyp, " recommends a deload week after accumulating volume and load such that performance begins to drop or maximum recoverable volume is reached.", citePage Refs.israetelHyp 167 ]
      ]
    , section "Varying Intensity"
      [ par [ text "The periodization used here is for the intensity of an exercise and is called daily undulating periodization.", cite Refs.low, ref Refs.low, text " recommends experimenting with periodization when simpler progression methods plateau at intermediate and advanced levels."]
      , par [ hi "Strength" "label--small--str", text " Vary intensity within the strength range, e.g. cycling sets of 6, 4, and 2.", cite Refs.israetelStr, text " There is little reason to use loads less than approximately 70% 1RM (~12 reps max) for strength.", cite Refs.schoenfeld ]
      , par [ hi "Hypertrophy" "label--small--hyp", text " Vary intensity within a wide range (1-20+ reps), possibly with a focus on the 6-12RM range.", cite Refs.schoenfeld, ref Refs.israetelHyp, text " suggests avoiding high intensity (<5RM) due to increased fatigue, which can limit the number of weekly sets that can be performed at higher volumes." ]
      , par [text "Here muscle groups with a periodization sequence scheduled will cycle through the specified intensity levels, where the default intensity levels are specified as above."]
      ]
    , section "Varying exercises"
      [ par [ hi "Strength" "label--small--str", text " Focus on a smaller number of exercises. Varying specific exercises every mesocycle (4-8 weeks) or so can be useful." ]
      , par [ hi "Hypertrophy" "label--small--hyp", text " It can be useful to vary exercises more throughout the week, as long as exercises can still be progressively overloaded." ]
      ]
    , section "References"
      [ div [cls "references"]
        [ mkReference Refs.low
        , mkReference Refs.israetelStr
        , mkReference Refs.israetelHyp
        , mkReference Refs.schoenfeld
        , mkReference Refs.landmarks
        ]
      ]
    ]

intensityTable :: forall w i. HTML w i
intensityTable =
  table [cls "table--small"]
    [ thead []
      [ tr []
        [ th [] []
        , th [] []
        , th [] [text "Concentric"]
        , th [] [text "Isometric"]
        , th [] [text "Eccentric"]
        , th [] [text "~% 1RM"]
        ]
      ]
    , tbody []
      [ tr []
        [ td [] [text "VH"]
        , td [] [text "Very Heavy"]
        , td [] [text "1-3 reps"]
        , td [] [text "2-6s"]
        , td [] [text "1-3x3-5s"]
        , td [] [text "94-100%"]
        ]
      , tr []
        [ td [] [text "H"]
        , td [] [text "Heavy"]
        , td [] [text "3-4 reps"]
        , td [] [text "6-8s"]
        , td [] [text "3x3-5s"]
        , td [] [text "92-94%"]
        ]
      , tr []
        [ td [] [text "M"]
        , td [] [text "Moderate"]
        , td [] [text "5-8 reps"]
        , td [] [text "10-16s"]
        , td [] [text "3x5-8s"]
        , td [] [text "81-89%"]
        ]
      , tr []
        [ td [] [text "L"]
        , td [] [text "Light"]
        , td [] [text "8-12 reps"]
        , td [] [text "16-24s"]
        , td [] [text "3x8-12s"]
        , td [] [text "71-81%"]
        ]
      , tr []
        [ td [] [text "VL"]
        , td [] [text "Very Light"]
        , td [] [text "12-15 reps"]
        , td [] [text "24-30s"]
        , td [] [text "3x12-15s"]
        , td [] [text "67-71%"]
        ]
      ]
    ]

section :: forall w i. String -> Array (HTML w i) -> HTML w i
section title content =
  div [cls "sidebar__section"]
    [ div [cls "section__title"] [text title]
    , div [cls "section__content"] content]

ref :: forall w i. Reference -> HTML w i
ref {tag} = HH.a [cls "reference-link", HP.href ("#" <> tag)] [text ("[" <> tag <> "]")]

refPage :: forall w i. Reference -> Int -> HTML w i
refPage {tag} pageNum =
  HH.a [cls "reference-link"]
  [ text ("[" <> tag <> " p. " <> show pageNum <> "]") ]

citePage :: forall w i. Reference -> Int -> HTML w i
citePage {tag} pageNum =
  HH.a [cls "citation-link"]
    [ text ("[" <> tag <> " p. " <> show pageNum <> "]") ]

cite :: forall w i. Reference -> HTML w i
cite {tag} = HH.a [cls "citation-link"] [text ("[" <> tag <> "]")]

hi :: forall w i. String -> String -> HTML w i
hi str className = span [cls className] [text str]

mkReference :: forall w i. Reference -> HTML w i
mkReference { tag, title, author, publishYear, link } =
  HH.a [cls "reference", HP.href link, HP.id tag]
  [ text $ "[" <> tag <> "] \"" <> title <> "\". " <> author <> ". " <> publishYear <> "." ]

par content = div [cls "paragraph"] content
