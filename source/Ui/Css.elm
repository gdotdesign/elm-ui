module Ui.Css exposing (..)

import Html exposing (text)
import Regex
import List.Extra
import Dict

type Node
  = SelectorNode { name: String, nodes: List Node}
  | PropertyNode String String
  | SelectorsNode (List { name: String, nodes: List Node})
  | KeyFrames String (List (String, List Node))
  | Mixin (List Node)


keyframes : String -> List (String, List Node) -> Node
keyframes =
  KeyFrames

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
property =
  PropertyNode


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

      SelectorNode item ->
        List.map getProperty item.nodes
        |> List.foldr (++) []

      PropertyNode key value ->
        [(key, value)]

      _ ->
        []


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
    KeyFrames _ _ ->
      selectors

    Mixin nodes ->
      selectors

    PropertyNode key value ->
      selectors

    SelectorsNode subs ->
      List.map SelectorNode subs
      |> List.map (flatten [])
      |> List.foldr (++) selectors

    SelectorNode selector ->
      let
        mixinNodes nodes =
          List.map (\item ->
            case item of
              Mixin nodes ->
                nodes ++ (mixinNodes nodes)
              _ -> [item])
          nodes
          |> List.foldr (++) []

        mxNodes =
          mixinNodes selector.nodes

        subSelectors =
          String.split "," selector.name

        otherSelectors =
          mxNodes
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
            , properties = properties (SelectorNode { name = selector.name, nodes = mxNodes }) }]
        , otherSelectors
        , selectors
        ]
        |> List.concat

getKeyFrames : List Node -> String
getKeyFrames nodes =
  let
    getFrame node =
      case node of
        KeyFrames name data -> [(name, data)]
        SelectorNode nd -> frames nd.nodes
        SelectorsNode nd ->
          List.map (.nodes >> frames) nd
          |> List.foldr (++) []
        Mixin nds -> frames nds
        PropertyNode _ _ -> []

    frames nds =
      List.map getFrame nds
        |> List.foldr (++) []

    allKeyframes = frames nodes

    renderBody (step, properties) =
      let
        prop nd =
          case nd of
            PropertyNode key value -> [(key, value)]
            _ -> []

        props =
          List.map prop properties
          |> List.foldr (++) []
      in
        step ++ "{\n" ++ (renderProperties props) ++ "\n}"

    renderKeyframe (name, body) =
      let
        renderedBody =
          List.map renderBody body
          |> String.join "\n"
      in
        "@keyframes " ++ name ++ " {\n"
        ++ (renderedBody) ++ "\n}"
  in
    List.map renderKeyframe allKeyframes
    |> String.join "\n"

resolve : List Node -> String
resolve nodes =
  let
    keyframes =
      getKeyFrames nodes

    flattened =
      List.map (flatten []) nodes
      |> List.foldr (++) []
  in
    (keyframes ++ "\n\n" ++ (render flattened))

embed : List Node -> Html.Html msg
embed nodes =
  Html.node "style" [ ] [ text (resolve nodes) ]

group : List { name: String, properties: List (String, String) } -> List { name: String, properties: List (String, String) }
group list =
  let
    fn item dict =
      let
        properties =
          Dict.get item.name dict
          |> Maybe.withDefault []
      in
        Dict.insert item.name (properties ++ item.properties) dict
  in
    List.foldr fn Dict.empty list
    |> Dict.toList
    |> List.map (\(key,value) -> { name = key, properties = value })

renderProperties properties  =
  properties
    |> List.Extra.uniqueBy Tuple.first
    |> List.map (\(key, value) -> "  " ++ key ++ ": " ++ value ++ ";")
    |> String.join("\n")

render : List { name: String, properties: List (String, String) } -> String
render selectors =
  let
    renderSelector selector =
      selector.name ++ " {\n" ++ (renderProperties selector.properties) ++ "\n}"
  in
    selectors
    |> group
    |> List.filter (.properties >> List.isEmpty >> not)
    |> List.map renderSelector
    |> String.join "\n"
