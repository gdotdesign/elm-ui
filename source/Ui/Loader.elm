module Ui.Loader where

import Effects
import Task

import Html.Attributes exposing (classList)
import Html exposing (node)

import Svg.Attributes exposing (x, y, width, height, transform, attributeType,
                                attributeName, type', values, begin, dur,
                                repeatCount)
import Svg exposing (svg, rect, animateTransform)

loader1 =
  let
    animateAttributes = [ attributeType "xml"
                        , attributeName "transform"
                        , type' "translate"
                        , values "0 0; 0 20; 0 0"
                        , dur "0.6s"
                        , repeatCount "indefinite"
                        ]
  in
    svg [width "24px", height "30px"]
      [ rect [x "0", y "0", width "4", height "10", transform "translate(0 2.22222)"]
        [ animateTransform ((begin "0") :: animateAttributes) [] ]
      , rect [x "10", y "0", width "4", height "10", transform "translate(0 11.1111)"]
        [ animateTransform ((begin "0.2s") :: animateAttributes) [] ]
      , rect [x "20", y "0", width "4", height "10", transform "translate(0 15.5556)"]
        [ animateTransform ((begin "0.4s") :: animateAttributes) [] ]
      ]

type alias Model =
  { loading : Bool
  , shown : Bool
  , timeout : Float
  }

type Action = Show

init : Float -> Model
init timeout =
  { loading = False
  , shown = False
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

overlayView : Model -> Html.Html
overlayView model =
  view "overlay" [loader1] model

barView : Model -> Html.Html
barView model =
  view "bar" [] model

view : String -> List Html.Html -> Model -> Html.Html
view kind content model =
  node "ui-loader"
    [ classList [ ("ui-loader-" ++ kind, True)
                , ("loading", model.shown)
                ]
    ]
    content

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
