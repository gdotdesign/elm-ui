module Kitchensink.Showcase exposing (..)

import Html exposing (tr, td)


type alias Partial a =
  { a
    | disabled : Bool
    , readonly : Bool
  }


type alias Model component msg parentMsg =
  { update : msg -> component -> ( component, Cmd msg )
  , subscribe : component -> Sub parentMsg
  , subscriptions : component -> Sub msg
  , disabled : component
  , readonly : component
  , enabled : component
  }


type Msg a
  = Enabled a
  | Disabled a
  | Readonly a


subscriptions : Model component msg parentMsg -> Sub (Msg msg)
subscriptions model =
  Sub.batch
    [ Sub.map Enabled (model.subscriptions model.enabled)
    , Sub.map Readonly (model.subscriptions model.readonly)
    , Sub.map Disabled (model.subscriptions model.disabled)
    ]


subscribe : Model component msg parentMsg -> Sub parentMsg
subscribe model =
  Sub.batch
    [ model.subscribe model.enabled
    , model.subscribe model.readonly
    , model.subscribe model.disabled
    ]


init :
  (() -> Partial component)
  -> (msg
      -> Partial component
      -> ( Partial component, Cmd msg )
     )
  -> (Partial component -> Sub parentMsg)
  -> (Partial component -> Sub msg)
  -> Model (Partial component) msg parentMsg
init fn update subscribe subscriptions =
  let
    enabled =
      fn ()

    disabled =
      fn ()

    readonly =
      fn ()
  in
    { enabled = enabled
    , disabled = { disabled | disabled = True }
    , readonly = { readonly | readonly = True }
    , update = update
    , subscribe = subscribe
    , subscriptions = subscriptions
    }


update :
  Msg msg
  -> Model component msg parentMsg
  -> ( Model component msg parentMsg, Cmd (Msg msg) )
update action model =
  case action of
    Enabled act ->
      let
        ( enabled, effect ) =
          model.update act model.enabled
      in
        ( { model | enabled = enabled }, Cmd.map Enabled effect )

    Readonly act ->
      let
        ( readonly, effect ) =
          model.update act model.readonly
      in
        ( { model | readonly = readonly }, Cmd.map Readonly effect )

    Disabled act ->
      let
        ( disabled, effect ) =
          model.update act model.disabled
      in
        ( { model | disabled = disabled }, Cmd.map Disabled effect )


view2 :
  (Msg msg -> parentMsg)
  -> ((msg -> parentMsg) -> component -> Html.Html parentMsg)
  -> Model component msg parentMsg
  -> Html.Html parentMsg
view2 address renderFn model =
  (tr
    []
    [ td [] [ (renderFn (address << Enabled) model.enabled) ]
    , td [] [ (renderFn (address << Readonly) model.readonly) ]
    , td [] [ (renderFn (address << Disabled) model.disabled) ]
    ]
  )


view :
  (Msg msg -> parentMsg)
  -> (component -> Html.Html msg)
  -> Model component msg parentMsg
  -> Html.Html parentMsg
view address renderFn model =
  render address renderFn model


render :
  (Msg msg -> parentMsg)
  -> (component -> Html.Html msg)
  -> Model component msg parentMsg
  -> Html.Html parentMsg
render address renderFn model =
  Html.map
    address
    (tr
      []
      [ td [] [ Html.map Enabled (renderFn model.enabled) ]
      , td [] [ Html.map Readonly (renderFn model.readonly) ]
      , td [] [ Html.map Disabled (renderFn model.disabled) ]
      ]
    )


updateModels :
  (component -> component)
  -> Model component msg parentMsg
  -> Model component msg parentMsg
updateModels fn model =
  { model
    | enabled = fn model.enabled
    , disabled = fn model.disabled
    , readonly = fn model.readonly
  }


updateModelsWithCmd :
  (component -> (component, Cmd msg))
  -> Model component msg parentMsg
  -> (Model component msg parentMsg, Cmd (Msg msg))
updateModelsWithCmd fn model =
  let
    (enabled, enabledMsg) = fn model.enabled
    (disabled, disabledMsg) = fn model.disabled
    (readonly, readonlyMsg) = fn model.readonly
  in
    ({ model
      | enabled = enabled
      , disabled = disabled
      , readonly = readonly
    }, Cmd.batch
    [ Cmd.map Enabled enabledMsg
    , Cmd.map Disabled disabledMsg
    , Cmd.map Readonly readonlyMsg
    ])
