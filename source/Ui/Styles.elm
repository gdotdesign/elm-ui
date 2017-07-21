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
