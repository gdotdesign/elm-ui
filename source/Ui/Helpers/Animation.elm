module Ui.Helpers.Animation where

import Time exposing (Time, second)
import Easing

type alias Animation =
  { running : Bool
  , startTime : Time
  , value : Float
  , from : Float
  , to : Float
  , duration : Time
  }

init from to duration =
  { running = False
  , startTime = second
  , value = from
  , from = from
  , to = to
  , duration = Time.inMilliseconds duration
  }

isEnded model =
  model.value == model.to

reset model =
  { model | value = model.from }

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
