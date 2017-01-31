import Spec exposing (..)

import Html exposing (text)
import Ui.Breadcrumbs

view : String -> Html.Html msg
view model =
  Ui.Breadcrumbs.view
    (text "|")
    [ { contents = [ text "Home" ]
      , target = Nothing
      , msg = Nothing
      , url = Just "/"
      }
    , { contents = [ text "Posts" ]
      , target = Nothing
      , msg = Nothing
      , url = Just "/posts"
      }
    , { contents = [ text "Github" ]
      , target = Just "_blank"
      , msg = Nothing
      , url = Just "http://www.github.com"
      }
    , { contents = [ text "Inert" ]
      , target = Nothing
      , msg = Nothing
      , url = Nothing
      }
    ]


specs : Node
specs =
  describe "Ui.Breadcrumbs"
    [ it "displays items"
      [ assert.containsText
        { selector = "ui-breadcrumb:first-child"
        , text = "Home"
        }
      , assert.containsText
        { selector = "ui-breadcrumb:nth-child(3)"
        , text = "Posts"
        }
      , assert.containsText
        { selector = "ui-breadcrumb:nth-child(5)"
        , text = "Github"
        }
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = \_ _ -> ( "", Cmd.none)
    , init = \_ -> ""
    , view = view
    } specs
