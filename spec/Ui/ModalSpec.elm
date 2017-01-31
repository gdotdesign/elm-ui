import Spec exposing (..)

import Html exposing (div, text, button)
import Html.Events exposing (onClick)
import Steps exposing (..)
import Ui.Modal


type alias Model =
  { modal : Ui.Modal.Model
  }


type Msg
  = Modal Ui.Modal.Msg
  | Open


init : () -> Model
init _ =
  { modal = Ui.Modal.init
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Open ->
      ( { model | modal = Ui.Modal.open model.modal }, Cmd.none )

    Modal msg ->
      ( { model | modal = Ui.Modal.update msg model.modal }, Cmd.none )


viewModel : Ui.Modal.ViewModel Msg
viewModel =
  { contents = [ text "Hello" ]
  , footer = [ text "footer" ]
  , title = "Test Modal"
  , address = Modal
  }


view : Model -> Html.Html Msg
view { modal } =
  div
    [ ]
    [ Ui.Modal.view viewModel modal
    , button [ onClick Open ] [ text "Open" ]
    ]


specs : Node
specs =
  describe "Ui.Modal"
    [ before
      [ assert.not.elementPresent "ui-modal[open]"
      , steps.click "button"
      ]

    , it "displays modal"
      [ assert.elementPresent "ui-modal[open]"
      ]

    , it "clicking on the close icon closes the modal"
      [ clickSvg "ui-modal svg"
      , assert.not.elementPresent "ui-modal[open]"
      ]

    , it "clicking on the backdrop closes the modal"
      [ steps.click "ui-modal-backdrop"
      , assert.not.elementPresent "ui-modal[open]"
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , init = init
    , view = view
    } specs
