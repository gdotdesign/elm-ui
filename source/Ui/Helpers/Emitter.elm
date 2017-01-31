effect module Ui.Helpers.Emitter
  where { command = MyCmd, subscription = MySub }
  exposing
    ( send
    , sendString
    , sendFloat
    , sendInt
    , sendBool
    , sendNaked
    , sendFile
    , listen
    , listenString
    , listenFloat
    , listenInt
    , listenBool
    , listenNaked
    , listenFile
    , decode
    )

{-| This is a module for publishing and subscribing to arbritary data in
different channels that are identified by strings.

# Listining
@docs listen, listenString, listenFloat, listenInt, listenBool, listenNaked
@docs listenFile

# Sending Data
@docs send, sendString, sendFloat, sendInt, sendBool, sendNaked, sendFile

# Decodeing
@docs decode

-}

import Ui.Native.FileManager exposing (File)
import Json.Decode exposing (Value)
import Task exposing (Task)
import Native.FileManager
import Json.Encode as JE

{-| Representation of a command.
-}
type MyCmd msg
  = Send String Value


{-| Representation of a subscription.
-}
type MySub msg
  = Listen String (Value -> msg)


{-| Sends the given value to the given channel.

    Ui.Helpers.Emitter.send "channelId" (Json.string "test")
-}
send : String -> Value -> Cmd msg
send id value =
  command (Send id value)


{-| Sends a _naked message_ (without value) to the given channel. This is used
generally to trigger actions.

    Ui.Helpers.Emitter.send "channelId"
-}
sendNaked : String -> Cmd msg
sendNaked id =
  command (Send id JE.null)


{-| Sends a string value to the given channel.

    Ui.Helpers.Emitter.sendString "channelId" "test"
-}
sendString : String -> String -> Cmd msg
sendString id value =
  send id (JE.string value)


{-| Sends a float value to the given channel.

    Ui.Helpers.Emitter.sendFloat "channelId" 0.42
-}
sendFloat : String -> Float -> Cmd msg
sendFloat id value =
  send id (JE.float value)


{-| Sends a integer value to the given channel.

    Ui.Helpers.Emitter.sendInt "channelId" 10
-}
sendInt : String -> Int -> Cmd msg
sendInt id value =
  send id (JE.int value)


{-| Sends a boolean value to the given channel.

    Ui.Helpers.Emitter.sendBool "channelId" 10
-}
sendBool : String -> Bool -> Cmd msg
sendBool id value =
  send id (JE.bool value)


{-| Sends a file value to the given channel.

    Ui.Helpers.Emitter.sendFile "channelId" file
-}
sendFile : String -> File -> Cmd msg
sendFile id value =
  send id (Native.FileManager.identity value)


{-| Creates a subscription for the given channel.

    Ui.Helpers.Emitter.listen "channelId" HandleValue
-}
listen : String -> (Value -> msg) -> Sub msg
listen id tagger =
  subscription (Listen id tagger)


{-| Creates a subscription for the given channel.

    Ui.Helpers.Emitter.listenNaked "channelId" NakedMsg
-}
listenNaked : String -> msg -> Sub msg
listenNaked id msg =
  listen id (\_ -> msg)


{-| Creates a subscription for the given string channel.

    Ui.Helpers.Emitter.listenString "channelId" HandleString
-}
listenString : String -> (String -> msg) -> Sub msg
listenString id tagger =
  listen id (decodeString "" tagger)


{-| Creates a subscription for the given float channel.

    Ui.Helpers.Emitter.listenFloat "channelId" HandleFloat
-}
listenFloat : String -> (Float -> msg) -> Sub msg
listenFloat id tagger =
  listen id (decodeFloat 0 tagger)


{-| Creates a subscription for the given integer channel.

    Ui.Helpers.Emitter.listenInt "channelId" HandleInt
-}
listenInt : String -> (Int -> msg) -> Sub msg
listenInt id tagger =
  listen id (decodeInt 0 tagger)


{-| Creates a subscription for the given boolean channel.

    Ui.Helpers.Emitter.listenBool "channelId" HandleBool
-}
listenBool : String -> (Bool -> msg) -> Sub msg
listenBool id tagger =
  listen id (decodeBool False tagger)


{-| Creates a subscription for the given file channel.

    Ui.Helpers.Emitter.listenBool "channelId" HandleFile
-}
listenFile : String -> (File -> msg) -> Sub msg
listenFile id tagger =
  listen id (Native.FileManager.identitiyTag tagger)


{-| Decodes a Json value and maps it to a message with a fallback value.

    Ui.Helpers.Emitter.decode Json.Decode.string "" HandleString value
-}
decode : Json.Decode.Decoder value -> value -> (value -> msg) -> Value -> msg
decode decoder default msg value =
  Json.Decode.decodeValue decoder value
    |> Result.withDefault default
    |> msg


{-| Decodes a Json string and maps it to a message with a fallback value.
-}
decodeString : String -> (String -> msg) -> Value -> msg
decodeString default msg =
  decode Json.Decode.string default msg


{-| Decodes a Json float and maps it to a message with a fallback value.
-}
decodeFloat : Float -> (Float -> msg) -> Value -> msg
decodeFloat default msg =
  decode Json.Decode.float default msg


{-| Decodes a Json integer and maps it to a message with a fallback value.
-}
decodeInt : Int -> (Int -> msg) -> Value -> msg
decodeInt default msg =
  decode Json.Decode.int default msg


{-| Decodes a Json boolean and maps it to a message with a fallback value.
-}
decodeBool : Bool -> (Bool -> msg) -> Value -> msg
decodeBool default msg =
  decode Json.Decode.bool default msg



-- Effect related


{-| Maps a command to an other command.
-}
cmdMap : (a -> b) -> MyCmd a -> MyCmd b
cmdMap _ (Send id value) =
  Send id value


{-| Maps a subsctiption to an other subscription.
-}
subMap : (a -> b) -> MySub a -> MySub b
subMap func sub =
  case sub of
    Listen id tagger ->
      Listen id (tagger >> func)


{-| Representation of message (dummy).
-}
type Msg
  = Msg


{-| Representation of a state.
-}
type alias State =
  {}


{-| Initializes a state.
-}
init : Task Never State
init =
  Task.succeed {}


{-| On effects send values to listeners.
-}
onEffects : Platform.Router msg Msg -> List (MyCmd msg) -> List (MySub msg) -> State -> Task Never State
onEffects router commands subscriptions model =
  let
    {- Filter subscriptions and send messages to listeners. -}
    sendCommandMessages (Send id value) =
      List.filter (\(Listen subId _) -> subId == id) subscriptions
        |> List.map (send id value)

    {- Actually send messages to the app. -}
    send targetId value (Listen id tagger) =
      Platform.sendToApp router (tagger value)

    {- Get a list of tasks to execute. -}
    tasks =
      List.map sendCommandMessages commands
        |> List.foldr (++) []
  in
    {- Execute tasks and return the state -}
    Task.sequence tasks
      |> Task.andThen (\_ -> Task.succeed model)


{-| On self message do nothing because we don't receive these.
-}
onSelfMsg : Platform.Router msg Msg -> Msg -> State -> Task Never State
onSelfMsg router message model =
  Task.succeed model
