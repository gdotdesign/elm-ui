import Spec exposing (..)

import Steps exposing (..)
import Ui.Container
import Ui.Calendar
import Ext.Date
import Html


view : Ui.Calendar.Model -> Html.Html Ui.Calendar.Msg
view model =
  Ui.Container.row []
    [ Ui.Calendar.view "en_us" model
    , Ui.Calendar.view "en_us" { model | disabled = True }
    , Ui.Calendar.view "en_us" { model | readonly = True }
    , Ui.Calendar.view "en_us" { model | selectable = False }
    ]


specs : Node
specs =
  describe "Ui.Calendar"
    [ it "has selected cell"
      [ assert.elementPresent "ui-calendar-cell[selected]"
      ]
    , it "has 42 cells"
      [ assert.elementPresent "ui-calendar-cell:nth-child(42)"
      ]
    , it "has a inactive cells"
      [ assert.elementPresent "ui-calendar-cell[inactive]"
      ]
    , context "Clicking on an active cell"
      [ it "makes that cell selected"
        [ assert.elementPresent "ui-calendar-cell:nth-child(32)[selected]"
        , assert.containsText
          { selector = "ui-calendar-cell:nth-child(32)[selected]"
          , text = "28"
          }
        , steps.click "ui-calendar-cell:nth-child(5)"
        , assert.elementPresent "ui-calendar-cell:nth-child(5)[selected]"
        , assert.containsText
          { selector = "ui-calendar-cell:nth-child(5)[selected]"
          , text = "1"
          }
        ]
      ]
    , context "Clicking on the left chevron"
      [ it "changes the month to April"
        [ assert.containsText
          { text = "1987 - May", selector = "ui-calendar ui-container div" }
        , clickSvg "svg:first-child"
        , assert.containsText
          { text = "1987 - April", selector = "ui-calendar ui-container div" }
        , assert.not.elementPresent "ui-calendar-cell[selected]"
        ]
      ]
    , context "Clicking on the right chevron"
      [ it "changes the month to June"
        [ assert.containsText
          { text = "1987 - May", selector = "ui-calendar ui-container div" }
        , clickSvg "svg:last-child"
        , assert.containsText
          { text = "1987 - June", selector = "ui-calendar ui-container div" }
        , assert.not.elementPresent "ui-calendar-cell[selected]"
        ]
      ]
    , context "Disabled"
      [ context "Clicking on an active cell"
        [ it "does not make that cell selected"
          [ assert.elementPresent
            "ui-calendar[disabled] ui-calendar-cell:nth-child(32)[selected]"
          , steps.click "ui-calendar[disabled] ui-calendar-cell:nth-child(5)"
          , assert.not.elementPresent
            "ui-calendar[disabled] ui-calendar-cell:nth-child(5)[selected]"
          , assert.elementPresent
            "ui-calendar[disabled] ui-calendar-cell:nth-child(32)[selected]"
          ]
        ]
      , context "Clicking on the left chevron"
        [ it "does not change month"
          [ assert.containsText
            { selector = "ui-calendar[disabled] ui-container div"
            , text = "1987 - May"
            }
          , clickSvg "ui-calendar[disabled] svg:first-child"
          , assert.containsText
            { selector = "ui-calendar[disabled] ui-container div"
            , text = "1987 - May"
            }
          ]
        ]
      , context "Clicking on the right chevron"
        [ it "does not change month"
          [ assert.containsText
            { selector = "ui-calendar[disabled] ui-container div"
            , text = "1987 - May"
            }
          , clickSvg "ui-calendar[disabled] svg:last-child"
          , assert.containsText
            { selector = "ui-calendar[disabled] ui-container div"
            , text = "1987 - May"
            }
          ]
        ]
      ]
    , context "Readonly"
      [ it "does not have chevrons"
        [ assert.elementPresent "ui-calendar[readonly] svg"
        ]
      , context "Clicking on an active cell"
        [ it "does not make that cell selected"
          [ assert.elementPresent
            "ui-calendar[readonly] ui-calendar-cell:nth-child(32)[selected]"
          , steps.click "ui-calendar[readonly] ui-calendar-cell:nth-child(5)"
          , assert.not.elementPresent
            "ui-calendar[readonly] ui-calendar-cell:nth-child(5)[selected]"
          , assert.elementPresent
            "ui-calendar[readonly] ui-calendar-cell:nth-child(32)[selected]"
          ]
        ]
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Calendar.update
    , init = \_ ->
      Ui.Calendar.init ()
      |> Ui.Calendar.setValue (Ext.Date.createDate 1987 5 28)
    , view = view
    } specs
