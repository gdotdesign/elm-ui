import Spec exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Container
import Ui.Ratings

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Container
import Ui.Styles.Ratings
import Ui.Styles

import Steps exposing (keyDown)

view : Ui.Ratings.Model -> Html.Html Ui.Ratings.Msg
view model =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.Ratings.style
      , Ui.Styles.Container.style
      ] default
    , Ui.Container.row []
      [ Ui.Ratings.view model
      , Ui.Ratings.view { model | disabled = True }
      , Ui.Ratings.view { model | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.Ratings"
    [ it "has tabindex"
      [ assert.elementPresent "ui-ratings[tabindex]"
      ]
    , context "Disabled"
      [ it "does not have tabindex"
        [ assert.elementPresent "ui-ratings[disabled]"
        , assert.not.elementPresent "ui-ratings[disabled][tabindex]"
        ]
      ]
    , context "Readonly"
      [ it "has tabindex"
        [ assert.elementPresent "ui-ratings[readonly][tabindex]"
        ]
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Ratings.update
    , init = Ui.Ratings.init
    , view = view
    } specs
