module Ui.App exposing (Model, Msg, init, subscriptions, update, view, render)

{-| Ui.App is the starting point of any Elm-UI application, it has multiple
responsibilities:
  - Schedules updates for the **Ui.Time** component
  - Sets the **viewport meta tag** to be mobile friendly

# Model
@docs Model, Msg, update, init, subscriptions

# View
@docs view, render
-}

import Html.Attributes exposing (name, content, style)
import Html exposing (node, text)
import Html.Lazy

import Time exposing (Time)

import Ui.Time


{-| Representation of an application.
-}
type alias Model =
  { }


{-| Messages that an application can receive.
-}
type Msg
  = Tick Time


{-| Initializes an application.

    app = Ui.App.init
-}
init : Model
init =
  {}


{-| Subscriptions for an application.

    Sub.map App Ui.App.subscriptions
-}
subscriptions : Sub Msg
subscriptions =
  Sub.none


{-| Updates an application.

    Ui.App.update msg app
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  model ! []


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
    ([ node
        "meta"
        [ content "initial-scale=1.0, user-scalable=no"
        , name "viewport"
        ]
        []
     ]
      ++ children
    )
