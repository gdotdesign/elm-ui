module Ui.Styles.NotificationCenter exposing (..)

{-| Styles for a notification center.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a notification center.
-}
style : Style
style =
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

  , zIndex (var "ui-notification-center-z-index" "2000")
  , transform [ translate3d zero zero zero ]
  , position fixed
  , right (px 20)
  , top (px 20)

  , flexDirection column
  , alignItems flexEnd
  , display flex

  , selector "ui-notification"
    [ fontFamily (varf "ui-notification-center-font-family" "font-family")
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
    [ borderRadius (varf "ui-notification-center-border-radius" "border-radius")
    , background "rgba(17, 17, 17, 0.8)"
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
  |> mixin
  |> Ui.Styles.attributes "ui-notification-center"


{-| Inflix 2 tuple.
-}
(=>) : a -> b -> ( a , b )
(=>) = (,)
