module Ui.Css.Properties exposing (..)

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

type alias Animation =
  { name : String
  , duration : String
  , easing : String
  , delay : String
  , iterationCount : String
  , direction : String
  , fillMode : String
  , playState : String
  }

property : String -> String -> (String, String)
property =
  (,)

zero : String
zero =
  "0"

(.) : String -> String -> String
(.) a b = a ++ " " ++ b

ms : Int -> String
ms value =
  (toString value) ++ "ms"

pct : Float -> String
pct value =
  (toString value) ++ "%"

px : Int -> String
px value =
  (toString value) ++ "px"

vh : Int -> String
vh value =
  (toString value) ++ "vh"

vw : Int -> String
vw value =
  (toString value) ++ "vw"

em : Float -> String
em value =
  (toString value) ++ "em"

-- Values

inherit : String
inherit =
  "inherit"

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

dashed : String
dashed =
  "dashed"

inlineFlex : String
inlineFlex =
  "inline-flex"

inlineBlock : String
inlineBlock =
  "inline-block"

flex : String
flex =
  "flex"

stretch : String
stretch =
  "stretch"

block : String
block =
  "block"

pointer : String
pointer =
  "pointer"

borderBox : String
borderBox =
  "border-box"

contentBox : String
contentBox =
  "content-box"

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

currentColor : String
currentColor =
  "currentColor"

transparent : String
transparent =
  "transparent"

wrap : String
wrap =
  "wrap"

preWrap : String
preWrap =
  "pre-wrap"

uppercase : String
uppercase =
  "uppercase"

normal : String
normal =
  "normal"

breakWord : String
breakWord =
  "break-word"

bold : String
bold =
  "bold"

rowResize : String
rowResize =
  "row-resize"

colResize : String
colResize =
  "col-resize"

auto : String
auto =
  "auto"

italic : String
italic =
  "italic"

scroll : String
scroll =
  "scroll"

-- Properties

textTransform : String -> (String, String)
textTransform =
  property "text-transform"

textDecoration : String -> (String, String)
textDecoration =
  property "text-decoration"

wordWrap : String -> (String, String)
wordWrap =
  property "word-wrap"

wordBreak : String -> (String, String)
wordBreak =
  property "word-break"

fill : String -> (String, String)
fill =
  property "fill"

flex_ : String -> (String, String)
flex_ =
  property "flex"

flexWrap : String -> (String, String)
flexWrap =
  property "flex-wrap"

alignSelf : String -> (String, String)
alignSelf =
  property "align-self"

lineHeight : String -> (String, String)
lineHeight =
  property "line-height"

flexDirection : String -> (String, String)
flexDirection =
  property "flex-direction"

backgroundColor : String -> (String, String)
backgroundColor =
  property "background-color"

backgroundSize : String -> (String, String)
backgroundSize =
  property "background-size"

background : String -> (String, String)
background =
  property "background"

backgroundClip : String -> (String, String)
backgroundClip =
  property "background-clip"

backgroundPositionX : String -> (String, String)
backgroundPositionX =
  property "background-position-x"

boxSizing : String -> (String, String)
boxSizing =
  property "box-sizing"

outline : String -> (String, String)
outline =
  property "outline"

important : String
important =
  "!important"

border : String -> (String, String)
border =
  property "border"

borderWidth : String -> (String, String)
borderWidth =
  property "border-width"

borderStyle : String -> (String, String)
borderStyle =
  property "border-style"

borderLeft : String -> (String, String)
borderLeft =
  property "border-left"

borderBottom : String -> (String, String)
borderBottom =
  property "border-bottom"

borderTop : String -> (String, String)
borderTop =
  property "border-top"

borderRight : String -> (String, String)
borderRight =
  property "border-right"

borderRightColor : String -> (String, String)
borderRightColor =
  property "border-right-color"

borderTopColor : String -> (String, String)
borderTopColor =
  property "border-top-color"

borderColor : String -> (String, String)
borderColor =
  property "border-color"

borderRadius : String -> (String, String)
borderRadius =
  property "border-radius"

fontWeight : String -> (String, String)
fontWeight =
  property "font-weight"

fontSize : String -> (String, String)
fontSize =
  property "font-size"

fontStyle : String -> (String, String)
fontStyle =
  property "font-style"

cursor : String -> (String, String)
cursor =
  property "cursor"

visibility : String -> (String, String)
visibility =
  property "visibility"

