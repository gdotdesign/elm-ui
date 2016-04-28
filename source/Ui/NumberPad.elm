module Ui.NumberPad exposing
  (Model, Msg, init, update, ViewModel, view, setValue)

-- where

{-| Number pad component.

# Model
@docs Model, Msg, init, update

# View
@docs ViewModel, view

# Functions
@docs setValue
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, text)

import Number.Format exposing (prettyInt)
import String
import Dict

import Native.Uid

import Ui.Helpers.Emitter as Emitter
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
  { maximumDigits : Int
  , disabled : Bool
  , readonly : Bool
  , prefix : String
  , affix : String
  , format : Bool
  , value : Int
  , uid : String
  }

{-| Represents elements for the view:
  - **bottomRight** - What to display in the bottom right button
  - **bottomLeft** - What to display in the bottom left button
-}
type alias ViewModel msg =
  { bottomRight : Html.Html msg
  , bottomLeft : Html.Html msg
  }

{-| Actions that a number pad can make. -}
type Msg
  = Pressed Int
  | Tasks ()
  | Delete

{-| Initializes a number pad with the given value.

    NumberPad.init 0
-}
init : Int -> Model
init value =
  {  maximumDigits = 10
  , disabled = False
  , readonly = False
  , format = True
  , value = value
  , prefix = ""
  , affix = ""
  , uid = Native.Uid.uid ()
  }

{-| Updates a number pad. -}
update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Pressed number ->
      addDigit number model
      |> sendValue

    Delete ->
      deleteDigit model
      |> sendValue

    Tasks _ ->
      (model, Cmd.none)

-- Sends the value to the signal
sendValue : Model -> (Model, Cmd Msg)
sendValue model =
  (model, Emitter.sendInt model.uid model.value)

{-| Renders a number pad. -}
view : ViewModel msg -> (Msg -> msg) -> Model -> Html.Html msg
view viewModel address model =
  render viewModel address model

-- Renders a number pad.
render : ViewModel msg -> (Msg -> msg) -> Model -> Html.Html msg
render viewModel address model =
  let
    value =
      if model.format then prettyInt ',' model.value else toString model.value

    buttons =
      List.map (\number -> renderButton address number model) [1,2,3,4,5,6,7,8,9]

    textValue =
      text (model.prefix ++ value ++ model.affix)

    back =
      Ui.enabledActions model [onClick (address Delete)]

    actions =
      Ui.enabledActions model
        [ onKeys [ (8, address Delete)
                 , (46, address Delete)
                 , (48, address (Pressed 0))
                 , (49, address (Pressed 1))
                 , (50, address (Pressed 2))
                 , (51, address (Pressed 3))
                 , (52, address (Pressed 4))
                 , (53, address (Pressed 5))
                 , (54, address (Pressed 6))
                 , (55, address (Pressed 7))
                 , (56, address (Pressed 8))
                 , (57, address (Pressed 9))
                 , (96, address (Pressed 0))
                 , (97, address (Pressed 1))
                 , (98, address (Pressed 2))
                 , (99, address (Pressed 3))
                 , (100, address (Pressed 4))
                 , (101, address (Pressed 5))
                 , (102, address (Pressed 6))
                 , (103, address (Pressed 7))
                 , (104, address (Pressed 8))
                 , (105, address (Pressed 9))
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
setValue : Int -> Model -> Model
setValue value model =
  { model | value = clampValue value model }

{- Renders a digit button. -}
renderButton : (Msg -> msg) -> Int -> Model -> Html.Html msg
renderButton address number model =
  let
    click = Ui.enabledActions model [onClick (address (Pressed number))]
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
