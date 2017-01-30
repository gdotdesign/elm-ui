module Ui.Link exposing (view)

{-| Non obtrusive link:
- Ctrl click doesn't trigger the message
- Mouse middle click doesn't tigger the message
- Enter or Space triggers the message
- Simple click triggers the message

@docs view
-}

import Html.Events.Extra exposing (unobtrusiveClick, onKeys)
import Html.Attributes exposing (href, tabindex, target)
import Html exposing (node)

import Maybe.Extra exposing (isJust)

{-| Renders a link.
-}
view : Maybe msg -> Maybe String -> String -> List (Html.Html msg) -> Html.Html msg
view msg url target_ =
  let
    tabIndex =
      if isJust msg || isJust url then
        [ tabindex 0 ]
      else
        []

    attributes =
      case msg of
        Just action ->
          [ unobtrusiveClick action
          , onKeys True
              [ ( 13, action )
              , ( 32, action )
              ]
          ]

        Nothing ->
          []

    hrefAttribute =
      case url of
        Just value ->
          [ href value
          , target target_
          ]

        Nothing ->
          []
  in
    node "a" (tabIndex ++ hrefAttribute ++ attributes)
