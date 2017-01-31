import Spec exposing (..)

import Steps exposing (..)
import Ui.Container
import Ui.Checkbox
import Html


view : Ui.Checkbox.Model -> Html.Html Ui.Checkbox.Msg
view model =
  Ui.Container.column []
    [ Ui.Container.row []
      [ Ui.Checkbox.view model
      , Ui.Checkbox.view { model | disabled = True }
      , Ui.Checkbox.view { model | readonly = True }
      ]
    , Ui.Container.row []
      [ Ui.Checkbox.viewRadio model
      , Ui.Checkbox.viewRadio { model | disabled = True }
      , Ui.Checkbox.viewRadio { model | readonly = True }
      ]
    , Ui.Container.row []
      [ Ui.Checkbox.viewToggle model
      , Ui.Checkbox.viewToggle { model | disabled = True }
      , Ui.Checkbox.viewToggle { model | readonly = True }
      ]
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
    , context "Readonly"
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
        [ steps.click "ui-checkbox"
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
          [ steps.click "ui-checkbox[disabled]"
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
          [ steps.click "ui-checkbox[readonly]"
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
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Checkbox.update
    , init = Ui.Checkbox.init
    , view = view
    } specs
