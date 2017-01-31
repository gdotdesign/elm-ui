import Spec exposing (..)

import Html exposing (div, text, button)
import Html.Events exposing (onClick)
import Steps exposing (..)
import Ui.Loader


type alias Model =
  { loader : Ui.Loader.Model
  }


type Msg
  = Loader Ui.Loader.Msg
  | Stop
  | Start


init : () -> Model
init _ =
  { loader =
      Ui.Loader.init ()
        |> Ui.Loader.timeout 0
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Stop ->
      ( { model | loader = Ui.Loader.finish model.loader }, Cmd.none )

    Start ->
      let
        ( loader, cmd ) =
          Ui.Loader.start model.loader
      in
        ( { model | loader = loader }
        , Cmd.map Loader cmd )

    Loader msg ->
      let
        ( loader, cmd ) =
          Ui.Loader.update msg model.loader
      in
        ( { model | loader = loader }
        , Cmd.map Loader cmd )


view : Model -> Html.Html Msg
view { loader } =
  div
    [ ]
    [ Html.map Loader (Ui.Loader.barView loader)
    , Html.map Loader (Ui.Loader.overlayView loader)
    , button [ onClick Start ] [ text "Start" ]
    , button [ onClick Stop ] [ text "Stop" ]
    ]


specs : Node
specs =
  describe "Ui.Loader"
    [ it "hidden by default"
      [ assert.styleEquals
        { selector = "ui-loader[kind=bar]"
        , style = "visibility"
        , value = "hidden"
        }
      , assert.styleEquals
        { selector = "ui-loader[kind=overlay]"
        , style = "visibility"
        , value = "hidden"
        }
      ]
    , it "shows after start"
      [ steps.click "button"
      , steps.click "button" -- this is needed to wait for a RAF
      , assert.elementPresent "ui-loader[kind=bar][loading]"
      , assert.elementPresent "ui-loader[kind=overlay][loading]"
      , assert.styleEquals
        { selector = "ui-loader[kind=bar]"
        , style = "visibility"
        , value = "visible"
        }
      , assert.styleEquals
        { selector = "ui-loader[kind=overlay]"
        , style = "visibility"
        , value = "visible"
        }
      ]
    ]


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , init = init
    , view = view
    } specs
