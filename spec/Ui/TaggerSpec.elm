import Spec exposing (..)

import Ui.Native.Uid as Uid
import Json.Encode as Json
import Steps exposing (..)
import Ui.Container
import Ui.Tagger
import Html


type alias Model =
  { tagger : Ui.Tagger.Model
  , tags : List Ui.Tagger.Tag
  }


type Msg
  = Tagger Ui.Tagger.Msg
  | Remove String
  | Create String


init : () -> Model
init _ =
  { tagger = Ui.Tagger.init ()
  , tags = []
  }


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Ui.Tagger.onRemove Remove model.tagger
    , Ui.Tagger.onCreate Create model.tagger
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Tagger msg ->
      let
        ( tagger, cmd ) = Ui.Tagger.update msg model.tagger
      in
        ( { model | tagger = tagger }, Cmd.map Tagger cmd )

    Create value ->
      ( { model | tags = { id = Uid.uid (), label = value } :: model.tags }
      , Cmd.none )

    Remove id ->
      ( { model | tags = List.filter (.id >> (/=) id) model.tags }, Cmd.none )


view : Model -> Html.Html Msg
view { tagger, tags } =
  Ui.Container.row []
    [ Html.map Tagger (Ui.Tagger.view tags tagger)
    , Html.map Tagger (Ui.Tagger.view tags { tagger | disabled = True })
    , Html.map Tagger (Ui.Tagger.view tags { tagger | readonly = True })
    ]


createTag value =
  stepGroup ("Created tag " ++ value)
    [ steps.setValue value "ui-tagger ui-input input"
    , steps.dispatchEvent "input" (Json.object []) "ui-tagger ui-input input"
    , steps.click "ui-tagger ui-icon-button"
    ]


specs : Node
specs =
  describe "Ui.Tagger"
    [ context "Filling out the input"
      [ it "enables the button"
        [ assert.elementPresent "ui-tagger:first-child ui-icon-button[disabled]"
        , steps.setValue "test" "ui-tagger ui-input input"
        , steps.dispatchEvent "input" (Json.object []) "ui-tagger ui-input input"
        , assert.elementPresent "ui-tagger:first-child ui-icon-button:not([disabled])"
        ]
      ]
    , context "Creating tags"
      [ it "creates tag"
        [ assert.not.elementPresent "ui-tagger-tag"
        , createTag "Asdf"
        , assert.elementPresent "ui-tagger-tag"
        , assert.containsText
          { selector = "ui-tagger-tag"
          , text = "Asdf"
          }
        ]
      ]
    , context "With tags"
      [ before
        [ createTag "Hello"
        , createTag "test"
        ]
      , it "displays tags"
        [ assert.elementPresent "ui-tagger-tag:first-child"
        , assert.containsText
          { selector = "ui-tagger-tag:first-child"
          , text = "test"
          }
        , assert.elementPresent "ui-tagger-tag:nth-child(2)"
        , assert.containsText
          { selector = "ui-tagger-tag:nth-child(2)"
          , text = "Hello"
          }
        ]
      , context "Clicking on the remove button"
        [ it "fires remove event"
          [ assert.elementPresent "ui-tagger-tag:nth-child(2)"
          , clickSvg "ui-tagger-tag svg"
          , assert.not.elementPresent "ui-tagger-tag:nth-child(2)"
          , clickSvg "ui-tagger-tag svg"
          , assert.not.elementPresent "ui-tagger-tag"
          ]
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
