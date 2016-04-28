module Ui.Chooser exposing
  (Model, Item, Msg, init, update, close, toggleItem,
   getFirstSelected, view, updateData, selectFirst, setValue)

-- where

{-| This is a component for selecting a single / multiple items
form a list of choises, with lots of options.

# Model
@docs Model, Item, Msg, init, subscribe, update

# View
@docs view

# Functions
@docs toggleItem, close, getFirstSelected, updateData, selectFirst, setValue
-}
import Html.DropdownDimensions exposing (DropdownDimensions, onWithDropdownDimensions,onKeysWithDimensions)
import Html.Extra exposing (onPreventDefault, onStop)
import Html.Attributes exposing (value, placeholder, readonly, classList
                                , disabled)
import Html.Events exposing (onFocus, onBlur, onClick, onInput)
import Html exposing (span, text, node, input, Html)
import Html.Lazy

import Set exposing (Set)
import String
import Regex
import List
import Dict

import Debug exposing (log)

import Ui.Helpers.Intendable as Intendable
import Ui.Helpers.Dropdown as Dropdown
import Ui

{-| Representation of an selectable item. -}
type alias Item =
  { label : String
  , value : String
  }

{-| Representation of a chooser component:
  - **deselectable** - True if the component can have no selected value false if not
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **data** - List of items to select from and display in the dropdown
  - **multiple** - Whether or not the user can select multiple items
  - **placeholder** - The text to display when no item is selected
  - **searchable** - Whether or not a user can filter the items
  - **valueAddress** - The address to send changes in value to
  - **readonly** - Whether or not the chooser is readonly
  - **disabled** - Whether or not the chooser is disabled
  - **selected** - A *Set* of values of selected items
  - **open** - Whether or not the dropdown is open
  - **render** - Function to render the items
  - **intended** (internal) - The currently intended value (for keyboard selection)
  - **dropdownPosition** (internal) - Where the dropdown is positioned
  - **value** (internal) - The value of the input
-}
type alias Model =
  { dropdownPosition : String
  , render : Item -> Html Msg
  , selected : Set String
  , placeholder : String
  , closeOnSelect : Bool
  , deselectable: Bool
  , intended : String
  , searchable : Bool
  , data : List Item
  , multiple : Bool
  , disabled : Bool
  , readonly : Bool
  , value : String
  , open : Bool
  }

{-| Actions that a chooser can make. -}
type Msg
  = Toggle DropdownDimensions
  | Focus DropdownDimensions
  | Close DropdownDimensions
  | Enter DropdownDimensions
  | Next DropdownDimensions
  | Prev DropdownDimensions
  | Filter String
  | Select String
  | Tasks ()
  | NoOp
  | Blur

{-| Initializes a chooser with the given values.

    Chooser.init items placeholder selectedValue
-}
init : List Item -> String -> String -> Model
init data placeholder value =
  let
    selected = if value == "" then Set.empty else Set.singleton value
  in
    { render = (\item -> span [] [text item.label])
    , dropdownPosition = "bottom"
    , placeholder = placeholder
    , closeOnSelect = False
    , deselectable = False
    , selected = selected
    , searchable = False
    , multiple = False
    , disabled = False
    , readonly = False
    , intended = ""
    , open = False
    , data = data
    , value = ""
    }
      |> intendFirst

