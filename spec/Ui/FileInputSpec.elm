import Spec exposing (..)

import Json.Encode as Json
import Steps exposing (..)
import Ui.Container
import Ui.FileInput
import Html

view : Ui.FileInput.Model -> Html.Html Ui.FileInput.Msg
view model =
  Ui.Container.column []
    [ Ui.Container.row []
      [ Ui.FileInput.view model
      , Ui.FileInput.view { model | disabled = True }
      , Ui.FileInput.view { model | readonly = True }
      ]

    , Ui.Container.row []
      [ Ui.FileInput.viewDetails model
      , Ui.FileInput.viewDetails { model | disabled = True }
      , Ui.FileInput.viewDetails { model | readonly = True }
      ]
    ]


specs : Node
specs =
  describe "Ui.FileInput"
    [ it "has a button"
      [ assert.elementPresent "ui-button"
      ]
    ]


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.FileInput.update
    , init = Ui.FileInput.init
    , view = view
    } specs
