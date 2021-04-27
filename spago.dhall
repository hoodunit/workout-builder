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
  , "foreign-generic"
  , "halogen"
  , "js-uri"
  , "lists"
  , "maybe"
  , "ordered-collections"
  , "psci-support"
  , "record"
  , "simple-json"
  , "strings"
  , "stringutils"
  , "test-unit"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