{-| Updates a chooser. -}
update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Enter dimensions ->
      let
        (updatedModel, effect) = toggleItem model.intended model
        fn = if model.closeOnSelect then
              Dropdown.toggleWithDimensions
             else
              Dropdown.openWithDimensions
      in
        (fn dimensions updatedModel, effect)


    Select value ->
      toggleItemAndClose value model

    _ ->
      (update' action model, Cmd.none)

-- Non effects updates
update' : Msg -> Model -> Model
update' action model =
  case action of
    Filter value ->
      setInputValue value model
       |> intendFirst

    Toggle dimensions ->
      Dropdown.toggleWithDimensions dimensions model
        |> intendFirst

    Focus dimensions ->
      Dropdown.openWithDimensions dimensions model
       |> intendFirst

    Close _ ->
      close model

    Blur ->
      close model

    Next dimensions ->
      { model | intended = Intendable.next
                            model.intended
                            (availableItems model) }
        |> Dropdown.openWithDimensions dimensions

    Prev dimensions ->
      { model | intended = Intendable.previous
                            model.intended
                            (availableItems model) }
        |> Dropdown.openWithDimensions dimensions

    _ ->
      model

{-| Renders a chooser. -}
view : Model -> Html.Html Msg
view  model =
  render  model

-- Renders a chooser.
render : Model -> Html.Html Msg
render model =
  let
    children =
      (List.map (\item -> renderItem item model) (items model))

    dropdown =
      [ Dropdown.view NoOp model.dropdownPosition
        [(Ui.scrolledPanel children)] ]

    val =
      if model.open && model.searchable then
        model.value
      else
        label model

    isReadOnly = not model.searchable || not model.open || model.readonly

    actions =
      Ui.enabledActions model
        [ onInput Filter
        , onWithDropdownDimensions "focus" Focus
        , onBlur Blur
        , onWithDropdownDimensions "mousedown" Toggle
        , onKeysWithDimensions
          ([ (27, Close)
           , (13, Enter)
           , (40, Next)
           , (38, Prev)
           ] ++ (if (not model.searchable) then [(32, Enter)] else []))
        ]
  in
    node "ui-chooser" ([classList [ ("searchable", model.searchable)
                                  , ("dropdown-open", model.open)
                                  , ("disabled", model.disabled)
                                  , ("readonly", model.readonly)
                                  ]
                       ])
      ([ input ([ placeholder model.placeholder
                , disabled model.disabled
                , readonly isReadOnly
                , value val
                ] ++ actions) []] ++ dropdown)

{-| Selects the given value of chooser. -}
setValue : String -> Model -> Model
setValue value model =
  let
    newSelected = Set.singleton value
  in
    if (Set.size (Set.diff newSelected model.selected)) == 0 then
      model
    else
      { model | selected = newSelected }

{-| Closes the dropdown of a chooser. -}
close : Model -> Model
close model =
  Dropdown.close model
  |> setInputValue ""

{-| Selects or deselects the item with the given value. -}
toggleItem : String -> Model -> (Model, Cmd Msg)
toggleItem value model =
  if model.multiple then
    toggleMultipleItem value model
  else
    toggleSingleItem value model

{-| Gets the first selected item of a chooser. -}
getFirstSelected : Model -> Maybe String
getFirstSelected model =
  List.head (Set.toList model.selected)

{-| Updates the data of a chooser. -}
updateData : List Item -> Model -> Model
updateData data model =
  { model | data = data }

{-| Selects the first item if available. -}
selectFirst : Model -> (Model, Cmd Msg)
selectFirst model =
  case List.head model.data of
    Just item ->
      { model | selected = Set.singleton item.value }
      |> sendValue
    _ ->
      (model, Cmd.none)

-- ========================= PRIVATE =========================

-- Sends the current value of the model to the signal
sendValue : Model -> (Model, Cmd Msg)
sendValue model =
  -- (model, Ext.Signal.sendAsEffect model.valueAddress model.selected Tasks)
  (model, Cmd.none)

{- Select or deslect a single item with the given value and closes
the dropdown if needed. -}
toggleItemAndClose : String -> Model -> (Model, Cmd Msg)
toggleItemAndClose value model =
  let
    (model, effect) = toggleItem value model
  in
    (closeIfShouldClose model, effect)

-- Toggle item if multiple is True.
toggleMultipleItem : String -> Model -> (Model, Cmd Msg)
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
   {model | selected = updated_set }
   |> sendValue

-- Toggle item if multiple is False.
toggleSingleItem : String -> Model -> (Model, Cmd Msg)
toggleSingleItem value model =
  let
    updatedModel =
      if (Set.member value model.selected) && model.deselectable then
        { model | selected = Set.empty }
      else
        { model | selected = Set.singleton value }
  in
    sendValue updatedModel

-- Intends the first item if it is available.
intendFirst : Model -> Model
intendFirst model =
  let
    available = availableItems model
    index = Intendable.index model.intended available
  in
    if index == -1 then
      { model | intended = Intendable.next "" available }
    else
      model

-- Sets the value of a chooser.
setInputValue : String -> Model -> Model
setInputValue value model =
  { model | value = value }

-- Returns the label of a chooser.
label : Model -> String
label model =
  List.filter (\item -> Set.member item.value model.selected) model.data
    |> List.map .label
    |> String.join ", "

-- Closes a chooser if indicated
closeIfShouldClose : Model -> Model
closeIfShouldClose model =
  if model.closeOnSelect then close model else model

-- Creates a regexp for filtering
createRegex : String -> Regex.Regex
createRegex value =
  Regex.escape value
    |> Regex.regex
    |> Regex.caseInsensitive

-- Renders an item
renderItem : Item -> Model -> Html.Html Msg
renderItem item model =
  let
    selectEvent =
      if model.closeOnSelect then
        onStop "mouseup" (Select item.value)
      else
        onPreventDefault "mousedown" (Select item.value)
  in
    node "ui-chooser-item"
      [ selectEvent
      , classList [ ("selected", Set.member item.value model.selected)
                  , ("intended", item.value == model.intended)
                  ]
      ]
      [ model.render item ]

-- Returns the items to display for a chooser.
items : Model -> List Item
items model =
  let
    test item =
      Regex.contains (createRegex model.value) item.label
  in
    if String.isEmpty (String.trim model.value) then
      model.data
    else
      List.filter test model.data

-- Returns the values of available items
availableItems : Model -> List String
availableItems model =
  List.map .value (items model)
