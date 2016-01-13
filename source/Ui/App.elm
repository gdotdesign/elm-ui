module Ui.App (Model, Action(..), init, update, view) where

{-| Base frame for a web/mobile application:
  - Provides a signal for **load** and **scroll** events
  - Sets the viewport to be mobile friendly
  - Sets the title of the application
  - Loads the stylesheet

# Model
@docs Model, Action, update, init

# View
@docs view
-}
import Ext.Signal
import Effects

import Html.Attributes exposing (name, content, style)
import Html.Extra exposing (onScroll)
import Html exposing (node, text)
import Html.Lazy

import Ui

{-| Representation of an application:
  - **loadedAddress** - The address to send messages when the application is loaded
  - **scrolledAddress** - The address to send messages when something is scrolled
  - **loaded** (internal) - Whether or not the application is loaded
  - **title** - The title of the application (and the window)
-}
type alias Model =
  { scrolledAddress : Signal.Address Bool
  , loadedAddress : Signal.Address Bool
  , title : String
  , loaded : Bool
  }

{-| Actions an application can make. -}
type Action
  = Scrolled
  | Loaded
  | Tasks ()

{-| Initializes an application with the given title.

    App.init (forwardTo address Loaded) (forwardTo address Scrolled) "My Application"
-}
init : Signal.Address Bool -> Signal.Address Bool -> String -> Model
init loadedAddress scrolledAddress title =
  { scrolledAddress = scrolledAddress
  , loadedAddress = loadedAddress
  , loaded = False
  , title = title
  }

{-| Updates an application. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Loaded ->
      ({ model | loaded = True }
       , Ext.Signal.sendAsEffect model.loadedAddress True Tasks)

    Scrolled ->
      (model, Ext.Signal.sendAsEffect model.scrolledAddress True Tasks)

    Tasks _ ->
      (model, Effects.none)

{-| Renders an application.

    App.view address app [text "Hello there!"]
-}
view: Signal.Address Action -> Model -> List Html.Html -> Html.Html
view address model children =
  Html.Lazy.lazy3 render address model children

-- Render (Internal)
render : Signal.Address Action -> Model -> List Html.Html -> Html.Html
render address model children =
  node "ui-app" [ onScroll address Scrolled
                , style [("visibility", if model.loaded then "" else "hidden")]
                ]
    ([ Ui.stylesheetLink "main.css" address Loaded
     , node "title" [] [text model.title]
     , node "meta" [ name "viewport"
                   , content "initial-scale=1.0, user-scalable=no"
                   ] []
     ] ++ children)
