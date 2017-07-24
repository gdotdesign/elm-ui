import Spec exposing (..)

import Html exposing (text)
import Ui.ScrolledPanel

view : String -> Html.Html msg
view model =
  Ui.ScrolledPanel.view [] [text "Hello There"]


specs : Node
specs =
  describe "Ui.ScrolledPanel"
    []


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = \_ _ -> ( "", Cmd.none)
    , init = \_ -> ""
    , view = view
    } specs
