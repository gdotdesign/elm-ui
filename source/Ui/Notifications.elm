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
  = Hide Int
  | Remove Int

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
  case log "a" action of
    Hide id ->
      hide id model
    Remove id ->
      ({ model | notifications = remove id model.notifications }
       , Effects.none)

add : String -> Model -> (Model, Effects.Effects Action)
add text model =
  let
    noti = initNotification model text
    updatedModel = { model | notifications = model.notifications ++ [noti] }
  in
    (updatedModel, asEffect model.timeout (Hide noti.id))

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

hide: Int -> Model -> (Model, Effects.Effects Action)
hide id model =
  let
    updatedNotis = List.map updatedNoti model.notifications
    effect =
      if updatedNotis /= model.notifications then asEffect model.duration (Remove id)
      else asEffect 10 (Hide id)
    updatedNoti item =
      let
        index = List.Extra.elemIndex item model.notifications
                |> Maybe.withDefault -1
      in
        if item.id == id && index == 0 then
          { item | class = "ui-notification-hide" }
        else item
  in
    ({ model | notifications = updatedNotis }, effect)

remove : Int -> List Notification -> List Notification
remove id notifications =
  List.filter (\item -> item.id /= id) notifications
