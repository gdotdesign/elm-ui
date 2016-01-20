module Showcase where

import Signal exposing (forwardTo)
import Html exposing (tr, td)
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
  , render : Signal.Address b -> a -> Html.Html
  , update : b -> a -> (a, Effects.Effects b)
  }

type Action a
  = Enabled a
  | Disabled a
  | Readonly a

init fn address render update =
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
    , render = render
    , update = update
    }

update action model =
  case action of
    Enabled act ->
      let
        (enabled, effect) = model.update act model.enabled
      in
        ({ model | enabled = enabled }, Effects.map Enabled effect)
    _ ->
      (model, Effects.none)

view model =
  tr []
    [ td [] [ model.render model.enabledAddress model.enabled  ]
    , td [] [ model.render model.readonlyAddress model.readonly ]
    , td [] [ model.render model.disabledAddress model.disabled ]
    ]
