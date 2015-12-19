module Ui.Chooser
  (Model, Item, Action, init, update, close, toggleItem,
   getFirstSelected, view, updateData, selectFirst) where

{-| This is a component for selecting a single / multiple items
form a list of choises, with lots of options.

# Model
@docs Model, Item, Action, init, update

# View
@docs view

# Functions
@docs toggleItem, close, getFirstSelected, updateData, selectFirst
-}
import Html.Attributes exposing (value, placeholder, readonly, classList, disabled)
import Html.Events exposing (onFocus, onBlur, onClick, onMouseDown)
import Html.Extra exposing (onInput, onPreventDefault, onKeys)
import Html exposing (span, text, node, input, Html)
import Html.Lazy

import Set exposing (Set)
import Native.Browser
import String
import Regex
import List.Extra
import List
import Dict

import Debug exposing (log)

import Ui.Helpers.Intendable as Intendable
import Ui.Helpers.Dropdown as Dropdown

{-| Representation of an selectable item. -}
type alias Item =
  { label : String
  , value : String
  }

{-| Representation of a chooser component:
  - **placeholder** - The text to display when no item is selected
  - **selected** - A *Set* of values of selected items
  - **searchable** - Whether or not a user can filter the items
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **data** - List of items to select from and display in the dropdown
  - **multiple** - Whether or not the user can select multiple items
  - **deselectable** - True if the component can have no selected value false if not
  - **disabled** - Whether or not the chooser is disabled
  - **render** - Function to render the items
  - **value** - (Internal) The value of the input
  - **intended** - (Internal) The currently intended value (for keyboard selection)
  - **open** - Whether or not the dropdown is open
-}
type alias Model =
  { placeholder : String
  , selected : Set String
  , searchable : Bool
  , closeOnSelect : Bool
  , data : List Item
  , multiple : Bool
  , value : String
  , open : Bool
  , deselectable: Bool
  , intended : String
  , disabled : Bool
  , render : Item -> Html
  }

{-| Actions that a chooser can make:
  - **Filter** - Filters the list of choises
  - **Focus** - Opens the dropdown
  - **Close** - Closes the dropdown
  - **Select** - Selects the given value
  - **Next** - Intends the next item for selection
  - **Prev** - Intends the previous item for selection
  - **Enter** - Selects the currently intended selection
-}
type Action
  = Filter String
  | Focus
  | Select String
  | Close
  | Next
  | Prev
  | Enter
  | Nothing

{-| Initializes a chooser with the given values.

    Chooser.init items placeholder selectedValue
-}
init : List Item -> String -> String -> Model
init data placeholder value =
  let
    selected = if value == "" then Set.empty else Set.singleton value
  in
    { data = data
    , searchable = False
    , closeOnSelect = False
    , placeholder = placeholder
    , value = ""
    , selected = selected
    , open = False
    , deselectable = False
    , multiple = False
    , intended = ""
    , disabled = False
    , render = (\item -> span [] [text item.label])
    }
      |> intendFirst

{-| Updates a chooser. -}
update : Action -> Model -> Model
update action model =
  let
    model' =
      case action of
        Filter value ->
          setValue value model
           |> intendFirst

        Focus ->
          Dropdown.open model
           |> intendFirst

        Close ->
          close model

        Enter ->
          toggleItemAndClose model.intended model

        Next ->
          { model | intended = Intendable.next
                                model.intended
                                (availableItems model) }
            |> Dropdown.open

        Prev ->
          { model | intended = Intendable.previous
                                  model.intended
                                  (availableItems model) }
            |> Dropdown.open

        Select value ->
          toggleItemAndClose value model

        _ ->
          model
  in
    model'

{-| Renders a chooser. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Renders a chooser.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    dropdown =
      [ Dropdown.view [] (List.map (\item -> renderItem item address model) (items model)) ]

    val =
      if model.open && model.searchable then
        model.value
      else
        label model
  in
    node "ui-chooser" ([classList [ ("dropdown-open", model.open)
                                  , ("searchable", model.searchable)
                                  , ("disabled", model.disabled)
                                  ]
                       ])
      ([ input [ onInput address Filter
               , onClick address Focus
               , onFocus address Focus
               , onBlur address Close
               , disabled model.disabled
               , onKeys address Nothing (Dict.fromList [ (27, Close)
                                                       , (13, Enter)
                                                       , (40, Next)
                                                       , (38, Prev) ])
               , placeholder model.placeholder
               , value val
               , readonly (not model.searchable || not model.open)
               ] []] ++ dropdown)


{-| Closes the dropdown of a chooser. -}
close : Model -> Model
close model =
  Dropdown.close model
    |> setValue ""

{-| Select or deslect a single item with the given value and closes
the dropdown if needed. -}
toggleItemAndClose : String -> Model -> Model
toggleItemAndClose value model =
  toggleItem value model
    |> closeIfShouldClose

{-| Selects or deselects the item with the given value. -}
toggleItem : String -> Model -> Model
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
selectFirst : Model -> Model
selectFirst model =
  let
    first = List.Extra.find (\_ -> True) model.data
  in
    case first of
      Just item -> { model | selected = Set.singleton item.value }
      _ -> model

{- ========================= PRIVATE ========================= -}

{- Toggle item if multiple is True. -}
toggleMultipleItem : String -> Model -> Model
toggleMultipleItem value model =
  let
    updated_set =
      if Set.member value model.selected then
        if model.deselectable || (List.length (Set.toList model.selected)) > 1 then
          Set.remove value model.selected
        else
          model.selected
      else
        Set.insert value model.selected
  in
   {model | selected = updated_set }

{- Toggle item if multiple is False.  -}
toggleSingleItem : String -> Model -> Model
toggleSingleItem value model =
  if (Set.member value model.selected) && model.deselectable then
    { model | selected = Set.empty }
  else
    { model | selected = Set.singleton value }

{- Intends the first item if it is available. -}
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

{- Sets the value of a chooser. -}
setValue : String -> Model -> Model
setValue value model =
  { model | value = value }

{- Returns the label of a chooser. -}
label : Model -> String
label model =
  List.filter (\item -> Set.member item.value model.selected) model.data
    |> List.map .label
    |> String.join ", "

{- Closes a chooser if indicated -}
closeIfShouldClose : Model -> Model
closeIfShouldClose model =
  if model.closeOnSelect then close model else model

{- Creates a regexp for filtering -}
createRegex : String -> Regex.Regex
createRegex value =
  Regex.escape value
    |> Regex.regex
    |> Regex.caseInsensitive

{- Renders an item -}
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

{- Returns the items to display for a chooser. -}
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

{- Returns the values of available items -}
availableItems : Model -> List String
availableItems model =
  List.map .value (items model)
