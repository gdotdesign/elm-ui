module Ui.Tabs exposing (ViewModel, Model, Msg, init, update, render, view)

{-| A component for tabbed content.

# Model
@docs Model, Msg, init, update

# View
@docs ViewModel, view, render
-}

import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)
import Html.Lazy

import List.Extra

import Ui.Styles.Tabs exposing (defaultStyle)
import Ui.Styles
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


{-| Representation of a tabs component view model:
  - **contents** - The list of contents for the tabs
  - **address** - The address
-}
type alias ViewModel msg =
  { contents : List ( String, Html.Html msg )
  , address : (Msg -> msg)
  }


{-| Messages that a tabs component can receive.
-}
type Msg
  = Select Int


{-| Initializes a tabs component with the index of the selected tab.

    tabs = Ui.Tabs.init ()
-}
init : () -> Model
init _ =
  { readonly = False
  , disabled = False
  , selected = 0
  }


{-| Updates a tabs component.

    ( updatedTabs, cmd ) = Ui.Tabs.update msg tabs
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Select page ->
      ( { model | selected = page }, Cmd.none )


{-| Lazily renders a tabs component.

    Ui.Tabs.render
      { contents =
        [ ("Tab 1", tab1Contents)
        , ("title", tab2Contents)
        ]
      , address Tabs
      }
      tabs
-}
view : ViewModel msg -> Model -> Html.Html msg
view viewModel model =
  Html.Lazy.lazy2 render viewModel model


{-| Renders a tabs component.

    Ui.Tabs.render
      { contents =
        [ ("Tab 1", tab1Contents)
        , ("title", tab2Contents)
        ]
      , address Tabs
      }
      tabs
-}
render : ViewModel msg -> Model -> Html.Html msg
render { contents, address } model =
  let
    tabs =
      List.indexedMap
        (renderTabHandle address model)
        contents

    activeTab =
      contents
        |> List.Extra.getAt model.selected
        |> Maybe.map Tuple.second
        |> Maybe.withDefault (text "")
  in
    node
      "ui-tabs"
      ( [ Ui.attributeList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
        , Ui.Styles.apply defaultStyle
        ]
        |> List.concat
      )
      [ node "ui-tabs-handles" [] tabs
      , node "ui-tabs-content" [] [ activeTab ]
      ]


{-| Renders a tab handle.
-}
renderTabHandle : (Msg -> msg) -> Model -> Int -> ( String, Html.Html msg ) -> Html.Html msg
renderTabHandle address model index ( title, contents ) =
  let
    action =
      Select index
  in
    node
      "ui-tabs-handle"
      ( (Ui.attributeList [ ( "selected", index == model.selected ) ])
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
