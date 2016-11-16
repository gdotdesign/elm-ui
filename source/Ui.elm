module Ui exposing
  (icon, title, subTitle, panel, spacer, inputGroup, iconAttributes,
   stylesheetLink, tabIndex, fab, textBlock, enabledActions, breadcrumbs,
   scrolledPanel, link)

{-| UI Library for Elm!

# Static Components
@docs icon, title, subTitle, panel, spacer, stylesheetLink, inputGroup
@docs fab, textBlock, breadcrumbs, scrolledPanel, link

# Helper Functions
@docs tabIndex, enabledActions, iconAttributes
-}

import Html.Attributes exposing (classList, attribute, rel, href, class, tabindex, target)
import Html.Events.Extra exposing (onLoad, unobtrusiveClick, onKeys)
import Html.Events exposing (onClick)
import Html exposing (node, text)

import Maybe.Extra exposing (isJust)


{-| An icon component from Ionicons.

    Ui.icon "android-download" False [ onClick Download ]
-}
icon : String -> Bool -> List (Html.Attribute msg) -> Html.Html msg
icon glyph clickable attributes =
  node "ui-icon" (iconAttributes glyph clickable attributes) []


{-| Attributes for icons.

    Ui.iconAttributes "android-download" False [ onClick Download ]
-}
iconAttributes :
  String
  -> Bool
  -> List (Html.Attribute msg)
  -> List (Html.Attribute msg)
iconAttributes glyph clickable attributes =
  let
    classes =
      classList
        [ ( "ion-" ++ glyph, True )
        , ( "clickable", clickable )
        ]
  in
    classes :: attributes


{-| Renders a title component.

    Ui.title "Hulk smash!"
-}
title : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
title attributes children =
  node "ui-title" attributes children


{-| Renders a subtitle component.

    Ui.subtitle "The avengers"
-}
subTitle : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
subTitle attributes children =
  node "ui-subtitle" attributes children


{-| Renders a panel component.

    Ui.panel [] [ div [] [ text "This is a panel!" ] ]
-}
panel : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
panel attributes children =
  node "ui-panel" attributes children


{-| Renders an input group component.

    Ui.inputGroup
      "Password"
      [ Html.App.map Input (Ui.Input.view model.password) ]
-}
inputGroup : String -> Html.Html msg -> Html.Html msg
inputGroup label input =
  node
    "ui-input-group"
    []
    [ node "ui-input-group-label" [] [ Html.text label ]
    , input
    ]


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
  -- # TODO: Use Html.Attributes.tabindex when the issue is fixed
  if model.disabled then
    []
  else
    [ attribute "tabindex" "0" ]


{-| Retruns the given attributes unless the model is disabled or readonly, in
that case it returs an empty list. This is usefull when you only want to add
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


{-| Renders a spacer element.

    Ui.spacer
-}
spacer : Html.Html msg
spacer =
  node "ui-spacer" [] []


{-| Renders a floating action button.

    Ui.fab "[ onClick Open ]
-}
fab : String -> List (Html.Attribute msg) -> Html.Html msg
fab glyph attributes =
  node
    "ui-fab"
    attributes
    [ icon glyph False [] ]


{-| Renders a text block.

    Ui.text "Some long text here..."
-}
textBlock : String -> Html.Html msg
textBlock value =
  node "ui-text" [] [ Html.text value ]


{-| Renders breadcrumbs.

    Ui.breadcrumbs
      (text "|")
      [ ("Home", Just Home)
      , ("Posts", Just Posts)
      , ("Post", Just (Post 1))
      ]
-}
breadcrumbs : Html.Html msg -> List ( String, Maybe msg ) -> Html.Html msg
breadcrumbs separator items =
  let
    renderItem ( label, action_ ) =
      let
        attributes =
          case action_ of
            Just action ->
              [ onClick action
              , class "clickable"
              ]

            Nothing ->
              []
      in
        node
          "ui-breadcrumb"
          attributes
          [ node "span" [] [ text label ] ]
  in
    node
      "ui-breadcrumbs"
      []
      (List.map renderItem items
        |> List.intersperse separator
      )


{-| Renders a panel that have scrolling content.

    Ui.scrolledPanel [ text "Long scrollable text..." ]
-}
scrolledPanel : List (Html.Html msg) -> Html.Html msg
scrolledPanel contents =
  node
    "ui-scrolled-panel"
    []
    [ node "ui-scrolled-panel-wrapper" [] contents ]


{-| Non obtrusive link:
- Ctrl click doesn't trigger the message
- Mouse middle click doesn't tigger the message
- Enter or Space triggers the message
- Simple click triggers the message
-}
link : Maybe msg -> Maybe String -> String -> List (Html.Html msg) -> Html.Html msg
link msg url target_ =
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
          , onKeys
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
