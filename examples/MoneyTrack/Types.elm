module MoneyTrack.Types where

import Date

{- Represents a transaction. -}
type alias Transaction =
  { id : String
  , amount : Int
  , comment : String
  , category : Category
  , date : Date.Date
  }

{- Represents a category. -}
type alias Category =
  { id : String
  , icon : String
  , name : String
  }

{- Represents an account. -}
type alias Account =
  { id : String
  , initialBalance: Int
  , name : String
  , icon : String
  , transactions : List Transaction
  }

type alias Store =
  { accounts : List Account
  , categories : List Category
  }
