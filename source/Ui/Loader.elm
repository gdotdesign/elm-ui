module Ui.Loader where

import Effects
import Task

import Html.Attributes exposing (classList)
import Html exposing (node)

type alias Model =
  { loading : Bool
  , shown : Bool
  , kind : String
  , timeout : Float
  }

type Action = Show

init : Float -> String -> Model
init timeout kind =
  { loading = False
  , shown = False
  , kind = kind
  , timeout = timeout
  }

update : Action -> Model -> Model
update action model =
  case action of
    Show ->
      if model.loading then
        { model | shown = True }
      else
        model

view : Model -> Html.Html
view model =
  node "ui-loader"
    [ classList [ (model.kind, True)
                , ("loading", model.shown)
                ]
    ]
    []

finish : Model -> Model
finish model =
  { model | loading = False, shown = False }

start :  Model -> (Model, Effects.Effects Action)
start model =
  let
    effect =
      Task.andThen
        (Task.sleep model.timeout)
        (\_ -> Task.succeed Show)
        |> Effects.task
  in
  ({ model | loading = True }, effect)
