module Main where

import StartApp
import Effects
import Signal exposing (forwardTo)
import Task
import List
import Storage.Local
import Html exposing (div, text)

import Ui.NumberPad
import Ui.App
import Ui

type alias ID = Int

type Action
  = App Ui.App.Action
  | NumberPad Ui.NumberPad.Action
  | Load

{- Represents a transaction. -}
type alias Transaction =
  { id : ID
  , amount : Int
  , comment : String
  , category : Category
  }

{- Represents a category. -}
type alias Category =
  { id : ID
  , icon : String
  , name : String
  }

{- Represents an account. -}
type alias Account =
  { id : ID
  , initialBalance: Int
  , name : String
  , icon : String
  , transactions : List Transaction
  }

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
  [ { id = 0, name = "Bills", icon = "cash" }
  , { id = 0, name = "Transportation", icon = "android-bus" }
  , { id = 0, name = "Food", icon = "android-cart" }
  ]

init =
  ({ app = Ui.App.init
   , numberPad = Ui.NumberPad.init 0
   , data = ""
   , categories = initialCategories
   , accounts = [ { id = 0
                  , initialBalance = 0
                  , name = "Bank Card"
                  , icon = ""
                  , transactions = []
                  }
                , { id = 1
                  , initialBalance = 0
                  , name = "Cash"
                  , icon = ""
                  , transactions = []
                  }
                ]
   }, Effects.task (Task.succeed Load))

view address model =
  Ui.App.view (forwardTo address App) model.app
    [ dashboard address model
    , form address model ]

dashboard address model =
  div [] [text (toString (balance model.accounts))]

form address model =
  let
    numberPadView = { bottomLeft = div [] [Ui.icon "close" False []]
                    , bottomRight = div [] [Ui.icon "checkmark" False []]
                    }
  in
    div [] [Ui.NumberPad.view (forwardTo address NumberPad) numberPadView model.numberPad]

update action model =
  case action of
    App act ->
      ({ model | app = Ui.App.update act model.app }, Effects.none)
    NumberPad act ->
      ({ model | numberPad = Ui.NumberPad.update act model.numberPad }, Effects.none)
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
