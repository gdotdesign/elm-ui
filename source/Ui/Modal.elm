module Ui.Modal exposing
  ( Model, ViewModel, Msg, init, update, view, render, open, close, closable
  , backdrop)

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

import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy
import Ui


{-| Representation of a modal:
  - **closable** - Whether or not the modal is closable by clicking on the
    backdrop or the close button.
  - **backdrop** - Whether or not to show a backdrop
  - **open** - Whether or not the modal is open
-}
type alias Model =
  { closable : Bool
  , backdrop : Bool
  , open : Bool
  }


{-| Representation of the view model for a view:
  - **content** - The elements to display in the body
  - **footer** - The elements to display in the footer
  - **title** - The title of the modal
-}
type alias ViewModel msg =
  { content : List (Html.Html msg)
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

    Ui.Modal.update msg modal
-}
update : Msg -> Model -> Model
update action model =
  case action of
    Close ->
      close model


{-| Lazily renders a modal with the given view model.

    Ui.Modal.view Modal viewModel modal
-}
view : ViewModel msg -> Model -> Html.Html msg
view viewModel model =
  Html.Lazy.lazy2 render viewModel model


{-| Renders a modal with the given view model.

    Ui.Modal.render Modal viewModel modal
-}
render : ViewModel msg -> Model -> Html.Html msg
render viewModel model =
  let
    backdrop =
      [ node "ui-modal-backdrop" closeAction [] ]

    closeAction =
      if model.closable && model.backdrop then
        [ onClick (viewModel.address Close) ]
      else
        []

    closeIcon =
      if model.closable then
        [ Ui.icon "close" True [ onClick (viewModel.address Close) ] ]
      else
        []
  in
    node
      "ui-modal"
      [ classList [ ( "ui-modal-open", model.open ) ] ]
      ([ node
          "ui-modal-wrapper"
          []
          [ node
              "ui-modal-header"
              []
              ([ node "ui-modal-title" [] [ text viewModel.title ] ] ++ closeIcon)
          , node "ui-modal-content" [] viewModel.content
          , node "ui-modal-footer" [] viewModel.footer
          ]
       ]
        ++ (if model.backdrop then
              backdrop
            else
              []
           )
      )


{-| Closes a modal window.

    Ui.Modal.close modal
-}
close : Model -> Model
close model =
  { model | open = False }


{-| Opens a modal window.

    Ui.Modal.open modal
-}
open : Model -> Model
open model =
  { model | open = True }
