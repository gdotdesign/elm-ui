module Ui.App (Model, Action(..), init, update, view) where

{-| Base frame for a web/mobile application:
  - Loads the stylesheet
  - Sets up a scroll handler
  - Sets the viewport to be mobile friendly
  - Sets the title of the application

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

{-| Representation of an application. -}
type alias Model =
  { title : String
  , loaded : Bool
  , mailbox : Signal.Mailbox String
  }

{-| Actions an application can make:
  - **Scrolled** - Dispatched when something inside the application has scrolled
  - **Loaded** - Dispatched when the stylesheet is loaded
-}
type Action
  = Scrolled
  | Loaded
  | Tasks ()

{-| Initializes an application.

    App.init "My Application"
-}
init : String -> Model
init title =
  { loaded = False
  , title = title
  , mailbox = Signal.mailbox ""
  }

{-| Updates an application. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Loaded ->
      ({ model | loaded = True }
       , Ext.Signal.sendAsEffect model.mailbox.address "load" Tasks)

    Scrolled ->
      (model, Ext.Signal.sendAsEffect model.mailbox.address "scroll" Tasks)

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
