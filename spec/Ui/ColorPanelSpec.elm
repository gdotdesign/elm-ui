import Spec exposing (..)

import Html exposing (div)

import Ui.Container
import Ui.ColorPanel

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Container
import Ui.Styles.ColorPanel
import Ui.Styles

import Steps exposing (..)

view : Ui.ColorPanel.Model -> Html.Html Ui.ColorPanel.Msg
view model =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.ColorPanel.style
      , Ui.Styles.Container.style
      ] default
    , Ui.Container.row []
      [ Ui.ColorPanel.view model
      , Ui.ColorPanel.view { model | disabled = True }
      , Ui.ColorPanel.view { model | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.ColorPanel"
    [
    ]

main =
  runWithProgram
    { subscriptions = Ui.ColorPanel.subscriptions
    , update = Ui.ColorPanel.update
    , init = Ui.ColorPanel.init
    , view = view
    } specs
