module String.Split exposing (..)
{-| Split strings into chunks

# Splitters
@docs chunksOfLeft, chunksOfRight

-}

import String exposing (..)
import List

{-| Split string into smaller strings of length `k`, starting from the left.

    chunksOfLeft 3 "abcdefgh" == ["abc", "def", "gh"]
-}
chunksOfLeft : Int -> String -> List String
chunksOfLeft k s =
  let len = length s
  in  if len > k
      then left k s :: chunksOfLeft k (dropLeft k s)
      else [s]

{-| Split string into smaller strings of length `k`, starting from the right.

    chunksOfRight 3 "abcdefgh" == ["ab", "cde", "fgh"]
-}
chunksOfRight : Int -> String -> List String
chunksOfRight k s =
  let len = length s
      k2 = 2 * k
      chunksOfR s' =
        if length s' > k2
        then right k s' :: chunksOfR (dropRight k s')
        else right k s' :: [dropRight k s']
  in  if len > k2 then
          List.reverse (chunksOfR s)
      else if len > k then
          dropRight k s :: [right k s]
      else
          [s]
