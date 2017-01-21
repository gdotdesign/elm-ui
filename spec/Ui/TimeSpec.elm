import Spec exposing (..)

import Date exposing (Date)
import Ext.Date
import Ui.Time

date : Date
date =
  Ext.Date.createDate 1987 5 28

specs : Node
specs =
  let
    ago =
      Ext.Date.ago date (Ext.Date.now ())
  in
    describe "Ui.Time"
      [ it "displays relative date"
        [ assert.elementPresent "ui-time"
        , assert.containsText
          { selector = "ui-time"
          , text = ago
          }
        ]
      , it "has tooltip"
        [ assert.elementPresent "ui-time[title]"
        , assert.attributeEquals
          { selector = "ui-time"
          , attribute = "title"
          , text = "1987-05-28 00:00:00"
          }
        ]
      ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , init = \_ -> Ui.Time.init date
    , update = Ui.Time.update
    , view = Ui.Time.view
    } specs
