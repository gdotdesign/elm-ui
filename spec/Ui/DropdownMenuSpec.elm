import Spec exposing (..)

import Html exposing (button, div, text, span)

import Ui.DropdownMenu
import Ui.Container
import Ui.Icons

import Ui.Styles.Theme exposing (default)
import Ui.Styles

import Steps exposing (..)

type alias Model =
  { dropdown : Ui.DropdownMenu.Model }

type Msg
  = DropdownMenu Ui.DropdownMenu.Msg

init : () -> Model
init _ =
  { dropdown = Ui.DropdownMenu.init () }

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map DropdownMenu (Ui.DropdownMenu.subscriptions model.dropdown)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    DropdownMenu msg ->
      ( { model | dropdown = Ui.DropdownMenu.update msg model.dropdown }, Cmd.none )

viewModel =
  { items =
    [ Ui.DropdownMenu.item []
      [ Ui.Icons.calendar []
      , span [] [ text "tab 1" ]
      ]
    , Ui.DropdownMenu.item [] [ text "tab 2" ]
    , Ui.DropdownMenu.item [] [ text "tab 3" ]
    ]
  , element = button [] [ text "Hello" ]
  , address = DropdownMenu
  }

view : Model -> Html.Html Msg
view { dropdown } =
  div
    [ ]
    [ Ui.DropdownMenu.view viewModel dropdown
    , Ui.Container.row [] []
    ]

(=>) = (,)

specs : Node
specs =
  describe "Ui.DropdownMenu"
    [ context "Clicking the button"
      [ layout
        [ "ui-dropdown-panel" =>
          { top = 0
          , left = 0
          , bottom = 0
          , right = 0
          , width = 200
          , height = 50
          , zIndex = 0
          }
        , "ui-dropdown-menu" =>
          { top = 0
          , left = 0
          , bottom = 0
          , right = 0
          , width = 100
          , height = 50
          , zIndex = 1
          }
        ]
      , it "opens the dropdown"
        [ assert.not.elementPresent "ui-dropdown-panel[open]"
        , assert.styleEquals
          { selector = "ui-dropdown-panel"
          , style = "visibility"
          , value = "hidden"
          }
        , clickOn "ui-dropdown-menu" 10 10
        , assert.elementPresent "ui-dropdown-panel[open]"
        , assert.styleEquals
          { selector = "ui-dropdown-panel"
          , style = "visibility"
          , value = "visible"
          }
        ]
      , it "closes the dropdown if it's open"
        [ assert.not.elementPresent "ui-dropdown-panel[open]"
        , clickOn "ui-dropdown-menu" 10 10
        , assert.elementPresent "ui-dropdown-panel[open]"
        , clickOn "ui-dropdown-menu" 10 10
        , assert.not.elementPresent "ui-dropdown-panel[open]"
        ]
      ]
    ]

main =
  runWithProgram
    { subscriptions = subscriptions
    , update = update
    , view = view
    , init = init
    } specs
