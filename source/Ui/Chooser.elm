module Ui.Chooser
  (Model, Item, Action, init, initWithAddress, update, close, toggleItem,
   getFirstSelected, view, updateData, selectFirst, select) where

{-| This is a component for selecting a single / multiple items
form a list of choises, with lots of options.

# Model
@docs Model, Item, Action, init, initWithAddress, update

# View
@docs view

# Functions
@docs toggleItem, close, getFirstSelected, updateData, selectFirst, select
-}
import Html.Extra exposing (onInput, onPreventDefault, onWithDropdownDimensions
                           ,onKeysWithDimensions)
import Html.Attributes exposing (value, placeholder, readonly, classList
                                , disabled)
import Html.Events exposing (onFocus, onBlur, onClick, onMouseDown)
import Html exposing (span, text, node, input, Html)
import Html.Lazy

import Set exposing (Set)
import Native.Browser
import Ext.Signal
import Effects
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
  { valueAddress : Maybe (Signal.Address (Set String))
  , dropdownPosition : String
  , render : Item -> Html
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
type Action
  = Focus Html.Extra.DropdownDimensions
  | Close Html.Extra.DropdownDimensions
  | Enter Html.Extra.DropdownDimensions
  | Next Html.Extra.DropdownDimensions
  | Prev Html.Extra.DropdownDimensions
  | Filter String
  | Select String
  | Tasks ()
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
    , valueAddress = Nothing
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

{-| Initializes a chooser with the given values and value address.

    Chooser.init
      (forwardTo address ChooserChanged)
      items
      placeholder
      selectedValue
-}
initWithAddress : Signal.Address (Set String) -> List Item -> String -> String -> Model
initWithAddress valueAddress data placeholder value =
  let
    model = init data placeholder value
  in
    { model | valueAddress = Just valueAddress }

{-| Updates a chooser. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Enter dimensions ->
      let
        (updatedModel, effect) = toggleItem model.intended model
      in
        (Dropdown.toggleWithDimensions dimensions updatedModel, effect)

    Select value ->
      toggleItemAndClose value model

    _ ->
      (update' action model, Effects.none)

-- Non effects updates
update' : Action -> Model -> Model
update' action model =
  case action of
    Filter value ->
      setValue value model
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
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Renders a chooser.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    dropdown =
      [ Dropdown.view model.dropdownPosition
        (List.map (\item -> renderItem item address model) (items model)) ]

    val =
      if model.open && model.searchable then
        model.value
      else
        label model

    isReadOnly = not model.searchable || not model.open || model.readonly

    actions =
      Ui.enabledActions model
        [ onInput address Filter
        , onWithDropdownDimensions "focus" address Focus
        , onBlur address Blur
        , onKeysWithDimensions address [ (27, Close)
                                       , (13, Enter)
                                       , (40, Next)
                                       , (38, Prev)
                                       ]
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
select : String -> Model -> (Model, Effects.Effects Action)
select value model =
  { model | selected = Set.singleton value }
  |> sendValue

{-| Closes the dropdown of a chooser. -}
close : Model -> Model
close model =
  Dropdown.close model
  |> setValue ""

{-| Selects or deselects the item with the given value. -}
toggleItem : String -> Model -> (Model, Effects.Effects Action)
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
selectFirst : Model -> (Model, Effects.Effects Action)
selectFirst model =
  case List.head model.data of
    Just item ->
      { model | selected = Set.singleton item.value }
      |> sendValue
    _ ->
      (model, Effects.none)

-- ========================= PRIVATE =========================

-- Sends the current value of the model to the signal
sendValue : Model -> (Model, Effects.Effects Action)
sendValue model =
  (model, Ext.Signal.sendAsEffect model.valueAddress model.selected Tasks)

{- Select or deslect a single item with the given value and closes
the dropdown if needed. -}
toggleItemAndClose : String -> Model -> (Model, Effects.Effects Action)
toggleItemAndClose value model =
  let
    (model, effect) = toggleItem value model
  in
    (closeIfShouldClose model, effect)

-- Toggle item if multiple is True.
toggleMultipleItem : String -> Model -> (Model, Effects.Effects Action)
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
toggleSingleItem : String -> Model -> (Model, Effects.Effects Action)
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
setValue : String -> Model -> Model
setValue value model =
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
renderItem : Item -> Signal.Address Action -> Model -> Html.Html
renderItem item address model =
  let
    selectEvent =
      if model.closeOnSelect then
        onMouseDown address (Select item.value)
      else
        onPreventDefault "mousedown" address (Select item.value)
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
