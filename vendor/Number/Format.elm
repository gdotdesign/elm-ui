module Number.Format exposing (..)
{-|
@docs pretty, prettyInt
-}

import String
import String.Split as String

{-| A (de facto?) standard pretty formatting for numbers.

    pretty 2 ',' '.' 81601710123.338023  == "81,601,710,123.34"
    pretty 3 ' ' '.' 81601710123.338023  == "81 601 710 123.338"
    pretty 3 ' ' '.' -81601710123.338023 == "-81 601 710 123.34"

* Numbers are rounded to the nearest printable digit
* Digits before the decimal are grouped into spans of three and separated by a seperator character
-}
pretty : Int -> Char -> Char -> Float -> String
pretty decimals sep ds n =
  let decpow  = 10 ^ decimals
      nshift  = n * toFloat decpow
      nshifti = round nshift
      nshifti' = abs nshifti
      ni = nshifti' // decpow
      nf = nshifti' - ni * decpow
      nfs = toString nf
      nflen = String.length nfs
  in  ( if nshifti < 0
        then prettyInt sep -ni
        else prettyInt sep ni
      )
      `String.append`
      String.cons ds (String.padLeft decimals '0' nfs)


{-| A (de facto?) standard pretty formatting for numbers.
This version of the function operates on integers instead of floating point values.
In future `pretty` may be used on both integers as well as floating point values and this function
will be deprecated.

    prettyInt ',' 81601710123  == "81,601,710,123"
    prettyInt ' ' 81601710123  == "81 601 710 123"
    prettyInt ' ' -81601710123 == "-81 601 710 123"

* Digits are grouped into spans of three and separated by a seperator character
-}
prettyInt : Char -> Int -> String
prettyInt sep n =
  let ni = abs n
      nis = String.join (String.fromChar sep) (String.chunksOfRight 3 <| toString ni)
  in  if n < 0
      then String.cons '-' nis
      else nis
