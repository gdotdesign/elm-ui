module Ui.App
  (Model, Action, init, update, view) where

{-| Base frame for a web/mobile application:
  - Loads the stylesheet
  - Sets up a click handler
  - Sets the viewport to be mobile friendly

# Model
@docs Model, Action, update, init

# View
@docs view
-}
import Html.Attributes exposing (name, content)
import Html.Events exposing (onClick)
import Html exposing (node)
import Html.Lazy

import Ui

{-| Representation of an application. -}
type alias Model =
  { loaded: Bool }

{-| Actions an application can make:
  - **Clicked** - Dispatched when a click is made
  - **Loaded** - Dispatched when the stylesheet is loaded
-}
type Action
  = Clicked
  | Loaded

{-| Initializes an application. -}
init : Model
init =
  { loaded = False }

{-| Updates an application. -}
update : Action -> Model -> Model
update action model =
  case action of
    Loaded ->
      { model | loaded = True }
    Clicked ->
      model

{-| Renders an application.

    view address []
      [text "Hello there!"]
-}
view: Signal.Address Action -> Model -> List Html.Html -> Html.Html
view address model children =
  Html.Lazy.lazy3 render address model children

-- Render (Internal)
render : Signal.Address Action -> Model -> List Html.Html -> Html.Html
render address model children =
  node "ui-app" [onClick address Clicked]
    ([ Ui.stylesheetLink "/index.css" address Loaded
     , node "meta" [ name "viewport"
                   , content "initial-scale=1.0, user-scalable=no"] []
     ] ++ if model.loaded then children else [])
