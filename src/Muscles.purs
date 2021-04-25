module WorkoutBuilder.Muscles where

import WorkoutBuilder.OwnPrelude

import Data.Set (Set)
import WorkoutBuilder.Types (Muscle)

allMuscles =
 [ adductorMagnus
 , biceps
 , brachialis
 , brachioradialis
 , deltoidAnterior
 , deltoidLateral
 , deltoidPosterior
 , erectorSpinae
 , gastrocnemius
 , gluteusMaximus
 , gluteusMedius
 , gluteusMinimus
 , hamstrings
 , infraspinatus
 , lats
 , levatorScapulae
 , pecsLower
 , pecsMinor
 , pecsUpper
 , quadratusLumborum
 , quadriceps
 , rectusAbdominus
 , rhomboids
 , serratusAnterior
 , soleus
 , supraspinatus
 , teresMajor
 , teresMinor
 , trapsLower
 , trapsMiddle
 , trapsUpper
 , triceps
 , wristExtensors
 , wristFlexors
 ]

byBodyPart =
  { arms:
    [ triceps
    , brachialis
    , brachioradialis
    , biceps
    , wristFlexors
    , wristExtensors
    ]
  , chest:
    [ pecsUpper
    , pecsLower
    , pecsMinor
    , serratusAnterior ]
  , back:
    [ levatorScapulae
    , trapsUpper
    , trapsMiddle
    , trapsLower
    , rhomboids
    , lats
    , teresMajor
    , teresMinor
    , infraspinatus
    , supraspinatus
    ]
  , shoulders:
    [ deltoidAnterior
    , deltoidLateral
    , deltoidPosterior
    ]
  , legs:
    [ hamstrings
    , gluteusMaximus
    , gluteusMedius
    , gluteusMinimus
    , quadriceps
    , soleus
    , gastrocnemius
    , adductorMagnus
   ]
  , core:
    [ rectusAbdominus
    , obliques
    , quadratusLumborum
    ]
  }

type PushPullMap a =
  { push :: a
  , pull :: a
  , legs :: a
  , core :: a }

byPushPull :: PushPullMap (Set Muscle)
byPushPull =
  { push: set
    [ triceps
    , pecsUpper
    , pecsLower
    , pecsMinor
    , deltoidAnterior
    , deltoidLateral
    , serratusAnterior
    ]
  , pull: set
    [ brachialis
    , brachioradialis
    , biceps
    , levatorScapulae
    , trapsUpper
    , trapsMiddle
    , trapsLower
    , rhomboids
    , lats
    , deltoidPosterior
    , teresMajor
    , teresMinor
    , infraspinatus
    , supraspinatus
    ]
  , legs: set
    [ hamstrings
    , gluteusMaximus
    , gluteusMedius
    , gluteusMinimus
    , quadriceps
    , soleus
    , gastrocnemius
    , adductorMagnus ]
  , core: set
    [ rectusAbdominus
    , obliques
    , quadratusLumborum
    , erectorSpinae
    ]
    -- wristFlexors
    -- wristExtensors
  }

-- Renaissance Periodization training volume landmarks
byTrainingLandmarks =
  { back: set [rhomboids, serratusAnterior, lats]
  , abs: set [rectusAbdominus, obliques] --quadratusLumborum?
  , traps: set [trapsUpper, trapsMiddle, trapsLower]
  , triceps: set [triceps]
  , forearms: set [wristFlexors, wristExtensors]
  , calves: set [soleus, gastrocnemius]
  , "front delts": set [deltoidAnterior]
  , glutes: set [gluteusMaximus, gluteusMedius, gluteusMinimus]
  , chest: set [pecsUpper, pecsLower, pecsMinor]
  , biceps: set [biceps, brachialis, brachioradialis]
  , quads: set [quadriceps]
  , hamstrings: set [hamstrings]
  , "side delts": set [deltoidLateral]
  , "rear delts": set [deltoidPosterior]
  , other: [erectorSpinae, levatorScapulae, adductorMagnus]}

adductorMagnus = "adductor magnus"
biceps = "biceps"
brachialis = "brachialis"
brachioradialis = "brachioradialis"
deltoidAnterior = "deltoid (anterior)"
deltoidLateral = "deltoid (lateral)"
deltoidPosterior = "deltoid (posterior)"
erectorSpinae = "erector spinae"
gastrocnemius = "gastrocnemius"
gluteusMaximus = "gluteus maximus"
gluteusMedius = "gluteus medius"
gluteusMinimus = "gluteus minimus"
hamstrings = "hamstrings"
infraspinatus = "infraspinatus"
lats = "lats"
levatorScapulae = "levator scapulae"
obliques = "obliques"
pecsLower = "pectoralis major (lower)" -- sternal head
pecsMinor = "pectoralis minor"
pecsUpper = "pectoralis major (upper)" -- clavicular head
quadratusLumborum = "quadratus lumborum"
quadriceps = "quadriceps"
rectusAbdominus = "rectus abdominus"
rhomboids = "rhomboids"
serratusAnterior = "serratus anterior"
soleus = "soleus"
supraspinatus = "supraspinatus" -- rotary cuff
teresMajor = "teres major"
teresMinor = "teres minor"
trapsLower = "traps (lower)"
trapsMiddle = "traps (middle)"
trapsUpper = "traps (upper)"
triceps = "triceps"
wristExtensors = "wrist extensors"
wristFlexors = "wrist flexors"

-- Uncategorized
iliopsoas = "iliopsoas"
tensorFasciaeLatae = "tensor fasciae latae"
pectineus = "pectineus"
sartorius = "sartorius"
adductorLongus = "adductor longus"
adductorBrevis = "adductor brevis"
rectusFemoris = "rectus femoris"
gracilis = "gracilis"
popliteus = "popliteus"
tibialisAnterior = "tibialis anterior"
psoasMajor = "psoas major"
iliocastalisLumborum = "iliocastalis lumborum"
iliocastalisThoracis = "iliocastalis thoracis"
hipAdductors = "hip adductors"
