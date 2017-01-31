import Spec exposing (..)

import Html exposing (div, text, button)
import Html.Events exposing (onClick)
import Ui.NotificationCenter
import Steps exposing (..)


type alias Model =
  { notifications : Ui.NotificationCenter.Model Msg
  }


type Msg
  = NotificationCenter Ui.NotificationCenter.Msg
  | Notify


init : () -> Model
init _ =
  { notifications = Ui.NotificationCenter.init ()
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Notify ->
      let
        ( notifications, cmd ) =
          Ui.NotificationCenter.notify (text "Hello") model.notifications
      in
        ( { model | notifications = notifications }
        , Cmd.map NotificationCenter cmd )

    NotificationCenter msg ->
      let
        ( notifications, cmd ) =
          Ui.NotificationCenter.update msg model.notifications
      in
        ( { model | notifications = notifications }
        , Cmd.map NotificationCenter cmd )


view : Model -> Html.Html Msg
view { notifications } =
  div
    [ ]
    [ Ui.NotificationCenter.view NotificationCenter notifications
    , button [ onClick Notify ] [ text "Notify" ]
    ]


specs : Node
specs =
  describe "Ui.NotificationCenter"
    [ it "displays notificaitons"
      [ assert.not.elementPresent "ui-notification"
      , steps.click "button"
      , assert.elementPresent "ui-notification"
      ]
    , it "clicking on notification hides it"
      [ assert.not.elementPresent "ui-notification"
      , steps.click "button"
      , assert.elementPresent "ui-notification"
      , steps.click "ui-notification"
      , assert.elementPresent "ui-notification[ui-notification-hide]"
      ]
    ]


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , init = init
    , view = view
    } specs
