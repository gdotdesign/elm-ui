module Kitchensink.Showcase exposing (..)

import Html exposing (tr, td)
import Html.App

-- where

type alias Partial a =
  { a | disabled : Bool
      , readonly : Bool }

type alias Model component msg =
  { enabled : component
  , disabled : component
  , readonly : component
  , update : msg -> component -> (component, Cmd msg)
  , subscriptions : component -> Sub msg
  }

type Msg a
  = Enabled a
  | Disabled a
  | Readonly a

init : (() -> Partial component)
     -> (msg -> Partial component -> (Partial component, Cmd msg))
     -> (Partial component -> Sub msg)
     -> Model (Partial component) msg
init fn update subscriptions =
  let
    enabled = fn ()
    disabled = fn ()
    readonly = fn ()
  in
    { enabled = enabled
    , disabled = { disabled | disabled = True }
    , readonly = { readonly | readonly = True }
    , update = update
    , subscriptions = subscriptions
    }

update : Msg msg -> Model component msg -> (Model component msg, Cmd (Msg msg))
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

view : ((Msg msg) -> parentMsg) -> (component -> Html.Html msg) -> Model component msg -> Html.Html parentMsg
view address renderFn model =
  render address renderFn model

render : ((Msg msg) -> parentMsg) -> (component -> Html.Html msg) -> Model component msg -> Html.Html parentMsg
render address renderFn model =
  Html.App.map address
    (tr []
      [ td [] [ Html.App.map Enabled (renderFn model.enabled) ]
      , td [] [ Html.App.map Readonly (renderFn model.readonly) ]
      , td [] [ Html.App.map Disabled (renderFn model.disabled) ]
      ])
