import Spec exposing (..)

import Html exposing (div, text, button)
import Html.Events exposing (onClick)

import Json.Encode as Json
import Steps exposing (..)

import Ui.DrawerMenu
import Ui.Icons
import Ui

import Ui.Icons

type alias Model =
  { menu : Ui.DrawerMenu.Model
  }


type Msg
  = Menu Ui.DrawerMenu.Msg
  | Close
  | Open

init : () -> Model
init _ =
  { menu = Ui.DrawerMenu.init }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Menu msg ->
      ( { model | menu = Ui.DrawerMenu.update msg model.menu }, Cmd.none )

    Open ->
      ( { model | menu = Ui.DrawerMenu.open model.menu }, Cmd.none )

    Close ->
      ( { model | menu = Ui.DrawerMenu.close model.menu }, Cmd.none )


view : Model -> Html.Html Msg
view model =
  div
    [ ]
    [ Ui.DrawerMenu.view
      { address = Menu
      , contents =
        [ Ui.DrawerMenu.title "Menu"
        , Ui.DrawerMenu.item
          { contents = [ text "Calendar" ]
          , target = Nothing
          , msg = Just Close
          , url = Nothing
          , icon = Just (Ui.Icons.calendar [])
          }
        , Ui.DrawerMenu.devider
        , Ui.DrawerMenu.item
          { contents = [ text "Work board" ]
          , target = Nothing
          , msg = Just Close
          , url = Nothing
          , icon = Nothing
          }
        , Ui.DrawerMenu.item
          { contents = [ text "Designs" ]
          , target = Nothing
          , msg = Just Close
          , url = Nothing
          , icon = Nothing
          }
        , Ui.DrawerMenu.devider
        ]
      }
      model.menu
    , button [ onClick Open ] [ text "Open" ]
    ]


specs : Node
specs =
  describe "Ui.DrawerMenu"
    [ ]

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
