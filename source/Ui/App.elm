module Ui.App exposing
  (Model, Msg(..), init, subscribe, subscriptions, update, view) -- where

{-| Base frame for a web/mobile application:
  - Provides subscriptions for **load** and **scroll** events
  - Provides periodic updates to Ui.Time
  - Sets the viewport to be mobile friendly
  - Sets the title of the application
  - Loads the stylesheet

# Model
@docs Model, Msg, update, init, subscribe, subscriptions

# View
@docs view
-}
import Html.Attributes exposing (name, content, style)
import Html.Events exposing (onMouseDown, onMouseUp)
import Html.Extra exposing (onScroll, onMouseMove)
import Html exposing (node, text)
-- import Html.Lazy

import Json.Decode as JD
import Json.Encode as JE

import Time exposing (Time)
import Native.Uid

import Ui.Helpers.Emitter as Emitter
import Ui.Time
import Ui

{-| Representation of an application:
  - **loaded** (internal) - Whether or not the application is loaded
  - **title** - The title of the application (and the window)
  - **uid** - The unique ID of the application
-}
type alias Model =
  { title : String
  , loaded : Bool
  , uid : String
  }

{-| Actions an application can make. -}
type Msg
  = Tick Time
  | Scrolled
  | MouseMove (Int, Int)
  | Click Bool
  | Loaded
  | Tasks ()

{-| Initializes an application with the given title.

    app = App.init "My Application"
-}
init : String -> Model
init title =
  { uid = Native.Uid.uid ()
  , loaded = False
  , title = title
  }

{-| Subscribes to changes for an application.

    Ui.App.subscribe ScrollAction LoadAction app
-}
subscribe : (Bool -> a) -> (Bool -> a) -> Model -> Sub a
subscribe scrollMsg loadMsg model =
  let
    decoder =
      Emitter.decode JD.bool False
  in
    Sub.batch
      [ Emitter.listen (model.uid ++ "-scroll") (decoder scrollMsg)
      , Emitter.listen (model.uid ++ "-load") (decoder loadMsg)
      ]

{-| Subscriptions for an application.

    Sub.map App Ui.App.subscriptions
-}
subscriptions : Sub Msg
subscriptions =
  Time.every 1000 Tick

{-| Updates an application. -}
update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Loaded ->
      ({ model | loaded = True }
       , Emitter.send (model.uid ++ "-load") (JE.bool True))

    Scrolled ->
      (model, Emitter.send (model.uid ++ "-scroll") (JE.bool True))

    Tick now ->
      (model, Ui.Time.updateTime now)

    MouseMove (x,y) ->
      (model, Emitter.send "mouse-move" (JE.list [JE.int x, JE.int y]))

    Click pressed ->
      (model, Emitter.send "mouse-click" (JE.bool pressed))

    _ ->
      (model, Cmd.none)

{-| Renders an application.

    Ui.App.view address app [text "Hello there!"]
-}
view: (Msg -> msg) -> Model -> List (Html.Html msg) -> Html.Html msg
view address model children =
  render address model children
  -- FIXME: Lazy is broken in 0.17
  -- Html.Lazy.lazy3 render model address children

-- Render (Internal)
render : (Msg -> msg) -> Model -> List (Html.Html msg) -> Html.Html msg
render address model children =
  node "ui-app" [ style [("visibility", if model.loaded then "" else "hidden")]
                , onScroll (address Scrolled)
                , onMouseMove (\pos -> address (MouseMove pos))
                , onMouseUp (address (Click False))
                , onMouseDown (address (Click True))
                ]
    ([ Ui.stylesheetLink "http://localhost:8000/Projects/elm-017-experiments/main.css" (address Loaded)
     , node "title" [] [text model.title]
     , node "meta"
       [ content "initial-scale=1.0, user-scalable=no"
       , name "viewport"
       ] []
     ] ++ children)
