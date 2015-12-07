module Ui.NumberPad
  (Model, Action, init, update, ViewModel, view) where

{-| Number pad component.

# Model
@docs Model, Action, init, update

# View
@docs ViewModel, view
-}
import Number.Format exposing (prettyInt)
import Html.Extra exposing (onTouch)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import String

import Ui

{-| Represents a number pad.
  - **value** - The current value
  - **maximumDigits** - The maximum length of the value
  - **format** - Wheter or not to format the value
  - **prefix** - The prefix to use
  - **affix** - The affix to use
-}
type alias Model =
  { value: Int
  , maximumDigits : Int
  , format : Bool
  , prefix : String
  , affix : String
  }

{-| Represents elements for the view:
  - **bottomLeft** - What to display in the bottom left button
  - **bottomRight** - What to display in the bottom right button
-}
type alias ViewModel =
  { bottomLeft : Html.Html
  , bottomRight : Html.Html
  }

{-| Actions that a number pad can make. -}
type Action
  = Pressed Int
  | Delete

{-| Initializes a number pad with the given value.

    Ui.NumberPad.init 0
-}
init : Int -> Model
init value =
  { value = value
  , maximumDigits = 10
  , format = False
  , prefix = ""
  , affix = ""
  }

{-| Updates a number pad. -}
update : Action -> Model -> Model
update action model =
  case action of
    Pressed number ->
      addDigit number model
    Delete ->
      deleteDigit model

{-| Renders a number pad. -}
view : Signal.Address Action -> ViewModel -> Model -> Html.Html
view address viewModel model =
  let
    value =
      if model.format then prettyInt ',' model.value else toString model.value
    buttons =
      List.map (\number -> renderButton address number) [1,2,3,4,5,6,7,8,9]
    textValue =
      text (model.prefix ++ value ++ model.affix)
  in
    node "ui-number-pad" []
      [ node "ui-number-pad-value" []
        [ node "span" [] [textValue]
        , Ui.icon "backspace" True [onClick address Delete]
        ]
      , node "ui-number-pad-buttons" []
        (buttons ++ [ node "ui-number-pad-button" [] [viewModel.bottomLeft]
                    , renderButton address 0
                    , node "ui-number-pad-button" [] [viewModel.bottomRight]
                    ])
      ]

{- Renders a digit button. -}
renderButton : Signal.Address Action -> Int -> Html.Html
renderButton address number =
  node
    "ui-number-pad-button"
    [onClick address (Pressed number)]
    [text (toString number)]

{- Removes a digit from the end of the value. -}
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

{- Adds a digit to the end of the value. -}
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
