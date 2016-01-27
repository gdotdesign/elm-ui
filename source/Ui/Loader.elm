module Ui.Loader
  (Model, Action, init, update, view, overlayView, barView, start, finish) where

{-| Loading component, it has a wait period before showing itself.

# Model
@docs Model, Action, init, update

# View
@docs view, overlayView, barView

# Functions
@docs start, finish
-}
import Effects
import Task

import Html.Attributes exposing (classList, class)
import Html exposing (node, div)
import Html.Lazy

{-| Representation of a loader:
  - **loading** - Whether or not the loading is started
  - **shown** - Whether or not the loader is shown
  - **timeout** - The waiting perid in milliseconds
-}
type alias Model =
  { timeout : Float
  , loading : Bool
  , shown : Bool
  }

{-| Actions that a loader can make. -}
type Action = Show

{-| Initializes a loader with the given timeout.

    Loader.init 200
-}
init : Float -> Model
init timeout =
  { timeout = timeout
  , loading = False
  , shown = False
  }

{-| Updates a loader. -}
update : Action -> Model -> Model
update action model =
  case action of
    Show ->
      if model.loading then
        { model | shown = True }
      else
        model

{-| Renders a loader as an overlay. -}
overlayView : Model -> Html.Html
overlayView model =
  view "overlay" [loadingRects] model

{-| Renders a loader as a bar. -}
barView : Model -> Html.Html
barView model =
  view "bar" [] model

{-| Renders a loader. -}
view : String -> List Html.Html -> Model -> Html.Html
view kind content model =
  Html.Lazy.lazy3 render kind content model

{-| Finishes the loading process. -}
finish : Model -> Model
finish model =
  { model | loading = False, shown = False }

{-| Starts the loading process. -}
start : Model -> (Model, Effects.Effects Action)
start model =
  let
    effect =
      Task.andThen
        (Task.sleep model.timeout)
        (\_ -> Task.succeed Show)
        |> Effects.task
  in
  ({ model | loading = True }, effect)


-- Render internal
render : String -> List Html.Html -> Model -> Html.Html
render kind content model =
  node "ui-loader"
    [ classList [ ("ui-loader-" ++ kind, True)
                , ("loading", model.shown)
                ]
    ]
    content

-- Renders loading rects
loadingRects : Html.Html
loadingRects =
  div [ class "ui-loader-rects" ]
    [ div [] []
    , div [] []
    , div [] []
    ]
