module Ui.Link exposing (Model, view)

{-| Non obtrusive link element:
- Mouse middle click doesn't tigger the message
- Ctrl click doesn't trigger the message
- Enter or Space triggers the message
- Simple click triggers the message

# Model
@docs Model

# View
@docs view
-}

import Html.Events.Extra exposing (unobtrusiveClick, onKeys)
import Html.Attributes exposing (href, tabindex, target)
import Html exposing (node)

import Maybe.Extra exposing (isJust)

{-| Representation of a link:
  - **contents** - The contents of the link, usually just text
  - **target** - The value for the target attribute
  - **url** - The value for the href attribute
  - **msg** - The message to trigger
-}
type alias Model msg =
  { contents : List (Html.Html msg)
  , target : Maybe String
  , url : Maybe String
  , msg : Maybe msg
  }


{-| Renders a link.
-}
view : Model msg -> Html.Html msg
view { msg, url, target, contents } =
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

    targetAttribute =
      case ( url, target ) of
        ( Just _, Just value ) ->
          [ Html.Attributes.target value
          ]

        _ ->
          []

    hrefAttribute =
      case url of
        Just value ->
          [ href value
          ]

        Nothing ->
          []
  in
    node "a"
      ( [ targetAttribute
        , hrefAttribute
        , attributes
        , tabIndex
        ]
        |> List.concat
      ) contents
