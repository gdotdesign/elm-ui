module Ui.Styles exposing (Style, apply, attributes)

{-| This module contains functions to add styles to elements.

@docs Style, apply, attributes
-}
import Html.Attributes exposing (attribute)
import Html

import Css exposing (Node, resolve)
import Lazy exposing (Lazy)
import Json.Encode as Json
import Native.Styles
import Murmur3

{-| Representation of a style.
-}
type alias Style =
  Lazy
    { id : Int
    , value : String
    }


{-| Converts a style to use it in an element.
-}
apply : Style -> List (Html.Attribute msg)
apply style =
  Lazy.map
    (\{ id, value } ->
      let
        styles = Json.object
          [ ("id", Json.int id)
          , ("value", Json.string value)
          ]

      in
        [ Html.Attributes.property "__styles" styles
        , attribute "style-id" (toString id)
        ]
    )
    style
  |> Lazy.force


{-| Returns a style from a node.
-}
attributes : Node -> Style
attributes node =
  Lazy.lazy <| \() ->
    let
      id = Murmur3.hashString 0 (toString node)
    in
      { value =
          resolve [ Css.selector ("[style-id='" ++ (toString id) ++ "']") [ node ] ]
      , id = id
      }
