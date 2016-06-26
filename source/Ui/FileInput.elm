module Ui.FileInput exposing (..)

import Task

import Html exposing (node, div, text)
import Html.Lazy

import Numeral exposing (format)
import Http

import Ui.Native.FileManager as FileManager exposing (File)
import Ui.Button

type alias Model =
  { readonly : Bool
  , disabled : Bool
  , file: Maybe File
  , accept : String
  }

type Msg
  = Browse
  | Selected File
  | Clear

init : String -> Model
init accept =
  { readonly = False
  , disabled = False
  , accept = accept
  , file = Nothing
  }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Browse ->
      (model, Task.perform (\_ -> Debug.crash "") Selected (FileManager.open model.accept))

    Selected file ->
      ({ model | file = Just file }, Cmd.none)

    Clear ->
      ({ model | file = Nothing }, Cmd.none)

asFormData : String -> Model -> Http.Data
asFormData key model =
  case model.file of
    Just file ->
      FileManager.toFormData key file
    Nothing ->
      Debug.crash "There is no file selected!"

view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model

render : Model -> Html.Html Msg
render model =
  node "ui-file-input"
    []
    [ renderFileStatus model
    , Ui.Button.view Browse { text = "Browse"
                            , kind = "primary"
                            , readonly = model.readonly
                            , disabled = model.disabled
                            , size = "medium"
                            }
    ]

----------------------------------- PRIVATE ------------------------------------

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
