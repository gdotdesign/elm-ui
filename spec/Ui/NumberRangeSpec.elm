import Spec exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.NumberRange
import Ui.Container

import Ui.Styles.Theme exposing (default)
import Ui.Styles.NumberRange
import Ui.Styles.Container
import Ui.Styles

import Steps exposing (keyDown)

view : Ui.NumberRange.Model -> Html.Html Ui.NumberRange.Msg
view model =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.NumberRange.style
      , Ui.Styles.Container.style
      ] default
    , Ui.Container.row []
      [ Ui.NumberRange.view model
      , Ui.NumberRange.view { model | disabled = True }
      , Ui.NumberRange.view { model | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.NumberRange"
    [
    ]

main =
  runWithProgram
    { subscriptions = Ui.NumberRange.subscriptions
    , update = Ui.NumberRange.update
    , init = Ui.NumberRange.init
    , view = view
    } specs
