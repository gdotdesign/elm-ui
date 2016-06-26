module Ui.Native.FileManager exposing (..)

import Native.FileManager
import Http
import Task exposing (Task)

{-| The type of the files content.
-}
type Data = Data

type alias File =
  { name : String
  , mimeType : String
  , size : Float
  , data : Data
  }

readAsString : File -> Task Never String
readAsString file =
  Native.FileManager.readAsString file

readAsDataURL : File -> Task Never String
readAsDataURL file =
  Native.FileManager.readAsDataURL file

toFormData : String -> File -> Http.Data
toFormData key file =
  Http.stringData key (Native.FileManager.toFormData file)

open : String -> Task Never File
open accept =
  Native.FileManager.open accept

download : String -> String -> String -> Task Never String
download filename mimeType data =
  Native.FileManager.download filename mimeType data
