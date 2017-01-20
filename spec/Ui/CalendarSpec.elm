import Spec exposing (describe, it, Node, context, before, after)
import Spec.Assertions exposing (assert)
import Spec.Steps exposing (click)
import Spec.Runner

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Container
import Ui.Calendar

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Container
import Ui.Styles.Calendar
import Ui.Styles

import Steps exposing (keyDown)

view : Ui.Calendar.Model -> Html.Html Ui.Calendar.Msg
view model =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.Calendar.style default
      , Ui.Styles.Container.style
      ]
    , Ui.Container.row []
      [ Ui.Calendar.view "en_us" model
      , Ui.Calendar.view "en_us" { model | disabled = True }
      , Ui.Calendar.view "en_us" { model | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.Calendar"
    [ it "has selected cell"
      [ assert.elementPresent "ui-calendar-cell[selected]"
      ]
    ]

main =
  Spec.Runner.runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Calendar.update
    , init = Ui.Calendar.init
    , view = view
    } specs
