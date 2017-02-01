import Spec exposing (..)


import Html exposing (div, text, p)
import Json.Encode as Json
import Steps exposing (..)
import Ui.Header
import Ui.Icons
import Ui


type alias Model
  = String


type Msg
  = Set


init : () -> String
init _ =
  "Initial"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Set ->
      ( "Set", Cmd.none )


view : Model -> Html.Html Msg
view model =
  div
    [ ]
    [ Ui.Header.view
        [ Ui.Header.title
          { text = "Hello World"
          , action = Just Set
          , link = Just "/"
          , target = ""
          }
        , Ui.Header.spacer
        , Ui.Header.item
          { text = "Home"
          , action = Just Set
          , link = Nothing
          , target = ""
          }
        , Ui.Header.separator
        , Ui.Header.iconItem
          { text = "Github"
          , action = Just Set
          , link = Nothing
          , target = ""
          , glyph = Ui.Icons.starFull []
          , side = "left"
          }
        , Ui.Header.separator
        , Ui.Header.icon
          { glyph = Ui.Icons.starEmpty []
          , action = Just Set
          , link = Nothing
          , target = ""
          , size = 24
          }
        ]
    , p [] [ text model ]
    ]


specs : Node
specs =
  describe "Ui.Button"
    [ context "Clicking on items"
      [ it "calls sends the given message"
        [ assert.containsText { selector = "p", text = "Initial"}
        , steps.dispatchEvent
            "click"
            (Json.object [("ctrlKey", Json.bool False), ("button", Json.int 0)])
            "ui-header-icon a"
        , assert.containsText { selector = "p", text = "Set"}
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
