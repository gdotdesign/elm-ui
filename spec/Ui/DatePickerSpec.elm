import Spec exposing (..)

import Html exposing (div)

import Ui.DatePicker
import Ui.Container

import Ui.Styles.Theme exposing (default)
import Ui.Styles.DatePicker
import Ui.Styles.Container
import Ui.Styles

import Steps exposing (..)

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
  div
    [ ]
    [ Ui.Styles.embedSome
      [ Ui.Styles.DatePicker.style
      , Ui.Styles.Container.style
      ] default
    , Ui.Container.row []
      [ Html.map Enabled (Ui.DatePicker.view "en_us" model.enabled)
      , Html.map Disabled (Ui.DatePicker.view "en_us" { disabled | disabled = True } )
      , Html.map Readonly (Ui.DatePicker.view "en_us" { readonly | readonly = True } )
      ]
    ]

specs : Node
specs =
  describe "Ui.DatePicker"
    [
    ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , init = init
    , view = view
    } specs
