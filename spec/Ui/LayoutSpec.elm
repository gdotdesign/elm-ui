import Spec exposing (..)

import Html exposing (div, text)
import Ui.Layout


view : String -> Html.Html msg
view model =
  div
    [ ]
    [ Ui.Layout.website
      [ text "header"  ]
      [ text "content" ]
      [ text "footer"  ]
    , Ui.Layout.app
      [ text "sidebar" ]
      [ text "toolbar" ]
      [ text "content" ]
    , Ui.Layout.sidebar
      [ text "sidebar" ]
      [ text "content" ]
    ]


specs : Node
specs =
  describe "Ui.Layout"
    [ context "Website"
      [ it "renders header"
        [ assert.elementPresent "ui-layout-website-header"
        , assert.containsText
          { selector = "ui-layout-website-header"
          , text = "header"
          }
        ]
      , it "renders content"
        [ assert.elementPresent "ui-layout-website-content"
        , assert.containsText
          { selector = "ui-layout-website-content"
          , text = "content"
          }
        ]
      , it "renders footer"
        [ assert.elementPresent "ui-layout-website-footer"
        , assert.containsText
          { selector = "ui-layout-website-footer"
          , text = "footer"
          }
        ]
      ]
    , context "App"
      [ it "renders sidebar"
        [ assert.elementPresent "ui-layout-app-sidebar"
        , assert.containsText
          { selector = "ui-layout-app-sidebar"
          , text = "sidebar"
          }
        ]
      , it "renders content"
        [ assert.elementPresent "ui-layout-app-content"
        , assert.containsText
          { selector = "ui-layout-app-content"
          , text = "content"
          }
        ]
      , it "renders toolbar"
        [ assert.elementPresent "ui-layout-app-toolbar"
        , assert.containsText
          { selector = "ui-layout-app-toolbar"
          , text = "toolbar"
          }
        ]
      ]
    , context "Sidebar"
      [ it "renders sidebar"
        [ assert.elementPresent "ui-layout-sidebar-bar"
        , assert.containsText
          { selector = "ui-layout-sidebar-bar"
          , text = "sidebar"
          }
        ]
      , it "renders content"
        [ assert.elementPresent "ui-layout-sidebar-content"
        , assert.containsText
          { selector = "ui-layout-sidebar-content"
          , text = "content"
          }
        ]
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = \_ _ -> ( "", Cmd.none)
    , init = \_ -> ""
    , view = view
    } specs
