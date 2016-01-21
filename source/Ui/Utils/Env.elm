module Ui.Utils.Env where

{-| Module for interacting with the environment variables.

@docs get
-}
import Date.Format exposing (format)
import Json.Decode as Json
import Native.Env
import Ext.Date
import Debug

{-| Gets the value of the given environment variable with a decoder and a
default value. -}
get : String -> a -> Json.Decoder a -> a
get key default decoder =
  let
    value = Native.Env.get key
  in
    case Json.decodeValue decoder value of
      Ok data -> data
      Err msg ->
        let
          log =
            Debug.log
              ("Error getting ENV value '" ++ key ++ "'")
              msg
        in
          default
