import Spec exposing (describe, it, Node, context, before, after)
import Spec.Assertions exposing (assert)
import Spec.Steps exposing (click)
import Spec.Runner

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Checkbox
import Ui.Styles

import Steps exposing (keyDown)

view : Ui.Checkbox.Model -> Html.Html Ui.Checkbox.Msg
view model =
  div
    [ ]
    [ Ui.Styles.embed
    , Ui.Checkbox.view model
    , Ui.Checkbox.view { model | disabled = True }
    , Ui.Checkbox.view { model | readonly = True }
    ]

specs : Node
specs =
  describe "Ui.Checkbox"
    [ it "has tabindex"
      [ assert.elementPresent "ui-checkbox[tabindex]"
      ]
    , context "Disabled"
      [ it "does not have tabindex"
        [ assert.not.elementPresent "ui-checkbox[disabled][tabindex]"
        ]
      ]
    , context "Redaonly"
      [ it "has tabindex"
        [ assert.elementPresent "ui-checkbox[readonly][tabindex]"
        ]
      ]
    , context "Toggle"
      [ before
        [ assert.not.elementPresent "ui-checkbox[checked]"
        ]
      , after
        [ assert.elementPresent "ui-checkbox[checked]"
        ]
      , it "on click"
        [ click "ui-checkbox"
        ]
      , it "on enter"
        [ keyDown 13 "ui-checkbox"
        ]
      , it "on space"
        [ keyDown 32 "ui-checkbox"
        ]
      ]
    , context "No actions"
      [ before
        [ assert.not.elementPresent "ui-checkbox[checked]"
        ]
      , after
        [ assert.not.elementPresent "ui-checkbox[checked]"
        ]
      , context "Disabled"
        [ it "not toggles on click"
          [ click "ui-checkbox[disabled]"
          ]
        , it "not toggles on enter"
          [ keyDown 13 "ui-checkbox[disabled]"
          ]
        , it "not toggles on space"
          [ keyDown 32 "ui-checkbox[disabled]"
          ]
        ]
      , context "Readonly"
        [ it "should not trigger action on click"
          [ click "ui-checkbox[readonly]"
          ]
        , it "not triggers on enter"
          [ keyDown 13 "ui-checkbox[readonly]"
          ]
        , it "not triggers on enter"
          [ keyDown 32 "ui-checkbox[readonly]"
          ]
        ]
      ]
    ]

main =
  Spec.Runner.runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Checkbox.update
    , init = Ui.Checkbox.init
    , view = view
    } specs
