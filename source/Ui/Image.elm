module Ui.Image exposing (Model, Msg, init, update, render, view)

{-| Image component that fades when loaded.

# Model
@docs Model, Msg, init, update

# View
@docs render, view
-}

import Html.Events.Extra exposing (onLoad)
import Html.Attributes exposing (src)
import Html exposing (node, img)
import Html.Lazy

import Ui.Styles.Image exposing (defaultStyle)
import Ui.Styles
import Ui

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

    updatedImage = Ui.Image.update image
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
  Html.Lazy.lazy render model


{-| Renders an image.

    Ui.Image.render model
-}
render : Model -> Html.Html Msg
render model =
  node
    "ui-image"
    ( [ Ui.attributeList [ ("loaded", model.loaded ) ]
      , Ui.Styles.apply defaultStyle
      ]
      |> List.concat
    )
    [ img [ src model.src, onLoad Loaded ] []
    ]
