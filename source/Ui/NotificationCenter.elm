module Ui.NotificationCenter exposing
  (Model, Msg, init, update, view, notify, duration, timeout)

{-| Notification center for displaying toast messages to the user.

# Models
@docs Model, Msg, init, update

# DSL
@docs timeout, duration

# View
@docs view

# Functions
@docs notify
-}

import Html.Attributes exposing (style, attribute)
import Html.Events exposing (onClick)
import Html exposing (node)
import Html.Keyed
import Html.Lazy

import List.Extra
import Process
import Vendor
import Task

import Ui.Styles.NotificationCenter exposing (defaultStyle)
import Ui.Styles

{-| Representation of a notification center:
  - **timeout** - The timeout of the notification before it's hidden
  - **notifications** - The list of notifications that is displayed
  - **duration** - The duration of the notifications animation
-}
type alias Model msg =
  { notifications : List (Notification msg)
  , duration : Float
  , timeout : Float
  }


{-| Messages that notification center can recieve.
-}
type Msg
  = AutoHide Int
  | Remove Int
  | Hide Int


{-| Initializes a notification center.

    notificationCenter =
      Ui.NotificationCenter.init ()
        |> Ui.NotificationCenter.timeout 5000
        |> Ui.NotificationCenter.duration 500
-}
init : () -> Model msg
init _ =
  { notifications = []
  , duration = 500
  , timeout = 5000
  }


{-| Sets the timeout (in milliseconds) of a notification center.
-}
timeout : Float -> Model msg -> Model msg
timeout value model =
  { model | timeout = value }


{-| Sets the duration (in milliseconds) of a notification center.
-}
duration : Float -> Model msg -> Model msg
duration value model =
  { model | duration = value }


{-| Updates a notification center.

    ( updatedNotificationCenter, cmd ) =
      Ui.NotificationCenter.update msg notificationCenter
-}
update : Msg -> Model msg -> ( Model msg, Cmd Msg )
update msg model =
  case msg of
    AutoHide id ->
      autoHide id model

    Remove id ->
      remove id model

    Hide id ->
      hide id model


{-| Renders a notification center.

    Ui.NotificationCenter.view notificationCenter
-}
view : (Msg -> a) -> Model a -> Html.Html a
view address model =
  Html.Lazy.lazy2 render address model


{-| Adds a notification with the given html content.

    ( updatedNotificationCenter, cmd ) =
      Ui.NotificationCenter.notify (text "Hello") notificationCenter
-}
notify : Html.Html msg -> Model msg -> ( Model msg, Cmd Msg )
notify contents model =
  let
    notification =
      initNotification model contents

    updatedModel =
      { model | notifications = model.notifications ++ [ notification ] }
  in
    ( updatedModel
    , performTask (AutoHide notification.id) (Process.sleep model.timeout)
    )


{-| Representation of a notification.
-}
type alias Notification msg =
  { contents : Html.Html msg
  , attribute : String
  , duration : Float
  , id : Int
  }


{-| Performs the given task and turns it into the given message.
-}
performTask : Msg -> Task.Task Never b -> Cmd Msg
performTask msg task =
  Task.perform (\_ -> msg) task


{-| Renders a notification center.
-}
render : (Msg -> a) -> Model a -> Html.Html a
render address model =
  Html.Keyed.node
    "ui-notification-center"
    (Ui.Styles.apply defaultStyle)
    (List.map (renderNotification address) model.notifications)


{-| Renders a notification.
-}
renderNotification : (Msg -> a) -> Notification a -> ( String, Html.Html a )
renderNotification address model =
  let
    duration =
      (toString model.duration) ++ "ms"

    prefix =
      case Vendor.prefix of
        Vendor.Webkit ->
          "-webkit-"

        Vendor.Moz ->
          "-moz-"

        Vendor.MS ->
          "-ms-"

        Vendor.O ->
          "-o-"

        _ ->
          ""

    html =
      node
        "ui-notification"
        [ onClick (address (Hide model.id))
        , attribute model.attribute ""
        , style
            [ ( "animation-duration", duration )
            , ( prefix ++ "animation-duration", duration )
            ]
        ]
        [ node "ui-notification-body" [] [ model.contents ] ]
  in
    ( toString model.id, html )


{-| Initiliazes a notification with the given contents and model.
-}
initNotification : Model a -> Html.Html a -> Notification a
initNotification model contents =
  let
    id =
      List.map .id model.notifications
        |> List.maximum
        |> Maybe.withDefault -1
  in
    { attribute = "ui-notification-show"
    , duration = model.duration
    , contents = contents
    , id = id + 1
    }


{-| Hides the notification with the given id.
-}
hide : Int -> Model msg -> ( Model msg, Cmd Msg )
hide id model =
  let
    updatedNotifications =
      List.map updatedNotification model.notifications

    updatedNotification item =
      if item.id == id then
        { item | attribute = "ui-notification-hide" }
      else
        item
  in
    ( { model | notifications = updatedNotifications }
    , performTask (Remove id) (Process.sleep (model.duration + 250))
    )


{-| Tries to hide the notification with the given id.
-}
autoHide : Int -> Model a -> ( Model a, Cmd Msg )
autoHide id model =
  let
    updatedNotifications =
      List.map updatedNotification model.notifications

    isMember =
      List.map .id model.notifications
        |> List.member id

    hideCmd =
      if updatedNotifications /= model.notifications then
        performTask (Remove id) (Process.sleep (model.duration + 250))
      else
        performTask (AutoHide id) (Process.sleep 100)

    cmd =
      if isMember then
        hideCmd
      else
        Cmd.none

    updatedNotification item =
      let
        index =
          List.Extra.elemIndex item model.notifications
            |> Maybe.withDefault -1
      in
        if item.id == id && index == 0 then
          { item | attribute = "ui-notification-hide" }
        else
          item
  in
    ( { model | notifications = updatedNotifications }, cmd )


{-| Removes the notification with the given id.
-}
remove : Int -> Model a -> ( Model a, Cmd Msg )
remove id model =
  let
    updatedNotifications =
      List.filter (\item -> item.id /= id) model.notifications
  in
    ( { model | notifications = updatedNotifications }, Cmd.none )
