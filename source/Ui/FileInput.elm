module Ui.FileInput exposing
  ( Model, Msg, init, update, onChange, view, accept, render, viewDetails
  , renderDetails )

{-| Component for selecting a file.

# Model
@docs Model, Msg, init, update

# DSL
@docs accept

# Events
@docs onChange

# View
@docs view, render

# View Variations
@docs viewDetails, renderDetails
-}

import Numeral exposing (format)
import Task exposing (Task)

import Html exposing (node, text)
import Html.Events exposing (on)
import Html.Lazy

import Ui.Native.FileManager as FileManager exposing (File)
import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.Button
import Ui

import Ui.Styles.FileInput exposing (defaultStyle, defaultStyleDetails)
import Ui.Styles

{-| Representation of a file input:
  - **readonly** - Whether or not the file input is readonly
  - **disabled** - Whether or not the file input is disabled
  - **accept** - The mime types that the file input accepts
  - **uid** - The unique identifier of the file input
  - **file** - (Maybe) The selected file
-}
type alias Model =
  { file : Maybe File
  , disabled : Bool
  , readonly : Bool
  , accept : String
  , uid : String
  }


{-| Messages that a file input can receive.
-}
type Msg
  = Open (Task Never File)
  | Selected File
  | Clear
  | NoOp


{-| Initializes a file input with the given accept value.

    fileInput = Ui.FileInput.init ()
-}
init : () -> Model
init _ =
  { uid = Uid.uid ()
  , readonly = False
  , disabled = False
  , file = Nothing
  , accept = "*/*"
  }


{-| Subscribe to the changes of a file input.

    subscriptions = Ui.FileInput.onChange FileInputChanged fileInput
-}
onChange : (File -> msg) -> Model -> Sub msg
onChange msg model =
  Emitter.listenFile model.uid msg


{-| Sets the accept property of a file input
-}
accept : String -> Model -> Model
accept value model =
  { model | accept = value }


{-| Updates a file input.

    ( updatedFileInput, cmd ) = Ui.FileInput.update msg fileInput
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Selected file ->
      ( { model | file = Just file }, Emitter.sendFile model.uid file )

    Clear ->
      ( { model | file = Nothing }, Cmd.none )

    Open task ->
      ( model, Task.perform Selected task )

    NoOp ->
      ( model, Cmd.none )


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
  let
    label =
      Maybe.map .name model.file
        |> Maybe.withDefault "No file is selected!"

    attributes =
      Ui.enabledActions
        model
        [ on "click" (FileManager.openSingleDecoder model.accept Open) ]
  in
    node "ui-file-input"
      ( [ Ui.attributeList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
        , Ui.Styles.apply defaultStyle
        , attributes
        ]
        |> List.concat
      )
      [ node "ui-file-input-content" [] [ text label ]
      , Ui.Button.view
          NoOp
          { readonly = model.readonly
          , disabled = model.disabled
          , kind = "primary"
          , text = "Browse"
          , size = "medium"
          }
      ]


{-| Renders a file input lazily showing the details of the file.

    Ui.FileInput.renderDetails fileInput
-}
viewDetails : Model -> Html.Html Msg
viewDetails model =
  Html.Lazy.lazy renderDetails model


{-| Renders a file input showing the details of the file.

    Ui.FileInput.renderDetails fileInput
-}
renderDetails : Model -> Html.Html Msg
renderDetails model =
  let
    attributes =
      Ui.enabledActions
        model
        [ on "click" (FileManager.openSingleDecoder model.accept Open) ]
  in
    node "ui-file-input-details"
      ( [ Ui.attributeList
          [ ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
        , Ui.Styles.apply defaultStyleDetails
        , attributes
        ]
        |> List.concat
      )
      [ renderFileStatus model
      , Ui.Button.view
          NoOp
          { readonly = model.readonly
          , disabled = model.disabled
          , kind = "primary"
          , text = "Browse"
          , size = "medium"
          }
      ]


{-| Renders a file status for a file input.
-}
renderFileStatus : Model -> Html.Html Msg
renderFileStatus model =
  case model.file of
    Just file ->
      node "ui-file-input-info"
        []
        [ node "ui-file-input-name"
            []
            [ text file.name ]
        , node "ui-file-input-size"
            []
            [ text ("Size: " ++ (format "0.0b" file.size)) ]
        , node "ui-file-input-type"
            []
            [ text ("Type: " ++ file.mimeType) ]
        ]

    Nothing ->
      node "ui-file-input-no-file"
        []
        [ text "No file is selected!" ]
