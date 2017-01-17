import Spec exposing (describe, it, Node)
import Spec.Assertions exposing (assert)
import Spec.Steps exposing (click)
import Spec.Runner

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Button
import Ui.Styles

type alias Model
  = String

type Msg
  = Set

init : () -> Model
init _ =
  "Initial"

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Set ->
      ( "Clicked", Cmd.none )

view : Model -> Html.Html Msg
view model =
  div
    [ ]
    [ Ui.Styles.embed
    , Ui.Button.primary "Set" Set
    , div [ class "result" ] [ text model ]
    ]

specs : Node
specs =
  describe "Ui.Button"
    [ it "it should trigger action on click"
      [ assert.containsText { text = "Initial", selector = "div" }
      , click "ui-button"
      , assert.containsText { text = "Clicked", selector = "div" }
      ]
    ]

main =
  Spec.Runner.runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
