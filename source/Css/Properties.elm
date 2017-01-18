module Css.Properties exposing (..)

import Css exposing (Node, property)

type alias Transition =
  { easing : String
  , duration : String
  , property : String
  , delay : String
  }

type alias BoxShadow =
  { x : String
  , y : String
  , blur : String
  , spread : String
  , color : String
  , inset : Bool
  }

zero : String
zero =
  "0"

(.) : String -> String -> String
(.) a b = a ++ " " ++ b

ms : Int -> String
ms value =
  (toString value) ++ "ms"

pct : Int -> String
pct value =
  (toString value) ++ "%"

px : Int -> String
px value =
  (toString value) ++ "px"

em : Float -> String
em value =
  (toString value) ++ "em"

-- Values

absolute : String
absolute =
  "absolute"

relative : String
relative =
  "relative"

fixed : String
fixed =
  "fixed"

hidden : String
hidden =
  "hidden"

none : String
none =
  "none"

visible : String
visible =
  "visible"

ellipsis : String
ellipsis =
  "ellipsis"

nowrap : String
nowrap =
  "nowrap"

center : String
center =
  "center"

solid : String
solid =
  "solid"

inlineFlex : String
inlineFlex =
  "inline-flex"

inlineBlock : String
inlineBlock =
  "inline-block"

flexDisplay : String
flexDisplay =
  "flex"

pointer : String
pointer =
  "pointer"

borderBox : String
borderBox =
  "border-box"

column : String
column =
  "column"

row : String
row =
  "row"

flexStart : String
flexStart =
  "flex-start"

flexEnd : String
flexEnd =
  "flex-end"

spaceBetween : String
spaceBetween =
  "space-between"

spaceAround : String
spaceAround =
  "space-around"

-- Properties

flexDirection : String -> Node
flexDirection =
  property "flex-direction"

backgroundColor : String -> Node
backgroundColor =
  property "background-color"

boxSizing : String -> Node
boxSizing =
  property "box-sizing"

outline : String -> Node
outline =
  property "outline"

border : String -> Node
border =
  property "border"

borderRadius : String -> Node
borderRadius =
  property "border-radius"

fontWeight : Int -> Node
fontWeight =
  toString >> (property "font-weight")

fontSize : String -> Node
fontSize =
  property "font-size"

cursor : String -> Node
cursor =
  property "cursor"

padding : String -> Node
padding =
  property "padding"

margin : String -> Node
margin =
  property "margin"

marginTop : String -> Node
marginTop =
  property "margin-top"

marginLeft : String -> Node
marginLeft =
  property "margin-left"

fontFamily : String -> Node
fontFamily =
  property "font-family"

zIndex : Int -> Node
zIndex value =
  property "z-index" (toString value)

color : String -> Node
color =
  property "color"

overflow : String -> Node
overflow =
  property "overflow"

position : String -> Node
position =
  property "position"

display : String -> Node
display =
  property "display"

alignItems : String -> Node
alignItems =
  property "align-items"

justifyContent : String -> Node
justifyContent =
  property "justify-content"

textAlign : String -> Node
textAlign =
  property "text-align"

pointerEvents : String -> Node
pointerEvents =
  property "pointer-events"

textOverflow : String -> Node
textOverflow =
  property "text-overflow"

whiteSpace : String -> Node
whiteSpace =
  property "white-space"

left : String -> Node
left =
  property "left"

top : String -> Node
top =
  property "top"

bottom : String -> Node
bottom =
  property "bottom"

right : String -> Node
right =
  property "right"

height : String -> Node
height =
  property "height"

width : String -> Node
width =
  property "width"

userSelect : String -> Node
userSelect value =
  Css.mixin
    [ property "-webkit-user-select" value
    , property "-moz-user-select" value
    , property "-ms-user-select" value
    , property "user-select" value
    ]

type Transform
  = Scale Float

scale : Float -> Transform
scale =
  Scale

transformOrigin : String -> String -> Node
transformOrigin top left =
  property "transform-origin" (top ++ " " ++ left)

transform : List Transform -> Node
transform transforms =
  let
    render item =
      case item of
        Scale value -> "scale(" ++ (toString value) ++ ")"

    value =
      List.map render transforms
        |> String.join " "
  in
    property "transform" value

opacity : Float -> Node
opacity value =
  property "opacity" (toString value)

boxShadow : List BoxShadow -> Node
boxShadow shadows =
  let
    render item =
      [ item.x
      , item.y
      , item.blur
      , item.spread
      , item.color
      , if item.inset then "inset" else ""
      ]
        |> String.join " "

    value =
      List.map render shadows
        |> String.join ", "
  in
    property "box-shadow" value

transition : List Transition -> Node
transition transitions =
  let
    render item =
      [ item.property
      , item.duration
      , item.delay
      , item.easing
      ]
        |> String.join " "

    value =
      List.map render transitions
        |> String.join ", "
  in
    property "transition" value
