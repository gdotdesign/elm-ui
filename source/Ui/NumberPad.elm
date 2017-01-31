module Ui.NumberPad exposing
  ( Model, ViewModel, Msg, init, onChange, update, view, render, setValue
  , maximumDigits, format, affix, prefix )

{-| A component for displaying a type of
[numeric keypad](https://en.wikipedia.org/wiki/Numeric_keypad),
that is mainly used for asking the user for a passcode or other forms of
numberic data.

# Model
@docs Model, Msg, init, update

# Events
@docs onChange

# DSL
@docs maximumDigits, prefix, affix, format

# View
@docs ViewModel, view, render

# Functions
@docs setValue
-}

import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import Numeral
import String

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.Icons
import Ui

import Ui.Styles.NumberPad exposing (defaultStyle)
import Ui.Styles

{-| Representation of a number pad:
  - **disabled** - Whether or not the number pad is disabled
  - **readonly** - Whether or not the number pad is readonly
  - **maximumDigits** - The maximum length of the value
  - **format** - Wheter or not to format the value
  - **uid** - The unique identifier of the input
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
  , uid : String
  , value : Int
  }


{-| Representation of the elements for the view:
  - **bottomRight** - What to display in the bottom right button
  - **bottomLeft** - What to display in the bottom left button
-}
type alias ViewModel msg =
  { bottomRight : Html.Html msg
  , bottomLeft : Html.Html msg
  , address : (Msg -> msg)
  }


{-| Messages that a number pad can receive.
-}
type Msg
  = Pressed Int
  | Delete


{-| Initializes a number pad with the given value.

    numberPad =
      Ui.NumberPad.init ()
        |> Ui.NumberPad.maximumDigits 5
        |> Ui.NumberPad.affix "USD"
-}
init : () -> Model
init _ =
  { maximumDigits = 10
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , format = True
  , prefix = ""
  , affix = ""
  , value = 0
  }


{-| Subscribe to the changes of a number pad.

    subscriptions = Ui.NumberPad.onChange NumberPadChanged numberPad
-}
onChange : (Int -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenInt model.uid msg


{-| Sets the maximum digits enterable for a number pad.
-}
maximumDigits : Int -> Model -> Model
maximumDigits value model =
  { model | maximumDigits = value }


{-| Sets whether or not to format the value of a number pad.
-}
format : Bool -> Model -> Model
format value model =
  { model | format = value }


{-| Sets the affix of a number pad.
-}
affix : String -> Model -> Model
affix value model =
  { model | affix = value }


{-| Sets the prefix of a number pad.
-}
prefix : String -> Model -> Model
prefix value model =
  { model | prefix = value }


{-| Updates a number pad.

    ( updatedNumberPad, cmd ) = Ui.NumberPad.update msg numberPad
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Pressed number ->
      addDigit number model
        |> sendValue

    Delete ->
      deleteDigit model
        |> sendValue


{-| Lazily renders a number pad.

    Ui.NumberPad.view
      { bottomRight = text ""
      , bottomLeft = text ""
      , address = NumberPad
      }
      NumberPad
      numberPad
-}
view : ViewModel msg -> Model -> Html.Html msg
view viewModel model =
  Html.Lazy.lazy2 render viewModel model


{-| Renders a number pad.

    Ui.NumberPad.render
      { bottomRight = text ""
      , bottomLeft = text ""
      , address = NumberPad
      }
      NumberPad
      numberPad
-}
render : ViewModel msg -> Model -> Html.Html msg
render ({ address } as viewModel) model =
  let
    value =
      if model.format then
        Numeral.format "0,0" (toFloat model.value)
      else
        toString model.value

    buttons =
      List.map
        (renderButton address model)
        [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]

    textValue =
      text (model.prefix ++ value ++ model.affix)

    back =
      Ui.enabledActions model [ onClick (address Delete) ]

    actions =
      Ui.enabledActions
        model
        [ onKeys True
            [ ( 8, address Delete )
            , ( 46, address Delete )
            , ( 48, address (Pressed 0) )
            , ( 49, address (Pressed 1) )
            , ( 50, address (Pressed 2) )
            , ( 51, address (Pressed 3) )
            , ( 52, address (Pressed 4) )
            , ( 53, address (Pressed 5) )
            , ( 54, address (Pressed 6) )
            , ( 55, address (Pressed 7) )
            , ( 56, address (Pressed 8) )
            , ( 57, address (Pressed 9) )
            , ( 96, address (Pressed 0) )
            , ( 97, address (Pressed 1) )
            , ( 98, address (Pressed 2) )
            , ( 99, address (Pressed 3) )
            , ( 100, address (Pressed 4) )
            , ( 101, address (Pressed 5) )
            , ( 102, address (Pressed 6) )
            , ( 103, address (Pressed 7) )
            , ( 104, address (Pressed 8) )
            , ( 105, address (Pressed 9) )
            ]
        ]
  in
    node
      "ui-number-pad"
      ( [ Ui.Styles.apply defaultStyle
        , Ui.tabIndex model
        , actions
        , Ui.attributeList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
        ]
          |> List.concat
      )
      [ node
          "ui-number-pad-value"
          []
          [ node "span" [] [ textValue ]
          , Ui.Icons.backspace back
          ]
      , node
          "ui-number-pad-buttons"
          []
          (buttons
            ++ [ node "ui-number-pad-button" [] [ viewModel.bottomLeft ]
               , renderButton address model 0
               , node "ui-number-pad-button" [] [ viewModel.bottomRight ]
               ]
          )
      ]


{-| Sets the value of a number pad.

    updatedNumberPad = Ui.NumberPad.setValue 10 numberPad
-}
setValue : Int -> Model -> Model
setValue value model =
  { model | value = clampValue value model }


{-| Renders a digit button.
-}
renderButton : (Msg -> msg) -> Model -> Int ->  Html.Html msg
renderButton address model number =
  let
    click =
      Ui.enabledActions model [ onClick (address (Pressed number)) ]
  in
    node
      "ui-number-pad-button"
      click
      [ text (toString number) ]


{-| Removes a digit from the end of the value.
-}
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


{-| Adds a digit to the end of the value.
-}
addDigit : Int -> Model -> Model
addDigit number model =
  let
    result =
      (toString model.value)
        ++ (toString number)
        |> String.toInt
        |> Result.withDefault 0

    value =
      clampValue result model
  in
    { model | value = value }


{-| Clamps the value to the max digit.
-}
clampValue : Int -> Model -> Int
clampValue value model =
  if (String.length (toString value)) > model.maximumDigits then
    model.value
  else
    value


{-| Sends the value to the emitter.
-}
sendValue : Model -> ( Model, Cmd Msg )
sendValue model =
  ( model, Emitter.sendInt model.uid model.value )
