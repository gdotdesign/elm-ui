module Date.Config.Configs exposing
  ( getConfig
  , configs
  ) -- where

{-| Get a Date Extra Config based up on a locale code.

@docs getConfig
@docs configs

Copyright (c) 2016 Robin Luiten
-}

import Dict exposing (Dict)
import Regex exposing (replace, regex, HowMany (All))
import String

import Date.Config as Config exposing (Config)
import Date.Config.Config_en_us as Config_en_us
import Date.Config.Config_en_au as Config_en_au


{-| Built in configurations. -}
configs : Dict String Config
configs =
  Dict.fromList
    [ ("en_au", Config_en_au.config)
    , ("en_us", Config_en_us.config)
    ]


{-| Get a Date Extra Config for a locale id.

Lower case matches strings and accepts "-" or "_" to seperate
the characters in code.

Returns "en_us" config if it can't find a match in configs.
-}
getConfig : String -> Config
getConfig id =
  let
    lowerId = String.toLower id
    fixedId = replace All (regex "-") (\_ -> "_") lowerId
  in
    Maybe.withDefault Config_en_us.config
      (Dict.get fixedId configs)
