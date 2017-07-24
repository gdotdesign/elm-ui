module Ui.Styles exposing (Style, apply, attributes)

{-| This module contains functions to add styles to elements.

@docs Style, apply, attributes
-}

import Html.Attributes exposing (attribute)
import Html

import Ui.Css exposing (Node, resolve)

import Json.Encode as Json
import Native.Styles
import Murmur3

{-| Representation of a style.
-}
type alias Style =
  { value : String
  , id : String
  }


{-| The default variables.
-}
variables : Node
variables =
  [ ("--font-family" ,"-apple-system, system-ui, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Arial, sans-serif")

  , ("--disabled-border-color", "#C7C7C7")
  , ("--border-color" ,"#DDD")
  , ("--border-radius" ,"2px")

  , ("--colors-disabled-background", "#D7D7D7")
  , ("--colors-disabled-text", "#9A9A9A")

  , ("--colors-primary-background", "#158DD8")
  , ("--colors-primary-text", "#FFF")

  , ("--colors-danger-background", "#E04141")
  , ("--colors-danger-text", "#FFF")

  , ("--colors-secondary-background", "#5D7889")
  , ("--colors-secondary-text", "#FFF")

  , ("--colors-success-background", "#4DC151")
  , ("--colors-success-text", "#FFF")

  , ("--colors-warning-background", "#FF9730")
  , ("--colors-warning-text", "#FFF")

  , ("--colors-focus-background", "#00C0FF")
  , ("--colors-focus-text", "#FFF")

  , ("--colors-input-secondary-background", "#F3F3F3")
  , ("--colors-input-secondary-text", "#616161")

  , ("--colors-input-background", "#FDFDFD")
  , ("--colors-input-text", "#606060")
  ]
  |> Native.Styles.setVariables


{-| Converts a style to use it in an element.
-}
apply : Style -> List (Html.Attribute msg)
apply { id, value } =
  let
    styles =
      Json.object
        [ ( "id", Json.string id )
        , ( "value", Json.string value )
        ]
  in
    [ Html.Attributes.property "__styles" styles
    ]


{-| Returns a style from a node.
-}
attributes : String -> Node -> Style
attributes id node =
  { value =
      resolve
        [ Ui.Css.selector id [ node ]
        ]
  , id = id
  }
