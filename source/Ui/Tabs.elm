module Ui.Tabs (Model, Action, init, update, view) where

{-| A component for tabbed content.

# Model
@docs Model, Action, init, update, view
-}
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick)
import Html.Extra exposing (onKeys)
import Html exposing (node, text)
import Html.Lazy

import List.Extra
import Effects

import Ui

{-| Representation of a tabs component:
  - **readonly** - Whether or not the component is readonly
  - **disabled** - Whether or not the component is disabled
  - **selected** - The currently selected tabs index
-}
type alias Model =
  { selected : Int
  , readonly : Bool
  , disabled : Bool
  }

{-| Actions that a tabs component can make. -}
type Action
  = Select Int

{-| Initializes a tabs component with the index of the selected tab. -}
init : Int -> Model
init selected =
  { selected = selected
  , readonly = False
  , disabled = False
  }

{-| Updates a tabs component. -}
update: Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Select page ->
      ({ model | selected = page }, Effects.none)

{-| Renders a tabs component. -}
view: List (String, Html.Html) -> Signal.Address Action -> Model -> Html.Html
view contents address model =
  Html.Lazy.lazy3 render contents address model

{-| Renders a tabs component. -}
render: List (String, Html.Html) -> Signal.Address Action -> Model -> Html.Html
render contents address model =
  let
    activeTab =
      List.Extra.getAt contents model.selected
      |> Maybe.map snd
      |> Maybe.withDefault (text "")
  in
    node "ui-tabs" [ classList [ ("disabled", model.disabled)
                               , ("readonly", model.readonly)
                               ]
                   ]
      [ node "ui-tab-handles" [] (List.indexedMap (renderTabHandle address model) contents)
      , node "ui-tabs-content" [] [ activeTab ]
      ]

{-| Renders a tab handle. -}
renderTabHandle : Signal.Address Action -> Model -> Int -> (String, Html.Html) -> Html.Html
renderTabHandle address model index (title, contents) =
  let
    action = Select index
  in
    node "ui-tab-handle"
      ([ classList [("selected", index == model.selected)]] ++
        (Ui.enabledActions model [ onClick address action
                                 , onKeys address [ (13, action)
                                                  , (32, action)
                                                  ]]) ++
        (Ui.tabIndex model))
      [ text title ]
