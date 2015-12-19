module Ui.Pager
  (Model, Action, init, update, view, select) where

{-| Pager Component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs select
-}
import Html.Attributes exposing (style, classList)
import Html.Extra exposing (onTransitionEnd)
import Html exposing (node)
import Html.Lazy
import List.Extra

{-| Representation of a pager.
  - **left** (internal) - Pages at the left side
  - **center** (internal) - Pages at the center
  - **active** (internal) - The active page
  - **width** - The width of the pager
  - **height** - The height of the pager
-}
type alias Model =
  { left : List Int
  , center : List Int
  , active : Int
  , width : String
  , height : String
  }

{-| Actions that a pager can take. -}
type Action
  = End Int
  | Active Int

{-| Initailizes a pager with the given page as active. -}
init : Int -> Model
init active =
  { left = []
  , center = []
  , active = active
  , width = "100vw"
  , height = "100vh"
  }

{-| Updates a pager. -}
update : Action -> Model -> Model
update action model =
  case action of
    End page ->
      { model | left = [] }
    Active page ->
      { model | center = [], active = page }

{-| Renders a pager. -}
view : Signal.Address Action -> List Html.Html -> Model -> Html.Html
view address pages model =
  Html.Lazy.lazy3 render address pages model

-- Render internal
render : Signal.Address Action -> List Html.Html -> Model -> Html.Html
render address pages model =
  let
    updatedPage page =
      let
        index = Maybe.withDefault -1 (List.Extra.elemIndex page pages)

        attributes =
          if List.member index model.left then
            [ classList [("animating", True)]
            , style [("left", "-100%")]
            , onTransitionEnd address (End index)
            ]
          else if List.member index model.center then
            [ style [("left", "0%")]
            , classList [("animating", True)]
            , onTransitionEnd address (Active index)
            ]
          else if index == model.active then
            [ style [("left", "0%")] ]
          else
            [ style [("left", "100%")] ]
      in
        node "ui-page" attributes [page]
  in
    node
      "ui-pager"
      [ style [ ("width", model.width)
              , ("height", model.height)
              ]
      ]
      (List.map updatedPage pages)

{-| Selects the page with the given index.

    {- Selects the first page. -}
    select 0 pager
-}
select : Int -> Model -> Model
select page model =
  if model.left == [] && model.center == [] then
    { model | left = [model.active], center = [page] }
  else
    model
