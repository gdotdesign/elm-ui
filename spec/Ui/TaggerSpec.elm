import Spec exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html exposing (div, text)

import Ui.Container
import Ui.Tagger

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Tagger
import Ui.Styles

import Steps exposing (keyDown)

view : Ui.Tagger.Model -> Html.Html Ui.Tagger.Msg
view model =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.Tagger.style
      ] default
    , Ui.Container.row []
      [ Ui.Tagger.view [{ id = "0", label = "Hello" }] model
      , Ui.Tagger.view [{ id = "0", label = "Hello" }] { model | disabled = True }
      , Ui.Tagger.view [{ id = "0", label = "Hello" }] { model | readonly = True }
      ]
    ]

specs : Node
specs =
  describe "Ui.Tagger"
    [ it "has tags"
      [ assert.elementPresent "ui-tagger-tag"
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Tagger.update
    , init = Ui.Tagger.init
    , view = view
    } specs
