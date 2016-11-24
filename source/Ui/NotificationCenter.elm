module Ui.NotificationCenter exposing (Model, Msg, init, update, view, notify)

{-| Notification center for displaying messages to the user.

# Models
@docs Model, Msg, init, update

# View
@docs view

# Functions
@docs notify
-}

import Html.Attributes exposing (classList, style, id)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Keyed

import Json.Encode
import List.Extra
import Process
import Vendor
import Task


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


{-| Actions that notification center can make.
-}
type Msg
  = AutoHide Int
  | Remove Int
  | Hide Int


{-| Initializes a notification center with the given timeout and duration (in
milliseconds).

    notis = Ui.NotificationCenter.init timeout duration
-}
init : Float -> Float -> Model msg
init timeout duration =
  { duration = duration
  , notifications = []
  , timeout = timeout
  }


{-| Updates a notification center.

    Ui.NotificationCenter.update notis
-}
update : Msg -> Model msg -> ( Model msg, Cmd Msg )
update action model =
  case action of
    AutoHide id ->
      autoHide id model

    Remove id ->
      remove id model

    Hide id ->
      hide id model


{-| Renders a notification center.

    Ui.NotificationCenter.view notis
-}
view : (Msg -> a) -> Model a -> Html.Html a
view address model =
  render address model


{-| Adds a notification with the given html content.

    Ui.NotificationCenter.notify (text "Hello") model
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



----------------------------------- PRIVATE ------------------------------------


{-| Representation of a notification.
-}
type alias Notification msg =
  { contents : Html.Html msg
  , duration : Float
  , class : String
  , id : Int
  }


performTask : Msg -> Task.Task Never b -> Cmd Msg
performTask msg task =
  Task.perform (\_ -> msg) task


{-| Renders a notification center.
-}
render : (Msg -> a) -> Model a -> Html.Html a
render address model =
  Html.Keyed.node
    "ui-notification-center"
    []
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
        [ classList [ ( model.class, True ) ]
        , onClick (address (Hide model.id))
        , style
            [ ( "animation-duration", duration )
            , ( prefix ++ "animation-duration", duration )
            ]
        ]
        [ node "div" [] [ model.contents ] ]
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
    { class = "ui-notification-show"
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
        { item | class = "ui-notification-hide" }
      else
        item
  in
    ( { model | notifications = updatedNotifications }
    , performTask (Remove id) (Process.sleep (model.duration + 100))
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

    hideEffect =
      if updatedNotifications /= model.notifications then
        performTask (Remove id) (Process.sleep (model.duration + 100))
      else
        performTask (AutoHide id) (Process.sleep 100)

    effect =
      if isMember then
        hideEffect
      else
        Cmd.none

    updatedNotification item =
      let
        index =
          List.Extra.elemIndex item model.notifications
            |> Maybe.withDefault -1
      in
        if item.id == id && index == 0 then
          { item | class = "ui-notification-hide" }
        else
          item
  in
    ( { model | notifications = updatedNotifications }, effect )


{-| Removes the notification with the given id.
-}
remove : Int -> Model a -> ( Model a, Cmd Msg )
remove id model =
  let
    updatedNotifications =
      List.filter (\item -> item.id /= id) model.notifications
  in
    ( { model | notifications = updatedNotifications }, Cmd.none )
