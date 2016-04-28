module Kitchensink.Showcase exposing (..)

import Html exposing (tr, td)

-- where

type alias Partial a =
  { a | enabled : Bool
      , disabled : Bool
      , readonly : Bool }

type alias Model a b =
  { enabled : a
  , disabled : a
  , readonly : a
  , enabledAddress : b
  , disabledAddress : b
  , readonlyAddress : b
  , update : b -> a -> (a, Cmd b)
  , handleMove : Int -> Int -> a -> (a, Cmd b)
  , handleClick : Bool -> a -> a
  }

type Action a
  = Enabled a
  | Disabled a
  | Readonly a

init fn address update handleMove handleClick =
  let
    enabledAddress = address Enabled
    disabledAddress = address Disabled
    readonlyAddress = address Readonly

    enabled = fn enabledAddress
    disabled = fn disabledAddress
    readonly = fn readonlyAddress
  in
    { enabled = enabled
    , disabled = { disabled | disabled = True }
    , readonly = { readonly | readonly = True }
    , enabledAddress = enabledAddress
    , disabledAddress = disabledAddress
    , readonlyAddress = readonlyAddress
    , update = update
    , handleMove = handleMove
    , handleClick = handleClick
    }

handleMove x y model =
  let
    (enabled, enabledEffect) = model.handleMove x y model.enabled
    (disabled, disabledEffect) = model.handleMove x y model.disabled
    (readonly, readonlyEffect) = model.handleMove x y model.readonly
    effect =
      [ Cmd.map Enabled enabledEffect
      , Cmd.map Disabled disabledEffect
      , Cmd.map Readonly readonlyEffect
      ] |> Cmd.batch
  in
    ({ model | enabled = enabled
             , disabled = disabled
             , readonly = readonly }, effect)

handleClick pressed model =
  { model | enabled = model.handleClick pressed model.enabled
          , disabled = model.handleClick pressed model.disabled
          , readonly = model.handleClick pressed model.readonly }

update action model =
  case action of
    Enabled act ->
      let
        (enabled, effect) = model.update act model.enabled
      in
        ({ model | enabled = enabled }, Cmd.map Enabled effect)

    Readonly act ->
      let
        (readonly, effect) = model.update act model.readonly
      in
        ({ model | readonly = readonly }, Cmd.map Readonly effect)

    Disabled act ->
      let
        (disabled, effect) = model.update act model.disabled
      in
        ({ model | disabled = disabled }, Cmd.map Disabled effect)

view renderFn model =
  render renderFn model

render renderFn model =
  tr []
    [ td [] [ renderFn model.enabledAddress model.enabled  ]
    , td [] [ renderFn model.readonlyAddress model.readonly ]
    , td [] [ renderFn model.disabledAddress model.disabled ]
    ]
