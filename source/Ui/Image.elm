module Ui.Image exposing (Model, Msg, init, update, render, view)

{-| Image component that fades when loaded.

# Model
@docs Model, Msg, init, update

# View
@docs render, view
-}

-- where

import Html.Attributes exposing (src, classList)
import Html.Events.Extra exposing (onLoad)
import Html exposing (node, img)


{-| Representation of an image:
  - **loaded** - Whether or not the image is loaded
  - **src** - The url for the image
-}
type alias Model =
  { loaded : Bool
  , src : String
  }


{-| Messages that an image can receive.
-}
type Msg
  = Loaded


{-| Initializes an image from an URL.

    image = Ui.Image.init "http://some.url/image.png"
-}
init : String -> Model
init url =
  { loaded = False
  , src = url
  }


{-| Updates an image.

    Ui.Image.update image
-}
update : Msg -> Model -> Model
update action model =
  case action of
    Loaded ->
      { model | loaded = True }


{-| Lazily renders an image.

    Ui.Image.view model
-}
view : Model -> Html.Html Msg
view model =
  render model


{-| Renders an image.

    Ui.Image.render model
-}
render : Model -> Html.Html Msg
render model =
  node
    "ui-image"
    [ classList [ ( "loaded", model.loaded ) ] ]
    [ img [ src model.src, onLoad Loaded ] []
    ]
