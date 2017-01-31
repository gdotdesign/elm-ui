import Spec exposing (..)

import Steps exposing (..)
import Json.Encode as Json
import Ui.DatePicker
import Ui.Container
import Html


type alias Model =
  { enabled : Ui.DatePicker.Model
  , disabled : Ui.DatePicker.Model
  , readonly : Ui.DatePicker.Model
  }


type Msg
  = Enabled Ui.DatePicker.Msg
  | Disabled Ui.DatePicker.Msg
  | Readonly Ui.DatePicker.Msg


init : () -> Model
init _ =
  { enabled = Ui.DatePicker.init ()
  , disabled = Ui.DatePicker.init ()
  , readonly = Ui.DatePicker.init ()
  }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Readonly msg ->
      let
        ( readonly, cmd ) = Ui.DatePicker.update msg model.readonly
      in
        ( { model | readonly = readonly }, Cmd.map Readonly cmd )

    Disabled msg ->
      let
        ( disabled, cmd ) = Ui.DatePicker.update msg model.disabled
      in
        ( { model | disabled = disabled }, Cmd.map Disabled cmd )

    Enabled msg ->
      let
        ( enabled, cmd ) = Ui.DatePicker.update msg model.enabled
      in
        ( { model | enabled = enabled }, Cmd.map Enabled cmd )


view : Model -> Html.Html Msg
view ({ disabled, readonly } as model) =
  Ui.Container.row []
    [ Html.map Enabled (Ui.DatePicker.view "en_us" model.enabled)
    , Html.map Disabled (Ui.DatePicker.view "en_us" { disabled | disabled = True } )
    , Html.map Readonly (Ui.DatePicker.view "en_us" { readonly | readonly = True } )
    ]


specs : Node
specs =
  describe "Ui.DatePicker"
    [ it "has tabindex"
      [ assert.elementPresent "ui-picker[tabindex]"
      ]
    , context "Disabled"
      [ it "does not have tabindex"
        [ assert.not.elementPresent "ui-picker[disabled][tabindex]"
        ]
      ]
    , context "Readonly"
      [ it "has tabindex"
        [ assert.elementPresent "ui-picker[readonly][tabindex]"
        ]
      ]
    , context "Open"
      [ before
        [ assert.not.elementPresent "ui-dropdown-panel[open]"
        , focus "ui-picker"
        , assert.elementPresent "ui-dropdown-panel[open]"
        ]
      , it "toggles on mousedown"
        [ steps.dispatchEvent "mousedown" (Json.object []) "ui-picker-input"
        , assert.not.elementPresent "ui-dropdown-panel[open]"
        , steps.dispatchEvent "mousedown" (Json.object []) "ui-picker-input"
        , assert.elementPresent "ui-dropdown-panel[open]"
        ]
      , context "Keys"
        [ it "toggles on enter"
          [ keyDown 13 "ui-picker"
          , assert.not.elementPresent "ui-dropdown-panel[open]"
          , keyDown 13 "ui-picker"
          , assert.elementPresent "ui-dropdown-panel[open]"
          ]
        , it "closes on esc"
          [ keyDown 27 "ui-picker"
          , assert.not.elementPresent "ui-dropdown-panel[open]"
          , keyDown 27 "ui-picker"
          , assert.not.elementPresent "ui-dropdown-panel[open]"
          ]
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
