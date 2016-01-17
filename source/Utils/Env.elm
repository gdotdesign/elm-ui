module Utils.Env where

import Json.Decode as Json
import Native.Env
import Debug

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
