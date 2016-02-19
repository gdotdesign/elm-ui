module Ui
  (icon, title, subTitle, panel, spacer, inputGroup, iconAttributes,
   stylesheetLink, tabIndex, fab, textBlock, open, redirect, alert,
   enabledActions, breadcrumbs ) where

{-| UI Library for ELM!

# Static Components
@docs icon, title, subTitle, panel, spacer, stylesheetLink, inputGroup
@docs fab, textBlock, breadcrumbs

# Helper Functions
@docs tabIndex, open, redirect, alert, enabledActions, iconAttributes
-}
import Html.Attributes exposing (classList, tabindex, rel, href, class)
import Html.Events exposing (onClick)
import Html.Extra exposing (onLoad)
import Html exposing (node, text)

import Native.Browser

{-| An icon component from Ionicons. -}
icon : String -> Bool -> List Html.Attribute -> Html.Html
icon glyph clickable attributes =
  node "ui-icon" (iconAttributes glyph clickable attributes) []

{-| Attributes for icons. -}
iconAttributes : String -> Bool -> List Html.Attribute -> List Html.Attribute
iconAttributes glyph clickable attributes =
  let
    classes =
      classList [ ("ion-" ++ glyph, True)
                , ("clickable", clickable)
                ]
  in
    classes :: attributes

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

{-| Renders an input group component. -}
inputGroup : String -> Html.Html -> Html.Html
inputGroup label input =
  node "ui-input-group" []
    [ node "ui-input-group-label" [] [Html.text label]
    , input
    ]

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

{-| Retruns the given attributes unless the model is disabled or readonly, in
that case it returs an empty list. This is usefull when you only want to add
for example some event listeners when the component is not disabled or readonly.
-}
enabledActions : { a | disabled : Bool, readonly : Bool } -> List b -> List b
enabledActions model attributes =
  if model.disabled || model.readonly then [] else attributes

{-| Renders a spacer element. -}
spacer : Html.Html
spacer =
  node "ui-spacer" [] []

{-| Renders a floating action button. -}
fab : String -> List Html.Attribute -> Html.Html
fab glyph attributes =
  node "ui-fab" attributes
    [ icon glyph False []]

{-| Renders a text block. -}
textBlock : String -> Html.Html
textBlock value =
  node "ui-text" [] [Html.text value]

{-| Renders a breadcrumbs. -}
breadcrumbs : Signal.Address a -> Html.Html -> List (String, Maybe a) -> Html.Html
breadcrumbs address separator items =
  let
    renderItem (label, action') =
      let
        attributes =
          case action' of
            Just action -> [ onClick address action
                           , class "clickable"
                           ]
            Nothing -> []
      in
        node "ui-breadcrumb" attributes
          [node "span" [] [text label]]
  in
    node "ui-breadcrumbs" []
      (List.map renderItem items
      |> List.intersperse separator)

{-| Opens a link. -}
open : String -> a -> a
open url model =
  Native.Browser.open url model

{-| Replace the current page with the given url. -}
redirect : String -> a -> a
redirect url model =
  Native.Browser.redirect url model

{-| Shows an alert box. -}
alert : String -> a -> a
alert message model =
  Native.Browser.alert message model
