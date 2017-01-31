import Spec exposing (..)

import Steps exposing (..)
import Json.Encode as Json
import Ui.SearchInput
import Ui.Container
import Html


view : Ui.SearchInput.Model -> Html.Html Ui.SearchInput.Msg
view model =
  Ui.Container.row []
    [ Ui.SearchInput.view model
    , Ui.SearchInput.view { model | disabled = True }
    , Ui.SearchInput.view { model | readonly = True }
    ]


specs : Node
specs =
  describe "Ui.SearchInput"
    [ context "Disabled"
      [ it "input has disabled attribute"
        [ assert.elementPresent "ui-search-input:nth-child(2) input[disabled]"
        ]
      ]
    , context "Readonly"
      [ it "input has readonly attribute"
        [ assert.elementPresent "ui-search-input:nth-child(3) input[readonly]"
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
    , update = Ui.SearchInput.update
    , init = \_ ->
      Ui.SearchInput.init ()
      |> Ui.SearchInput.showClearIcon True
      |> Ui.SearchInput.timeout 0
    , view = view
    } specs
