module Ui.Notifications where

import Html.Attributes exposing (classList, style)
import Html exposing (node, text)

import Effects
import Task
import Debug exposing (log)
import List.Extra

type alias Notification =
  { id : Int
  , text : String
  , class : String
  , duration : Float
  }

type alias Model =
  { notifications : List Notification
  , timeout : Float
  , duration : Float
  }

type Action
  = Hide
  | Remove

init : Float -> Float -> Model
init timeout duration =
  { notifications = []
  , timeout = timeout
  , duration = duration
  }

view: Signal.Address Action -> Model -> Html.Html
view address model =
  node "ui-notifications" []
    (List.map (renderNotification address) model.notifications)

update: Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Hide ->
      ({ model | notifications = hideFirst model.notifications }
       , asEffect model.duration Remove)
    Remove ->
      ({ model | notifications = remove model.notifications }
       , Effects.none)

add : String -> Model -> (Model, Effects.Effects Action)
add text model =
  let
    noti = initNotification model text
    updatedModel = { model | notifications = noti :: model.notifications }
  in
    (updatedModel, asEffect model.timeout Hide)

asEffect timeout action =
  Task.andThen (Task.sleep timeout) (\_ -> Task.succeed action)
  |> Effects.task

renderNotification : Signal.Address Action -> Notification -> Html.Html
renderNotification address model =
  node "ui-notification"
    [ classList [(model.class, True)]
    , style [ ("animation-duration", (toString model.duration) ++ "ms") ]
    ]
    [ node "div" [] [text model.text] ]

initNotification : Model -> String -> Notification
initNotification model text =
  let
    id =
      List.map .id model.notifications
      |> List.maximum
      |> Maybe.withDefault -1
  in
    { id = id + 1
    , text = text
    , class = "ui-notification-show"
    , duration = model.duration
    }

hideFirst: List Notification -> List Notification
hideFirst notifications =
  let
    first = List.head notifications
    id =
      Maybe.map (\item ->  if item.class == "ui-notification-hide" then -1 else item.id) first
        |> Maybe.withDefault -1
    updatedNoti item =
      if item.id == id then
        { item | class = "ui-notification-hide" }
      else item
  in
    List.map updatedNoti notifications

remove : List Notification -> List Notification
remove notifications =
  let
    first = List.head notifications
    id =
      Maybe.map (\item ->  if item.class == "ui-notification-show" then -1 else item.id) first
        |> Maybe.withDefault -1
  in
    List.filter (\item -> item.id /= id) notifications
