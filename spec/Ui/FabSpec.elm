import Spec exposing (..)

import Html exposing (text)
import Ui.Icons
import Ui.Fab

view : String -> Html.Html msg
view model =
  Ui.Fab.view (Ui.Icons.plus []) []


specs : Node
specs =
  describe "Ui.Fab"
    []

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = \_ _ -> ( "", Cmd.none)
    , init = \_ -> ""
    , view = view
    } specs
