import Spec exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Container
import Ui.NumberPad

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Container
import Ui.Styles.NumberPad
import Ui.Styles

import Steps exposing (keyDown)

type alias Model =
  { numberPad : Ui.NumberPad.Model
  }

type Msg
  = NumberPad Ui.NumberPad.Msg

init : () -> Model
init _ =
  { numberPad = Ui.NumberPad.init ()
  }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    NumberPad msg ->
      let
        ( numberPad, cmd ) = Ui.NumberPad.update msg model.numberPad
      in
        ( { model | numberPad = numberPad }, Cmd.map NumberPad cmd )

viewModel : Ui.NumberPad.ViewModel Msg
viewModel =
  { bottomRight = text ""
  , bottomLeft = text ""
  , address = NumberPad
  }

view : Model -> Html.Html Msg
view { numberPad } =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.NumberPad.style
      , Ui.Styles.Container.style
      ] default
    , Ui.Container.row []
      [ Ui.NumberPad.view viewModel numberPad
      , Ui.NumberPad.view viewModel { numberPad | disabled = True }
      , Ui.NumberPad.view viewModel { numberPad | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.NumberPad"
    [ it "has tabindex"
      [ assert.elementPresent "ui-number-pad[tabindex]"
      ]
    , context "Disabled"
      [ it "does not have tabindex"
        [ assert.not.elementPresent "ui-number-pad[disabled][tabindex]"
        ]
      ]
    , context "Readonly"
      [ it "has tabindex"
        [ assert.elementPresent "ui-number-pad[readonly][tabindex]"
        ]
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , init = init
    , view = view
    } specs
