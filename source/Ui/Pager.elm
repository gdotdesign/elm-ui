module Ui.Pager exposing (Model, Msg, init, update, view, render, select)

{-| Pager Component.

# Model
@docs Model, Msg, init, update

# View
@docs view, render

# Functions
@docs select
-}

import Html.Attributes exposing (style, classList, property)
import Html.Events.Extra exposing (onTransitionEnd)
import Html exposing (node)
import Html.Lazy

import Json.Decode as Json
import Json.Encode as JE


{-| Representation of a pager:
  - **center** - Pages at the center
  - **left** - Pages at the left side
  - **height** - The height of the pager
  - **width** - The width of the pager
  - **active** - The active page
-}
type alias Model =
  { center : List Int
  , left : List Int
  , height : String
  , width : String
  , active : Int
  }


{-| Messages that a pager can receive.
-}
type Msg
  = Active Int
  | End Int


{-| Initailizes a pager with the given page as active.

    pager = Ui.Pager.init 0
-}
init : Int -> Model
init active =
  { height = "100vh"
  , width = "100vw"
  , active = active
  , center = []
  , left = []
  }


{-| Updates a pager.

    Ui.Pager.update msg pager
-}
update : Msg -> Model -> Model
update action model =
  case action of
    End page ->
      { model | left = [] }

    Active page ->
      { model | center = [], active = page }


{-| Lazily renders a pager.

    Ui.Pager.view Pager pages pager
-}
view : (Msg -> msg) -> List (Html.Html msg) -> Model -> Html.Html msg
view address pages model =
  Html.Lazy.lazy3 render address pages model


{-| Renders a pager.

    Ui.Pager.render Pager pages pager
-}
render : (Msg -> msg) -> List (Html.Html msg) -> Model -> Html.Html msg
render address pages model =
  let
    renderPage index page =
      let
        decoder msg =
          Json.at [ "target", "_page" ] (Json.succeed msg)

        attributes =
          if List.member index model.left then
            [ classList [ ( "animating", True ) ]
            , style [ ( "left", "-100%" ) ]
            , onTransitionEnd (decoder (address (End index)))
            ]
          else if List.member index model.center then
            [ style [ ( "left", "0%" ) ]
            , classList [ ( "animating", True ) ]
            , onTransitionEnd (decoder (address (Active index)))
            ]
          else if index == model.active then
            [ style [ ( "left", "0%" ) ]
            ]
          else
            [ style [ ( "left", "100%" ), ( "visibility", "hidden" ) ]
            ]
      in
        node "ui-page" ((property "_page" (JE.string (toString index))) :: attributes) [ page ]
  in
    node
      "ui-pager"
      [ style
          [ ( "width", model.width )
          , ( "height", model.height )
          ]
      ]
      (List.indexedMap renderPage pages)


{-| Selects the page with the given index.

    Ui.Pager.select 0 pager -- Selects the first page
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
      { model | left = [ model.active ], center = [ page ] }
    else
      model
