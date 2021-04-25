module WorkoutBuilder.Exercises where

import Prelude
import WorkoutBuilder.Muscles
import WorkoutBuilder.OwnPrelude
import WorkoutBuilder.Types

allExercises :: Array Exercise
allExercises =
  [ bulgarianSplitSquat
  , squat
  , pistolSquat
  , singleLegRdl
  , hinge
  , dip
  , ringDip
  , pushUp
  , weightedRingPushUp
  , pikePushUp
  , handstandPushUp
  , pseudoPlanchePushUp
  , pullUp
  , chinUp
  , weightedPullUp
  , row
  , frontLeverRow
  , weightedHorizontalRow
  , bicepCurl
  , lateralRaise
  , shrug
  , copenhagenPlank
  , hyperextension
  , pikePullThrough
  , pancakeStretch
  , weightedHang
  , straddleSplits
  , hangingLegRaise
  , legCurl
  , benchPress
  , militaryPress
  , dumbbellRow
  , deadlift
  , romanianDeadlift
  ]

-- Sourced from ExRx.net (where available)

bulgarianSplitSquat :: Exercise
bulgarianSplitSquat =
  { name: "Bulgarian split squat"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [quadriceps]
    , synergists: set [gluteusMaximus, adductorMagnus, soleus]
    , stabilizers: set [hamstrings, gastrocnemius, erectorSpinae, gluteusMedius, gluteusMinimus]
    }
  }
pistolSquat :: Exercise
pistolSquat =
  { name: "Pistol squat"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [quadriceps]
    , synergists: set [gluteusMaximus, adductorMagnus, soleus]
    , stabilizers: set [hamstrings, gastrocnemius, gluteusMedius, gluteusMinimus, quadratusLumborum, obliques, rectusAbdominus, iliopsoas, tensorFasciaeLatae, pectineus, sartorius]
    }
  }
squat :: Exercise
squat =
  { name: "Squat"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [quadriceps]
    , synergists: set [gluteusMaximus, adductorMagnus, soleus]
    , stabilizers: set [hamstrings, gastrocnemius, erectorSpinae, rectusAbdominus, obliques]
    }
  }
singleLegRdl :: Exercise
singleLegRdl =
  { name: "Single leg RDL"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [gluteusMaximus]
    , synergists: set [hamstrings, adductorMagnus]
    , stabilizers: set [erectorSpinae, quadriceps, gluteusMaximus, gluteusMinimus, quadratusLumborum, obliques, gluteusMaximus, rectusAbdominus]
    }
  }
hinge :: Exercise
hinge =
  { name: "Hinge"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles: singleLegRdl.muscles
  }
dip :: Exercise
dip =
  { name: "Dip"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [pecsLower]
    , synergists: set [deltoidAnterior, triceps, pecsUpper, pecsMinor, rhomboids, levatorScapulae, lats, teresMajor]
    , stabilizers: set [trapsLower]
    }
  }
ringDip :: Exercise
ringDip =
  { name: "Weighted ring dip"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [pecsLower]
    , synergists: set [deltoidAnterior, triceps, pecsUpper, pecsMinor, rhomboids, levatorScapulae, lats, teresMajor]
    , stabilizers: set [trapsLower]
    }
  }
pushUp :: Exercise
pushUp =
  { name: "Push-up"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [pecsLower]
    , synergists: set [pecsUpper, deltoidAnterior, triceps]
    , stabilizers: set [biceps, rectusAbdominus, obliques, quadriceps, erectorSpinae]
    }
  }
weightedRingPushUp :: Exercise
weightedRingPushUp =
  { name: "Weighted ring push-up"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [pecsLower]
    , synergists: set [pecsUpper, deltoidAnterior, triceps]
    , stabilizers: set [biceps, rectusAbdominus, obliques, pecsMinor, serratusAnterior, quadriceps, gastrocnemius, soleus, erectorSpinae]
    }
  }
