effect module Ui.Helpers.PeriodicUpdate
  where { subscription = MySub }
  exposing (listen)

{-| Effects module for calling all the subscribers simultaneously every 5
seconds, created for and mainly used in Ui.Time.

# Subscription
@docs listen
-}

import Time exposing (Time)
import Task exposing (Task)
import Ext.Date
import Process

{-| The state containing the process ID and subscribers.
-}
type alias State msg =
  { process : Maybe Platform.ProcessId
  , subs : List (MySub msg)
  }


{-| The subscription type.
-}
type MySub msg
  = Sub (Time -> msg)


{-| Initializes a state.
-}
init : Task Never (State msg)
init =
  Task.succeed
    { process = Nothing
    , subs = []
    }


{-| Returns a subscription for the update.
-}
listen : (Time -> msg) -> Sub msg
listen msg =
  subscription (Sub msg)


{-| Maps a subscription.
-}
subMap : (a -> b) -> MySub a -> MySub b
subMap f (Sub msg) =
  Sub (f << msg)


{-| Runs every time subscriptions changes.
-}
onEffects : Platform.Router msg () -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs ({ process, subs } as state) =
  let
    haveSubs =
      not (List.isEmpty newSubs)

    updatedState =
      { state | subs = newSubs }

    updateProcess process =
      Task.succeed { updatedState | process = process }
  in
    case ( process, haveSubs ) of
      -- nothing changes
      ( Just id, True ) ->
        Task.succeed updatedState

      -- start process
      ( Nothing, True ) ->
        Process.spawn (setInterval 5000 (Platform.sendToSelf router ()))
          |> Task.andThen (updateProcess << Just)

      -- stop process
      ( Just id, False ) ->
        Process.kill id
          |> Task.andThen (\_ -> updateProcess Nothing)

      -- no process, no subscribers
      ( Nothing, False ) ->
        Task.succeed { process = Nothing, subs = [] }


{-| Actually notifys subscribers.
-}
onSelfMsg : Platform.Router msg () -> () -> State msg -> Task Never (State msg)
onSelfMsg router _ state =
  let
    value =
      Ext.Date.nowTime ()

    mapSub sub =
      case sub of
        Sub msg ->
          msg
  in
    state.subs
      |> List.map mapSub
      |> List.map (\tagger -> Platform.sendToApp router (tagger value))
      |> Task.sequence
      |> Task.andThen (\_ -> Task.succeed state)


{-| Native function for setting intervals.
-}
setInterval : Time -> Task Never () -> Task x Never
setInterval =
  Native.DateTime.setInterval
