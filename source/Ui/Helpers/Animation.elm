module Ui.Helpers.Animation where

{-| Functions for handling a values animation over time
with an easing function.

# Model
@docs Animation, init, update

# Functions
@docs isEnded, reset
-}
import Time exposing (Time, second)
import Easing

{-| Represents an animation. -}
type alias Animation =
  { startTime : Time
  , duration : Time
  , running : Bool
  , value : Float
  , from : Float
  , to : Float
  }

{-| Initializes an animation.

    Animation.init 0 100 (10 * second) - from 0 to 100 in 10 seconds
-}
init : Float -> Float -> Time -> Animation
init from to duration =
  { duration = Time.inMilliseconds duration
  , startTime = second
  , running = False
  , value = from
  , from = from
  , to = to
  }

{-| Returns whether the animation has ended or not. -}
isEnded : Animation -> Bool
isEnded model =
  model.value == model.to

{-| Resets an animation. -}
reset : Animation -> Animation
reset model =
  { model | value = model.from }

{-| Updates an animation based on the current clock time. -}
update : Time -> Animation -> Animation
update clockTime model =
  let
    start = if model.running then model.startTime else clockTime
    elapsed = clockTime - start
    value =
      Easing.ease
        Easing.easeInOutQuad
        Easing.float
        model.from
        model.to
        model.duration
        elapsed
    ended = value == model.to
  in
    if ended then
      { model | running = False, value = model.to }
    else if model.running then
      { model | value = value }
    else
      { model | running = True, startTime = clockTime, value = model.from }
