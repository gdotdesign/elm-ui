module Date.Internal exposing (..)

{-| This module not exposed to clients.
-}

import Date exposing (Date)

import Date.Core as Core
import Date.Create as Create


{-| Adjust date as if it was in utc zone. -}
hackDateAsUtc : Date -> Date
hackDateAsUtc date =
  hackDateAsOffset (Create.getTimezoneOffset date) date


{-| Adjust date for time zone offset in minutes. -}
hackDateAsOffset : Int -> Date -> Date
hackDateAsOffset offsetMinutes date =
  --  Core.fromTime <| Core.toTime date + (offsetMinutes * Core.ticksAMinute)
  -- let _ = Debug.log("hackDateAsOffset") (offsetMinutes)
  -- in
  Core.toTime date
  |> (+) (offsetMinutes * Core.ticksAMinute)
  |> Core.fromTime
