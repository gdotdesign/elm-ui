module Ui.Chooser exposing
  ( Model, Item, Msg, init, subscribe, update, view, render
  , close, toggleItem, getFirstSelected, updateData, selectFirst, setValue )

{-| This is a component for selecting a single / multiple items
form a list of choises, with lots of options.

# Model
@docs Model, Item, Msg, init, subscribe, update

# View
@docs view, render

# Functions
@docs setValue, toggleItem, close, getFirstSelected, updateData, selectFirst
-}

import Html.Events exposing (onFocus, onBlur, onClick, onInput)
import Html.Events.Extra exposing (onPreventDefault, onStop)
import Html exposing (span, text, node, input, Html)
import Html.Lazy

import Html.Attributes
  exposing
    ( value
    , placeholder
    , attribute
    , readonly
    , classList
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
import Ui


{-| Representation of an selectable item.
-}
type alias Item =
  { label : String
  , value : String
  }


{-| Representation of a chooser:
  - **dropdownPosition** - Where the dropdown is positioned
  - **render** - Function to render the items
  - **selected** - A *Set* of values of selected items
  - **placeholder** - The text to display when no item is selected
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **deselectable** - Whether or not it can have no selected value
  - **intended** - The currently intended value (for keyboard selection)
  - **searchable** - Whether or not a user can filter the items
  - **data** - List of items to select from and display in the dropdown
  - **multiple** - Whether or not the user can select multiple items
  - **disabled** - Whether or not the chooser is disabled
  - **readonly** - Whether or not the chooser is readonly
  - **value** - The value of the input
  - **uid** - The unique identifier of the chooser
  - **open** - Whether or not the dropdown is open
-}
type alias Model =
  { dropdownPosition : String
  , render : Item -> Html Msg
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
  , open : Bool
  }


{-| Messages that a chooser can recieve.
-}
type Msg
  = Toggle Dropdown.Dimensions
  | Focus Dropdown.Dimensions
  | Close Dropdown.Dimensions
  | Enter Dropdown.Dimensions
  | Next Dropdown.Dimensions
  | Prev Dropdown.Dimensions
  | Filter String
  | Select String
  | NoOp
  | Blur


{-| Initializes a chooser with the given values.

    chooser = Ui.Chooser.init items placeholder selectedValue
-}
init : List Item -> String -> String -> Model
init data placeholder value =
  let
    selected =
      if value == "" then
        Set.empty
      else
        Set.singleton value
  in
    { render = (\item -> span [] [ text item.label ])
    , dropdownPosition = "bottom"
    , placeholder = placeholder
    , uid = Native.Uid.uid ()
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


{-| Subscribe to the changes of a chooser.

    ...
    subscriptions =
      \model -> Ui.Chooser.subscribe ChooserChanged model.chooser
    ...
-}
subscribe : (Set String -> msg) -> Model -> Sub msg
subscribe msg model =
  let
    decoder =
      JD.list JD.string
        |> JD.map Set.fromList
  in
    Emitter.listen model.uid (Emitter.decode decoder Set.empty msg)


{-| Updates a chooser.

    Ui.Chooser.update msg chooser
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Enter dimensions ->
      let
        ( updatedModel, effect ) =
          toggleItem model.intended model

        fn =
          if model.closeOnSelect then
            Dropdown.toggleWithDimensions
          else
            Dropdown.openWithDimensions
      in
        ( fn dimensions updatedModel, effect )

    Select value ->
      toggleItemAndClose value model

    Filter value ->
      ( intendFirst <| setInputValue value model, Cmd.none )

    Toggle dimensions ->
      ( intendFirst <| Dropdown.toggleWithDimensions dimensions model, Cmd.none )

    Focus dimensions ->
      ( intendFirst <| Dropdown.openWithDimensions dimensions model, Cmd.none )

    Close _ ->
      ( close model, Cmd.none )

    Blur ->
      ( close model, Cmd.none )

    Next dimensions ->
      ( { model
          | intended =
              Intendable.next
                model.intended
                (availableItems model)
        }
          |> Dropdown.openWithDimensions dimensions
      , Cmd.none
      )

    Prev dimensions ->
      ( { model
          | intended =
              Intendable.previous
                model.intended
                (availableItems model)
        }
          |> Dropdown.openWithDimensions dimensions
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
      (List.map (renderItem model) (items model))

    dropdown =
      [ Dropdown.view
          NoOp
          model.dropdownPosition
          [ (Ui.scrolledPanel children) ]
      ]

    val =
      if model.open && model.searchable then
        model.value
      else
        label model

    isReadOnly =
      not model.searchable || not model.open || model.readonly

    actions =
      Ui.enabledActions
        model
        [ onInput Filter
        , onBlur Blur
        , Dropdown.onWithDimensions "mousedown" Toggle
        , Dropdown.onWithDimensions "focus" Focus
        , Dropdown.onKeysWithDimensions
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
    node
      "ui-chooser"
      ([ classList
          [ ( "searchable", model.searchable )
          , ( "dropdown-open", model.open )
          , ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
       ]
      )
      ([ input
          ([ placeholder model.placeholder
           , attribute "uid" model.uid
           , disabled model.disabled
           , readonly isReadOnly
           , value val
           ]
            ++ actions
          )
          []
       ]
        ++ dropdown
      )


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



----------------------------------- PRIVATE ------------------------------------


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
    ( model, effect ) =
      toggleItem value model
  in
    ( closeIfShouldClose model, effect )


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



{- Toggle item if multiple is False. -}


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



{- Intends the first item if it is available. -}


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



{- Sets the value of a chooser. -}


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
  let
    selectEvent =
      if model.closeOnSelect then
        onStop "mouseup" (Select item.value)
      else
        onPreventDefault "mousedown" (Select item.value)
  in
    node
      "ui-chooser-item"
      [ selectEvent
      , classList
          [ ( "selected", Set.member item.value model.selected )
          , ( "intended", item.value == model.intended )
          ]
      ]
      [ model.render item ]


{-| Returns the items to display for a chooser.
-}
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


{-| Returns the values of available items
-}
availableItems : Model -> List String
availableItems model =
  List.map .value (items model)
