module Ui.Pager where

import Html.Extra exposing (onTransitionEnd)
import Html.Attributes exposing (style, classList)
import Html exposing (node, text)
import Time exposing (Time, second)
import Effects
import Json.Decode as Json
import List.Extra

type alias Model =
  { left : List Int
  , center : List Int
  , active : Int
  , width : String
  , height : String
  }

type Action
  = Animate Time
  | End Int
  | Active Int

init : Int -> Model
init active =
  { left = []
  , center = []
  , active = active
  , width = "100vw"
  , height = "100vh"
  }

update : Action -> Model -> Model
update action model =
  case action of
    End page ->
      { model | left = [] }
    Active page ->
      { model | center = [], active = page }
    _ ->
      model

view : Signal.Address Action -> List Html.Html -> Model -> Html.Html
view address pages model =
  let
    updatedPage page =
      let
        index = Maybe.withDefault -1 (List.Extra.elemIndex page pages)

        attributes =
          if List.member index model.left then
            [ classList [("animating", True)]
            , style [("left", "-100%")]
            , onTransitionEnd address (End index)
            ]
          else if List.member index model.center then
            [ style [("left", "0%")]
            , classList [("animating", True)]
            , onTransitionEnd address (Active index)
            ]
          else if index == model.active then
            [ style [("left", "0%")] ]
          else
            [ style [("left", "100%")] ]
      in
        node "ui-page" attributes [page]
  in
    node
      "ui-pager"
      [ style [ ("width", model.width)
              , ("height", model.height)
              ]
      ]
      (List.map updatedPage pages)

select : Int -> Model -> Model
select page model =
  if model.left == [] && model.center == [] then
    { model | left = [model.active], center = [page] }
  else
    model
