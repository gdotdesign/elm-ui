module Ui.Pager exposing
  (ViewModel, Model, Msg, init, update, view, render, select)

{-| Pager Component.

# Model
@docs Model, Msg, init, update

# View
@docs ViewModel, view, render

# Functions
@docs select
-}

import Html.Attributes exposing (style, attribute, property)
import Html.Events.Extra exposing (onTransitionEnd)
import Html exposing (node)
import Html.Lazy

import Json.Decode as Json
import Json.Encode as JE

import Ui.Styles.Pager exposing (defaultStyle)
import Ui.Styles

{-| Representation of a pager:
  - **center** - Pages at the center
  - **left** - Pages at the left side
  - **active** - The active page
-}
type alias Model =
  { center : List Int
  , left : List Int
  , active : Int
  }


{-| Representation of the view model of a pager.
  - **address** - The address for the messages
  - **pages** - The pages to display
-}
type alias ViewModel msg =
  { pages : List (Html.Html msg)
  , address : Msg -> msg
  }


{-| Messages that a pager can receive.
-}
type Msg
  = Active Int
  | End Int


{-| Initailizes a pager.

    pager = Ui.Pager.init ()
-}
init : () -> Model
init _ =
  { center = []
  , active = 0
  , left = []
  }


{-| Updates a pager.

    updatedPager = Ui.Pager.update msg pager
-}
update : Msg -> Model -> Model
update action model =
  case action of
    End page ->
      { model | left = [] }

    Active page ->
      { model | center = [], active = page }


{-| Lazily renders a pager.

    Ui.Pager.view
      { address = Pager
      , pages = pages
      }
      pager
-}
view : ViewModel msg -> Model -> Html.Html msg
view viewModel model =
  Html.Lazy.lazy2 render viewModel model


{-| Renders a pager.

    Ui.Pager.render
      { address = Pager
      , pages = pages
      }
      pager
-}
render : ViewModel msg -> Model -> Html.Html msg
render { address, pages } model =
  let
    renderPage index page =
      let
        decoder msg =
          Json.at [ "target", "_page" ] (Json.succeed msg)

        attributes =
          if List.member index model.left then
            [ onTransitionEnd (decoder (address (End index)))
            , style [ ( "left", "-100%" ) ]
            , attribute "animating" ""
            ]
          else if List.member index model.center then
            [ onTransitionEnd (decoder (address (Active index)))
            , style [ ( "left", "0%" ) ]
            , attribute "animating" ""
            ]
          else if index == model.active then
            [ style [ ( "left", "0%" ) ]
            ]
          else
            [ style
              [ ( "visibility", "hidden" )
              , ( "left", "100%" )
              ]
            ]
      in
        node "ui-page"
          ((property "_page" (JE.string (toString index))) :: attributes)
          [ page ]
  in
    node
      "ui-pager"
      (Ui.Styles.apply defaultStyle)
      (List.indexedMap renderPage pages)


{-| Selects the page with the given index.

    -- Selects the first page
    updatedPager = Ui.Pager.select 0 pager
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
