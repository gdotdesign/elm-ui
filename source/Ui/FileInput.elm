module Ui.FileInput exposing
  (Model, Msg, init, update, view, render)

{-| Component for selecting a file.

# Model
@docs Model, Msg, init, update

# View
@docs view, render
-}

import Numeral exposing (format)
import Task
import Http

import Html exposing (node, div, text)
import Html.Lazy

import Ui.Native.FileManager as FileManager exposing (File)
import Ui.Button


{-| Representation of a file input:
  - **readonly** - Whether or not the date picker is readonly
  - **disabled** - Whether or not the date picker is disabled
  - **accept** - The mime types that the file input accepts
  - **file** - (Maybe) The selected file
-}
type alias Model =
  { readonly : Bool
  , disabled : Bool
  , file : Maybe File
  , accept : String
  }


{-| Messages that a file input can receive.
-}
type Msg
  = Browse
  | Selected File
  | Clear


{-| Initializes a file input with the given accept value.

    fileInput = Ui.FileInput.init "image/*"
-}
init : String -> Model
init accept =
  { readonly = False
  , disabled = False
  , accept = accept
  , file = Nothing
  }


{-| Updates a file input.

    Ui.FileInput.update msg fileInput
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Browse ->
      ( model, Task.perform (\_ -> Debug.crash "") Selected (FileManager.open model.accept) )

    Selected file ->
      ( { model | file = Just file }, Cmd.none )

    Clear ->
      ( { model | file = Nothing }, Cmd.none )


{-| Renders a file input lazily.

    Ui.FileInput.view fileInput
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a file input.

    Ui.FileInput.render fileInput
-}
render : Model -> Html.Html Msg
render model =
  node "ui-file-input"
    []
    [ renderFileStatus model
    , Ui.Button.view Browse
        { text = "Browse"
        , kind = "primary"
        , readonly = model.readonly
        , disabled = model.disabled
        , size = "medium"
        }
    ]



----------------------------------- PRIVATE ------------------------------------


{-| Renders a file status for a file input.
-}
renderFileStatus : Model -> Html.Html Msg
renderFileStatus model =
  case model.file of
    Just file ->
      node "ui-file-input-info"
        []
        [ node "ui-file-input-name" [] [ text file.name ]
        , node "ui-file-input-size" [] [ text ("Size: " ++ (format "0.0b" file.size)) ]
        , node "ui-file-input-type" [] [ text ("Type: " ++ file.mimeType) ]
        ]

    Nothing ->
      node "ui-file-input-no-file"
        []
        [ text "No file is selected!" ]
