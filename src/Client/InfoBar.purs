module WorkoutBuilder.Client.InfoBar where

import WorkoutBuilder.Client.UiPrelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import WorkoutBuilder.Client.Images (images)
import WorkoutBuilder.Client.References (Reference)
import WorkoutBuilder.Client.References as Refs
import WorkoutBuilder.Client.References
import WorkoutBuilder.Client.State (Action(..), InfoBarState)

infoBar :: forall w i. InfoBarState -> HTML w Action
infoBar _ =
  div [cls "content__sidebar"]
    [ div [cls "content__sidebar__content"] [infoContent] ]

infoContent :: forall w. HTML w Action
infoContent =
  div [cls "content__sidebar__content__wrapper"]
    [ div [cls "sidebar__title"] [text "Designing a Strength Training Program"]
    , par [text "This app provides tools and guidelines for creating an optimal strength training program for your specific goals and schedule. All advice is intended to be directly sourced from reputable sources such as Steven Low (bodyweight strength training", cite low, text "), Brad Schoenfeld (hypertrophy", cite sch, text "), Mike Israetel et al (hypertrophy ", cite hyp, text " and strength/powerlifting training", cite str, text "), and others", cite sbsPeriodization, text "."]
    , par [text "The guidelines below are roughly in order of importance, with later items becoming important mainly in intermediate and advanced stages (typically after 1-3 years of training)."]
    , section "Goals and Specificity"
      [ par [text "Optimal training depends on your specific goals and will be different for specific ", strTag, text ", ", hypTag, text " (muscle mass), and skill goals. Only choose exercises that advance your specific goals."]
      ]
    , section "Exercise selection"
      [ par [ text "Prefer compound exercises over isolation exercises for both ", strTag, text " and ", hypTag, text ".", citeP low 73, citeP str 92, citeP hyp 28 ]
      , par [ strTag, text " Choose almost exclusively compound exercises and include isolation exercises only as needed for prehabilitation, rehabilitation, or strengthening specific weaknesses.", citeP low 139, citeP str 339 ]
      , par [ hypTag, text " Include both compound and isolation exercises with a strong preference for compound work. Isolation work should primarily target specific muscles that aren't sufficiently targeted in compound lifts.", citeP sch 103, citeP low 139, citeP str 339 ]
      , par [ ref low, text " generally recommends for beginners a full-body, 3x weekly routine ", citeP low 72, text " with two exercise progressions from each of the following categories: push, pull, and legs.", citeP low 90, text "At intermediate or advanced levels a third exercise can be added to each category. In addition ", ref low, text " recommends balancing between horizontal and vertical pushing/pulling exercises (e.g. pull-ups vs bodyweight rows)." ]
      , par [ text "Bodyweight strength training uses exercise progressions that become progressively more difficult, while weightlifting has specific exercises with increasing weights. All exercises in this app should be assumed to either belong to a progression or use weights to progress." ]
      ]
    , section "Intensity and Progressive Overload"
      [ par [ text "All exercise sets should be performed to within a few reps of failure but mostly not to failure", text " (", refP sch 131, text ": 1-2 reps in reserve, ", refP hyp 56, text ": 2-3 RIR average, 5 max)." ]
      , par [ text "Exercise intensity can be modulated by choosing exercise progressions or weights for which your max number of reps falls within a certain range. Intensity ranges for concentric exercises (standard reps, e.g. pull-ups), isometrics (static holds like planche), eccentrics (e.g. pull-up negatives), and percentages of a single rep max (1RM) can be roughly compared using the following table (based on ", refP low 100, text "):" ]
      , intensityTable
      , par [ strTag, text " Work primarily at high intensity in the 1-8RM range close to failure with 3+ minute rest times ", citeP low 52, text "(", refP str 339, text ": mainly 75-90% 1RM [~5-10RM]). Overload by increasing intensity (harder progressions or load) and reps within a rep range and adding volume where necessary. See also notes on varying intensity." ]
      , par [ hypTag, text " Hypertrophy can be gained effectively across broad rep ranges (1-30RM+) as long as sets are taken close to failure and volume is sufficient.", citeP sch 100, citeP hyp 249, citeP low 52, text "Suggested ranges to favor are the 5-15+RM range", citeP low 52, text ", the 6-12RM range", citeP sch 100, text "or the 10-20RM range.", citeP hyp 249, text "See also the notes on varying intensity. Current research supports resting as long as necessary, typically 2+ minutes for compound exercises, though 60 to 90 second rest periods may be sufficient for isolation exercises", citeP sch 114, text " and shorter rest periods may be enough for individuals or for saving time.", citeP hyp 71, ref hyp, text " suggests overloading by increasing both set volume (number of weekly sets) and intensity (harder progressions or load), with periodic deload weeks. Training to failure produces better muscle growth in a single session but also has more risk of injury and produces higher fatigue, which can limit weekly set volume.", citeP str 97, citeP sch 131, citeP hyp 56 ]
      , par [ text "It is worth also noting that bodyweight strength training in particular puts more stress on joints, tendons, and connective tissue. For developing connective tissue, ", ref low, text " recommends longer rests between sets, slower tempos, higher rep ranges (such as 15-40), and avoiding failure.", citeP low 141, ref str, text " recommends taking a break from training beyond 80% 1RM for at least one month every 4 months or so.", citeP str 209 ]
      ]
    , section "Volume"
      [ par [text "Strength training volume is typically measured as the number of hard sets per muscle group in a week.", citeP sch 183, cite land]
      , par [text "Beginners can develop with very little volume, for example as low as 6 sets per week per muscle group. General recommendations for intermediates and advanced:"]
      , par [ strTag, text " Aim for 10-20 sets per week per muscle group", citeP str 339 ]
      , par [ hypTag, text " Aim for 15-30 sets per week per muscle group", citeP str 338 ]
      , par [ text "Exercises count towards the overall weekly sets for a muscle based on the role of the muscle in the exercise:"]
      , ul []
        [ li [] [hi "Targeted muscle (isolation)" "label--small--isolation", text "/", hi "Targeted muscle (compound)" "label--small--compound", text " - the prime mover of the exercise. Performance of compound (multi-joint) and isolation (single-joint) exercises can produce similar increases in muscle size, though mixed evidence suggests isolation exercises may promote more growth in certain cases (such as targeting individual heads of a muscle).", citeP sch 184]
        , li [] [hi "Supporting muscles" "label--small--synergist", text " - synergist muscles that assist in the movement. A recent meta-analysis found it justified to give equal weight to synergists and agonists [targeted muscles] when calculating volume for hypertrophy training, though other evidence suggests more targeted isolation work can promote even more growth.", citeP sch 184]
        , li [] [hi "Stabilizer muscles" "label--small--stabilizer", text " - muscles that contract to maintain postural stability during a movement. Stabilizers muscles are unlikely to grow in strength or hypertrophy in the same way as targeted and supporting muscles, though they may develop."]
        ]
      , par [ ref land, text " further breaks down recommended set volumes by specific muscle groups."]
      ]
    , section "Frequency, scheduling, and splits"
      [ par [ strTag, text " As frequent as possible while allowing sufficient rest to avoid overtraining or injuries.", citeP low 25, text " Between 2 and 4 sessions per body part per week, on average.", citeP str 339 ]
      , par [ hypTag, text " If total weekly set volume is held constant, anywhere between 2-4 sessions per muscle group per week should have the same results.", citeP hyp 192, text " For very high volumes (>30 sets per muscle per week), a minimum of three training days per week may be advisable.", citeP sch 91 ]
      , par [ ref low, text " strongly recommends a 3x weekly full-body routine with a focus on compound exercises for beginners and early intermediates, while intermediate and advanced athletes can consider other splits.", citeP low 71 ]
      , par [ text "Include a deload week (e.g. do half of sets for one week) roughly every 4-8 weeks or when performance begins to drop due to accumulated fatigue to help avoid injuries and keep progressing.", citeP low 151, citeP hyp 167, citeP str 154 ]
      ]
    , section "Varying Intensity"
      [ par [ strTag, text " Varying intensity within the strength range, e.g. cycling sets of 6, 4, and 2, can be an effective way to provide stimulus variation and manage fatigue.", citeP str 274 ]
      , par [ hypTag, text " ", refP sch 100, text ": Vary intensity within a wide range (1-20+ reps), possibly with a focus on the 6-12RM range. ", refP hyp 249, text ": vary reps between the 5-10, 10-20, and 20-30 ranges, with a focus on the 10-20 range for best stimulus-fatigue ratios (e.g. split 25%-50%-25%). ", ref hyp, text " suggests avoiding high intensity (<5RM) due to increased fatigue, which can limit the number of weekly sets that can be performed at higher volumes. ", refP sch 100, text ": \"If the goal is to promote hypertrophy to maximize muscular strength, there appears little reason to employ loads less than approximately 70% of 1RM [~12 reps max], other than perhaps during deload periods.\"" ]
      , par [text "The periodization provided in this tool is for the intensity of an exercise and is called daily undulating periodization. Muscle groups with a periodization sequence will cycle through the specified intensity levels, where the default intensity levels are specified as in the table above (but can be adjusted per exercise)."]
      ]
    , section "Varying exercises"
      [ par [ strTag, text " Focus on a smaller number of exercises. Varying specific exercises every mesocycle (4-8 weeks) or so can be useful." ]
      , par [ hypTag, text " It can be useful to vary exercises more throughout the week, as long as exercises can still be progressively overloaded." ]
      ]
    , section "Periodization"
      [ par [ text "Periodization or phase potentiation (as ", refP str 278, text " and ", refP hyp 269, text " refer to it) is the planning of training over microcycle (week), mesocycle (typically ~3-8 weeks), and macrocycle (months) time scales. Periodization strategies include progressively increasing intensity or volume with periodic deloads as in linear periodization, varying intensity and volume on a daily or weekly basis (daily/weekly undulating periodization or nonlinear periodization), and organizing around larger training blocks focused on hypertrophy, strength, and \"peaking\" for competitions (block periodization)." ]
      , par [ strTag, text " Research suggests periodized training produces faster and larger strength gains than non-periodized training, regardless of training age and mostly independent of periodization style (linear or nonlinear periodization).", cite sbsPeriodization, citeP sch 199]
      , par [ hypTag, text " Periodization is thought to provide benefits for hypertrophy training, although research is scant and existing studies show little effect.", citeP sch 191, cite sbsPeriodization, text " However, as there are clear effects for strength training and hypertrophy training correlates well with strength training, it seems likely periodization will benefit hypertrophy training as well.", citeP sch 194]
      ]
      , par [ ref low, text " focuses on bodyweight strength training built around gymnastic/calisthenic-style exercises for both ", strTag, text " and ", hypTag, text ", although he seems to focus on strength. The author, Steven Low, recommends experimenting with periodization only when simpler progression methods plateau at intermediate and advanced levels and seems to prefer concurrent nonlinear/undulating styles to linear periodization.", citeP low 132]
      , par [ ref str, text " is oriented around ", strTag, text " training for powerlifting. It promotes a style of cycling hypertrophy, strength, and peaking blocks with different focuses. Hypertrophy blocks have one or more mesocycles with progressively increasing set volumes and loads followed by a deload week. Strength blocks have one or more mesocycles with progressively increasing loads followed by a deload. Peaking blocks have one or more mesocycles with progressively increasing loads and decreasing volumes."]
      , par [ ref hyp, text " targets ", hypTag, text " training using weights. It promotes block periodization with muscle gain, maintenance (or resensitization), and fat loss blocks. Blocks generally contain macrocycles with progressively increasing load and volume until maximum recoverable volume is reached followed by a deload week, with the goal of continually finding and adjusting training based on minimum effective volumes (MEV) and maximum recoverable volumes (MRV)."]
    , section "References"
      [ div [cls "references"]
        [ mkReference low
        , mkReference str
        , mkReference hyp
        , mkReference sch
        , mkReference land
        , mkReference sbsPeriodization
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

strTag :: forall w i. HTML w i
strTag = hi "Strength" "label--small--str"

hypTag :: forall w i. HTML w i
hypTag = hi "Hypertrophy" "label--small--hyp"

section :: forall w i. String -> Array (HTML w i) -> HTML w i
section title content =
  div [cls "sidebar__section"]
    [ div [cls "section__title"] [text title]
    , div [cls "section__content"] content]

ref :: forall w i. Reference -> HTML w i
ref {tag} = HH.a [cls "reference-link"] [text ("[" <> tag <> "]")]

refP :: forall w i. Reference -> Int -> HTML w i
refP {tag} pageNum =
  HH.a [cls "reference-link"]
  [ text ("[" <> tag <> " p. " <> show pageNum <> "]") ]

citeP :: forall w i. Reference -> Int -> HTML w i
citeP {tag} pageNum =
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
