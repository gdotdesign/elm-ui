module Ui.App exposing (Model, Msg, init, subscriptions, update, view, render, setTitle)

{-| Ui.App is the starting point of any Elm-UI application, it has multiple
responsibilities:
  - Schedules updates for the **Ui.Time** component
  - Sets the **viewport meta tag** to be mobile friendly
  - Sets the **title** of the window

# Model
@docs Model, Msg, update, init, subscriptions

# View
@docs view, render

# Functions
@docs setTitle
-}

import Html.Attributes exposing (name, content, style)
import Html exposing (node, text)
import Html.Lazy

import Time exposing (Time)

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Browser as Browser
import Ui.Native.Uid as Uid
import Ui.Time
import Ui


{-| Representation of an application:
  - **title** - The title of the application (and the window)
  - **uid** - The unique identifier of the application
-}
type alias Model =
  { title : String
  , uid : String
  }


{-| Messages that an application can receive.
-}
type Msg
  = Tick Time


{-| Initializes an application with the given title.

    app = Ui.App.init "My Application"
-}
init : String -> Model
init title =
  { uid = Uid.uid ()
  , title = title
  }


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
    []
    ([ node "title" [] [ text model.title ]
    , node
        "meta"
        [ content "initial-scale=1.0, user-scalable=no"
        , name "viewport"
        ]
        []
    ] ++ children)


{-| Sets the title of the application

    Ui.App.setTitle "New Title" model.app
-}
setTitle : String -> Model -> Model
setTitle title model =
  { model | title = title }
