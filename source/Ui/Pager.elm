module Ui.Pager where

import Html.Attributes exposing (style)
import Html exposing (node, text)
import Time exposing (Time, second)
import Effects
import List.Extra

import Ui.Helpers.Animation as Animation exposing (Animation)

type alias Model =
  { active : Int
  , next : Int
  , animation : Animation
  , width : String
  , height : String
  }

type Action
  = Animate Time

init : Int -> Model
init active =
  { active = active
  , next = active
  , animation = Animation.init 100 0 320
  , width = "100vw"
  , height = "100vh"
  }

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Animate clockTime ->
      let
        isEnded = Animation.isEnded updatedAnimation
        updatedAnimation
          = Animation.update clockTime model.animation
        effect =
          if isEnded then
            Effects.none
          else
            Effects.tick Animate
        active =
          if isEnded then
            model.next
          else
            model.active
      in
        ({ model | animation = updatedAnimation, active = active }, effect)

view : Signal.Address Action -> List Html.Html -> Model -> Html.Html
view address pages model =
  let
    updatedPage page =
      let
        index = Maybe.withDefault -1 (List.Extra.elemIndex page pages)
      in
        if index == model.active then
          if model.animation.running then
            node "ui-page" [style [("left", (toString -(100 - model.animation.value)) ++ "%")]] [page]
          else
            node "ui-page" [style [("left", "0%")]] [page]
        else if index == model.next then
          node "ui-page" [style [("left", (toString model.animation.value) ++ "%")]] [page]
        else
          node "ui-page" [style [("left", "100%")]] [page]
  in
    node
      "ui-pager"
      [ style [ ("width", model.width)
              , ("height", model.height)
              ]
      ]
      (List.map updatedPage pages)

select : Int -> Model -> (Model, Effects.Effects Action)
select page model =
  ({ model | next = page, animation = Animation.reset model.animation }, Effects.tick Animate)
