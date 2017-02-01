module Ui.Styles.NotificationCenter exposing (..)

{-| Styles for a notification center.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a notification center using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a notification center using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , keyframes "ui-notification-show"
      [ "0%" =>
        [ transform
          [ translateX (pct 100)
          , translateX (px 50)
          ]
        , opacity 0
        ]
      , "100%" =>
        [ transform [ translateX zero ]
        , opacity 1
        ]
      ]

    , keyframes "ui-notification-hide"
      [ "0%" =>
        [ transform [ translateX zero ]
        , marginBottom (px 10)
        , maxHeight (px 100)
        , opacity 1
        ]
      , "50%" =>
        [ transform
          [ translateX (pct 100)
          , translateX (px 50)
          ]
        , marginBottom (px 10)
        , maxHeight (px 100)
        , opacity 0
        ]
      , "100%" =>
        [ transform
          [ translateX (pct 100)
          , translateX (px 50)
          ]
        , marginBottom zero
        , maxHeight zero
        , opacity 0
        ]
      ]

    , transform [ translate3d zero zero zero ]
    , zIndex theme.zIndexes.notifications
    , position fixed
    , right (px 20)
    , top (px 20)

    , flexDirection column
    , alignItems flexEnd
    , display flex

    , selector "ui-notification"
      [ fontFamily theme.fontFamily
      , marginBottom (px 10)
      , maxHeight (px 100)
      , overflow visible
      , display block

      , boxShadow
        [ { color = "rgba(0, 0, 0, 0.5)"
          , blur = (px 10)
          , inset = False
          , spread = zero
          , x = zero
          , y = zero
          }
        ]

      , selector "&:hover"
        [ cursor pointer

        , selector "ui-notification-body"
          [ background "rgba(34, 34, 34, 0.8)"
          ]
        ]
      ]

    , selector "ui-notification-body"
      [ background "rgba(17, 17, 17, 0.8)"
      , borderRadius theme.borderRadius
      , padding ((px 14) . (px 24))
      , fontWeight bold
      , display block
      , color "#FFF"
      ]

    , selector "[ui-notification-show]"
      [ animation
        [ { easing = "cubic-bezier(0.645, 0.045, 0.355, 1)"
          , name = "ui-notification-show"
          , playState = "running"
          , iterationCount = "1"
          , direction = "normal"
          , duration = (ms 0)
          , fillMode = "both"
          , delay = (ms 0)
          }
        ]
      ]

    , selector "[ui-notification-hide]"
      [ animation
        [ { easing = "cubic-bezier(0.645, 0.045, 0.355, 1)"
          , name = "ui-notification-hide"
          , playState = "running"
          , iterationCount = "1"
          , direction = "normal"
          , duration = (ms 0)
          , fillMode = "both"
          , delay = (ms 0)
          }
        ]
      ]
    ]


{-| Inflix 2 tuple.
-}
(=>) : a -> b -> ( a , b )
(=>) = (,)
