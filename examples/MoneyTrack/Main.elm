module Main where

import StartApp
import Effects
import Signal exposing (forwardTo)
import Task
import List
import List.Extra
import Storage.Local
import Html.Attributes exposing (style, classList)
import Html.Extra exposing (onStop)
import Html.Events exposing (onClick)
import Html exposing (div, text, node)
import Ext.Date
import Date.Format exposing (format)
import List.Extra
import Json.Encode
import Json.Decode as Json
import Number.Format exposing (prettyInt)
import Native.Uid
import Date
import Window

import Ui.Container
import Ui.Charts.Bar
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
  | NextDate
  | PreviousDate
  | Save
  | Width Int

spendingInMonth : Date.Date -> List Transaction -> Int
spendingInMonth date transactions =
  List.filter (\transaction -> Ext.Date.isSameMonth transaction.date date) transactions
    |> List.map .amount
    |> List.foldr (+) 0

initialCategories : List Category
initialCategories =
  [ { id = "0", name = "Bills", icon = "cash" }
  , { id = "1", name = "Transportation", icon = "android-bus" }
  , { id = "2", name = "Food", icon = "android-cart" }
  ]

categoryChart date model =
  let
    mapGroup group =
      let
        first = List.Extra.find (\_ -> True) group
        value = List.foldr (+) 0 (List.map .amount group)
      in
        case first of
          Just item ->
            { label = item.categoryId, value = value }
          _ -> { label = "unknownd", value = value}

  in
    List.filter (\transaction -> Ext.Date.isSameMonth transaction.date date) model.transactions
      |> List.sortBy .categoryId
      |> List.Extra.groupBy (\a b -> a.categoryId == b.categoryId)
      |> List.map mapGroup

populateForm date amount model =
  { model | form = Form.populate model.store date amount model.form }

type alias Model =
  { app : Ui.App.Model
  , pager : Ui.Pager.Model
  , form : Form.Model
  , data : String
  , store : Store
  }

init =
  ({ app = Ui.App.init
   , pager = Ui.Pager.init 0
   , form = Form.init
   , date = Ext.Date.now
   , data = ""
   , width = 0
   , store = { categories = initialCategories
             , transactions = []
             , accounts = [ { id = "0"
                            , initialBalance = 0
                            , name = "Bank Card"
                            , icon = ""
                            }
                          , { id = "1"
                            , initialBalance = 0
                            , name = "Cash"
                            , icon = ""
                            }
                          ]
             }
   }, Effects.task (Task.succeed Load))

view address model =
  let
    app =
      div [classList [("money-track", True)]]
        [ Ui.Pager.view (forwardTo address Pager)
            [ dashboard address model
            , form address model
            , settings address model
            ]
            model.pager
        ]
    app2 = if model.width < 700 then app else node "ui-mobile" [] [app]
  in
    Ui.App.view (forwardTo address App) model.app [app2]

settings address model =
  Ui.Container.view { align = "stretch"
                    , direction = "column"
                    , compact = True
                    } []
    [ Ui.header []
      [ Ui.icon "android-arrow-back" False [onClick address (SelectPage 0)]
      , Ui.headerTitle [] [text "Settings"]
      ]
    , div [] [text "a"]
    ]

dashboard address model =
  let
    spending = prettyInt ',' (spendingInMonth model.date model.store.transactions)
  in
    Ui.Container.view { align = "stretch"
                      , direction = "column"
                      , compact = True
                      } []
      [ Ui.header []
        [ Ui.headerTitle [] [text "MoneyTrack"]
        , Ui.spacer
        , Ui.icon "android-options" False [onClick address (SelectPage 2)]
        ]
      , Ui.panel []
        [ Ui.Container.view { align = "stretch"
                            , direction = "column"
                            , compact = False
                            } []
          [ Ui.Container.view { align = "stretch"
                              , direction = "row"
                              , compact = False
                              } []
              [ Ui.icon "chevron-left" False [onClick address PreviousDate]
              , div [style [("text-align", "center"),("flex", "1")]] [text (format "%B, %Y" model.date)]
              , Ui.icon "chevron-right" False [onClick address NextDate]
              ]
          , div [ style [ ("text-align", "center")
                        , ("font-size", "30px")
                        ]
                ]
            [text spending]
          , Ui.Charts.Bar.view address { items = categoryChart model.date model.store }
          , div [onClick address (SelectPage 1)] [text "Form"]
          ]
        ]
      ]

form address model =
  let
    viewModel =
      { bottomLeft = div [onStop "mousedown" address (SelectPage 0)] [Ui.icon "close" False []]
      , bottomRight = div [onStop "mousedown" address Save] [Ui.icon "checkmark" False []]
      , backHandler = onStop "mousedown" address (SelectPage 0)
      }
  in
    Form.view (forwardTo address Form) viewModel model.form

update action model =
  let
    (updatedModel, effect) = update' action model
  in
    (updatedModel |> saveStore, effect)

saveStore model =
  case Storage.Local.setItem "moneytrack-data" (Json.Encode.encode 0 (storeEncoder model.store)) of
    _ -> model

update' action model =
  case action of
    Form act ->
      ({ model | form = Form.update act model.form }, Effects.none)
    App act ->
      ({ model | app = Ui.App.update act model.app }, Effects.none)
    NextDate ->
      ({ model | date = Ext.Date.nextMonth model.date }, Effects.none)
    PreviousDate ->
      ({ model | date = Ext.Date.previousMonth model.date }, Effects.none)
    Pager act ->
      ({ model | pager = Ui.Pager.update act model.pager }, Effects.none)
    Width width ->
      ({ model | width = width }, Effects.none)
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

        transaction data =
          { id = Native.Uid.uid Nothing
          , amount = data.amount
          , date = data.date
          , categoryId = data.categoryId
          , accountId = data.accountId
          , comment = data.comment
          }

        updatedStore store =
          { store | transactions = transactions }

        (transactions, effect) =
          case formData of
            Just data ->
              (model.store.transactions ++ [transaction data], Effects.task (Task.succeed (SelectPage 0)))
            _ -> (model.store.transactions, Effects.none)
      in
        ({ model | store = updatedStore model.store }, effect)
    Load ->
      case (Storage.Local.getItem "moneytrack-data") of
        Ok data ->
          let
            store =
              case Json.decodeString storeDecoder data of
                Ok s -> s
                Err msg -> log msg model.store
          in
            ({ model | store = store }, Effects.none)
        Err msg -> (model, Effects.none)

app =
  StartApp.start { init = init
                 , view = view
                 , update = update
                 , inputs = [Signal.map Width Window.width] }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