pikePushUp :: Exercise
pikePushUp =
  { name: "Pike push-up"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [deltoidAnterior]
    , synergists: set [pecsUpper, triceps, deltoidLateral, trapsMiddle, trapsLower, serratusAnterior]
    , stabilizers: set [triceps, biceps, trapsUpper, levatorScapulae]
    }
  }
handstandPushUp :: Exercise
handstandPushUp =
  { name: "Handstand Push-up"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles: pikePushUp.muscles
  }
pseudoPlanchePushUp :: Exercise
pseudoPlanchePushUp =
  { name: "Pseudo planche push-up"
  , scheme: defaultRepSchemes
  , category: Compound
  -- No direct source
  , muscles:
    { target: set [deltoidAnterior]
    , synergists: set [pecsLower, pecsUpper, triceps, biceps]
    , stabilizers: set [rectusAbdominus, obliques, quadriceps, erectorSpinae]
    }
  }
pullUp :: Exercise
pullUp =
  { name: "Pull-up"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [lats]
    , synergists: set [brachialis, brachioradialis, biceps, teresMajor, deltoidPosterior, infraspinatus, teresMinor, rhomboids, levatorScapulae, trapsLower, trapsMiddle, pecsMinor]
    , stabilizers: set [triceps]
    }
  }
chinUp :: Exercise
chinUp =
  { name: "Chin-up"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [lats]
    , synergists: set [brachialis, brachioradialis, teresMajor, deltoidPosterior, rhomboids, levatorScapulae, trapsLower, trapsMiddle, pecsLower, pecsMinor]
    , stabilizers: set [biceps, triceps]
    }
  }
weightedPullUp :: Exercise
weightedPullUp =
  { name: "Weighted pull-up"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles: pullUp.muscles
  }
row :: Exercise
row =
  { name: "Bodyweight Row"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [] -- "Back, General"
    , synergists: set [trapsMiddle, trapsLower, rhomboids, lats, teresMajor, deltoidPosterior, infraspinatus, teresMinor, brachialis, brachioradialis, pecsLower]
    , stabilizers: set [biceps, triceps, erectorSpinae, hamstrings, gluteusMaximus, rectusAbdominus, obliques]
    }
  }
frontLeverRow :: Exercise
frontLeverRow =
  { name: "Front lever row"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles: row.muscles
  }
weightedHorizontalRow :: Exercise
weightedHorizontalRow =
  { name: "Weighted horizontal row"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles: row.muscles
  }
bicepCurl :: Exercise
bicepCurl =
  { name: "Dumbbell Curl"
  , scheme: defaultRepSchemes
  , category: Isolation
  , muscles:
    { target: set [biceps]
    , synergists: set [brachialis, brachioradialis]
    , stabilizers: set [deltoidAnterior, trapsUpper, trapsMiddle, levatorScapulae, wristFlexors]
    }
  }
lateralRaise :: Exercise
lateralRaise =
  { name: "Dumbbell Lateral Raise"
  , scheme: defaultRepSchemes
  , category: Isolation
  , muscles:
    { target: set [deltoidLateral]
    , synergists: set [deltoidAnterior, supraspinatus, trapsMiddle, trapsLower, serratusAnterior]
    , stabilizers: set [trapsUpper, levatorScapulae, wristExtensors]
    }
  }
shrug :: Exercise
shrug =
  { name: "Dumbbell Shrug"
  , scheme: defaultRepSchemes
  , category: Isolation
  , muscles:
    { target: set [trapsUpper]
    , synergists: set [trapsMiddle, levatorScapulae]
    , stabilizers: set [erectorSpinae]
    }
  }

copenhagenPlank :: Exercise
copenhagenPlank =
  { name: "Copenhagen plank"
  , scheme: defaultRepSchemes
  , category: Compound
  -- exrx: "side plank"
  , muscles:
    { target: set [obliques]
    , synergists: set []
    , stabilizers: set [gluteusMedius, gluteusMinimus, tensorFasciaeLatae, quadratusLumborum, psoasMajor, iliocastalisLumborum, iliocastalisThoracis, hipAdductors, pectineus, gracilis, gluteusMaximus, lats, pecsUpper, pecsLower, levatorScapulae]
    }
  }
