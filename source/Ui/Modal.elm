module Ui.Modal exposing
  (Model, ViewModel, Msg, init, view, update, close, open)

-- where

{-| Modal dialog.

# Model
@docs Model, Msg, init, update

# View
@docs ViewModel, view

# Functions
@docs open, close
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html exposing (node, text)

import Ui

{-| Representation of a modal window:
  - **closeable** - Whether or not the modal is closeable by clicking on the
    backdrop or the close button.
  - **backdrop** - Whether or not to show a backdrop
  - **open** - Whether or not the modal is open
-}
type alias Model =
  { closeable : Bool
  , backdrop : Bool
  , open : Bool
  }

{-| View model for the view. -}
type alias ViewModel msg =
  { content : List (Html.Html msg)
  , footer : List (Html.Html msg)
  , title : String
  }

{-| Actions that a modal window can make. -}
type Msg
  = Close

{-| Initializes the a modal. -}
init : Model
init =
  { closeable = True
  , backdrop = True
  , open = False
  }

{-| Renders a modal window. -}
view: (Msg -> msg) -> ViewModel msg -> Model -> Html.Html msg
view address viewModel model =
  render address viewModel model

{-| Updates a modal window. -}
update: Msg -> Model -> Model
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
render: (Msg -> msg) -> ViewModel msg -> Model -> Html.Html msg
render address viewModel model =
  let
    backdrop =
      [node "ui-modal-backdrop" closeAction []]

    closeAction =
      if model.closeable && model.backdrop then
        [onClick (address Close)]
      else []

    closeIcon =
      if model.closeable then
        [Ui.icon "close" True [onClick (address Close)]]
      else []
  in
    node "ui-modal" [classList [("ui-modal-open", model.open)]]
      ([ node "ui-modal-wrapper" []
        [ node "ui-modal-header" []
            ([ node "ui-modal-title" [] [text viewModel.title]] ++ closeIcon)
        , node "ui-modal-content" [] viewModel.content
        , node "ui-modal-footer" [] viewModel.footer
        ]
      ] ++ (if model.backdrop then backdrop else []))
