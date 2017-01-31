import Spec exposing (..)

import Ui.ButtonGroup
import Ui.Container
import Html

type alias Model
  = Ui.ButtonGroup.Model Msg

type Msg
  = Set

init : () -> Model
init _ =
  Ui.ButtonGroup.model
    [ ( "A", Set )
    , ( "B", Set )
    , ( "C", Set )
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Set ->
      ( model, Cmd.none )

view : Model -> Html.Html Msg
view model =
  Ui.ButtonGroup.view model

specs : Node
specs =
  describe "Ui.Button"
    [ context "First button"
      [ it "has rounded corners on the left side"
        [ assert.containsText
          { selector = "style[id='3559938210']"
          , text = "border-radius: 2px 0px 0px 2px"
          }
        ]
      ]
    , context "Middle buttons"
      [ it "has no rounded borders"
        [ assert.containsText
          { selector = "style[id='3559938210']"
          , text = "border-radius: 0px"
          }
        ]
      ]
    , context "Last button"
      [ it "has rounded corners on the right side"
        [assert.containsText
          { selector = "style[id='3559938210']"
          , text = "border-radius: 0px 2px 2px 0px"
          }
        ]
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
