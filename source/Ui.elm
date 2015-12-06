module Ui
  (icon, title, subTitle, panel, spacer, stylesheetLink, tabIndex) where

{-| UI Library for ELM!

# Static Components
@docs icon, title, subTitle, panel, spacer, stylesheetLink

# Helper Functions
@docs tabIndex
-}
import Html.Attributes exposing (classList, tabindex, rel, href)
import Html.Extra exposing (onLoad)
import Html exposing (node, text)

{-| An icon component from Ionicons. -}
icon : String -> Bool -> List Html.Attribute -> Html.Html
icon glyph clickable attributes =
  let
    classes =
      classList [ ("ion-" ++ glyph, True)
                , ("clickable", clickable)
                ]
  in
    node "ui-icon" ([classes] ++ attributes) []

{-| Renders a title component. -}
title : List Html.Attribute -> List Html.Html -> Html.Html
title attributes children =
  node "ui-title" attributes children

{-| Renders a subtitle component. -}
subTitle : List Html.Attribute -> List Html.Html -> Html.Html
subTitle attributes children =
  node "ui-subtitle" attributes children

{-| Renders a panel component. -}
panel : List Html.Attribute -> List Html.Html -> Html.Html
panel attributes children =
  node "ui-panel" attributes children

{-| Renders a link tag for a CSS Stylesheet. -}
stylesheetLink : String -> Signal.Address a -> a -> Html.Html
stylesheetLink path address action =
  node "link" [ rel "stylesheet"
              , href path
              , onLoad address action
              ] []

{-| Returns tabindex attribute for a generic model. -}
tabIndex : { a | disabled : Bool } -> List Html.Attribute
tabIndex model =
  if model.disabled then [] else [tabindex 0]

{-| Renders a spacer element. -}
spacer : Html.Html
spacer =
  node "ui-spacer" [] []
