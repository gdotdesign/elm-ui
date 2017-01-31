import Spec exposing (..)

import Steps exposing (..)
import Json.Encode as Json
import Ui.ColorPicker
import Ui.Container
import Html


type alias Model =
  { enabled : Ui.ColorPicker.Model
  , disabled : Ui.ColorPicker.Model
  , readonly : Ui.ColorPicker.Model
  }


type Msg
  = Enabled Ui.ColorPicker.Msg
  | Disabled Ui.ColorPicker.Msg
  | Readonly Ui.ColorPicker.Msg


init : () -> Model
init _ =
  { enabled = Ui.ColorPicker.init ()
  , disabled = Ui.ColorPicker.init ()
  , readonly = Ui.ColorPicker.init ()
  }


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map Enabled (Ui.ColorPicker.subscriptions model.enabled)
    , Sub.map Disabled (Ui.ColorPicker.subscriptions model.disabled)
    , Sub.map Readonly (Ui.ColorPicker.subscriptions model.readonly)
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Readonly msg ->
      let
        ( readonly, cmd ) = Ui.ColorPicker.update msg model.readonly
      in
        ( { model | readonly = readonly }, Cmd.map Readonly cmd )

    Disabled msg ->
      let
        ( disabled, cmd ) = Ui.ColorPicker.update msg model.disabled
      in
        ( { model | disabled = disabled }, Cmd.map Disabled cmd )

    Enabled msg ->
      let
        ( enabled, cmd ) = Ui.ColorPicker.update msg model.enabled
      in
        ( { model | enabled = enabled }, Cmd.map Enabled cmd )


view : Model -> Html.Html Msg
view ({ disabled, readonly } as model) =
  Ui.Container.row []
    [ Html.map Enabled (Ui.ColorPicker.view model.enabled)
    , Html.map Disabled (Ui.ColorPicker.view { disabled | disabled = True } )
    , Html.map Readonly (Ui.ColorPicker.view { readonly | readonly = True } )
    ]


specs : Node
specs =
  describe "Ui.ColorPicker"
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
    { subscriptions = subscriptions
    , update = update
    , init = init
    , view = view
    } specs
