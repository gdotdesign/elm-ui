module Ui.Native.FileManager
  exposing
    ( File
    , readAsString
    , readAsDataURL
    , toFormData
    , openSingle
    , openMultiple
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
@docs openSingle, openMultiple, download
-}

import Task exposing (Task)
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


{-| Converts a files data to Http.Data

    data = FileManager.toFormData file
-}
toFormData : String -> File -> Http.Data
toFormData key file =
  Http.stringData key (Native.FileManager.toFormData file)


{-| Opens a file browser for selecting a single file.

    task = FileManager.openSingle "image/*"
-}
openSingle : String -> Task Never File
openSingle accept =
  Native.FileManager.openSingle accept


{-| Opens a file browser for selecting multiple files.

    task = FileManager.openMultiple "image/*"
-}
openMultiple : String -> Task Never (List File)
openMultiple accept =
  Native.FileManager.openMultiple accept


{-| Downloads the given data with the given name and mime type.

    task = FileManager.download "test.txt" "text/plain" "Hello World!"
-}
download : String -> String -> String -> Task Never String
download filename mimeType data =
  Native.FileManager.download filename mimeType data
