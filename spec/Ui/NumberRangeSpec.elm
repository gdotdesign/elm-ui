import Spec exposing (..)

import Json.Encode as Json
import Steps exposing (..)
import Ui.NumberRange
import Ui.Container
import Html


view : Ui.NumberRange.Model -> Html.Html Ui.NumberRange.Msg
view model =
  Ui.Container.row []
    [ Ui.NumberRange.view model
    , Ui.NumberRange.view { model | disabled = True }
    , Ui.NumberRange.view { model | readonly = True }
    ]


assertValue value =
  assert.valueEquals
  { selector = "ui-number-range input"
  , text = toString value
  }


specs : Node
specs =
  describe "Ui.NumberRange"
    [ context "Dragging"
      [ layout
        [ ( "ui-number-range input"
          , { top = 0
            , left = 0
            , width = 200
            , height = 50
            , right = 0
            , bottom = 0
            , zIndex = 0
            }
          )
        ]
      , it "changes value"
        [ mouseDown 10 10 "ui-number-range input"
        , assertValue 0
        , mouseMove 15 15
        , assertValue 50
        ]
      , context "Dragging outside the limit"
        [ it "sets the value to maximum"
          [ mouseDown 10 10 "ui-number-range input"
          , assertValue 0
          , mouseMove 300 300
          , assertValue 100
          ]
        , it "sets the value to minimum"
          [ mouseDown 10 10 "ui-number-range input"
          , assertValue 0
          , mouseMove -300 -300
          , assertValue -100
          ]
        ]
      , context "Ending drag"
        [ it "does not change value"
          [ mouseDown 10 10 "ui-number-range input"
          , assertValue 0
          , mouseMove 15 15
          , assertValue 50
          , mouseUp
          , mouseMove 20 20
          , assertValue 50
          ]
        ]
      ]
    , context "Keyboard"
      [ it "increments on up arrow"
        [ assertValue 0
        , keyDown 38 "ui-number-range input"
        , assertValue 3
        ]
      , it "increments on right arrow"
        [ assertValue 0
        , keyDown 39 "ui-number-range input"
        , assertValue 3
        ]
      , it "decrements on left arrow"
        [ assertValue 0
        , keyDown 37 "ui-number-range input"
        , assertValue -3
        ]
      , it "decrements on down arrow"
        [ assertValue 0
        , keyDown 40 "ui-number-range input"
        , assertValue -3
        ]
      , it "starts editing if enter is pressed"
        [ assert.not.elementPresent "input:focus"
        , keyDown 13 "ui-number-range input"
        , assert.elementPresent "input:focus"
        ]
      , it "starts editing if a number is pressed"
        [ assertValue 0
        , assert.not.elementPresent "input:focus"
        , keyDown 56 "ui-number-range input"
        , assert.elementPresent "input:focus"
        , assertValue 8
        ]
      ]
    , context "Editing by keyboard"
      [ before
        [ assert.not.elementPresent "input:focus"
        , keyDown 13 "ui-number-range input"
        , assert.elementPresent "input:focus"
        ]
      , it "blur sets the value"
        [ steps.setValue "10" "ui-number-range input"
        , steps.dispatchEvent
          "input"
          (Json.object [])
          "ui-number-range input"
        , steps.dispatchEvent
          "blur"
          (Json.object [])
          "ui-number-range input"
        , assertValue 10
        ]
      , it "enter sets the value"
        [ steps.setValue "" "ui-number-range input"
        , steps.dispatchEvent
          "input"
          (Json.object [])
          "ui-number-range input"
        , keyDown 13 "ui-number-range input"
        , assertValue 0
        ]
      , context "text given"
        [ it "blur stets the value to 0"
          [ steps.setValue "asd" "ui-number-range input"
          , steps.dispatchEvent
            "input"
            (Json.object [])
            "ui-number-range input"
          , steps.dispatchEvent
            "blur"
            (Json.object [])
            "ui-number-range input"
          , assertValue 0
          ]
        ]
      ]
    ]


main =
  runWithProgram
    { subscriptions = Ui.NumberRange.subscriptions
    , update = Ui.NumberRange.update
    , init = \_ ->
        Ui.NumberRange.init ()
        |> Ui.NumberRange.min -100
        |> Ui.NumberRange.max 100
        |> Ui.NumberRange.dragStep 10
        |> Ui.NumberRange.keyboardStep 3
    , view = view
    } specs
