module Ui.App exposing
  (Model, Msg, init, subscribe, subscriptions, update, view, render, setTitle)

{-| Ui.App is the starting point of any Elm-UI application, it has multiple
responsibilities:
  - Loads the CSS file and provides a subscription to hanlde loaded state
  - Schedules updates for the **Ui.Time** component
  - Sets the **viewport meta tag** to be mobile friendly
  - Sets the **title** of the window

# Model
@docs Model, Msg, update, init, subscribe, subscriptions

# View
@docs view, render

# Functions
@docs setTitle
-}

import Html.Attributes exposing (name, content, style)
import Html exposing (node, text)
import Html.Lazy

import Time exposing (Time)

import Native.Uid

import Ui.Helpers.Emitter as Emitter
import Ui.Time
import Ui


{-| Representation of an application:
  - **title** - The title of the application (and the window)
  - **loaded** - Whether or not the application is loaded
  - **uid** - The unique identifier of the application
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
  | Loaded


{-| Initializes an application with the given title.

    app = Ui.App.init "My Application"
-}
init : String -> Model
init title =
  { uid = Native.Uid.uid ()
  , loaded = False
  , title = title
  }


{-| Subscribes to changes for an application.

    Ui.App.subscribe LoadMsg app
-}
subscribe : (Bool -> a) -> Model -> Sub a
subscribe loadMsg model =
  Emitter.listenBool (model.uid ++ "-load") loadMsg


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

    Tick now ->
      ( model, Ui.Time.updateTime now )


{-| Lazily renders an application.

    Ui.App.view App app [text "Hello there!"]
-}
view : (Msg -> msg) -> Model -> List (Html.Html msg) -> Html.Html msg
view address model children =
  Html.Lazy.lazy3 render address model children


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


{-| Sets the title of the application

    Ui.App.setTitle "New Title" model.app
-}
setTitle : String -> Model -> Model
setTitle title model =
  { model | title = title }
