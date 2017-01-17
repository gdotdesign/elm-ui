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

    , display inlineFlex
    , justifyContent center
    , alignItems center
    , textAlign center

    , borderRadius theme.borderRadius
    , userSelect none
    , fontWeight 600

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
      [ backgroundColor theme.colors.disabled.color
      , color theme.colors.disabled.bw
      ]

    , selector "&:not([disabled])"
      [ cursor pointer
      , selector "&[kind=primary]"
        [ backgroundColor theme.colors.primary.color
        , color theme.colors.primary.bw
        ]

      , selector "&[kind=secondary]"
        [ backgroundColor theme.colors.secondary.color
        , color theme.colors.secondary.bw
        ]
      ]
    ]
