module Main where

import StartApp
import Effects
import Signal exposing (forwardTo)
import Task
import List
import Storage.Local
import Html.Extra exposing (onStop)
import Html.Events exposing (onClick)
import Html exposing (div, text)
import Ext.Date
import List.Extra
import Native.Uid
import Date

import Ui.App
import Ui.Pager
import Ui

import Debug exposing (log)

import MoneyTrack.Types as Types exposing (..)
import MoneyTrack.Form as Form

type Action
  = App Ui.App.Action
  | Pager Ui.Pager.Action
  | Form Form.Action
  | SelectPage Int
  | Load
  | Save

accountBalance : Account -> Int
accountBalance account =
  let
    transactionBalance =
      List.map .amount account.transactions
        |> List.foldr (+) 0
  in
    account.initialBalance + transactionBalance

balance : List Account -> Int
balance accounts =
  List.map accountBalance accounts
    |> List.foldr (+) 0

initialCategories : List Category
initialCategories =
  [ { id = "0", name = "Bills", icon = "cash" }
  , { id = "1", name = "Transportation", icon = "android-bus" }
  , { id = "2", name = "Food", icon = "android-cart" }
  ]

populateForm date amount model =
  { model | form = Form.populate model.store date amount model.form }

init =
  ({ app = Ui.App.init
   , pager = Ui.Pager.init 0
   , form = Form.init
   , data = ""
   , store = { categories = initialCategories
             , accounts = [ { id = "0"
                            , initialBalance = 0
                            , name = "Bank Card"
                            , icon = ""
                            , transactions = []
                            }
                          , { id = "1"
                            , initialBalance = 0
                            , name = "Cash"
                            , icon = ""
                            , transactions = []
                            }
                          ]
             }
   }, Effects.task (Task.succeed Load))

view address model =
  Ui.App.view (forwardTo address App) model.app
    [ Ui.Pager.view (forwardTo address Pager)
      [ dashboard address model
      , form address model
      ]
      model.pager
    ]

dashboard address model =
  div []
    [ div [onClick address (SelectPage 1)] [text "Form"]
    ]

form address model =
  let
    viewModel =
      { bottomLeft = div [onStop "mousedown" address (SelectPage 0)] [Ui.icon "close" False []]
      , bottomRight = div [onStop "mousedown" address Save] [Ui.icon "checkmark" False []]
      }
  in
    Form.view (forwardTo address Form) viewModel model.form

update action model =
  case action of
    Form act ->
      ({ model | form = Form.update act model.form }, Effects.none)
    App act ->
      ({ model | app = Ui.App.update act model.app }, Effects.none)
    Pager act ->
      ({ model | pager = Ui.Pager.update act model.pager }, Effects.none)
    SelectPage page ->
      let
        pager = Ui.Pager.select page model.pager
      in
        case page of
          1 ->
            ({ model | pager = pager } |> populateForm 0 Ext.Date.now, Effects.none)
          _ ->
            ({ model | pager = pager }, Effects.none)
    Save ->
      let
        formData = Form.data model.store model.form

        updatedAccount item data =
          let
            transaction = { id = Native.Uid.uid Nothing
                          , amount = data.amount
                          , date = data.date
                          , category = data.category
                          , comment = data.comment
                          }
          in
            if data.account == item then
              { item | transactions = item.transactions ++ [transaction] }
            else
              item

        (updatedAccounts, effect) =
          case formData of
            Just data ->
              ( List.map (\account -> updatedAccount account data ) model.store.accounts
              , Effects.task (Task.succeed (SelectPage 0)))
            _ -> (model.store.accounts, Effects.none)

        updatedStore store =
          { store | accounts = updatedAccounts }
      in
        ({ model | store = updatedStore model.store }, effect)
    Load ->
      case (Storage.Local.getItem "moneytrack-data") of
        Ok data -> ({ model | data = data }, Effects.none)
        Err msg -> (model, Effects.none)

app =
  StartApp.start { init = init
                 , view = view
                 , update = update
                 , inputs = [] }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
