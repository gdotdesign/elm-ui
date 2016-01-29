module Ext.DateTests where

import ElmTest exposing (..)

import Ext.Date
import Date

tests : Test
tests =
  suite "Ext.Date"
    [ agoTests ]


ago : Float -> String
ago diff =
  let
    base = Ext.Date.createDate 2015 1 1
    now = Date.fromTime ((Date.toTime base) + diff)
  in
    Ext.Date.ago base now

agoTests : Test
agoTests =
  suite "#ago" (List.map (\(name, assert) -> test name assert)
    [ ("should render seconds branch", (assertEqual (ago 25000) "just now"))
    , ("should render mintue branch", (assertEqual (ago 61000) "a minute ago"))
    , ("should render mintues branch", (assertEqual (ago 120000) "2 minutes ago"))
    , ("should render hour branch", (assertEqual (ago 3610000) "an hour ago"))
    , ("should render hours branch", (assertEqual (ago 7200000) "2 hours ago"))
    , ("should render day branch", (assertEqual (ago 86600000) "a day ago"))
    , ("should render days branch", (assertEqual (ago 172800000) "2 days ago"))
    , ("should render month branch", (assertEqual (ago 2728000000) "a month ago"))
    , ("should render months branch", (assertEqual (ago 5256000000) "2 months ago"))
    , ("should render year branch", (assertEqual (ago 41536000000) "a year ago"))
    , ("should render years branch", (assertEqual (ago 63072000000) "2 years ago"))
    ])
