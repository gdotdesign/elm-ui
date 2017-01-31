import Spec exposing (..)

import Html exposing (div, button, text)
import Html.Events exposing (onClick)
import Steps exposing (..)
import Ui.Image


type alias Model =
  { image : Ui.Image.Model
  }


type Msg
  = Image Ui.Image.Msg
  | Load


init : () -> Model
init _ =
  { image = Ui.Image.init "" }


png : String
png =
  "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ ({ image } as model) =
  case msg_ of
    Load ->
      ( { model | image = { image  | src = png } } , Cmd.none )

    Image msg ->
      ( { model | image = Ui.Image.update msg model.image } , Cmd.none )


view : Model -> Html.Html Msg
view model =
  div
    [ ]
    [ Html.map Image (Ui.Image.view model.image)
    , button [ onClick Load ] [ text "Load" ]
    ]


specs : Node
specs =
  describe "Ui.Image"
    [ context "Not loaded"
      [ it "does not have loaded attribute"
        [ assert.not.elementPresent "ui-image[loaded]"
        ]
      ]
    , context "Loaded"
      [ it "has loaded attribute"
        [ assert.not.elementPresent "ui-image[loaded]"
        , steps.click "button"
        -- this is needed for some reason
        , assert.not.elementPresent "ui-image[loaded]"
        , assert.elementPresent "ui-image[loaded]"
        ]
      ]
    ]


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , init = init
    , view = view
    } specs
