module MoneyTrack.Dashboard where

import Number.Format exposing (prettyInt)
import Date.Format exposing (format)
import List.Extra
import Ext.Date
import Date

import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Html exposing (div, text, table, tr, td)

import Ui.Charts.Bar
import Ui.Container
import Ui

import MoneyTrack.Types exposing (..)

type alias Model =
  { date : Date.Date }

type alias ViewModel =
  { optionsHandler : Html.Attribute
  , formHandler : Html.Attribute
  , transactions : List Transaction
  , categories : List Category
  , settings : Settings
  }

type Action
  = NextDate
  | PreviousDate

init =
  { date = Ext.Date.now }

spendingInMonth : List Transaction -> Int
spendingInMonth transactions =
  List.map .amount transactions
    |> List.foldr (+) 0

categoryChart : List Transaction -> List Ui.Charts.Bar.Item
categoryChart transactions =
  let
    mapGroup group =
      let
        first = List.Extra.find (\_ -> True) group
        value = List.foldr (+) 0 (List.map .amount group)
      in
        case first of
          Just item ->
            { label = item.categoryId, value = value }
          _ -> { label = "Unknown", value = value}

  in
    List.sortBy .categoryId transactions
      |> List.Extra.groupBy (\a b -> a.categoryId == b.categoryId)
      |> List.map mapGroup

update: Action -> Model -> Model
update action model =
  case action of
    NextDate ->
      { model | date = Ext.Date.nextMonth model.date }
    PreviousDate ->
      { model | date = Ext.Date.previousMonth model.date }

renderCategory : Category -> List Transaction -> Html.Html
renderCategory category transactions =
  let
    categoryTransactions =
      List.filter (\item -> item.categoryId == category.id) transactions
    sum =
      List.map .amount categoryTransactions
        |> List.foldr (+) 0
  in
    div [style [("font-size", "20px")
               ,("margin-bottom", "20px")]]
      [ Ui.Container.view { align = "stretch"
                        , direction = "row"
                        , compact = False
                        } []
        [ div [] [text category.name]
        , div [style [("margin-left", "auto")]] [text (prettyInt ',' sum)]
        ]
      , table [style [("margin-left", "10px")]] (List.map renderTransaction categoryTransactions)
      ]

renderTransaction : Transaction -> Html.Html
renderTransaction transaction =
  tr []
    [ td [] [text (format "%Y-%m-%d" transaction.date)]
    , td [] [text (prettyInt ',' transaction.amount)]
    ]

view: Signal.Address Action -> ViewModel -> Model -> Html.Html
view address viewModel model =
  let
    {- Transactions in the selected month. -}
    transactions =
      List.filter
        (\transaction -> Ext.Date.isSameMonth transaction.date model.date)
        viewModel.transactions

    {- Spending in the selected month. -}
    spending =
      (viewModel.settings.prefix ++ " ") ++
        (prettyInt ',' (spendingInMonth transactions)) ++
        (" " ++ viewModel.settings.affix)
  in
    Ui.Container.view { align = "stretch"
                      , direction = "column"
                      , compact = True
                      } []
      [ Ui.header []
        [ Ui.headerTitle [] [text "Dashboard"]
        , Ui.spacer
        , Ui.icon "android-options" False [viewModel.optionsHandler]
        ]
      , Ui.panel [style [("flex", "1"),("overflow", "auto")]]
        [ Ui.Container.view { align = "stretch"
                            , direction = "column"
                            , compact = False
                            } []
          [ Ui.Container.view { align = "stretch"
                              , direction = "row"
                              , compact = False
                              } []
            [ Ui.icon "chevron-left" True [onClick address PreviousDate]
            , div
              [ style [ ("text-align", "center")
                      , ("flex", "1")
                      ]
              ]
              [text (format "%B, %Y" model.date)]
            , Ui.icon "chevron-right" True [onClick address NextDate]
            ]
          , div
            [ style [ ("text-align", "center")
                    , ("font-size", "30px")
                    ]
            ]
            [text spending]
          , Ui.Charts.Bar.view address { items = categoryChart transactions
                                       , affix = viewModel.settings.affix
                                       , prefix = viewModel.settings.prefix
                                       }
          , Ui.fab "plus" [viewModel.formHandler]
          , div [] (List.map (\c -> renderCategory c transactions) viewModel.categories)
          ]
        ]
      ]
