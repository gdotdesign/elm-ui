module Main where

import Signal exposing (forwardTo)
import StartApp
import Effects
import Task

import Html exposing (div, span, strong, text)

import Ui.Container
import Ui.Button
import Ui.App
import Ui

type alias Model =
  { app : Ui.App.Model
  , counter : Int
  }

type Action
  = App Ui.App.Action
  | Increment
  | Decrement

init : Model
init =
  { app = Ui.App.init "Elm-UI Project"
  , counter = 0
  }

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    App act ->
      let
        (app, effect) = Ui.App.update act model.app
      in
        ({ model | app = app }, Effects.map App effect)

    Increment ->
      ({ model | counter = model.counter + 1 }, Effects.none)

    Decrement ->
      ({ model | counter = model.counter - 1 }, Effects.none)

view : Signal.Address Action -> Model -> Html.Html
view address model =
  Ui.App.view (forwardTo address App) model.app
    [ Ui.Container.column []
      [ Ui.title [] [text "Elm-UI Counter"]
      , Ui.textBlock "This is an minimal project to get you started with Elm-UI!"
      , div []
        [ span [] [text "Counter:"]
        , strong [] [text (toString model.counter)]
        ]
      , Ui.Container.row []
        [ Ui.Button.primary "Decrement" address Decrement
        , Ui.Button.primary "Increment" address Increment
        ]
      ]
    ]

app =
  StartApp.start { init = (init, Effects.none)
                 , update = update
                 , view = view
                 , inputs = []
                 }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
