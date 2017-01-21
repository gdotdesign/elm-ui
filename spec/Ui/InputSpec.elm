import Spec exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Container
import Ui.Input

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Container
import Ui.Styles.Input
import Ui.Styles

import Steps exposing (keyDown)

import Json.Encode as Json

view : Ui.Input.Model -> Html.Html Ui.Input.Msg
view model =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.Input.style
      , Ui.Styles.Container.style
      ] default
    , Ui.Container.row []
      [ Ui.Input.view model
      , Ui.Input.view { model | disabled = True }
      , Ui.Input.view { model | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.Input"
    [ context "Disabled"
      [ it "input has disabled attribute"
        [ assert.elementPresent "ui-input:nth-child(2) input[disabled]"
        ]
      ]
    , context "Readonly"
      [ it "input has readonly attribute"
        [ assert.elementPresent "ui-input:nth-child(3) input[readonly]"
        ]
      ]
    , context "Clear icon"
      [ before
        [ steps.setValue "test" "ui-input:first-child input"
        , steps.dispatchEvent "input" (Json.object []) "ui-input:first-child input"
        ]
      , it "should be visible"
        [ assert.elementPresent "ui-input svg"
        ]
      , context "clicking"
        [ it "clears the input"
          [ steps.dispatchEvent "click" (Json.object []) "ui-input svg"
          , assert.valueEquals
            { selector = "ui-input:first-child input"
            , text = ""
            }
          ]
        ]
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Input.update
    , init = \_ ->
      Ui.Input.init ()
      |> Ui.Input.showClearIcon True
    , view = view
    } specs
