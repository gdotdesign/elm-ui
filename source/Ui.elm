module Ui exposing
  ( stylesheetLink, tabIndex, enabledActions, attributeList )

{-| This module provides utility functions for most of the components.

# Functions
@docs stylesheetLink, tabIndex, enabledActions, attributeList
-}

import Html.Attributes exposing (attribute, rel, href, tabindex)
import Html.Events.Extra exposing (onLoad)
import Html exposing (node)


{-| Renders a link tag for a CSS Stylesheet which triggers the given message
after it's loaded.

    Ui.stylesheetLink "http://some-css-file.css" Loaded
-}
stylesheetLink : String -> msg -> Html.Html msg
stylesheetLink path msg =
  node
    "link"
    [ rel "stylesheet"
    , href path
    , onLoad msg
    ]
    []


{-| Returns tabindex attribute for a generic model or an empty list if
disabled.

    Ui.tabIndex { disabled: False } -- [ tabindex 0 ]
    Ui.tabIndex { disabled: True } -- []
-}
tabIndex : { a | disabled : Bool } -> List (Html.Attribute msg)
tabIndex model =
  if model.disabled then
    []
  else
    [ attribute "tabindex" "0" ]


{-| Retruns the given attributes unless the model is disabled or readonly, in
that case it returns an empty list. This is useful when you only want to add
for example some event listeners when the component is not disabled or readonly.

    -- [ onClick Open ]
    Ui.enabledActions
      { disabeld: False, readonly: False }
      [ onClick Open ]

    -- []
    Ui.enabledActions
      { disabeld: False, readonly: True }
      [ onClick Open ]

    -- []
    Ui.enabledActions
      { disabeld: True, readonly: False }
      [ onClick Open ]
-}
enabledActions : { a | disabled : Bool, readonly : Bool } -> List b -> List b
enabledActions model attributes =
  if model.disabled || model.readonly then
    []
  else
    attributes


{-| Class list alternative for setting attributes.

    -- <div disabled>Hello</div>
    div (Ui.attributeList [ ( "disabled", True ) ]) [ text "Hello" ]
-}
attributeList : List ( String, Bool ) -> List (Html.Attribute msg)
attributeList items =
  let
    attr ( name, active ) =
      if active then
        [ attribute name "" ]
      else
        []
  in
    List.map attr items
      |> List.concat
