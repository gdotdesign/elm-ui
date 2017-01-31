module Ui.Helpers.Picker exposing (..)

{-| This is a module for creating dropdowns that acts as pickers.

# Model
@docs Model, Msg, update, subscriptions

# View
@docs ViewModel, view
-}

import Html.Events exposing (onBlur, onMouseDown, onFocus, on)
import Html.Events.Extra exposing (onKeys, onFocusOut)
import Html.Attributes exposing (attribute)
import Html exposing (node)

import Ui.Helpers.Dropdown as Dropdown exposing (Dropdown)
import Ui

import DOM

{-| Represents a picker.
-}
type alias Model a =
  { a
    | dropdown : Dropdown
    , readonly : Bool
    , disabled : Bool
    , uid : String
  }


{-| Represents the arguments for the view of a picker.
-}
type alias ViewModel msg =
  { dropdownContents : List (Html.Html msg)
  , attributes : List (Html.Attribute msg)
  , contents : List (Html.Html msg)
  , keyActions : List (Int, msg)
  , address : Msg -> msg
  }


{-| Messages that a picker can receive.
-}
type Msg
  = Dropdown Dropdown.Msg
  | Toggle
  | Focus
  | Close
  | Blur


{-| Subscriptions for a picker.
-}
subscriptions : Model a -> Sub Msg
subscriptions model =
  Sub.map Dropdown (Dropdown.subscriptions model)


{-| Updates a picker.
-}
update : Msg -> Model a -> Model a
update action model =
  case action of
    Toggle ->
      if DOM.contains ("[id='" ++ model.uid ++ "']:focus") then
        Dropdown.toggle model
      else
        model

    Blur ->
      let
        selector =
          "[id='" ++ model.uid ++ "'] *:focus"
      in
        if DOM.contains selector then
          model
        else
          Dropdown.close model

    Dropdown msg ->
      Dropdown.update msg model

    Close ->
      Dropdown.close model

    Focus ->
      Dropdown.open model


{-| Renders a picker.
-}
view : ViewModel msg -> Model a -> Html.Html msg
view ({ address } as viewModel) model =
  let
    actions =
      Ui.enabledActions
        model
        [ onFocusOut (address Blur)
        , onFocus (address Focus)
        , onBlur (address Blur)
        , onKeys False
          ([ ( 13, (address Toggle) )
            , ( 27, (address Close) )
            ] ++ viewModel.keyActions)
        ]


    toggleAction =
      if DOM.contains ("[id='" ++ model.uid ++ "']:focus") then
        [ onMouseDown Toggle ]
      else
        []

    finalActions =
      [ Ui.attributeList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
      , actions
      , Ui.tabIndex model
      , viewModel.attributes
      ]
        |> List.concat

    toggleAttributes =
      List.map (Html.Attributes.map viewModel.address) toggleAction
  in
    Dropdown.view
      { address = viewModel.address << Dropdown
      , contents = viewModel.dropdownContents
      , attributes = finalActions
      , tag = "ui-picker"
      , children =
          [ node "ui-picker-input" toggleAttributes viewModel.contents
          ]
      }
      model
