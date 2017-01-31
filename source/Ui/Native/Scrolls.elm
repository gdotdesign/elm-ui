effect module Ui.Native.Scrolls
  where { subscription = MySub }
  exposing ( scrolls )

{-| This library lets you listen to global scroll events.

# Subscriptions
@docs scrolls
-}

import Task exposing (Task)
import Dom.LowLevel as Dom
import Json.Decode as Json
import Process

{-| Subscribe to scrolls anywhere on screen.
-}
scrolls : msg -> Sub msg
scrolls msg =
  subscription (MySub msg)


{-| Subscription type.
-}
type MySub msg
  = MySub msg


{-| Map subscriptions.
-}
subMap : (a -> b) -> MySub a -> MySub b
subMap func (MySub msg) =
  MySub (func msg)


{-| State.
-}
type alias State msg =
  { subs : List (MySub msg)
  , pid : Maybe Process.Id
  }


{-| Init state.
-}
init : Task Never (State msg)
init =
  Task.succeed
    { subs = []
    , pid = Nothing
    }


{-| Self Message type
-}
type Msg
  = Msg


{-| On effects manage the pid of the event listener.
-}
onEffects : Platform.Router msg Msg -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs oldState =
  let
    state =
      ( oldState.pid, not (List.isEmpty newSubs) )
  in
    case state of
      {- If we have a process and have new subs just update subs -}
      ( Just pid, True ) ->
        Task.succeed { oldState | subs = newSubs }

      {- If we have a process and no new subs kill the process. -}
      ( Just pid, False ) ->
        Task.andThen
          (\_ -> Task.succeed { oldState | subs = [], pid = Nothing })
          (Process.kill pid)

      ( Nothing, True ) ->
        Process.spawn
          (Dom.onWindow
            "scroll"
            (Json.succeed "")
            (\_ -> Platform.sendToSelf router Msg)
          )
          |> Task.andThen
            (\pid -> Task.succeed { pid = Just pid, subs = newSubs })

      {- No process no new subs do nothing. -}
      ( Nothing, False ) ->
        Task.succeed oldState


{-| Send back messages to app when an event happens.
-}
onSelfMsg : Platform.Router msg Msg -> Msg -> State msg -> Task Never (State msg)
onSelfMsg router msg state =
  let
    send msg =
      case msg of
        MySub a ->
          Platform.sendToApp router a
  in
    Task.andThen
      (\_ -> Task.succeed state)
      (Task.sequence (List.map send state.subs))
