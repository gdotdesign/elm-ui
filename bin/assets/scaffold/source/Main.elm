module Main exposing (..)

import Html exposing (div, span, strong, text)
import Html.App

import Ui.Container
import Ui.Button
import Ui.App
import Ui


type alias Model =
  { app : Ui.App.Model
  , counter : Int
  }


type Msg
  = App Ui.App.Msg
  | Increment
  | Decrement


init : Model
init =
  { app = Ui.App.init "Elm-UI Project"
  , counter = 0
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    App act ->
      let
        ( app, effect ) =
          Ui.App.update act model.app
      in
        ( { model | app = app }, Cmd.map App effect )

    Increment ->
      ( { model | counter = model.counter + 1 }, Cmd.none )

    Decrement ->
      ( { model | counter = model.counter - 1 }, Cmd.none )


view : Model -> Html.Html Msg
view model =
  Ui.App.view
    App
    model.app
    [ Ui.Container.column
        []
        [ Ui.title [] [ text "Elm-UI Counter" ]
        , Ui.textBlock "This is an minimal project to get you started with Elm-UI!"
        , div
            []
            [ span [] [ text "Counter:" ]
            , strong [] [ text (toString model.counter) ]
            ]
        , Ui.Container.row
            []
            [ Ui.Button.primary "Decrement" Decrement
            , Ui.Button.primary "Increment" Increment
            ]
        ]
    ]


main =
  Html.App.program
    { init = ( init, Cmd.none )
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }
