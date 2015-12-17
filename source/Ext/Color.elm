module Ext.Color where

import Color exposing (Color)
import Ext.Number

alpha : Color -> Float
alpha color =
  (Color.toRgb color).alpha

value color =
  (toHsv color).value

type alias Hsv =
  { hue : Float
  , saturation : Float
  , value : Float
  , alpha : Float
  }

hsvToRgb : Hsv -> Color
hsvToRgb color =
  let
    saturation = color.saturation
    value = color.value
    hue = color.hue * 360

    c = value * saturation
    x = c * (1 - (abs (((hue / 60) `Ext.Number.remFloat` 2) - 1)))
    m = value - c

    (red, green, blue) = if 0 <= hue && hue < 60 then
                           (c, x, 0)
                         else if 60 <= hue && hue < 120 then
                           (x, c, 0)
                         else if 120 <= hue && hue < 180 then
                           (0, c, x)
                         else if 180 <= hue && hue < 240 then
                           (0, x, c)
                         else if 240 <= hue && hue < 300 then
                           (x, 0, c)
                         else
                           (c, 0, x)
  in
    Color.rgba
      (round ((red + m) * 255))
      (round ((green + m) * 255))
      (round ((blue + m) * 255))
      color.alpha

toHsv : Color -> Hsv
toHsv color =
  let
    rgba = (Color.toRgb color)

    red = (toFloat rgba.red) / 255
    green = (toFloat rgba.green) / 255
    blue = (toFloat rgba.blue) / 255

    cmax = max green (max red blue)
    cmin = min green (min red blue)
    delta = cmax - cmin

    saturation = if cmax == 0 then 0 else delta / cmax

    hue =  if delta == 0 then
             0
           else if cmax == red then
             60 * (((green - blue) / delta) `Ext.Number.remFloat` 6)
           else if cmax == green then
             60 * (((blue - red) / delta) + 2)
           else
             60 * (((red - green) / delta) + 4)
  in
    { hue = hue / 360
    , saturation = saturation
    , value = cmax
    , alpha = rgba.alpha
    }
