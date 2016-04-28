module Date.Config.Config_en_au exposing (..)

{-| This is the default english config for formatting dates.

@docs config

Copyright (c) 2016 Robin Luiten
-}

import Date
import Date.Config as Config
import Date.I18n.I_en_us as English


{-| Config for en-au. -}
config : Config.Config
config =
  { i18n =
      { dayShort = English.dayShort
      , dayName = English.dayName
      , monthShort = English.monthShort
      , monthName = English.monthName
      }
  , format =
      { date = "%-d/%m/%Y" -- d/MM/yyyy
      , longDate = "%A, %-d %B %Y" -- dddd, d MMMM yyyy
      , time = "%-I:%M %p" -- h:mm tt
      , longTime = "%-I:%M:%S %p" -- h:mm:ss tt
      , dateTime = "%-d/%m/%Y %-I:%M %p"  -- date + time
      , firstDayOfWeek = Date.Mon
      }
  }
