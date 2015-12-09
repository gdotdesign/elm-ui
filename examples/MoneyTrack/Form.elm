module MoneyTrack.Form where

import Signal exposing (forwardTo)
import List.Extra
import Ext.Date
import Html
import Date

import Ui.NumberPad
import Ui.Chooser
import Ui.DatePicker
import Ui.Container
import Ui

import MoneyTrack.Types as Types exposing (..)

type Action
  = NumberPad Ui.NumberPad.Action
  | AccountChooser Ui.Chooser.Action
  | CategoryChooser Ui.Chooser.Action
  | DatePicker Ui.DatePicker.Action

type alias Model =
  { numberPad : Ui.NumberPad.Model
  , categoryChooser : Ui.Chooser.Model
  , accountChooser : Ui.Chooser.Model
  , datePicker : Ui.DatePicker.Model
  }

type alias ViewModel =
  { bottomLeft : Html.Html
  , bottomRight : Html.Html
  }

type alias Data =
  { account : Account
  , category : Category
  , date : Date.Date
  , comment : String
  , amount : Int
  }

init : Model
init =
  let
    datePicker      = Ui.DatePicker.init Ext.Date.now
    accountChooser  = Ui.Chooser.init [] "Account..." ""
    categoryChooser = Ui.Chooser.init [] "Category..." ""
  in
    { numberPad       = Ui.NumberPad.init 0
    , categoryChooser = { categoryChooser | closeOnSelect = True }
    , accountChooser  = { accountChooser | closeOnSelect = True }
    , datePicker      = { datePicker | closeOnSelect = True }
    }

populate : Store
         -> Int
         -> Date.Date
         -> Model
         -> Model
populate store amount date model =
  let
    mapItem item = { value = item.id, label = item.name }
    categories = List.map mapItem store.categories
    accounts = List.map mapItem store.accounts
  in
    { model | categoryChooser = Ui.Chooser.updateData categories model.categoryChooser
            , accountChooser  = Ui.Chooser.updateData accounts model.accountChooser
            , datePicker = Ui.DatePicker.setValue date model.datePicker
            , numberPad = Ui.NumberPad.setValue amount model.numberPad
            }


buildData : Account -> Category -> Int -> Model -> Data
buildData account category amount model =
  { category = category
  , account  = account
  , date     = model.datePicker.calendar.value
  , amount   = amount
  , comment  = ""
  }

data : Store -> Model -> Maybe Data
data store model =
  let
    find id' list =
      Maybe.andThen id' (\id -> List.Extra.find (\item -> item.id == id) list)

    account' =
      find (Ui.Chooser.getFirstSelected model.accountChooser) store.accounts

    category' =
      find (Ui.Chooser.getFirstSelected model.categoryChooser) store.categories

    amount' =
      if model.numberPad.value == 0 then
        Nothing
      else
        Just model.numberPad.value
  in
    Maybe.map4 buildData account' category' amount' (Just model)

update : Action -> Model -> Model
update action model =
  case action of
    NumberPad act ->
      { model | numberPad = Ui.NumberPad.update act model.numberPad }
    AccountChooser act ->
      { model | accountChooser = Ui.Chooser.update act model.accountChooser }
    CategoryChooser act ->
      { model | categoryChooser = Ui.Chooser.update act model.categoryChooser }
    DatePicker act ->
      { model | datePicker = Ui.DatePicker.update act model.datePicker }

view : Signal.Address Action -> ViewModel -> Model -> Html.Html
view address viewModel model =
  Ui.panel []
    [ Ui.Container.view { align = "stretch"
                      , direction = "column"
                      , compact = False
                      } []
      [ Ui.inputGroup "Date" (Ui.DatePicker.view (forwardTo address DatePicker) model.datePicker)
      , Ui.inputGroup "Account" (Ui.Chooser.view (forwardTo address AccountChooser) model.accountChooser)
      , Ui.inputGroup "Category" (Ui.Chooser.view (forwardTo address CategoryChooser) model.categoryChooser)
      , Ui.NumberPad.view
          (forwardTo address NumberPad)
          viewModel
          model.numberPad
      ]
    ]