hyperextension :: Exercise
hyperextension =
  { name: "Hyperextension"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [erectorSpinae]
    , synergists: set [gluteusMaximus, hamstrings, adductorMagnus]
    , stabilizers: set []
    }
  }
pikePullThrough :: Exercise
pikePullThrough =
  { name: "Pike pull-through"
  , scheme: defaultRepSchemes
  , category: Compound
  -- TODO: Verify
  , muscles:
    { target: set [rectusAbdominus]
    , synergists: set []
    , stabilizers: set []
    }
  }
pancakeStretch :: Exercise
pancakeStretch =
  { name: "Pancake stretch"
  , scheme: defaultRepSchemes
  , category: Isolation
  -- Empty - not a strength exercise
  , muscles:
    { target: set []
    , synergists: set []
    , stabilizers: set []
    }
  }
weightedHang :: Exercise
weightedHang =
  { name: "Weighted hang (grip)"
  , scheme: defaultRepSchemes
  , category: Isolation
  -- Forearm muscles not listed
  , muscles:
    { target: set []
    , synergists: set []
    , stabilizers: set []
    }
  }
straddleSplits :: Exercise
straddleSplits =
  { name: "Straddle splits"
  , scheme: defaultRepSchemes
  , category: Isolation
  -- Not a strength exercise
  , muscles:
    { target: set []
    , synergists: set []
    , stabilizers: set []
    }
  }
hangingLegRaise :: Exercise
hangingLegRaise =
  { name: "Hanging leg raise"
  , scheme: defaultRepSchemes
  , category: Compound
  -- "Hanging leg hip raise"
  , muscles:
    { target: set [rectusAbdominus]
    , synergists: set [iliopsoas, tensorFasciaeLatae, pectineus, sartorius, adductorLongus, adductorBrevis, obliques]
    , stabilizers: set [rectusFemoris]
    }
  }
legCurl :: Exercise
legCurl =
  { name: "Leg curl"
  , scheme: defaultRepSchemes
  , category: Isolation
  -- "Lever seated leg curl (plate loaded)"
  , muscles:
    { target: set [hamstrings]
    , synergists: set [gastrocnemius, gracilis, sartorius, popliteus]
    , stabilizers: set [tibialisAnterior]
    }
  }
benchPress :: Exercise
benchPress =
  { name: "Bench press"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [pecsUpper]
    , synergists: set [pecsLower, deltoidAnterior, triceps]
    , stabilizers: set [biceps]
    }
  }
militaryPress :: Exercise
militaryPress =
  { name: "Barbell military press"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [deltoidAnterior]
    , synergists: set [pecsUpper, triceps, deltoidLateral, trapsMiddle, trapsLower, serratusAnterior]
    , stabilizers: set [triceps, biceps, trapsUpper, levatorScapulae]
    }
  }
dumbbellRow :: Exercise
dumbbellRow =
  { name: "Dumbbell bent-over row"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [] -- "Back, general"
    , synergists: set [trapsMiddle, trapsLower, rhomboids, lats, teresMajor, deltoidPosterior, infraspinatus, teresMinor, brachialis, brachioradialis, pecsUpper]
    , stabilizers: set [biceps, triceps]
    }
  }
deadlift :: Exercise
deadlift =
  { name: "Deadlift"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [gluteusMaximus]
    , synergists: set [quadriceps, adductorMagnus, hamstrings, soleus]
    , stabilizers: set [hamstrings, gastrocnemius, erectorSpinae, trapsMiddle, trapsUpper, levatorScapulae, rhomboids, rectusAbdominus, obliques]
    }
  }
romanianDeadlift :: Exercise
romanianDeadlift =
  { name: "Romanian deadlift"
  , scheme: defaultRepSchemes
  , category: Compound
  , muscles:
    { target: set [gluteusMaximus]
    , synergists: set [hamstrings, adductorMagnus]
    , stabilizers: set [erectorSpinae, quadriceps, trapsMiddle, rhomboids, lats, trapsUpper, levatorScapulae, trapsLower, rectusAbdominus, obliques]
    }
  }
