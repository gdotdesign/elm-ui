module Css exposing (..)

import Html exposing (text)
import Regex

type Node
  = SelectorNode { name: String, nodes: List Node}
  | PropertyNode String String
  | SelectorsNode (List { name: String, nodes: List Node})
  | Mixin (List Node)

mixin : List Node -> Node
mixin nodes =
  Mixin nodes

selectors : List String -> List Node -> Node
selectors bases nodes =
  SelectorsNode (List.map (\base -> { name = base, nodes = nodes }) bases)

selector : String -> List Node -> Node
selector base nodes =
  SelectorNode { name = base, nodes = nodes }

property : String -> String -> Node
property key value =
  PropertyNode key value


properties : Node -> List (String, String)
properties node =
  let
    getProperty item =
      case item of
        PropertyNode key value -> [(key, value)]
        _ -> []
  in
    case node of
      Mixin props ->
        List.map getProperty props
        |> List.foldr (++) []

      SelectorsNode _ ->
        []

      SelectorNode item ->
        List.map getProperty item.nodes
        |> List.foldr (++) []

      PropertyNode key value ->
        [(key, value)]


substituteSelector selectors item =
  if String.contains "&" item.name then
    List.map
      (\selector ->
        SelectorNode { item
        | name = Regex.replace Regex.All (Regex.regex "\\&") (\_ -> selector) item.name
        }
      )
      selectors
  else
    List.map
      (\selector ->
        SelectorNode { item
        | name = selector ++ " " ++ item.name
        }
      )
      selectors

flatten : List { name: String, properties: List (String, String) }
        -> Node
        -> List { name: String, properties: List (String, String) }
flatten selectors node =
  case node of
    Mixin _ ->
      selectors

    PropertyNode key value ->
      selectors

    SelectorsNode subs ->
      List.map SelectorNode subs
      |> List.map (flatten [])
      |> List.foldr (++) selectors

    SelectorNode selector ->
      let
        mixinNodes =
          List.map (\item ->
            case item of
              Mixin nodes -> nodes
              _ -> [])
          selector.nodes
          |> List.foldr (++) []

        subSelectors =
          String.split "," selector.name
          |> Debug.log ""

        otherSelectors =
          (selector.nodes ++ mixinNodes)
          |> List.map subsSelector
          |> List.foldr (++) []
          |> List.map (flatten [])
          |> List.foldr (++) []

        subsSelector item_ =
          case item_ of
            SelectorsNode items ->
              List.map (substituteSelector subSelectors) items
              |> List.foldr (++) []

            SelectorNode item ->
              substituteSelector subSelectors item

            _ ->
              [ item_ ]
      in
        [ [ { name = selector.name
            , properties = properties (SelectorNode { name = selector.name, nodes = (selector.nodes ++ mixinNodes)}) }]
        , otherSelectors
        , selectors
        ]
        |> List.concat

embed : Node -> Html.Html msg
embed node =
  Html.node "style" [ ] [ text (render (flatten [] node)) ]


render : List { name: String, properties: List (String, String) } -> String
render selectors =
  let
    renderSelector selector =
      let
        body =
          List.map (\(key, value) -> "  " ++ key ++ ": " ++ value ++ ";") selector.properties
          |> String.join("\n")
      in
        selector.name ++ " {\n" ++ body ++ "\n}"
  in
    List.map renderSelector selectors
    |> String.join "\n"
