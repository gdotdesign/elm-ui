import Spec exposing (..)

import Steps exposing (..)
import Ui.ColorPanel
import Ui.Container
import Html

(=>) = (,)

view : Ui.ColorPanel.Model -> Html.Html Ui.ColorPanel.Msg
view model =
  Ui.Container.row []
    [ Ui.ColorPanel.view model
    , Ui.ColorPanel.view { model | disabled = True }
    , Ui.ColorPanel.view { model | readonly = True }
    ]


hueHandleEquals position =
  assert.inlineStyleEquals
    { selector = "ui-color-panel-hue ui-color-panel-handle"
    , style = "top"
    , value = position
    }


alphaHandleEquals position =
  assert.inlineStyleEquals
    { selector = "ui-color-panel-alpha ui-color-panel-handle"
    , style = "left"
    , value = position
    }


rectHandleEquals top left =
  stepGroup ("Rect handle equals (" ++ top ++ ", " ++ left ++ ")")
    [ assert.inlineStyleEquals
      { selector = "ui-color-panel-rect ui-color-panel-handle"
      , style = "top"
      , value = top
      }
    , assert.inlineStyleEquals
      { selector = "ui-color-panel-rect ui-color-panel-handle"
      , style = "left"
      , value = left
      }
    ]


specs : Node
specs =
  describe "Ui.ColorPanel"
    [ layout
      [ "ui-color-panel-rect" =>
        { top = 0
        , left = 0
        , right = 0
        , bottom = 0
        , width = 200
        , height = 200
        , zIndex = 0
        }
      , "ui-color-panel-alpha" =>
        { top = 220
        , left = 0
        , right = 0
        , bottom = 0
        , width = 200
        , height = 16
        , zIndex = 0
        }
      , "ui-color-panel-hue" =>
        { top = 0
        , left = 220
        , right = 0
        , bottom = 0
        , width = 16
        , height = 200
        , zIndex = 0
        }
      ]
    , it "Deafults to black"
      [ rectHandleEquals "100%" "0%"
      , alphaHandleEquals "100%"
      , hueHandleEquals "0%"
      ]
    , context "Hue"
      [ before
        [ mouseDown 228 20 "ui-color-panel-hue"
        , hueHandleEquals "10%"
        ]
      , it "sets value when dragging"
        [ mouseMove 50 228
        , hueHandleEquals "25%"
        ]
      , context "Draggig out of bounds"
        [ it "sets value to maximum"
          [ mouseMove 300 228
          , hueHandleEquals "100%"
          ]
        , it "sets value to minimum"
          [ mouseMove -50 228
          , hueHandleEquals "0%"
          ]
        ]
      ]
    , context "Alpha"
      [ before
        [ mouseDown 20 228 "ui-color-panel-alpha"
        , alphaHandleEquals "10%"
        ]
      , it "sets value when dragging"
        [ mouseMove 228 50
        , alphaHandleEquals "25%"
        ]
      , context "Draggig out of bounds"
        [ it "sets value to maximum"
          [ mouseMove 228 300
          , alphaHandleEquals "100%"
          ]
        , it "sets value to minimum"
          [ mouseMove 228 -50
          , alphaHandleEquals "0%"
          ]
        ]
      ]
    , context "Saturation / Value"
      [ before
        [ mouseDown 20 20 "ui-color-panel-rect"
        , rectHandleEquals "10%" "10%"
        ]
      , it "sets values when dragging"
        [ mouseMove 100 100
        , rectHandleEquals "50%" "50%"
        ]
      , context "Draggig out of bounds"
        [ it "sets value to maximum"
          [ mouseMove 1000 1000
          , rectHandleEquals "100%" "100%"
          ]
        , it "sets value to minimum"
          [ mouseMove -1000 -1000
          , rectHandleEquals "0%" "0%"
          ]
        ]
      ]
    ]


main =
  runWithProgram
    { subscriptions = Ui.ColorPanel.subscriptions
    , update = Ui.ColorPanel.update
    , init = Ui.ColorPanel.init
    , view = view
    } specs
