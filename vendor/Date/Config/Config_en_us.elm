module Date.Config.Config_en_us exposing (..)

{-| This is the default english config for formatting dates.

@docs config

Copyright (c) 2016 Robin Luiten
-}

import Date
import Date.Config as Config
import Date.I18n.I_en_us as English


{-| Config for en-us. -}
config : Config.Config
config =
  { i18n =
      { dayShort = English.dayShort
      , dayName = English.dayName
      , monthShort = English.monthShort
      , monthName = English.monthName
      }
  , format =
      { date = "%-m/%-d/%Y" -- M/d/YYY
      , longDate = "%A, %B %d, %Y" -- dddd, MMMM dd, yyyy
      , time = "%-H:%M %p" -- h:mm tt
      , longTime = "%-H:%M:%S %p" -- h:mm:ss tt
      , dateTime = "%-m/%-d/%Y %-I:%M %p" -- date + time
      , firstDayOfWeek = Date.Mon
      }
  }
