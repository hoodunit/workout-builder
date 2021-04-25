{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "workout-builder"
, dependencies =
  [ "console"
  , "debug"
  , "effect"
  , "exceptions"
  , "halogen"
  , "lists"
  , "maybe"
  , "ordered-collections"
  , "psci-support"
  , "record"
  , "strings"
  , "stringutils"
  , "test-unit"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
