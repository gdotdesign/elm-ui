import Spec exposing (..)

import Steps exposing (..)
import Ui.InplaceInput
import Ui.Container
import Html


view : Ui.InplaceInput.Model -> Html.Html Ui.InplaceInput.Msg
view model =
  Ui.Container.row []
    [ Ui.InplaceInput.view model
    , Ui.InplaceInput.view { model | disabled = True }
    , Ui.InplaceInput.view { model | readonly = True }
    ]


specs : Node
specs =
  describe "Ui.InplaceInput"
    [ context "Editing"
      [ before
        [ assert.not.elementPresent "ui-textarea"
        , steps.click "ui-inplace-input-content"
        ]
      , it "enters edit mode on click"
        [ assert.elementPresent "ui-textarea"
        ]
      , context "Save button"
        [ it "disabled when there is no text"
          [ assert.valueEquals
            { selector = "textarea"
            , text = ""
            }
          , assert.elementPresent "ui-button[kind=primary][disabled]"
          ]
        , it "enabled when there is text"
          [ steps.setValue "asdf" "textarea"
          , dispatchInput "textarea"
          , assert.elementPresent "ui-button[kind=primary]:not([disabled])"
          ]
        ]
      , context "Clicking the cancel button"
        [ it "discards text"
          [ steps.setValue "asdf" "textarea"
          , dispatchInput "textarea"
          , steps.click "ui-button[kind=secondary]:not([disabled])"
          , assert.containsText
            { selector = "ui-inplace-input-content"
            , text = ""
            }
          ]
        ]
      , context "Clicking the save button"
        [ it "saves the text"
          [ steps.setValue "asdf" "textarea"
          , dispatchInput "textarea"
          , steps.click "ui-button[kind=primary]:not([disabled])"
          , assert.containsText
            { selector = "ui-inplace-input-content"
            , text = "asdf"
            }
          ]
        ]
      ]
    ]


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.InplaceInput.update
    , init = \_ ->
        Ui.InplaceInput.init ()
          |> Ui.InplaceInput.placeholder "Hello There"
    , view = view
    } specs
