effect module Ui.Styles where { command = MyCmd } exposing (embed, embedSome, embedDefault, attributes)

{-| This module contains the styles for all components.

@docs embed, embedSome, embedDefault, attributes
-}

import Css.Properties exposing (..)
import Css exposing (..)

import Html.Attributes exposing (attribute)
import Html
import Set

import Ui.Styles.Theme exposing (Theme, default)

import Ui.Styles.ButtonGroup as ButtonGroup
import Ui.Styles.Container as Container
import Ui.Styles.Calendar as Calendar
import Ui.Styles.Checkbox as Checkbox
import Ui.Styles.Textarea as Textarea
import Ui.Styles.Button as Button
import Ui.Styles.Input as Input

import Task exposing (Task)
import Native.Styles

import Lazy exposing (Lazy)
import Json.Encode as Json
import Murmur3

type alias Style =
  { id : Int
  , value : String
  }

{-| Attributes for styles.
-}
attributes : Node -> Lazy (List (Html.Attribute msg))
attributes node =
  Lazy.lazy <| \() ->
    let
      value =
        resolve [ Css.selector ("[style-id='" ++ (toString id) ++ "']") [ node ] ]

      id = Murmur3.hashString 0 (toString node)

      styles =
        Json.object
          [ ("id", Json.int id)
          , ("value", Json.string value)
          ]
    in
      [ Html.Attributes.property "__styles" styles
      , attribute "style-id" (toString id)
      ]

-- Effect manager stuff

type MyCmd
  = Nothing

type alias State =
  {}

{-| Self Message type
-}
type Msg
  = Msg

init : Task Never State
init =
  Task.succeed {}

cmdMap : MyCmd -> MyCmd
cmdMap msg =
  Nothing

onEffects : Platform.Router msg Msg -> List (MyCmd msg) -> State -> Task Never State
onEffects router commands state =
  let
    _ = Native.Styles.patchStyles ()
  in
    Task.succeed state

onSelfMsg : Platform.Router msg Msg -> Msg -> State -> Task Never State
onSelfMsg router msg state =
  Task.succeed state

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
    [ ButtonGroup.style theme
    , Container.style theme
    , Calendar.style theme
    , Textarea.style theme
    , Checkbox.style theme
    , Button.style theme
    , Input.style theme
    ]
