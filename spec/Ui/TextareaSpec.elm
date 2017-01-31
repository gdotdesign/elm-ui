import Spec exposing (..)

import Html.Attributes exposing (class)
import Html exposing (div, text)
import Json.Encode as Json
import Steps exposing (..)
import Ui.Container
import Ui.Textarea


type alias Model =
  { textarea : Ui.Textarea.Model
  , content : String
  }


type Msg
  = Textarea Ui.Textarea.Msg
  | Changed String


init : () -> Model
init _ =
  { textarea =
      Ui.Textarea.init ()
        |> Ui.Textarea.placeholder "Placeholder..."
  , content = ""
  }


subscriptions : Model -> Sub Msg
subscriptions model =
  Ui.Textarea.onChange Changed model.textarea


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Textarea msg ->
      let
        ( textarea, cmd ) = Ui.Textarea.update msg model.textarea
      in
        ( { model | textarea = textarea }, Cmd.map Textarea cmd )

    Changed content ->
      ( { model | content = content }, Cmd.none )


view : Model -> Html.Html Msg
view { textarea, content } =
  div
    [ ]
    [ Ui.Container.row []
      [ Html.map Textarea (Ui.Textarea.view textarea)
      , Html.map Textarea (Ui.Textarea.view { textarea | disabled = True })
      , Html.map Textarea (Ui.Textarea.view { textarea | readonly = True })
      ]
    , div [ class "content" ] [ text content ]
    ]


specs : Node
specs =
  describe "Ui.Textarea"
    [ it "has placeholder"
      [ assert.elementPresent "ui-textarea textarea[placeholder='Placeholder...']"
      ]
    , it "fires change events"
      [ assert.containsText { selector = "div.content", text = "" }
      , steps.setValue "test" "ui-textarea textarea"
      , steps.dispatchEvent "input" (Json.object []) "ui-textarea textarea"
      , assert.containsText { selector = "div.content", text = "test" }
      ]
    , context "Disabled"
      [ it "textarea has disabled attribute"
        [ assert.elementPresent "ui-textarea:nth-child(2) textarea[disabled]"
        ]
      ]
    , context "Readonly"
      [ it "textarea has readonly attribute"
        [ assert.elementPresent "ui-textarea:nth-child(3) textarea[readonly]"
        ]
      ]
    ]


main =
  runWithProgram
    { subscriptions = subscriptions
    , update = update
    , init = init
    , view = view
    } specs
