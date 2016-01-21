module Ui.NumberPad
  (Model, Action, init, initWithAddress, update, ViewModel, view, setValue) where

{-| Number pad component.

# Model
@docs Model, Action, init, initWithAddress, update

# View
@docs ViewModel, view

# Functions
@docs setValue
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, text)
import Html.Lazy

import Number.Format exposing (prettyInt)
import Ext.Signal
import Effects
import Signal
import String
import Dict

import Ui

{-| Representation of a number pad.
  - **valueAddress** - The address to send the changes in value
  - **readonly** - Whether or not the number pad is interactive
  - **disabled** - Whether or not the number pad is disabled
  - **maximumDigits** - The maximum length of the value
  - **format** - Wheter or not to format the value
  - **prefix** - The prefix to use
  - **value** - The current value
  - **affix** - The affix to use
-}
type alias Model =
  { valueAddress : Maybe (Signal.Address Int)
  , maximumDigits : Int
  , disabled : Bool
  , readonly : Bool
  , prefix : String
  , affix : String
  , format : Bool
  , value: Int
  }

{-| Represents elements for the view:
  - **bottomRight** - What to display in the bottom right button
  - **bottomLeft** - What to display in the bottom left button
-}
type alias ViewModel =
  { bottomRight : Html.Html
  , bottomLeft : Html.Html
  }

{-| Actions that a number pad can make. -}
type Action
  = Pressed Int
  | Tasks ()
  | Delete

{-| Initializes a number pad with the given value.

    NumberPad.init 0
-}
init : Int -> Model
init value =
  { valueAddress = Nothing
  , maximumDigits = 10
  , disabled = False
  , readonly = False
  , format = True
  , value = value
  , prefix = ""
  , affix = ""
  }

{-| Initializes a number pad with the given value.

    NumberPad.init (forwardTo address NumberPadChanged) 0
-}
initWithAddress : Signal.Address Int -> Int -> Model
initWithAddress valueAddress value =
  let
    model = init value
  in
    { model | valueAddress = Just valueAddress }

{-| Updates a number pad. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Pressed number ->
      addDigit number model
      |> sendValue

    Delete ->
      deleteDigit model
      |> sendValue

    Tasks _ ->
      (model, Effects.none)

-- Sends the value to the signal
sendValue : Model -> (Model, Effects.Effects Action)
sendValue model =
  (model, Ext.Signal.sendAsEffect model.valueAddress model.value Tasks)

{-| Renders a number pad. -}
view : ViewModel -> Signal.Address Action -> Model -> Html.Html
view viewModel address model =
  Html.Lazy.lazy3 render viewModel address model

-- Renders a number pad.
render : ViewModel -> Signal.Address Action -> Model -> Html.Html
render viewModel address model =
  let
    value =
      if model.format then prettyInt ',' model.value else toString model.value

    buttons =
      List.map (\number -> renderButton address number model) [1,2,3,4,5,6,7,8,9]

    textValue =
      text (model.prefix ++ value ++ model.affix)

    back =
      Ui.enabledActions model [onClick address Delete]

    actions =
      Ui.enabledActions model
        [ onKeys address [ (8, Delete)
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
                         ]
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
setValue : Int -> Model -> (Model, Effects.Effects Action)
setValue value model =
  { model | value = clampValue value model }
  |> sendValue

{- Renders a digit button. -}
renderButton : Signal.Address Action -> Int -> Model -> Html.Html
renderButton address number model =
  let
    click = Ui.enabledActions model [onClick address (Pressed number)]
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