resize : String -> (String, String)
resize =
  property "resize"

content : String -> (String, String)
content value =
  property "content" value

contentString : String -> (String, String)
contentString value =
  property "content" ("\"" ++ value ++ "\"")

padding : String -> (String, String)
padding =
  property "padding"

paddingLeft : String -> (String, String)
paddingLeft =
  property "padding-left"

paddingTop : String -> (String, String)
paddingTop =
  property "padding-top"

paddingRight : String -> (String, String)
paddingRight =
  property "padding-right"

margin : String -> (String, String)
margin =
  property "margin"

marginTop : String -> (String, String)
marginTop =
  property "margin-top"

marginBottom : String -> (String, String)
marginBottom =
  property "margin-bottom"

marginLeft : String -> (String, String)
marginLeft =
  property "margin-left"

marginRight : String -> (String, String)
marginRight =
  property "margin-right"

fontFamily : String -> (String, String)
fontFamily =
  property "font-family"

zIndex : Int -> (String, String)
zIndex value =
  property "z-index" (toString value)

color : String -> (String, String)
color =
  property "color"

overflow : String -> (String, String)
overflow =
  property "overflow"

overflowY : String -> (String, String)
overflowY =
  property "overflow-y"

position : String -> (String, String)
position =
  property "position"

display : String -> (String, String)
display =
  property "display"

alignItems : String -> (String, String)
alignItems =
  property "align-items"

justifyContent : String -> (String, String)
justifyContent =
  property "justify-content"

textAlign : String -> (String, String)
textAlign =
  property "text-align"

pointerEvents : String -> (String, String)
pointerEvents =
  property "pointer-events"

textOverflow : String -> (String, String)
textOverflow =
  property "text-overflow"

whiteSpace : String -> (String, String)
whiteSpace =
  property "white-space"

left : String -> (String, String)
left =
  property "left"

top : String -> (String, String)
top =
  property "top"

bottom : String -> (String, String)
bottom =
  property "bottom"

right : String -> (String, String)
right =
  property "right"

height : String -> (String, String)
height =
  property "height"

width : String -> (String, String)
width =
  property "width"

minWidth : String -> (String, String)
minWidth =
  property "min-width"

minHeight : String -> (String, String)
minHeight =
  property "min-height"

maxHeight : String -> (String, String)
maxHeight =
  property "max-height"

maxWidth : String -> (String, String)
maxWidth =
  property "max-width"

userSelect : String -> List (String, String)
userSelect value =
  [ property "-webkit-user-select" value
  , property "-moz-user-select" value
  , property "-ms-user-select" value
  , property "user-select" value
  ]

type Transform
  = Scale Float
  | Rotate Float
  | TranslateX String
  | TranslateY String
  | Translate String String
  | Translate3D String String String

translate3d : String -> String -> String -> Transform
translate3d =
  Translate3D

translate : String -> String -> Transform
translate =
  Translate

translateX : String -> Transform
translateX =
  TranslateX

translateY : String -> Transform
translateY =
  TranslateY

scale : Float -> Transform
scale =
  Scale

rotate : Float -> Transform
rotate =
  Rotate

transformOrigin : String -> String -> (String, String)
transformOrigin top left =
  property "transform-origin" (top ++ " " ++ left)

transform : List Transform -> (String, String)
transform transforms =
  let
    render item =
      case item of
        Scale value -> "scale(" ++ (toString value) ++ ")"
        Rotate value -> "rotate(" ++ (toString value) ++ "deg)"
        Translate x y -> "translate(" ++ x ++ "," ++ y ++ ")"
        TranslateX x -> "translateX(" ++ x ++ ")"
        TranslateY y -> "translateY(" ++ y ++ ")"
        Translate3D x y z -> "translate3d(" ++ x ++ "," ++ y ++ "," ++ z ++ ")"

    value =
      List.map render transforms
        |> String.join " "
  in
    property "transform" value

opacity : Float -> (String, String)
opacity value =
  property "opacity" (toString value)

boxShadow : List BoxShadow -> (String, String)
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

animation : List Animation -> (String, String)
animation animations =
  let
    render item =
      [ item.name
      , item.duration
      , item.easing
      , item.delay
      , item.iterationCount
      , item.direction
      , item.fillMode
      , item.playState
      ]
        |> String.join " "

    value =
      List.map render animations
        |> String.join ", "
  in
    property "animation" value

transition : List Transition -> (String, String)
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
