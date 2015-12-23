module Ui.Image
  (Model, Action, init, update, view) where

{-| Image component that fades when loaded.

# Model
@docs Model, Action, init, update

# View
@docs view
-}
import Html.Attributes exposing (src, classList)
import Html.Extra exposing (onLoad)
import Html exposing (node, img)
import Html.Lazy

{-| Representation of an image. -}
type alias Model =
  { loaded : Bool
  , src : String
  }

{-| Actions that an image can make. -}
type Action = Loaded

{-| Initializes an image from an URL. -}
init : String -> Model
init url =
  { loaded = False
  , src = url
  }

{-| Updates an image. -}
update : Action -> Model -> Model
update action model =
  case action of
    Loaded -> { model | loaded = True }

{-| Renders an image. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Render internal
render : Signal.Address Action -> Model -> Html.Html
render address model =
  node "ui-image" [classList [("loaded", model.loaded)]] [
    img [src model.src, onLoad address Loaded] []
  ]
