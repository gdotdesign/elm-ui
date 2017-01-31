import Spec exposing (..)

import Task exposing (Task)
import Json.Encode as Json
import Steps exposing (..)
import Ui.ColorFields
import Ui.Container
import Html


view : Ui.ColorFields.Model -> Html.Html Ui.ColorFields.Msg
view model =
  Ui.Container.column []
    [ Ui.ColorFields.view model
    , Ui.ColorFields.view { model | disabled = True }
    , Ui.ColorFields.view { model | readonly = True }
    ]


setField : Int -> String -> String -> Task Never Outcome
setField index value expected =
  let
    selector =
      "ui-color-fields-column:nth-child(" ++ (toString index) ++ ") input"
  in
    stepGroup
      ("Setting value to " ++ value ++ " and triggering input on " ++ selector)
      [ steps.setValue value selector
      , steps.dispatchEvent "input" (Json.object []) selector
      , steps.dispatchEvent "change" (Json.object []) selector
      , assert.valueEquals { selector = selector, text = expected }
      ]


testPart : String -> Int -> String -> String -> Node
testPart name index fullHex partialHex =
  context name
    [ it "updates the hex value"
      [ setField index "255" "255"
      , assert.valueEquals
        { selector = "ui-color-fields-column:first-child input"
        , text = fullHex
        }
      ]
    , context "text"
      [ it "sets resets the value and does not update the hex value"
        [ setField index "130" "130"
        , assert.valueEquals
          { selector = "ui-color-fields-column:first-child input"
          , text = partialHex
          }
        , setField index "asd" "130"
        , assert.valueEquals
          { selector = "ui-color-fields-column:first-child input"
          , text = partialHex
          }
        ]
      ]
    , context "bigger number"
      [ it "sets the value to 255 and updates the hex value"
        [ setField index "10000" "255"
        , assert.valueEquals
          { selector = "ui-color-fields-column:first-child input"
          , text = fullHex
          }
        ]
      ]
    , context "lower number"
      [ it "sets the value to 0 and updates the hex value"
        [ setField index "-100" "0"
        , assert.valueEquals
          { selector = "ui-color-fields-column:first-child input"
          , text = "#000000"
          }
        ]
      ]
    ]


specs : Node
specs =
  describe "Ui.ColorFields"
    [ context "Setting values"
      [ before
        [ assert.valueEquals
          { selector = "ui-color-fields-column:first-child input"
          , text = "#000000"
          }
        ]
      , context "hex"
        [ it "sets other values"
          [ setField 5 "50" "50"
          , setField 1 "#828282" "#828282"
          , assert.valueEquals
            { selector = "ui-color-fields-column:nth-child(2) input"
            , text = "130"
            }
          , assert.valueEquals
            { selector = "ui-color-fields-column:nth-child(3) input"
            , text = "130"
            }
          , assert.valueEquals
            { selector = "ui-color-fields-column:nth-child(4) input"
            , text = "130"
            }
          , assert.valueEquals
            { selector = "ui-color-fields-column:nth-child(5) input"
            , text = "50"
            }
          , setField 1 "008282" "#008282"
          , assert.valueEquals
            { selector = "ui-color-fields-column:nth-child(2) input"
            , text = "0"
            }
          ]
        ]
      , context "alpha"
        [ context "negative number"
          [ it "sets the value to 0"
            [ setField 5 "-100" "0" ]
          ]
        , context "bigger number"
          [ it "sets the value to 100"
            [ setField 5 "120" "100" ]
          ]
        , context "text"
          [ it "doesn't update the value"
            [ setField 5 "54" "54"
            , setField 5 "asd" "54"
            ]
          ]
        ]
      , testPart "red" 2 "#FF0000" "#820000"
      , testPart "green" 3 "#00FF00" "#008200"
      , testPart "blue" 4 "#0000FF" "#000082"
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.ColorFields.update
    , init = Ui.ColorFields.init
    , view = view
    } specs
