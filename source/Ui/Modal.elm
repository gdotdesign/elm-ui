module Ui.Modal exposing
  (Model, ViewModel, Msg, init, update, view, render, open, close)

{-| Modal dialog.

# Model
@docs Model, Msg, init, update

# View
@docs ViewModel, view, render

# Functions
@docs open, close
-}

-- where

import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Ui


{-| Representation of a modal:
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


{-| Representation of the view model for a view:
  - **content** - The elements to display in the body
  - **footer** - The elements to display in the footer
  - **title** - The title of the modal
-}
type alias ViewModel msg =
  { content : List (Html.Html msg)
  , footer : List (Html.Html msg)
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
  { closeable = True
  , backdrop = True
  , open = False
  }


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
view : (Msg -> msg) -> ViewModel msg -> Model -> Html.Html msg
view address viewModel model =
  render address viewModel model


{-| Renders a modal with the given view model.

    Ui.Modal.render Modal viewModel modal
-}
render : (Msg -> msg) -> ViewModel msg -> Model -> Html.Html msg
render address viewModel model =
  let
    backdrop =
      [ node "ui-modal-backdrop" closeAction [] ]

    closeAction =
      if model.closeable && model.backdrop then
        [ onClick (address Close) ]
      else
        []

    closeIcon =
      if model.closeable then
        [ Ui.icon "close" True [ onClick (address Close) ] ]
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
