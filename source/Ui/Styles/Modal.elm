module Ui.Styles.Modal exposing (..)

{-| Styles for a modal.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a modal using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a modal using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , transform [ translate3d zero zero zero ]
    , zIndex theme.zIndexes.modal
    , fontFamily theme.fontFamily
    , justifyContent center
    , alignItems center
    , position fixed
    , display flex
    , bottom zero
    , right zero
    , left zero
    , top zero

    , pointerEvents none
    , visibility hidden
    , opacity 0

    , transition
      [ { property = "opacity"
        , duration = (ms 320)
        , easing = "ease"
        , delay = (ms 0)
        }
      , { property = "visibility"
        , duration = (ms 1)
        , delay = (ms 320)
        , easing = "ease"
        }
      ]

    , selector "ui-modal-backdrop"
      [ background "rgba(0,0,0,0.8)"
      , position absolute
      , bottom zero
      , right zero
      , left zero
      , top zero
      , zIndex 0
      ]

    , selector "ui-modal-wrapper"
      [ backgroundColor theme.colors.input.color
      , transform [ translateY (vh -5) ]
      , borderRadius theme.borderRadius
      , color theme.colors.input.bw
      , position relative
      , maxHeight (vw 80)
      , maxWidth (vw 80)
      , zIndex 1

      , transition
        [ { property = "transform"
          , duration = (ms 320)
          , easing = "ease"
          , delay = (ms 0)
          }
        ]

      , boxShadow
        [ { x = zero
          , y = px 5
          , blur = px 20
          , spread = zero
          , color = "rgba(0,0,0,0.1)"
          , inset = False
          }
        ]

      , selector "&:last-child"
        [ border ((px 1) . solid . theme.colors.border)
        ]
      ]

    , selectors
      [ "ui-modal-content"
      , "ui-modal-header"
      , "ui-modal-footer"
      ]
      [ padding (px 20)
      , display block
      ]

    , selector "ui-modal-footer"
      [ borderTop ((px 1) . solid . theme.colors.border)
      ]

    , selector "ui-modal-header"
      [ borderBottom ((px 1) . solid . theme.colors.border)
      , alignItems center
      , fontSize (px 20)
      , display flex

      , selector "svg"
        [ marginLeft (px 20)
        , fill currentColor
        , height (px 16)
        , width (px 16)

        , selector "&:hover"
          [ fill theme.colors.focus.color
          , cursor pointer
          ]
        ]
      ]

    , selector "ui-modal-title"
      [ fontWeight bold
      , flex_ "1"
      ]

    , selector "&[open]"
      [ pointerEvents auto
      , visibility visible
      , opacity 1

      , transition
        [ { property = "opacity"
          , duration = (ms 320)
          , easing = "ease"
          , delay = (ms 0)
          }
        , { property = "visibility"
          , duration = (ms 1)
          , delay = (ms 0)
          , easing = "ease"
          }
        ]

      , selector "ui-modal-wrapper"
        [ transform [ translateY zero ]
        ]
      ]
    ]
