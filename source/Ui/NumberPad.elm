module Ui.NumberPad
  (Model, Action, init, update, ViewModel, view, setValue) where

{-| Number pad component.

# Model
@docs Model, Action, init, update

# View
@docs ViewModel, view

# Functions
@docs setValue
-}
import Html.Attributes exposing (classList)
import Html.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import Number.Format exposing (prettyInt)
import String
import Dict

import Ui

{-| Representation of a number pad.
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
  , disabled : Bool
  , readonly : Bool
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
  , disabled = False
  , readonly = False
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
  Html.Lazy.lazy3 render address viewModel model

-- Renders a number pad.
render : Signal.Address Action -> ViewModel -> Model -> Html.Html
render address viewModel model =
  let
    value =
      if model.format then prettyInt ',' model.value else toString model.value

    buttons =
      List.map (\number -> renderButton address number model) [1,2,3,4,5,6,7,8,9]

    textValue =
      text (model.prefix ++ value ++ model.affix)

    back =
      if model.disabled || model.readonly then []
      else [onClick address Delete]

    actions =
      if model.disabled || model.readonly then []
      else [ onKeys address
              (Dict.fromList [ (8, Delete)
              , (46, Delete)
              , (48, Pressed 0)
              , (49, Pressed 1)
              , (50, Pressed 2)
              , (51, Pressed 3)
              , (52, Pressed 4)
              , (53, Pressed 5)
              , (54, Pressed 6)
              , (55, Pressed 7)
              , (56, Pressed 8)
              , (57, Pressed 9)
              , (96, Pressed 0)
              , (97, Pressed 1)
              , (98, Pressed 2)
              , (99, Pressed 3)
              , (100, Pressed 4)
              , (101, Pressed 5)
              , (102, Pressed 6)
              , (103, Pressed 7)
              , (104, Pressed 8)
              , (105, Pressed 9)
              ])
            ]
  in
    node "ui-number-pad"
      ((Ui.tabIndex model) ++ actions ++
        [classList [ ("disabled", model.disabled)
                   , ("readonly", model.readonly)
                   ]])
      [ node "ui-number-pad-value" []
        [ node "span" [] [textValue]
        , Ui.icon "backspace" True back
        ]
      , node "ui-number-pad-buttons" []
        (buttons ++ [ node "ui-number-pad-button" [] [viewModel.bottomLeft]
                    , renderButton address 0 model
                    , node "ui-number-pad-button" [] [viewModel.bottomRight]
                    ])
      ]

{-| Sets the value of a number pad. -}
setValue : Int -> Model -> Model
setValue value model =
  { model | value = clampValue value model }

{- Renders a digit button. -}
renderButton : Signal.Address Action -> Int -> Model -> Html.Html
renderButton address number model =
  let
    click =
      if model.disabled || model.readonly then []
      else [onClick address (Pressed number)]
  in
    node
      "ui-number-pad-button"
      click
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

{- Clamps the value to the max digit. -}
clampValue : Int -> Model -> Int
clampValue value model =
  if (String.length (toString value)) > model.maximumDigits then
    model.value
  else
    value

{- Adds a digit to the end of the value. -}
addDigit : Int -> Model -> Model
addDigit number model =
  let
    result =
      (toString model.value) ++ (toString number)
        |> String.toInt
        |> Result.withDefault 0

    value =
      clampValue result model
  in
    { model | value = value }
