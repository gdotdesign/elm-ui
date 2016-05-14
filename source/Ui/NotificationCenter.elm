module Ui.NotificationCenter exposing
  (Model, Msg, init, update, view, notify)

{-| Notification center for displaying messages to the user.

TODO: Refactor this into something that doesn't use animations, or wait for
virtual-dom to fix "keys" concept.

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

import Json.Encode
import List.Extra
import Process
import Task

import Ui.Native.Browser as Browser

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

{-| Actions that notification center can make. -}
type Msg
  = AutoHide Int ()
  | Remove Int ()
  | Hide Int
  | Tasks ()

{-| Initializes a notification center with the given timeout and duration (in
milliseconds).

    NotificationCenter.init timeout duration
-}
init : Float -> Float -> Model msg
init timeout duration =
  { duration = duration
  , notifications = []
  , timeout = timeout
  }

{-| Renders a notification center. -}
view: (Msg -> a) -> Model a -> Html.Html a
view address model =
  render address model

{-| Updates a notification center. -}
update: Msg -> Model msg -> (Model msg, Cmd Msg)
update action model =
  case action of
    AutoHide id _ ->
      autoHide id model

    Remove id _ ->
      remove id model

    Hide id ->
      hide id model

    Tasks _ ->
      (model, Cmd.none)

{-| Adds a notification with the given html content.

    NotificationCenter.notify (text "Hello") model
-}
notify : Html.Html msg -> Model msg -> (Model msg, Cmd Msg)
notify contents model =
  let
    notification =
      initNotification model contents

    updatedModel =
      { model | notifications = model.notifications ++ [notification] }
  in
    (updatedModel, Task.perform Tasks (AutoHide notification.id) (Process.sleep model.timeout))

-- PRIVATE --

-- Represents a notification
type alias Notification msg =
  { contents : Html.Html msg
  , duration : Float
  , class : String
  , id : Int
  }

-- Render
render: (Msg -> a) -> Model a -> Html.Html a
render address model =
  node "ui-notification-center" []
    (List.map (renderNotification address) model.notifications)

-- Renders a notification
renderNotification : (Msg -> a) -> Notification a -> Html.Html a
renderNotification address model =
  let
    duration =
      (toString model.duration) ++ "ms"

    prefix =
      case Browser.prefix of
        Browser.Webkit -> "-webkit-"
        Browser.Moz -> "-moz-"
        Browser.MS -> "-ms-"
        Browser.O -> "-o-"
        _ -> ""
  in
    node "ui-notification"
      [ id (toString model.id)
      , classList [(model.class, True)]
      , onClick (address (Hide model.id))
      , style [ ("animation-duration", duration)
              , (prefix ++ "animation-duration", duration)
              ]
      ]
      [ node "div" [] [ model.contents ] ]

-- Initiliazes a notification with the given contents and model
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

-- Hides the notification with the given id
hide : Int -> Model msg -> (Model msg, Cmd Msg)
hide id model =
  let
    updatedNotifications =
      List.map updatedNotification model.notifications

    updatedNotification item =
      if item.id == id then
        { item | class = "ui-notification-hide" }
      else item
  in
    ({ model | notifications = updatedNotifications }
     , Task.perform Tasks (Remove id) (Process.sleep (model.duration + 100)))

-- Tries to hide the notification with the given id
autoHide: Int -> Model a -> (Model a, Cmd Msg)
autoHide id model =
  let
    updatedNotifications =
      List.map updatedNotification model.notifications

    isMember =
      List.map .id model.notifications
      |> List.member id

    hideEffect =
      if updatedNotifications /= model.notifications then
        Task.perform Tasks (Remove id) (Process.sleep (model.duration + 100))
      else
        Task.perform Tasks (AutoHide id) (Process.sleep 100)

    effect =
      if isMember then hideEffect else Cmd.none

    updatedNotification item =
      let
        index =
          List.Extra.elemIndex item model.notifications
          |> Maybe.withDefault -1
      in
        if item.id == id && index == 0 then
          { item | class = "ui-notification-hide" }
        else item
  in
    ({ model | notifications = updatedNotifications }, effect)

-- Removes the notification with the given id
remove : Int -> Model a -> (Model a, Cmd Msg)
remove id model =
  let
    updatedNotifications =
      List.filter (\item -> item.id /= id) model.notifications
  in
    ({ model | notifications = updatedNotifications }, Cmd.none)

