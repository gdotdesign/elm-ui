module MoneyTrack.Types where

import Json.Encode as J
import Json.Decode.Extra as JsonExtra
import Json.Decode as Json exposing ((:=))
import Date.Format exposing (format)
import Date

{- Represents a transaction. -}
type alias Transaction =
  { id : String
  , amount : Int
  , comment : String
  , categoryId : String
  , accountId : String
  , date : Date.Date
  }

transactionDecoder =
  Json.object6 Transaction
    ("id" := Json.string)
    ("amount" := Json.int)
    ("comment" := Json.string)
    ("categoryId" := Json.string)
    ("accountId" := Json.string)
    ("date" := JsonExtra.date )

transactionEncoder transaction =
  J.object
    [ ("id", J.string transaction.id)
    , ("amount", J.int transaction.amount)
    , ("comment", J.string transaction.comment)
    , ("categoryId", J.string transaction.categoryId)
    , ("accountId", J.string transaction.accountId)
    , ("date", J.string (format "%Y-%m-%d" transaction.date))
    ]

{- Represents a category. -}
type alias Category =
  { id : String
  , icon : String
  , name : String
  }

unkownCategory =
  { id = ""
  , icon = ""
  , name = "Unkown"
  }

categoryDecoder =
  Json.object3 Category
    ("id" := Json.string)
    ("icon" := Json.string)
    ("name" := Json.string)

categoryEncoder category =
  J.object
    [ ("id", J.string category.id)
    , ("icon", J.string category.icon)
    , ("name", J.string category.name)
    ]

{- Represents an account. -}
type alias Account =
  { id : String
  , initialBalance: Int
  , name : String
  , icon : String
  }

accountDecoder =
  Json.object4 Account
    ("id" := Json.string)
    ("initialBalance" := Json.int)
    ("name" := Json.string)
    ("icon" := Json.string)

accountEncoder account =
  J.object
    [ ("id", J.string account.id)
    , ("initialBalance", J.int account.initialBalance)
    , ("name", J.string account.name)
    , ("icon", J.string account.icon)
    ]

{- Represents a user sessions data. -}
type alias Store =
  { accounts : List Account
  , categories : List Category
  , transactions : List Transaction
  , settings : Settings
  }

type alias Settings =
  { prefix : String
  , affix : String
  }

settingsDecoder =
  Json.object2 Settings
    ("prefix" := Json.string )
    ("affix" := Json.string )

settingsEncoder settings =
  J.object
    [ ("prefix", J.string settings.prefix)
    , ("affix", J.string settings.affix)
    ]

storeDecoder =
  Json.object4 Store
    ("accounts" := Json.list accountDecoder)
    ("categories" := Json.list categoryDecoder)
    ("transactions" := Json.list transactionDecoder)
    ("settings" := settingsDecoder)

storeEncoder store =
  J.object
    [ ("accounts", J.list (List.map accountEncoder store.accounts) )
    , ("categories", J.list (List.map categoryEncoder store.categories) )
    , ("transactions", J.list (List.map transactionEncoder store.transactions) )
    , ("settings", settingsEncoder store.settings)
    ]

updateStoreSettings settings store =
  { store | settings = settings }
