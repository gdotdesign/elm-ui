module Ui.Pager exposing
  (Model, Msg, init, update, view, select)

-- where

{-| Pager Component.

# Model
@docs Model, Msg, init, update

# View
@docs view

# Functions
@docs select
-}
import Html.Attributes exposing (style, classList)
import Html.Extra exposing (onTransitionEnd)
import Html exposing (node)
import List.Extra

{-| Representation of a pager:
  - **left** (internal) - Pages at the left side
  - **center** (internal) - Pages at the center
  - **active** (internal) - The active page
  - **height** - The height of the pager
  - **width** - The width of the pager
-}
type alias Model =
  { center : List Int
  , left : List Int
  , height : String
  , width : String
  , active : Int
  }

{-| Actions that a pager can take. -}
type Msg
  = End Int
  | Active Int

{-| Initailizes a pager with the given page as active. -}
init : Int -> Model
init active =
  { height = "100vh"
  , width = "100vw"
  , active = active
  , center = []
  , left = []
  }

{-| Updates a pager. -}
update : Msg -> Model -> Model
update action model =
  case action of
    End page ->
      { model | left = [] }

    Active page ->
      { model | center = [], active = page }

{-| Renders a pager. -}
view : (Msg -> msg) -> List (Html.Html msg) -> Model -> Html.Html msg
view address pages model =
  render address pages model

-- Render internal
render : (Msg -> msg) -> List (Html.Html msg) -> Model -> Html.Html msg
render address pages model =
  let
    updatedPage page =
      let
        index = Maybe.withDefault -1 (List.Extra.elemIndex page pages)

        attributes =
          if List.member index model.left then
            [ classList [("animating", True)]
            , style [("left", "-100%")]
            , onTransitionEnd (address (End index))
            ]
          else if List.member index model.center then
            [ style [("left", "0%")]
            , classList [("animating", True)]
            , onTransitionEnd (address (Active index))
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

    select 0 pager -- Selects the first page
-}
select : Int -> Model -> Model
select page model =
  let
    canAnimate =
      model.left == [] && model.center == []

    isSamePage =
      model.active == page
  in
    if canAnimate && not isSamePage then
      { model | left = [model.active], center = [page] }
    else
      model
