module Ui.Chooser exposing
  ( Model, Item, Msg, init, onChange, update, view, render, subscriptions
  , close, toggleItem, getFirstSelected, updateData, selectFirst, setValue
  , placeholder, closeOnSelect, deselectable, searchable, multiple, items )

{-| This is a component for selecting a single / multiple items
form a list of choices, with lots of options.

# Model
@docs Model, Item, Msg, init, subscriptions, update

# Events
@docs onChange

# DSL
@docs placeholder, closeOnSelect, deselectable, searchable, multiple, items

# View
@docs view, render

# Functions
@docs setValue, toggleItem, close, getFirstSelected, updateData, selectFirst
-}

import Html.Events exposing (onFocus, onBlur, onInput, onMouseDown)
import Html.Events.Extra exposing (onPreventDefault, onKeys)
import Html exposing (text, node, input)
import Html.Keyed
import Html.Lazy

import Html.Attributes
  exposing
    ( value
    , placeholder
    , attribute
    , readonly
    , disabled
    )

import Json.Decode as JD
import Json.Encode as JE

import Set exposing (Set)
import String
import Regex
import List

import Ui.Helpers.Intendable as Intendable
import Ui.Helpers.Dropdown as Dropdown
import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui.ScrolledPanel
import Ui

import Ui.Styles.Chooser exposing (defaultStyle)
import Ui.Styles

{-| Representation of an selectable item:
  - **value** - The value of the item (it is sent when selected items change)
  - **id** - The unique identifier of the item
  - **label** - The label of the item
-}
type alias Item =
  { label : String
  , value : String
  , id : String
  }


{-| Representation of a chooser:
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **intended** - The currently intended value (for keyboard selection)
  - **data** - List of items to select from and display in the dropdown
  - **multiple** - Whether or not the user can select multiple items
  - **deselectable** - Whether or not it can have no selected value
  - **placeholder** - The text to display when no item is selected
  - **searchable** - Whether or not a user can filter the items
  - **disabled** - Whether or not the chooser is disabled
  - **readonly** - Whether or not the chooser is readonly
  - **selected** - A *Set* of values of selected items
  - **uid** - The unique identifier of the chooser
  - **dropdown** - The model for the dropdown
  - **render** - Function to render an item
  - **value** - The value of the input
-}
type alias Model =
  { render : Item -> Html.Html Msg
  , dropdown : Dropdown.Dropdown
  , selected : Set String
  , placeholder : String
  , closeOnSelect : Bool
  , deselectable : Bool
  , intended : String
  , searchable : Bool
  , data : List Item
  , multiple : Bool
  , disabled : Bool
  , readonly : Bool
  , value : String
  , uid : String
  }


{-| Messages that a chooser can recieve.
-}
type Msg
  = Dropdown Dropdown.Msg
  | Filter String
  | Select String
  | Toggle
  | Focus
  | Close
  | Enter
  | Next
  | Prev
  | NoOp
  | Blur


{-| Initializes a chooser with the given values.

    chooser =
      Ui.Chooser.init ()
        |> Ui.Chooser.placeholder "Select an item..."
        |> Ui.Chooser.searchable True
-}
init : () -> Model
init _ =
  { render = (\item -> text item.label)
  , dropdown = Dropdown.init
  , closeOnSelect = False
  , deselectable = False
  , selected = Set.empty
  , searchable = False
  , multiple = False
  , disabled = False
  , readonly = False
  , placeholder = ""
  , uid = Uid.uid ()
  , intended = ""
  , value = ""
  , data = []
  }
    |> Dropdown.offset 5


{-| Subscribe to the changes of a chooser.

    subscription = Ui.Chooser.onChange ChooserChanged chooser
-}
onChange : (Set String -> msg) -> Model -> Sub msg
onChange msg model =
  let
    decoder =
      JD.list JD.string
        |> JD.map Set.fromList
  in
    Emitter.listen model.uid (Emitter.decode decoder Set.empty msg)


{-| Sets the placeholder of a chooser.
-}
placeholder : String -> Model -> Model
placeholder value model =
  { model | placeholder = value }


