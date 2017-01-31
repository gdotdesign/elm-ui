module Ext.Color exposing (..)

{-| This module provides utility functions for colors and the ability to
convert colors to HSV format.

# Representations
@docs Hsv, Rgba

# Updating
@docs updateColor, setRed, setGreen, setBlue, setAlpha

# Converting
@docs hsvToRgb

# Rendering
@docs toCSSRgba

# Extracting
@docs toHsv

# Decoding / Encoding
@docs decodeHsv, encodeHsv
-}

import Ext.Number exposing (roundTo)

import Color exposing (Color)

import Json.Decode as JD
import Json.Encode as JE

{-| HSV color type.
-}
type alias Hsv =
  { saturation : Float
  , value : Float
  , alpha : Float
  , hue : Float
  }


{-| Rgba color type.
-}
type alias Rgba =
  { alpha : Float
  , green : Int
  , blue : Int
  , red : Int
  }


{-| Updates an Hsv color converting it to Rgb and then converting the result to
Color.
-}
updateColor : (Rgba -> Rgba) -> Hsv -> Color
updateColor function color =
  let
    currentColor =
      color
        |> hsvToRgb
        |> Color.toRgb

    updatedColor =
      function currentColor
  in
    Color.rgba
      updatedColor.red
      updatedColor.green
      updatedColor.blue
      updatedColor.alpha


{-| Converts a Hsv to Rgba and then sets the red value to the given value.
-}
setRed : Int -> Hsv -> Hsv
setRed value =
  updateColor (\c -> { c | red = clamp 0 255 value })
    >> toHsv


{-| Converts a Hsv to Rgba and then sets the green value to the given value.
-}
setGreen : Int -> Hsv -> Hsv
setGreen value =
  updateColor (\c -> { c | green = clamp 0 255 value })
    >> toHsv


{-| Converts a Hsv to Rgba and then sets the blue value to the given value.
-}
setBlue : Int -> Hsv -> Hsv
setBlue value =
  updateColor (\c -> { c | blue = clamp 0 255 value })
    >> toHsv


{-| Converts a Hsv to Rgba and then sets the alpha value to the given value.
-}
setAlpha : Float -> Hsv -> Hsv
setAlpha value =
  updateColor (\c -> { c | alpha = clamp 0 1 value })
    >> toHsv


{-| Decodes a HSV color type from a four element tuple.
-}
decodeHsv : JD.Decoder Hsv
decodeHsv =
  JD.map4
    (,,,)
    (JD.index 0 JD.float)
    (JD.index 1 JD.float)
    (JD.index 2 JD.float)
    (JD.index 3 JD.float)
    |> JD.map (\( sat, val, alpha, hue ) -> Hsv sat val alpha hue)


{-| Encodes a HSV color type to a four element tuple.
-}
encodeHsv : Hsv -> JE.Value
encodeHsv hsv =
  JE.list
    [ JE.float hsv.saturation
    , JE.float hsv.value
    , JE.float hsv.alpha
    , JE.float hsv.hue
    ]


{-| Renders the given HSV color to CSS string (rgba).

    Ext.Color.toCSSRgba blackHsv -- "rgba(0,0,0,1)"
-}
toCSSRgba : Hsv -> String
toCSSRgba hsv =
  let
    color =
      Color.toRgb (hsvToRgb hsv)
  in
    "rgba("
      ++ (toString color.red)
      ++ ","
      ++ (toString color.green)
      ++ ","
      ++ (toString color.blue)
      ++ ","
      ++ (toString (roundTo 2 color.alpha))
      ++ ")"


{-| Converts the given HSV color into Elm's color type (RGB).
-}
hsvToRgb : Hsv -> Color
hsvToRgb color =
  let
    saturation =
      color.saturation

    hue =
      color.hue * 360

    value =
      color.value

    c =
      value * saturation

    x =
      c * (1 - (abs ((Ext.Number.remFloat (hue / 60) 2) - 1)))

    m =
      value - c

    ( red, green, blue ) =
      if 0 <= hue && hue < 60 then
        ( c, x, 0 )
      else if 60 <= hue && hue < 120 then
        ( x, c, 0 )
      else if 120 <= hue && hue < 180 then
        ( 0, c, x )
      else if 180 <= hue && hue < 240 then
        ( 0, x, c )
      else if 240 <= hue && hue < 300 then
        ( x, 0, c )
      else
        ( c, 0, x )
  in
    Color.rgba
      (round ((red + m) * 255))
      (round ((green + m) * 255))
      (round ((blue + m) * 255))
      color.alpha



{-| Extract the components of a color in the HSV format.
-}
toHsv : Color -> Hsv
toHsv color =
  let
    fmod f n =
      let
        integer = floor f
      in
        toFloat (integer % n) + f - toFloat integer

    rgba =
      (Color.toRgb color)

    green =
      (toFloat rgba.green) / 255

    blue =
      (toFloat rgba.blue) / 255

    red =
      (toFloat rgba.red) / 255

    cmax =
      max green (max red blue)

    cmin =
      min green (min red blue)

    delta =
      cmax - cmin

    saturation =
      if cmax == 0 then
        0
      else
        delta / cmax

    hue =
      if delta == 0 then
        0
      else if cmax == red then
        60 * (fmod ((green - blue) / delta) 6)
      else if cmax == green then
        60 * (((blue - red) / delta) + 2)
      else
        60 * (((red - green) / delta) + 4)
  in
    { saturation = saturation
    , alpha = rgba.alpha
    , hue = hue / 360
    , value = cmax
    }
