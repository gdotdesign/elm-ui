module Ui.Styles.Button exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Ripple as Ripple
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  selector "ui-button"
    [ Ripple.style

    , fontFamily theme.fontFamily

    , justifyContent center
    , display inlineFlex
    , alignItems center
    , textAlign center

    , borderRadius theme.borderRadius
    , userSelect none
    , cursor pointer
    , fontWeight 700

    , selector "span"
      [ Mixins.ellipsis
      ]

    , selector "> *"
      [ pointerEvents none ]

    , selector "&:focus"
      [ outline none ]

    , selector "&[size=medium]"
      [ padding (zero . (px 24))
      , fontSize (px 16)
      , height (px 36)
      ]

    , selector "&[size=big]"
      [ padding (zero . (px 30))
      , fontSize (px 22)
      , height (px 50)
      ]

    , selector "&[size=small]"
      [ padding (zero . (px 16))
      , fontSize (px 12)
      , height (px 26)
      ]

    , selector "&[disabled]"
      [ Mixins.disabledColors theme
      , Mixins.disabled
      ]

    , selector "&[readonly]"
      [ Mixins.readonly ]

    , selector "&:not([disabled])"
      [ selector "&[kind=primary]"
        [ backgroundColor theme.colors.primary.color
        , color theme.colors.primary.bw
        ]

      , selector "&[kind=secondary]"
        [ backgroundColor theme.colors.secondary.color
        , color theme.colors.secondary.bw
        ]

      , selector "&[kind=warning]"
        [ backgroundColor theme.colors.warning.color
        , color theme.colors.warning.bw
        ]

      , selector "&[kind=success]"
        [ backgroundColor theme.colors.success.color
        , color theme.colors.success.bw
        ]

      , selector "&[kind=danger]"
        [ backgroundColor theme.colors.danger.color
        , color theme.colors.danger.bw
        ]
      ]
    ]
