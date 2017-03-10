import Spec exposing (..)

import Html

import Ui.Container
import Ui.Chooser

import Steps exposing (..)

view : Ui.Chooser.Model -> Html.Html Ui.Chooser.Msg
view model =
  Ui.Container.row []
    [ Ui.Chooser.view model
    , Ui.Chooser.view { model | searchable = True }
    , Ui.Chooser.view { model | disabled = True }
    , Ui.Chooser.view { model | readonly = True }
    ]

specs : Node
specs =
  describe "Ui.Chooser"
    [ it "Placeholder should be 'Select something...'"
        [ assert.attributeEquals 
            { text = "Select something..."
            , selector = "input"
            , attribute = "placeholder"
            }
        ]
    , it "emptyContent should be 'No items.'"
        [ assert.containsText 
            { text = "No items."
            , selector = "ui-chooser-empty-content"
            }
        ]
    ]


init : Ui.Chooser.Model
init = Ui.Chooser.init ()
      |> Ui.Chooser.placeholder "Select something..."
      |> Ui.Chooser.emptyContent (Html.text "No items.")
      |> Ui.Chooser.deselectable True
      |> Ui.Chooser.multiple True

main =
  runWithProgram
    { subscriptions = Ui.Chooser.subscriptions
    , update = Ui.Chooser.update
    , init = \() -> init
    , view = view
    } specs
