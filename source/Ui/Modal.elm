module Ui.Modal
  (Model, ViewModel, Action, init, view, update, close, open) where

{-| Modal dialog.

# Model
@docs Model, Action, init, update

# View
@docs ViewModel, view

# Functions
@docs open, close
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import Ui

{-| Representation of a modal window:
  - **backdrop** - Whether or not to show a backdrop
  - **open** - Whether or not the modal is open
  - **title** - The title of the modal
  - **closeable** - Whether or not the modal is closeable by clicking on the
    backdrop or the close button.
-}
type alias Model =
  { closeable : Bool
  , backdrop : Bool
  , title : String
  , open : Bool
  }

{-| View model for the view. -}
type alias ViewModel =
  { content : List Html.Html
  , footer : List Html.Html
  }

{-| Actions that a modal window can make. -}
type Action
  = Close

{-| Initializes the a modal with the given title.

    Modal.init "Test Modal"
-}
init : String -> Model
init title =
  { closeable = True
  , backdrop = True
  , title = title
  , open = False
  }

{-| Renders a modal window. -}
view: Signal.Address Action -> ViewModel -> Model -> Html.Html
view address viewModel model =
  Html.Lazy.lazy3 render address viewModel model

{-| Updates a modal window. -}
update: Action -> Model -> Model
update action model =
  case action of
    Close ->
      close model

{-| Closes a modal window. -}
close : Model -> Model
close model =
  { model | open = False }

{-| Opens a modal window. -}
open : Model -> Model
open model =
  { model | open = True }

-- Render internal
render: Signal.Address Action -> ViewModel -> Model -> Html.Html
render address viewModel model =
  let
    backdrop =
      [node "ui-modal-backdrop" closeAction []]

    closeAction =
      if model.closeable && model.backdrop then
        [onClick address Close]
      else []

    closeIcon =
      if model.closeable then
        [Ui.icon "close" True [onClick address Close]]
      else []
  in
    node "ui-modal" [classList [("ui-modal-open", model.open)]]
      ([ node "ui-modal-wrapper" []
        [ node "ui-modal-header" []
            ([ node "ui-modal-title" [] [text model.title]] ++ closeIcon)
        , node "ui-modal-content" [] viewModel.content
        , node "ui-modal-footer" [] viewModel.footer
        ]
      ] ++ (if model.backdrop then backdrop else []))
