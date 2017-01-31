module Ui.Native.FileManager
  exposing
    ( File
    , readAsString
    , readAsDataURL
    , toFormData
    , openSingleDecoder
    , openMultipleDecoder
    , download
    )

{-| Low level functions for managing [Files](https://developer.mozilla.org/en/docs/Web/API/File).

# Types
@docs File

# Reading
@docs readAsString, readAsDataURL

# For Http
@docs toFormData

# Open / Download
@docs openSingleDecoder, openMultipleDecoder, download
-}

import Task exposing (Task)
import Json.Decode as Json
import Native.FileManager
import Http

{-| The type of the files content.
-}
type Data
  = Data


{-| Representation of a file:
  - **data** - The file data (native File object)
  - **mimeType** - The mime type of the file
  - **name** - The name of the file
  - **size** - The size of the file
-}
type alias File =
  { mimeType : String
  , name : String
  , size : Float
  , data : Data
  }


{-| Reads a file as a string.

    task = FileManager.readAsString file
-}
readAsString : File -> Task Never String
readAsString file =
  Native.FileManager.readAsString file


{-| Reads a file as a [data URI](https://en.wikipedia.org/wiki/Data_URI_scheme)

    task = FileManager.readAsDataURL file
-}
readAsDataURL : File -> Task Never String
readAsDataURL file =
  Native.FileManager.readAsDataURL file


{-| Converts a files data to Http.Part

    data = FileManager.toFormData file
-}
toFormData : String -> File -> Http.Part
toFormData key file =
  Http.stringPart key (Native.FileManager.toFormData file)


{-| Provides a decoder that will open a file browser and return a task for
reading the chosen file.

    -- type
    | Opened (Task Never File)
    | GetFile File

    -- update
    Opened task ->
      (model, Task.peform (\_ -> Debug.crash "") GetFile task

    GetFile file ->
      ({ model | file = file }, Cmd.none)

    -- view
    div
      [ on "click" (Ui.Native.FileManager.openSingleDecoder "image/*" Opened) ]
      [ text "Open File" ]
-}
openSingleDecoder : String -> (Task Never File -> msg) -> Json.Decoder msg
openSingleDecoder accept msg =
  Json.map msg (Native.FileManager.openSingleDecoder accept)


{-| Provides a decoder that will open a file browser and return a task for
reading the chosen files.

    -- type
    | Opened (Task Never (List File))
    | GetFiles (List File)

    -- update
    Opened task ->
      (model, Task.peform (\_ -> Debug.crash "") GetFile task

    GetFiles files ->
      ({ model | files = files }, Cmd.none)

    -- view
    div
      [ on "click" (Ui.Native.FileManager.openMultipleDecoder "image/*" Opened) ]
      [ text "Open Files" ]
-}
openMultipleDecoder : String -> (Task Never (List File) -> msg) -> Json.Decoder msg
openMultipleDecoder accept msg =
  Json.map msg (Native.FileManager.openMultipleDecoder accept)


{-| Downloads the given data with the given name and mime type.

    task = FileManager.download "test.txt" "text/plain" "Hello World!"
-}
download : String -> String -> String -> Task Never String
download filename mimeType data =
  Native.FileManager.download filename mimeType data
