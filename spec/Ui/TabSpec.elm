import Spec exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Container
import Ui.Tabs

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Container
import Ui.Styles.Tabs
import Ui.Styles

import Steps exposing (keyDown)

type alias Model =
  { tabs : Ui.Tabs.Model }

type Msg
  = Tabs Ui.Tabs.Msg

init : () -> Model
init _ =
  { tabs = Ui.Tabs.init () }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Tabs msg ->
      let
        ( tabs, cmd ) = Ui.Tabs.update msg model.tabs
      in
        ( { model | tabs = tabs }, Cmd.map Tabs cmd )

viewModel =
  { contents =
    [ ("Tab 1", text "tab 1")
    , ("Tab 2", text "tab 2")
    , ("Tab 3", text "tab 3")
    ]
  , address = Tabs
  }

view : Model -> Html.Html Msg
view { tabs } =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.Tabs.style
      , Ui.Styles.Container.style
      ] default
    , Ui.Container.row []
      [ Ui.Tabs.view viewModel tabs
      , Ui.Tabs.view viewModel { tabs | disabled = True }
      , Ui.Tabs.view viewModel { tabs | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.Tabs"
    [
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
