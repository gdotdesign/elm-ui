module Ui.Modal exposing
  ( Model, ViewModel, Msg, init, update, view, render, open, close, closable
  , backdrop )

{-| Modal dialog.

# Model
@docs Model, Msg, init, update

# DSL
@docs closable, backdrop

# View
@docs ViewModel, view, render

# Functions
@docs open, close
-}

import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import Ui.Icons
import Ui

import Ui.Styles.Modal exposing (defaultStyle)
import Ui.Styles

{-| Representation of a modal:
  - **closable** - Whether or not the modal is closable
  - **backdrop** - Whether or not to show a backdrop
  - **open** - Whether or not the modal is open
-}
type alias Model =
  { closable : Bool
  , backdrop : Bool
  , open : Bool
  }


{-| Representation of the view model for a view:
  - **contents** - The elements to display in the body
  - **footer** - The elements to display in the footer
  - **title** - The title of the modal
-}
type alias ViewModel msg =
  { contents : List (Html.Html msg)
  , footer : List (Html.Html msg)
  , address : (Msg -> msg)
  , title : String
  }


{-| Messages that a modal can receive.
-}
type Msg
  = Close


{-| Initializes the a modal.

    model = Ui.Modal.init
-}
init : Model
init =
  { closable = True
  , backdrop = True
  , open = False
  }


{-| Sets whether or not the modal is closable.
-}
closable : Bool -> Model -> Model
closable value model =
  { model | closable = value }


{-| Sets wheter or not the model has a backdrop.
-}
backdrop : Bool -> Model -> Model
backdrop value model =
  { model | backdrop = value }


{-| Updates a modal window.

    updatedModal = Ui.Modal.update msg modal
-}
update : Msg -> Model -> Model
update action model =
  case action of
    Close ->
      close model


{-| Lazily renders a modal with the given view model.

    Ui.Modal.view viewModel modal
-}
view : ViewModel msg -> Model -> Html.Html msg
view viewModel model =
  Html.Lazy.lazy2 render viewModel model


{-| Renders a modal with the given view model.

    Ui.Modal.render viewModel modal
-}
render : ViewModel msg -> Model -> Html.Html msg
render viewModel model =
  let
    backdrop =
      [ node "ui-modal-backdrop" closeAction [] ]

    closeEvent =
      onClick (viewModel.address Close)

    closeAction =
      if model.closable && model.backdrop then
        [ closeEvent ]
      else
        []

    closeIcon =
      if model.closable then
        [ Ui.Icons.close [ closeEvent ] ]
      else
        []
  in
    node
      "ui-modal"
      ( [ Ui.attributeList [ ( "open", model.open ) ]
        , Ui.Styles.apply defaultStyle
        ]
        |> List.concat
      )
      ([ node "ui-modal-wrapper" []
        [ node "ui-modal-header"[]
          ([ node "ui-modal-title" [] [ text viewModel.title ] ] ++ closeIcon)
        , node "ui-modal-content" [] viewModel.contents
        , node "ui-modal-footer" [] viewModel.footer
        ]
       ] ++ (if model.backdrop then backdrop else [] ))


{-| Closes a modal window.

    updatedModal = Ui.Modal.close modal
-}
close : Model -> Model
close model =
  { model | open = False }


{-| Opens a modal window.

    updatedModal = Ui.Modal.open modal
-}
open : Model -> Model
open model =
  { model | open = True }