{-| Sets whether or not to close the dropdown when selecting an item.
-}
closeOnSelect : Bool -> Model -> Model
closeOnSelect value model =
  { model | closeOnSelect = value }


{-| Sets whether an item must be selected or not.
-}
deselectable : Bool -> Model -> Model
deselectable value model =
  { model | deselectable = value }


{-| Sets whether the user can search among the items or not.
-}
searchable : Bool -> Model -> Model
searchable value model =
  { model | searchable = value }


{-| Sets whether the user can select multiple items or not.
-}
multiple : Bool -> Model -> Model
multiple value model =
  { model | multiple = value }


{-| Sets the items of a chooser.
-}
items : List Item -> Model -> Model
items value model =
  { model | data = value }


{-| Subscriptions for a dropdown menu.

    subscriptions model =
      Sub.map
        Chooser
        (Ui.Chooser.subscriptions model.dropdownMenu)
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Dropdown (Dropdown.subscriptions model)


{-| Updates a chooser.

    ( updatedChoser, cmd ) = Ui.Chooser.update msg chooser
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Enter ->
      let
        ( updatedModel, effect ) =
          toggleItem model.intended model

        function =
          if model.closeOnSelect then
            Dropdown.toggle
          else
            Dropdown.open
      in
        ( function updatedModel, effect )

    Dropdown msg ->
      ( Dropdown.update msg model, Cmd.none )

    Select value ->
      toggleItemAndClose value model

    Filter value ->
      ( intendFirst <| setInputValue value model, Cmd.none )

    Toggle ->
      ( intendFirst <| Dropdown.open model, Cmd.none )

    Focus ->
      ( intendFirst <| Dropdown.open model, Cmd.none )

    Close ->
      ( close model, Cmd.none )

    Blur ->
      ( close model, Cmd.none )

    Next ->
      ( { model
          | intended =
              Intendable.next
                model.intended
                (availableItems model)
        }
          |> Dropdown.open
      , Cmd.none
      )

    Prev ->
      ( { model
          | intended =
              Intendable.previous
                model.intended
                (availableItems model)
        }
          |> Dropdown.open
      , Cmd.none
      )

    NoOp ->
      ( model, Cmd.none )


{-| Lazily renders a chooser.

    Ui.Chooser.view model
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a chooser.

    Ui.Chooser.render model
-}
render : Model -> Html.Html Msg
render model =
  let
    children =
      (List.map (Html.Lazy.lazy2 renderItem model) (items_ model))

    val =
      if model.dropdown.open && model.searchable then
        model.value
      else
        label model

    placeholder_ =
      if Set.isEmpty model.selected then
        model.placeholder
      else
        label model

    isReadOnly =
      not model.searchable || not model.dropdown.open || model.readonly

    actions =
      Ui.enabledActions
        model
        [ onMouseDown Toggle
        , onInput Filter
        , onFocus Focus
        , onBlur Blur
        , onKeys True
            ([ ( 27, Close )
             , ( 13, Enter )
             , ( 40, Next )
             , ( 38, Prev )
             ]
              ++ (if (not model.searchable) then
                    [ ( 32, Enter ) ]
                  else
                    []
                 )
            )
        ]
  in
    Dropdown.view
      { address = Dropdown
      , tag = "ui-chooser"
      , attributes =
        ( [ Ui.attributeList
            [ ( "searchable", model.searchable )
            , ( "open", model.dropdown.open )
            , ( "disabled", model.disabled )
            , ( "readonly", model.readonly )
            ]
          , Ui.Styles.apply defaultStyle
          ]
          |> List.concat
        )
      , contents =
        [ Ui.ScrolledPanel.view
          [ onPreventDefault "mousedown" NoOp ]
          children
        ]
      , children =
        [ input
          ([ Html.Attributes.placeholder placeholder_
           , attribute "id" model.uid
           , disabled model.disabled
           , readonly isReadOnly
           , value val
           ]
            ++ actions
          )
          []
        ]
      } model


{-| Selects the given value of chooser.
-}
setValue : String -> Model -> Model
setValue value model =
  let
    newSelected =
      Set.singleton value
  in
    if (Set.size (Set.diff newSelected model.selected)) == 0 then
      model
    else
      { model | selected = newSelected }


{-| Closes the dropdown of a chooser.
-}
close : Model -> Model
close model =
  Dropdown.close model
    |> setInputValue ""


{-| Selects or deselects the item with the given value.
-}
toggleItem : String -> Model -> ( Model, Cmd Msg )
toggleItem value model =
  if model.multiple then
    toggleMultipleItem value model
  else
    toggleSingleItem value model


{-| Gets the first selected item of a chooser.
-}
getFirstSelected : Model -> Maybe String
getFirstSelected model =
  List.head (Set.toList model.selected)


{-| Updates the data of a chooser.
-}
updateData : List Item -> Model -> Model
updateData data model =
  { model | data = data }


{-| Selects the first item if available.
-}
selectFirst : Model -> ( Model, Cmd Msg )
selectFirst model =
  case List.head model.data of
    Just item ->
      { model | selected = Set.singleton item.value }
        |> sendValue

    _ ->
      ( model, Cmd.none )


{-| Sends the current value of the model to the signal.
-}
sendValue : Model -> ( Model, Cmd Msg )
sendValue model =
  let
    value =
      Set.toList model.selected
        |> List.map JE.string
        |> JE.list
  in
    ( model, Emitter.send model.uid value )


{-| Select or deslect a single item with the given value and closes
the dropdown if needed.
-}
toggleItemAndClose : String -> Model -> ( Model, Cmd Msg )
toggleItemAndClose value model =
  let
    ( updatedModel, effect ) =
      toggleItem value model
  in
    ( closeIfShouldClose updatedModel, effect )


{-| Toggle item if multiple is True.
-}
toggleMultipleItem : String -> Model -> ( Model, Cmd Msg )
toggleMultipleItem value model =
  let
    updated_set =
      if Set.member value model.selected then
        if model.deselectable || (Set.size model.selected) > 1 then
          Set.remove value model.selected
        else
          model.selected
      else
        Set.insert value model.selected
  in
    { model | selected = updated_set }
      |> sendValue


{-| Toggle item if multiple is False.
-}
toggleSingleItem : String -> Model -> ( Model, Cmd Msg )
toggleSingleItem value model =
  let
    updatedModel =
      if (Set.member value model.selected) && model.deselectable then
        { model | selected = Set.empty }
      else
        { model | selected = Set.singleton value }
  in
    sendValue updatedModel


{-| Intends the first item if it is available.
-}
intendFirst : Model -> Model
intendFirst model =
  let
    available =
      availableItems model

    index =
      Intendable.index model.intended available
  in
    if index == -1 then
      { model | intended = Intendable.next "" available }
    else
      model


{-| Sets the value of a chooser.
-}
setInputValue : String -> Model -> Model
setInputValue value model =
  { model | value = value }


{-| Returns the label of a chooser.
-}
label : Model -> String
label model =
  List.filter (\item -> Set.member item.value model.selected) model.data
    |> List.map .label
    |> String.join ", "


{-| Closes a chooser if indicated.
-}
closeIfShouldClose : Model -> Model
closeIfShouldClose model =
  if model.closeOnSelect then
    close model
  else
    model


{-| Creates a regexp for filtering.
-}
createRegex : String -> Regex.Regex
createRegex value =
  Regex.escape value
    |> Regex.regex
    |> Regex.caseInsensitive


{-| Renders an item.
-}
renderItem : Model -> Item -> Html.Html Msg
renderItem model item =
  node
    "ui-chooser-item"
    ( [ [ onPreventDefault "mousedown" (Select item.value) ]
      , Ui.attributeList
        [ ( "selected", Set.member item.value model.selected )
        , ( "intended", item.value == model.intended )
        ]
      ]
      |> List.concat
    )
    [ model.render item ]


{-| Returns the items to display for a chooser.
-}
items_ : Model -> List Item
items_ model =
  let
    test item =
      Regex.contains (createRegex model.value) item.label
  in
    if String.isEmpty (String.trim model.value) then
      model.data
    else
      List.filter test model.data


{-| Returns the values of available items
-}
availableItems : Model -> List String
availableItems model =
  List.map .value (items_ model)
