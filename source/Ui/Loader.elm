module Ui.Loader exposing
  (Model, Msg, init, update, render, view, overlayView, barView, start, finish)

{-| Loading component, it has a waiting period before showing itself.

# Model
@docs Model, Msg, init, update

# View
@docs view, render

# View Variations
@docs overlayView, barView

# Functions
@docs start, finish
-}

import Html.Attributes exposing (classList, class)
import Html exposing (node, div)
import Html.Lazy

import Process
import Task


{-| Representation of a loader:
  - **timeout** - The waiting perid in milliseconds
  - **loading** - Whether or not the loading is started
  - **shown** - Whether or not the loader is shown
-}
type alias Model =
  { timeout : Float
  , loading : Bool
  , shown : Bool
  }


{-| Messages that a loader can receive.
-}
type Msg
  = Show


{-| Initializes a loader with the given timeout.

    loader = Ui.Loader.init 200
-}
init : Float -> Model
init timeout =
  { timeout = timeout
  , loading = False
  , shown = False
  }


{-| Updates a loader.

    Ui.Loader.update msg loader
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Show ->
      if model.loading then
        ( { model | shown = True }, Cmd.none )
      else
        ( model, Cmd.none )


{-| Lazily renders a loader.

    Ui.Loader.view loader
-}
view : String -> List (Html.Html msg) -> Model -> Html.Html msg
view kind content model =
  Html.Lazy.lazy3 render kind content model


{-| Lazily renders a loader as an overlay.

    Ui.Loader.overlayView loader
-}
overlayView : Model -> Html.Html msg
overlayView model =
  view "overlay" [ loadingRectangles ] model


{-| Lazily renders a loader as a bar.

    Ui.Loader.barView loader
-}
barView : Model -> Html.Html msg
barView model =
  view "bar" [] model


{-| Rendes a loader.

    Ui.Loader.render kind contents loader
-}
render : String -> List (Html.Html msg) -> Model -> Html.Html msg
render kind content model =
  node
    "ui-loader"
    [ classList
        [ ( "ui-loader-" ++ kind, True )
        , ( "loading", model.shown )
        ]
    ]
    content


{-| Finishes the loading process.

    Ui.Loader.finish loader
-}
finish : Model -> Model
finish model =
  { model | loading = False, shown = False }


{-| Starts the loading process.

    Ui.Loader.start loader
-}
start : Model -> ( Model, Cmd Msg )
start model =
  ( { model | loading = True }
  , Task.perform (\_ -> Show) (Process.sleep model.timeout)
  )


{-| Renders loading rectangles.
-}
loadingRectangles : Html.Html msg
loadingRectangles =
  div
    [ class "ui-loader-rectangles" ]
    [ div [] []
    , div [] []
    , div [] []
    ]
