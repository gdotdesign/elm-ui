effect module Ui.Helpers.Emitter
  where { command = MyCmd, subscription = MySub}
  exposing (send, sendString, sendFloat, listen, listenString, listenFloat, decode)

{-| This is a module for publishing and subscribing to arbritary data in
different channels that are identified by strings.

# Listining
@docs listen, listenString, listenFloat

# Sending Data
@docs send, sendString, sendFloat

# Decodeing
@docs decode

-}
import Json.Encode as JE
import Json.Decode exposing (Value)
import Task exposing (Task)
import Debug exposing (log)


type MyCmd msg
  = Send String Value


send : String -> Value -> Cmd b
send id value =
  command (Send id value)


sendString : String -> String -> Cmd b
sendString id value =
  send id (JE.string value)


sendFloat : String -> Float -> Cmd b
sendFloat id value =
  send id (JE.float value)


cmdMap : (a -> b) -> MyCmd a -> MyCmd b
cmdMap _ (Send id value) =
  Send id value


type MySub msg
  = Listen String (Value -> msg)


listen : String -> (Value -> msg) -> Sub msg
listen id tagger =
  subscription (Listen id tagger)

listenString : String -> (String -> msg) -> Sub msg
listenString id tagger =
  listen id (decodeString "" tagger)

listenFloat : String -> (Float -> msg) -> Sub msg
listenFloat id tagger =
  listen id (decodeFloat 0 tagger)

decode : Json.Decode.Decoder a -> a -> (a -> b) -> Value -> b
decode decoder default action value =
  Json.Decode.decodeValue decoder value
    |> Result.withDefault default
    |> action


decodeString : String -> (String -> a) -> Value -> a
decodeString default msg =
  decode Json.Decode.string default msg


decodeFloat : Float -> (Float -> a) -> Value -> a
decodeFloat default msg =
  decode Json.Decode.float default msg


subMap : (a -> b) -> MySub a -> MySub b
subMap func sub =
  case sub of
    Listen id tagger ->
      Listen id (tagger >> func)


{-| Dummy state and massage types.
-}
type Msg
  = Msg


type alias State =
  {}


{-| Initialize null state.
-}
init : Task Never State
init =
  Task.succeed {}


{-| On effects send values to listeners.
-}
onEffects : Platform.Router msg Msg -> List (MyCmd msg) -> List (MySub msg) -> State -> Task Never State
onEffects router commands subscriptions model =
  let
    sendCommandMessages (Send id value) =
      List.filter (\(Listen subId _) -> subId == id) subscriptions
        |> List.map (send id value)

    send targetId value (Listen id tagger) =
      Platform.sendToApp router (tagger value)

    tasks =
      List.map sendCommandMessages commands
        |> List.foldr (++) []
  in
    Task.sequence tasks `Task.andThen` (\_ -> Task.succeed model)


{-| On self message do nothing because we don't receive these.
-}
onSelfMsg : Platform.Router msg Msg -> Msg -> State -> Task Never State
onSelfMsg router message model =
  Task.succeed model
