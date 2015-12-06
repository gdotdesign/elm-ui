module Ui.Input where

{-| Component for text based input.

# Model
@docs Model, Action, init, update

# View
@docs view
-}
import Html.Attributes exposing (value, spellcheck, placeholder, type')
import Html.Extra exposing (onInput)
import Html exposing (node)
import String

{-| Representation of an input:
  - **placeholder** - The text to display when there is no value
  - **value** - The value
  - **kind** - The type of the input
-}
type alias Model =
  { placeholder : String
  , value : String
  , kind : String
  }

{-| Actions that an input can make:
  - **input** - Updates the value after an input event
-}
type Action
  = Input String

{-| Initializes an input.

    Ui.Input.init "value"
-}
init : String -> Model
init value =
  { placeholder = ""
  , value = value
  , kind = "text"
  }

{-| Updates an input. -}
update : Action -> Model -> Model
update action model =
  case action of
    Input value ->
      { model | value = value }

{-| Renders an input. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  node "input" [ placeholder model.placeholder
               , onInput address Input
               , value model.value
               , spellcheck False
               , type' model.kind
               ]
               []

