module Ui.Helpers.Intendable exposing (..)

{-| Helper functions for intending list items.

# Functions
@docs first, index, select, next, nextItem, previous, previousItem
-}

import List.Extra exposing (last, find, findIndex, splitAt)

{-| Returns the first item of a list.
-}
first : List String -> Maybe String
first list =
  find (\_ -> True) list


{-| Returns the index of the given value in a list.
-}
index : String -> List String -> Int
index value list =
  Maybe.withDefault -1 (findIndex (\item -> item == value) list)


{-| Returns an item with a fallback value.
-}
select : Maybe String -> Maybe String -> String
select item fallback =
  Maybe.withDefault (Maybe.withDefault "" fallback) item


{-| Returns the next selectable item in a list.
-}
next : String -> List String -> String
next value list =
  nextItem (splitAt ((index value list) + 1) list) (first list)


{-| Returns the next selectable item in separated list with a fallback.
-}
nextItem : ( List String, List String ) -> Maybe String -> String
nextItem ( before, after ) fallback =
  select (first after) fallback


{-| Returns the previous selectable item in a list.
-}
previous : String -> List String -> String
previous value list =
  previousItem (splitAt (index value list) list) (last list)


{-| Returns the previous selectable item in separated list with a fallback.
-}
previousItem : ( List String, List String ) -> Maybe String -> String
previousItem ( before, after ) fallback =
  select (last before) fallback
