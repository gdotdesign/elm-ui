module Ui.NotificationCenter (Model, Action, init, update, view, notify) where

{-| Notification center for displaying messages to the user.

# Models
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs notify
-}
import Html.Attributes exposing (classList, style)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import Json.Encode
import VirtualDom
import List.Extra
import Effects
import Vendor
import Task

{-| Representation of a notification center:
  - **timeout** - The timeout of the notification before it's hidden
  - **notifications** - The list of notifications that is displayed
  - **duration** - The duration of the notifications animation
-}
type alias Model =
  { notifications : List Notification
  , duration : Float
  , timeout : Float
  }

{-| Actions that notification center can make. -}
type Action
  = AutoHide Int
  | Remove Int
  | Hide Int

{-| Initializes a notification center with the given timeout and duration (in
milliseconds).

    NotificationCenter.init timeout duration
-}
init : Float -> Float -> Model
init timeout duration =
  { duration = duration
  , notifications = []
  , timeout = timeout
  }

{-| Renders a notification center. -}
view: Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

{-| Updates a notification center. -}
update: Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    AutoHide id ->
      autoHide id model

    Remove id ->
      remove id model

    Hide id ->
      hide id model

{-| Adds a notification with the given html content.

    NotificationCenter.notify (text "Hello") model
-}
notify : Html.Html -> Model -> (Model, Effects.Effects Action)
notify contents model =
  let
    notification =
      initNotification model contents

    updatedModel =
      { model | notifications = model.notifications ++ [notification] }
  in
    (updatedModel, asEffect model.timeout (AutoHide notification.id))

-- PRIVATE --

-- Represents a notification
type alias Notification =
  { contents : Html.Html
  , duration : Float
  , class : String
  , id : Int
  }

-- Returns an effect that will be run after the given timeout
asEffect : Float -> Action -> Effects.Effects Action
asEffect timeout action =
  Task.andThen (Task.sleep timeout) (\_ -> Task.succeed action)
  |> Effects.task

-- Render
render: Signal.Address Action -> Model -> Html.Html
render address model =
  node "ui-notification-center" []
    (List.map (renderNotification address) model.notifications)

-- Renders a notification
renderNotification : Signal.Address Action -> Notification -> Html.Html
renderNotification address model =
  let
    duration =
      (toString model.duration) ++ "ms"

    prefix =
      case Vendor.prefix of
        Vendor.Webkit -> "-webkit-"
        Vendor.Moz -> "-moz-"
        Vendor.MS -> "-ms-"
        Vendor.O -> "-o-"
        _ -> ""
  in
    node "ui-notification"
      [ VirtualDom.property "key" (Json.Encode.int model.id)
      , classList [(model.class, True)]
      , onClick address (Hide model.id)
      , style [ ("animation-duration", duration)
              , (prefix ++ "animation-duration", duration)
              ]
      ]
      [ node "div" [] [ model.contents ] ]

-- Initiliazes a notification with the given contents and model
initNotification : Model -> Html.Html -> Notification
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
hide : Int -> Model -> (Model, Effects.Effects Action)
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
     , asEffect (model.duration + 100) (Remove id))

-- Tries to hide the notification with the given id
autoHide: Int -> Model -> (Model, Effects.Effects Action)
autoHide id model =
  let
    updatedNotifications =
      List.map updatedNotification model.notifications

    isMember =
      List.map .id model.notifications
      |> List.member id

    hideEffect =
      if updatedNotifications /= model.notifications then
        asEffect (model.duration + 100) (Remove id)
      else
        asEffect 100 (AutoHide id)

    effect =
      if isMember then hideEffect else Effects.none

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
remove : Int -> Model -> (Model, Effects.Effects Action)
remove id model =
  let
    updatedNotifications =
      List.filter (\item -> item.id /= id) model.notifications
  in
    ({ model | notifications = updatedNotifications }, Effects.none)

