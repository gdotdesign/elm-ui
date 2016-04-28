module Ui.Loader exposing (Model, Msg, init, update, render, view, overlayView, barView, start, finish)

{-| Loading component, it has a wait period before showing itself.

# Model
@docs Model, Msg, init, update

# View
@docs render, view,

# View Variations
overlayView, barView

# Functions
@docs start, finish
-}

import Html.Attributes exposing (classList, class)
import Html exposing (node, div)

import Task


{-| Representation of a loader:
  - **timeout** - The waiting perid in milliseconds
  - **shown** - Whether or not the loader is shown
  - **loading** - Whether or not the loading is started
-}
type alias Model =
  { timeout : Float
  , loading : Bool
  , shown : Bool
  }


{-| Messages that a loader can receive.
-}
type Msg
  = Show ()
  | NoOp ()


{-| Initializes a loader with the given timeout.

    model = Ui.Loader.init 200
-}
init : Float -> Model
init timeout =
  { timeout = timeout
  , loading = False
  , shown = False
  }


{-| Updates a loader.

    Ui.Loader.update msg model
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Show _ ->
      if model.loading then
        ( { model | shown = True }, Cmd.none )
      else
        ( model, Cmd.none )

    _ ->
      ( model, Cmd.none )


{-| Lazily renders a loader.

    Ui.Loader.view model
-}
view : String -> List (Html.Html msg) -> Model -> Html.Html msg
view kind content model =
  render kind content model


{-| Lazily renders a loader as an overlay.

    Ui.Loader.overlayView model
-}
overlayView : Model -> Html.Html msg
overlayView model =
  view "overlay" [ loadingRectangles ] model


{-| Lazily renders a loader as a bar.

    Ui.Loader.barView model
-}
barView : Model -> Html.Html msg
barView model =
  view "bar" [] model


{-| Rendes a loader.

    Ui.Loader.render kind contents model
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
-}
finish : Model -> Model
finish model =
  { model | loading = False, shown = False }


{-| Starts the loading process.
-}
start : Model -> ( Model, Cmd Msg )
start model =
  ( { model | loading = True }, Task.perform Show NoOp (Task.succeed ()) )


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
