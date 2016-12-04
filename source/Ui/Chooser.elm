module Ui.Chooser exposing
  ( Model, Item, Msg, init, subscribe, update, view, render, subscriptions
  , close, toggleItem, getFirstSelected, updateData, selectFirst, setValue )

{-| This is a component for selecting a single / multiple items
form a list of choises, with lots of options.

# Model
@docs Model, Item, Msg, init, subscribe, subscriptions, update

# View
@docs view, render

# Functions
@docs setValue, toggleItem, close, getFirstSelected, updateData, selectFirst
-}

import Html.Events exposing (onFocus, onBlur, onClick, onInput, onMouseDown)
import Html.Events.Extra exposing (onPreventDefault, onKeys)
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
import Ui.Native.Uid as Uid
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
  { dropdown : Dropdown.Dropdown
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
  }


{-| Messages that a chooser can recieve.
-}
type Msg
  = Toggle
  | Focus
  | Close
  | Enter
  | Next
  | Prev
  | Dropdown Dropdown.Msg
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
    , dropdown = Dropdown.init
    , placeholder = placeholder
    , uid = Uid.uid ()
    , closeOnSelect = False
    , deselectable = False
    , selected = selected
    , searchable = False
    , multiple = False
    , disabled = False
    , readonly = False
    , intended = ""
    , data = data
    , value = ""
    }
      |> intendFirst
      |> Dropdown.offset 5


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

{-| Subscriptions for a dropdown menu.

    ...
    subscriptions =
      \model ->
        Sub.map
          DropdownMenu
          (Ui.DropdownMenu.subscriptions model.dropdownMenu)
    ...
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map Dropdown (Dropdown.subscriptions model)

{-| Updates a chooser.

    Ui.Chooser.update msg chooser
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Enter ->
      let
        ( updatedModel, effect ) =
          toggleItem model.intended model

        fn =
          if model.closeOnSelect then
            Dropdown.toggle
          else
            Dropdown.open
      in
        ( fn updatedModel, effect )

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
      (List.map (renderItem model) (items model))

    val =
      if model.dropdown.open && model.searchable then
        model.value
      else
        label model

    isReadOnly =
      not model.searchable || not model.dropdown.open || model.readonly

    actions =
      Ui.enabledActions
        model
        [ onInput Filter
        , onBlur Blur
        , onMouseDown Toggle
        , onFocus Focus
        , onKeys
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
      { tag = "ui-chooser"
      , address = Dropdown
      , attributes =
        [ classList
          [ ( "searchable", model.searchable )
          , ( "disabled", model.disabled )
          , ( "readonly", model.readonly )
          ]
       ]
      , contents = [ (Ui.scrolledPanel children)]
      , children =
        [ input
          ([ placeholder model.placeholder
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
  node
    "ui-chooser-item"
    [ onPreventDefault "mousedown" (Select item.value)
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
