import Spec exposing (..)

import Html exposing (div)

import Ui.Container
import Ui.Chooser

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Container
import Ui.Styles.Chooser
import Ui.Styles

import Steps exposing (..)

items =
  [ { id = "0", label = "Hello", value = "hello" }
  , { id = "0", label = "Batman", value = "batman" }
  , { id = "0", label = "Superman", value = "superman" }
  ]

view : Ui.Chooser.Model -> Html.Html Ui.Chooser.Msg
view model =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.Chooser.style
      , Ui.Styles.Container.style
      ] default
    , Ui.Container.row []
      [ Ui.Chooser.view model
      , Ui.Chooser.view { model | searchable = True }
      , Ui.Chooser.view { model | disabled = True }
      , Ui.Chooser.view { model | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.Chooser"
    [
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Chooser.update
    , init = \() ->
      Ui.Chooser.init ()
      |> Ui.Chooser.placeholder "Select something..."
      |> Ui.Chooser.items items
      |> Ui.Chooser.deselectable True
      |> Ui.Chooser.multiple True
    , view = view
    } specs
