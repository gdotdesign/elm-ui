import Spec exposing (..)

import Html exposing (div, text, button)
import Html.Events exposing (onClick)

import Ui.Pager

import Ui.Styles.Theme exposing (default)
import Ui.Styles.Pager
import Ui.Styles

import Css.Properties as Css
import Css

import Steps exposing (keyDown)

import Json.Encode as Json

type alias Model =
  { pager : Ui.Pager.Model
  }

type Msg
  = Pager Ui.Pager.Msg
  | SetPage Int

init : () -> Model
init _ =
  { pager = Ui.Pager.init ()
  }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    SetPage _ ->
      let
        index =
          if model.pager.active == 0 then
            1
          else
            0
      in
        ( { model | pager = Ui.Pager.select index model.pager }, Cmd.none )

    Pager msg ->
      ( { model | pager = Ui.Pager.update msg model.pager }, Cmd.none )

view : Model -> Html.Html Msg
view { pager } =
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.Pager.style
      , (\_ ->
          Css.selector "ui-pager"
            [ Css.width (Css.px 200)
            , Css.height (Css.px 200)
            ]
        )
      ] default
    , Ui.Pager.view
      { pages = [ text "A", text "B" ]
      , address = Pager
      }
      pager
    , button [ onClick (SetPage 1) ] [ text "Change page" ]
    ]

specs : Node
specs =
  describe "Ui.Pager"
    [ context "Changing pages"
      [ it "animates"
        [ assert.not.elementPresent "ui-page[animating]"
        , assert.inlineStyleEquals
          { selector = "ui-page:nth-child(2)"
          , style = "visibility"
          , value = "hidden"
          }
        , assert.inlineStyleEquals
          { selector = "ui-page:nth-child(1)"
          , style = "visibility"
          , value = ""
          }
        , steps.click "button"
        , assert.elementPresent "ui-page[animating]"
        , steps.dispatchEvent
            "transitionend"
            (Json.object [])
            "ui-page:nth-child(1)"
        , steps.dispatchEvent
            "transitionend"
            (Json.object [])
            "ui-page:nth-child(2)"
        , assert.not.elementPresent "ui-page[animating]"
        , assert.inlineStyleEquals
          { selector = "ui-page:nth-child(2)"
          , style = "visibility"
          , value = ""
          }
        , assert.inlineStyleEquals
          { selector = "ui-page:nth-child(1)"
          , style = "visibility"
          , value = "hidden"
          }
        ]
      ]
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , init = init
    , view = view
    } specs
