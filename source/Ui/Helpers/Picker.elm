module Ui.Helpers.Picker exposing (..)

import Html.Events exposing (onBlur, onMouseDown, onFocus, on)
import Html.Events.Extra exposing (onKeys, onFocusOut)
import Html.Attributes exposing (classList)
import Html exposing (node)

import Ui.Helpers.Dropdown as Dropdown exposing (Dropdown)
import Ui

type alias Model a =
  { a
  | dropdown : Dropdown
  , readonly : Bool
  , disabled : Bool
  , uid : String
  }

type alias ViewModel msg =
  { contents : List (Html.Html msg)
  , dropdownContents : List (Html.Html msg)
  , attributes : List (Html.Attribute msg)
  , address : Msg -> msg
  }

type Msg
  = Dropdown Dropdown.Msg
  | Toggle
  | Focus
  | Close
  | Blur

subscriptions model =
  Sub.map Dropdown (Dropdown.subscriptions model)

update : Msg -> Model a -> Model a
update action model =
  case action of
    Dropdown msg ->
      Dropdown.update msg model

    Toggle ->
      Dropdown.toggle model

    Focus ->
      Dropdown.open model

    Close ->
      Dropdown.close model

    Blur ->
      let
        selector =
          "[id='" ++ model.uid ++ "'] *:focus"
      in
        if Native.Dom.test selector then
          model
        else
          Dropdown.close model


view : ViewModel msg -> Model a -> Html.Html msg
view ({ address } as viewModel) model =
  let
    actions =
      Ui.enabledActions
        model
        ([ onFocusOut (address Blur)
        , onFocus (address Focus)
        , onBlur (address Blur)
        , onKeys
            [ ( 13, (address Toggle) )
            , ( 27, (address Close) )
            ]
        ] ++ viewModel.attributes)

    toggleAction =
      if Native.Dom.test ("[id='" ++ model.uid ++ "']:focus") then
        [ onMouseDown Toggle ]
      else
        []

    finalActions =
      [ classList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
      ]
        ++ actions
        ++ (Ui.tabIndex model)

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
      } model
