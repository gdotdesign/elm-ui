import Spec exposing (..)

import Html.Attributes exposing (class)
import Html exposing (div, text)

import Ui.IconButton
import Ui.Container
import Ui.Icons

import Steps exposing (..)


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
      ( "Clicked", Cmd.none )


view : Model -> Html.Html Msg
view model =
  let
    button =
      Ui.IconButton.model "" (Ui.Icons.close [])
  in
    div
      [ ]
      [ Ui.Container.column []
        [ Ui.Container.row []
          [ Ui.IconButton.view Set
            { button | text = "Primary",   kind = "primary"   }
          , Ui.IconButton.view Set
            { button | text = "Secondary", kind = "secondary" }
          , Ui.IconButton.view Set
            { button | text = "Warning",   kind = "warning"   }
          , Ui.IconButton.view Set
            { button | text = "Success",   kind = "success"   }
          , Ui.IconButton.view Set
            { button | text = "Danger",    kind = "danger"    }
          ]
        , Ui.Container.row []
          [ Ui.IconButton.view Set
            { button | size = "big", text = "Primary",   kind = "primary"   }
          , Ui.IconButton.view Set
            { button | size = "big", text = "Secondary", kind = "secondary" }
          , Ui.IconButton.view Set
            { button | size = "big", text = "Warning",   kind = "warning"   }
          , Ui.IconButton.view Set
            { button | size = "big", text = "Success",   kind = "success"   }
          , Ui.IconButton.view Set
            { button | size = "big", text = "Danger",    kind = "danger"    }
          ]
        , Ui.Container.row []
          [ Ui.IconButton.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          , Ui.IconButton.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          , Ui.IconButton.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          , Ui.IconButton.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          , Ui.IconButton.view Set
            { button | size = "small", text = "Primary",   kind = "primary"   }
          ]
        , Ui.Container.row []
          [ Ui.IconButton.render
            Set
            { glyph = (Ui.Icons.close [])
            , disabled = True
            , readonly = False
            , kind = "primary"
            , size = "medium"
            , text = "Hello"
            , side = "left"
            }
          , Ui.IconButton.render
            Set
            { glyph = (Ui.Icons.close [])
            , disabled = False
            , readonly = True
            , kind = "primary"
            , size = "medium"
            , text = "Hello"
            , side = "left"
            }
          ]
        ]
      , div [ class "result" ] [ text model ]
      ]


specs : Node
specs =
  describe "Ui.Button"
    [ it "has tabindex"
      [ assert.elementPresent "ui-icon-button[tabindex]"
      , assert.elementPresent "ui-icon-button[readonly][tabindex]"
      ]
    , context "Disabled"
      [ it "does not have tabindex"
        [ assert.not.elementPresent "ui-icon-button[disabled][tabindex]"
        ]
      ]
    , context "Icon"
      [ it "has margin"
        [ assert.styleEquals
          { selector = "ui-icon-button span"
          , style = "margin-left"
          , value = "0.625em"
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
