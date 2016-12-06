module Ui.Tabs exposing (Model, Msg, init, update, render, view)

{-| A component for tabbed content.

# Model
@docs Model, Msg, init, update

# View
@docs view, render
-}

import Html.Attributes exposing (classList)
import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import List.Extra

import Ui


{-| Representation of a tabs component:
  - **readonly** - Whether or not the component is readonly
  - **disabled** - Whether or not the component is disabled
  - **selected** - The currently selected tabs index
-}
type alias Model =
  { readonly : Bool
  , disabled : Bool
  , selected : Int
  }


{-| Messages that a tabs component can receive.
-}
type Msg
  = Select Int


{-| Initializes a tabs component with the index of the selected tab.

    tabs = Ui.Tabs.init 0
-}
init : Int -> Model
init selected =
  { selected = selected
  , readonly = False
  , disabled = False
  }


{-| Updates a tabs component.

    Ui.Tabs.update msg tabs
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Select page ->
      ( { model | selected = page }, Cmd.none )


{-| Lazily renders a tabs component.

    Ui.Tabs.render
      [("title", content), ("title", content)]
      Tabs
      tabs
-}
view :
  List ( String, Html.Html msg )
  -> (Msg -> msg)
  -> Model
  -> Html.Html msg
view contents address model =
  Html.Lazy.lazy3 render contents address model


{-| Renders a tabs component.

    Ui.Tabs.render
      [("title", content), ("title", content)]
      Tabs
      tabs
-}
render :
  List ( String, Html.Html msg )
  -> (Msg -> msg)
  -> Model
  -> Html.Html msg
render contents address model =
  let
    tabs =
      List.indexedMap
        (renderTabHandle address model)
        contents

    activeTab =
      List.Extra.getAt model.selected contents
        |> Maybe.map Tuple.second
        |> Maybe.withDefault (text "")
  in
    node
      "ui-tabs"
      [ classList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
      ]
      [ node "ui-tab-handles" [] tabs
      , node "ui-tabs-content" [] [ activeTab ]
      ]



----------------------------------- PRIVATE ------------------------------------


{-| Renders a tab handle.
-}
renderTabHandle : (Msg -> msg) -> Model -> Int -> ( String, Html.Html msg ) -> Html.Html msg
renderTabHandle address model index ( title, contents ) =
  let
    action =
      Select index
  in
    node
      "ui-tab-handle"
      ([ classList [ ( "selected", index == model.selected ) ] ]
        ++ (Ui.enabledActions
              model
              [ onClick (address action)
              , onKeys True
                  [ ( 13, address action )
                  , ( 32, address action )
                  ]
              ]
           )
        ++ (Ui.tabIndex model)
      )
      [ node "span" [] [ text title ] ]
