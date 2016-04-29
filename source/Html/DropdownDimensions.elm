module Html.DropdownDimensions exposing (..)

-- where

import Html.Extra exposing (keysDecoder, preventDefaultOptions)
import Html.WindowDimensions exposing (WindowDimensions)
import Html.Dimensions exposing (Dimensions, dimensionsDecoder)
import Html.Events exposing (defaultOptions, onWithOptions)
import Html

import Json.Decode as Json

type alias DropdownDimensions =
  { dimensions : Dimensions
  , dropdown : Dimensions
  , window : WindowDimensions
  }

{-| Decodes dimensions for a element and its dropdown. -}
decoder : Json.Decoder DropdownDimensions
decoder =
  Json.object3 DropdownDimensions
    (Json.at ["target"] Html.Dimensions.dimensionsDecoder)
    (Json.at ["target", "dropdown"] dimensionsDecoder)
    Html.WindowDimensions.decoder

{-| Returns dimensions for an element and its dropdown. -}
onWithDropdownDimensions : String
                           -> (DropdownDimensions -> msg)
                           -> Html.Attribute msg
onWithDropdownDimensions event msg =
  onWithOptions
    event
    defaultOptions
    (Json.map msg decoder)

{-| An event listener that will run the given actions on the associated keys. -}
onKeysWithDimensions : List (Int, (DropdownDimensions -> msg)) -> Html.Attribute msg
onKeysWithDimensions mappings =
  onWithOptions
    "keydown"
    preventDefaultOptions
    (Json.andThen (keysDecoder mappings) (\msg -> Json.map msg decoder))
