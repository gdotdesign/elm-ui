module Ui.NumberPad where

import Number.Format exposing (prettyInt)
import Html.Extra exposing (onTouch)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import String

import Ui

{-| Represents a number pad.

-}
type alias Model =
  { value: Int
  , maximumDigits : Int
  , prefix : String
  , affix : String
  }

type Action
  = Pressed Int
  | Delete

init : Model
init =
  { value = 0
  , maximumDigits = 10
  , prefix = "- "
  , affix = " Ft"
  }

update : Action -> Model -> Model
update action model =
  case action of
    Pressed number ->
      addDigit number model
    Delete ->
      deleteDigit model

deleteDigit : Model -> Model
deleteDigit model =
  let
    value =
      toString model.value
        |> String.dropRight 1
        |> String.toInt
        |> Result.withDefault 0
  in
    { model | value = value }

addDigit : Int -> Model -> Model
addDigit number model =
  let
    result =
      (toString model.value) ++ (toString number)

    value =
      if (String.length result) > model.maximumDigits then
        model.value
      else
        String.toInt result
          |> Result.withDefault 0
  in
    { model | value = value }

view : Signal.Address Action -> Model -> Html.Html
view address model =
  let
    buttons =
      List.map (\number -> renderButton address number) [1,2,3,4,5,6,7,8,9]
    textValue =
      text (model.prefix ++ (prettyInt ',' model.value) ++ model.affix)
  in
    node "ui-number-pad" []
      [ node "ui-number-pad-value" []
        [ node "span" [] [textValue]
        , Ui.icon "backspace" True [onClick address Delete]
        ]
      , node "ui-number-pad-buttons" [] (buttons ++ [renderButton address 0])
      ]

renderButton : Signal.Address Action -> Int -> Html.Html
renderButton address number =
  node
    "ui-number-pad-button"
    [onClick address (Pressed number)]
    [text (toString number)]
