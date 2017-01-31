import Spec exposing (..)

import Html exposing (text)
import Steps exposing (..)
import Ui.Container
import Ui.NumberPad


type alias Model =
  { numberPad : Ui.NumberPad.Model
  }


type Msg
  = NumberPad Ui.NumberPad.Msg


init : () -> Model
init _ =
  { numberPad =
      Ui.NumberPad.init ()
        |> Ui.NumberPad.format False
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
  { bottomRight = text "a"
  , bottomLeft = text "b"
  , address = NumberPad
  }


view : Model -> Html.Html Msg
view { numberPad } =
  Ui.Container.row []
    [ Ui.NumberPad.view viewModel numberPad
    , Ui.NumberPad.view viewModel { numberPad | disabled = True }
    , Ui.NumberPad.view viewModel { numberPad | readonly = True }
    ]


assertValue value =
  assert.containsText
    { selector = "ui-number-pad-value"
    , text = toString value
    }


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
    , it "displays bottom left"
      [ assert.containsText
        { selector = "ui-number-pad-button:nth-child(10)"
        , text = "b"
        }
      ]
    , it "displays bottom right"
      [ assert.containsText
        { selector = "ui-number-pad-button:nth-child(12)"
        , text = "a"
        }
      ]
    , it "does not overflow"
      [ keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , keyDown 55 "ui-number-pad"
      , assertValue 777777777
      , keyDown 55 "ui-number-pad"
      , assertValue 777777777
      ]
    , context "Clicking a button"
      [ it "adds the number to the value"
        [ assertValue 0
        , steps.click "ui-number-pad-button:nth-child(2)"
        , assertValue 2
        ]
      ]
    , context "Clicking on the backspace icon"
      [ it "removes a number from the value"
        [ steps.click "ui-number-pad-button:nth-child(2)"
        , steps.click "ui-number-pad-button:nth-child(3)"
        , assertValue 23
        , clickSvg "ui-number-pad-value svg"
        , assertValue 2
        ]
      ]
    , context "Keyboard"
      [ it "adds a number if it's pressed"
        [ assertValue 0
        , keyDown 55 "ui-number-pad"
        , assertValue 7
        ]
      , it "removes a number if delete is pressed"
        [ assertValue 0
        , keyDown 55 "ui-number-pad"
        , assertValue 7
        , keyDown 46 "ui-number-pad"
        , assertValue 0
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
