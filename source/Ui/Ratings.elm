module Ui.Ratings exposing
  ( Model, Msg, init, onChange, update, view, render, setValue, valueAsStars
  , size, setValueAsStars )

{-| A simple star rating component.

# Model
@docs Model, Msg, init, onChange, update

# DSL
@docs size

# View
@docs view, render

# Functions
@docs setValue, setValueAsStars, valueAsStars
-}

import Ext.Number exposing (roundTo)
import Array

import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Html.Events.Extra exposing (onKeys)
import Html exposing (node)
import Html.Lazy

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.Icons
import Ui

import Ui.Styles.Ratings exposing (defaultStyle)
import Ui.Styles

{-| Representation of a ratings component:
  - **clearable** - Whether or not the component is clearable
  - **disabled** - Whether or not the component is disabled
  - **readonly** - Whether or not the component is readonly
  - **hoverValue** - The transient value of the component
  - **value** - The current value of the component (0..1)
  - **uid** - The unique identifier of the input
  - **size** - The number of starts to display
-}
type alias Model =
  { hoverValue : Float
  , clearable : Bool
  , disabled : Bool
  , readonly : Bool
  , value : Float
  , uid : String
  , size : Int
  }


{-| Messages that a ratings component can receive.
-}
type Msg
  = MouseEnter Int
  | MouseLeave
  | Increment
  | Decrement
  | Click Int


{-| Initializes a ratings component.

    ratings = Ui.Ratings.init ()
-}
init : () -> Model
init _ =
  { clearable = False
  , uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , hoverValue = 0
  , value = 0
  , size = 5
  }


{-| Subscribe to the changes of a ratings components.

    subscriptions = Ui.Ratings.onChange RatingsChanged ratings
-}
onChange : (Float -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenFloat model.uid msg


{-| Sets the size of a ratings component.
-}
size : Int -> Model -> Model
size value model =
  { model | size = value }


{-| Updates a ratings component.

    ( updatedRatings, cmd ) = Ui.Ratings.update msg ratings
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    MouseEnter index ->
      ( { model | hoverValue = calculateValue index model }, Cmd.none )

    MouseLeave ->
      ( { model | hoverValue = model.value }, Cmd.none )

    Increment ->
      setAndSendValue (clamp 0 1 (model.value + (1 / (toFloat model.size)))) model

    Decrement ->
      let
        oneStarValue =
          1 / (toFloat model.size)

        min =
          if model.clearable then
            0
          else
            oneStarValue
      in
        setAndSendValue (clamp oneStarValue 1 (model.value - oneStarValue)) model

    Click index ->
      setAndSendValue (calculateValue index model) model


{-| Lazily renders a ratings component.

    Ui.Ratings.view ratings
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a ratings component.

    Ui.Ratings.render ratings
-}
render : Model -> Html.Html Msg
render model =
  let
    actions =
      Ui.enabledActions
        model
        [ onKeys True
            [ ( 40, Decrement )
            , ( 38, Increment )
            , ( 37, Decrement )
            , ( 39, Increment )
            ]
        ]

    stars =
      Array.initialize model.size ((+) 1)
        |> Array.toList
  in
    node
      "ui-ratings"
      ([ Ui.attributeList
         [ ( "disabled", model.disabled )
         , ( "readonly", model.readonly )
         ]
       , Ui.Styles.apply defaultStyle
       , Ui.tabIndex model
       , actions
       ]
        |> List.concat
      )
      (List.map (renderStar model) stars)


{-| Sets the value of a ratings component.

    Ui.Ratings.setValue 0.8 ratings
-}
setValue : Float -> Model -> Model
setValue value_ model =
  let
    value =
      roundTo 2 value_
  in
    if model.value == value
    && model.hoverValue == value
    then
      model
    else
      { model
        | value = value
        , hoverValue = value
      }


{-| Sets the value of a ratrings component as stars.
-}
setValueAsStars : Int -> Model -> Model
setValueAsStars value_ model =
  let
    value =
      (toFloat value_) / (toFloat model.size)
        |> clamp 0 1
  in
    setValue value model


{-| Returns the value of a ratings component as number of stars.

    Ui.NumberRange.valueAsStars 10 ratings
-}
valueAsStars : Float -> Model -> Int
valueAsStars value model =
  round (value * (toFloat model.size))


{-| Sets the given value and sends it to the value address.
-}
setAndSendValue : Float -> Model -> ( Model, Cmd Msg )
setAndSendValue value model =
  let
    updatedModel =
      setValue value model
  in
    if model.value == updatedModel.value then
      ( model, Cmd.none )
    else
      ( updatedModel, sendValue updatedModel )


{-| Sends the value to the value address as an effect.
-}
sendValue : Model -> Cmd Msg
sendValue model =
  Emitter.sendFloat model.uid model.value


{-| Calculates the value for the given star (index).
-}
calculateValue : Int -> Model -> Float
calculateValue index model =
  let
    value =
      clamp 0 1 ((toFloat index) / (toFloat model.size))

    currentIndex =
      valueAsStars model.value model
  in
    if currentIndex == index && model.clearable then
      0
    else
      value


{-| Renders a individual star.
-}
renderStar : Model -> Int -> Html.Html Msg
renderStar model index =
  let
    actions =
      Ui.enabledActions
        model
        [ onMouseEnter (MouseEnter index)
        , onMouseLeave MouseLeave
        , onClick (Click index)
        ]

    icon =
      if ((toFloat index) / (toFloat model.size)) <= model.hoverValue then
        Ui.Icons.starFull
      else
        Ui.Icons.starEmpty
  in
    node "ui-ratings-star" actions [ icon [] ]
