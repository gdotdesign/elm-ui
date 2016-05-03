module Ui.App exposing (Model, Msg, init, subscribe, subscriptions, update, view, render)

{-| Base frame for a web/mobile application:
  - Provides subscriptions for **load** and **scroll** events
  - Provides periodic updates to **Ui.Time**
  - Sets the viewport to be mobile friendly
  - Sets the title of the application
  - Loads the stylesheet

# Model
@docs Model, Msg, update, init, subscribe, subscriptions

# View
@docs view, render
-}

-- where

import Html.Attributes exposing (name, content, style)
import Html.Events.Geometry exposing (MousePosition)
import Html.Events exposing (onMouseDown, onMouseUp)
import Html.Events.Extra exposing (onScroll)
import Html exposing (node, text)

import Time exposing (Time)
import Json.Decode as JD
import Json.Encode as JE

import Native.Uid

import Ui.Helpers.Emitter as Emitter
import Ui.Time
import Ui


{-| Representation of an application:
  - **title** - The title of the application (and the window)
  - **loaded** - Whether or not the application is loaded
  - **uid** - The unique ID of the application
-}
type alias Model =
  { title : String
  , loaded : Bool
  , uid : String
  }


{-| Messages that an application can receive.
-}
type Msg
  = Tick Time
  | Scrolled
  | Loaded


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

    Ui.App.subscribe ScrollMsg LoadMsg app
-}
subscribe : (Bool -> a) -> (Bool -> a) -> Model -> Sub a
subscribe scrollMsg loadMsg model =
  Sub.batch
    [ Emitter.listenBool (model.uid ++ "-scroll") scrollMsg
    , Emitter.listenBool (model.uid ++ "-load") loadMsg
    ]


{-| Subscriptions for an application.

    Sub.map App Ui.App.subscriptions
-}
subscriptions : Sub Msg
subscriptions =
  Time.every 1000 Tick


{-| Updates an application.

    Ui.App.update msg app
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Loaded ->
      ( { model | loaded = True }
      , Emitter.sendBool (model.uid ++ "-load") True
      )

    Scrolled ->
      ( model, Emitter.sendBool (model.uid ++ "-scroll") True )

    Tick now ->
      ( model, Ui.Time.updateTime now )


{-| Lazily renders an application.

    Ui.App.view App app [text "Hello there!"]
-}
view : (Msg -> msg) -> Model -> List (Html.Html msg) -> Html.Html msg
view address model children =
  render address model children



{-| Renders an application.

    Ui.App.render App app [text "Hello there!"]
-}
render : (Msg -> msg) -> Model -> List (Html.Html msg) -> Html.Html msg
render address model children =
  node
    "ui-app"
    [ style
        [ ( "visibility"
          , if model.loaded then
              ""
            else
              "hidden"
          )
        ]
    , onScroll (address Scrolled)
    ]
    ([ Ui.stylesheetLink "/main.css" (address Loaded)
     , node "title" [] [ text model.title ]
     , node
        "meta"
        [ content "initial-scale=1.0, user-scalable=no"
        , name "viewport"
        ]
        []
     ]
      ++ children
    )
