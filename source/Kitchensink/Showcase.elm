module Kitchensink.Showcase where

import Signal exposing (forwardTo)
import Html exposing (tr, td)
import Html.Lazy
import Effects

type alias Partial a =
  { a | enabled : Bool
      , disabled : Bool
      , readonly : Bool }

type alias Model a b =
  { enabled : a
  , disabled : a
  , readonly : a
  , enabledAddress : Signal.Address b
  , disabledAddress : Signal.Address b
  , readonlyAddress : Signal.Address b
  , update : b -> a -> (a, Effects.Effects b)
  , handleMove : Int -> Int -> a -> (a, Effects.Effects b)
  , handleClick : Bool -> a -> a
  }

type Action a
  = Enabled a
  | Disabled a
  | Readonly a

init fn address update handleMove handleClick =
  let
    enabledAddress = forwardTo address Enabled
    disabledAddress = forwardTo address Disabled
    readonlyAddress = forwardTo address Readonly

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
      [ Effects.map Enabled enabledEffect
      , Effects.map Disabled disabledEffect
      , Effects.map Readonly readonlyEffect
      ] |> Effects.batch
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
        ({ model | enabled = enabled }, Effects.map Enabled effect)

    Readonly act ->
      let
        (readonly, effect) = model.update act model.readonly
      in
        ({ model | readonly = readonly }, Effects.map Readonly effect)

    Disabled act ->
      let
        (disabled, effect) = model.update act model.disabled
      in
        ({ model | disabled = disabled }, Effects.map Disabled effect)

view renderFn model =
  Html.Lazy.lazy2 render renderFn model

render renderFn model =
  tr []
    [ td [] [ renderFn model.enabledAddress model.enabled  ]
    , td [] [ renderFn model.readonlyAddress model.readonly ]
    , td [] [ renderFn model.disabledAddress model.disabled ]
    ]
