module Ui.Styles exposing (Style, apply, embed, embedSome, embedDefault, attributes)

{-| This module contains the styles for all components.

@docs Style, apply, embed, embedSome, embedDefault, attributes
-}

import Css.Properties exposing (..)
import Css exposing (..)

import Html.Attributes exposing (attribute)
import Html
import Set

import Ui.Styles.Theme exposing (Theme, default)

import Task exposing (Task)
import Native.Styles

import Lazy exposing (Lazy)
import Json.Encode as Json
import Murmur3

{-|-}
type alias Style =
  Lazy
    { id : Int
    , value : String
    }

{-|-}
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

{-| Attributes for styles.
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

{-| Renders the styles for the given components into a HTML tag.
-}
embedSome : List (Theme -> Node) -> Theme -> Html.Html msg
embedSome nodes theme =
  Css.embed (List.map (\fn -> fn theme) nodes)


{-| Renders the stylesheet with the default theme into an HTML tag.
-}
embedDefault : Html.Html msg
embedDefault =
  embed default

{-| Renders the stylesheet with the given theme into an HTML tag.
-}
embed : Theme -> Html.Html msg
embed theme =
  Css.embed
    [
    ]
