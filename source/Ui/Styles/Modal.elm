module Ui.Styles.Modal exposing (..)

{-| Styles for a modal.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a modal.
-}
style : Style
style =
  [ Mixins.defaults

  , fontFamily (varf "ui-modal-font-family" "font-family")
  , transform [ translate3d zero zero zero ]
  , zIndex (var "ui-modal-z-index" "100")
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
    , zIndex "0"
    , left zero
    , top zero
    ]

  , selector "ui-modal-wrapper"
    [ backgroundColor (varf "ui-modal-background" "colors-input-background")
    , borderRadius (varf "ui-modal-border-radius" "border-radius")
    , color (varf "ui-modal-text" "colors-input-text")
    , transform [ translateY (vh -5) ]
    , position relative
    , maxHeight (vw 80)
    , maxWidth (vw 80)
    , zIndex "1"

    , transition
      [ { property = "transform"
        , duration = (ms 320)
        , easing = "ease"
        , delay = (ms 0)
        }
      ]

    , boxShadow
      [ { color = "rgba(0,0,0,0.1)"
        , inset = False
        , spread = zero
        , blur = px 20
        , x = zero
        , y = px 5
        }
      ]

    , selector "&:last-child"
      [ border ((px 1) . solid . (varf "ui-modal-border" "border-color"))
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
    [ borderTop ((px 1) . solid . (varf "ui-modal-border" "border-color"))
    ]

  , selector "ui-modal-header"
    [ borderBottom ((px 1) . solid . (varf "ui-modal-border" "border-color"))
    , alignItems center
    , fontSize (px 20)
    , display flex

    , selector "svg"
      [ marginLeft (px 20)
      , fill currentColor
      , height (px 16)
      , width (px 16)

      , selector "&:hover"
        [ fill (varf "ui-modal-hover-color" "colors-focus-background")
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
  |> mixin
  |> Ui.Styles.attributes "ui-modal"
