module Ui.Styles.Tagger exposing (..)

{-| Styles for tagger.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a tagger using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)

{-| Returns the style node for a tagger using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , fontFamily theme.fontFamily
    , display inlineBlock

    , selector "> ui-container"
      [ marginBottom (px 5)

      , selector "ui-icon-button[size=medium]"
        [ flex_ (zero . zero . (px 36))
        , padding zero
        ]

      , selector "input"
        [ flex_ "1"
        ]
      ]

    , selector "ui-tagger-tags"
      [ display block
      , margin (zero . (px -5))
      ]

    , selector "ui-input"
      [ flex_ "1"
      ]

    , selector "ui-tagger-tag"
      [ margin (px 5)

      , backgroundColor theme.colors.gray.color
      , borderRadius theme.borderRadius
      , color theme.colors.gray.bw
      , padding (zero . (px 10))
      , display inlineBlock
      , lineHeight (px 38)
      , alignItems center
      , fontWeight bold
      , height (px 36)

      , selector "svg"
        [ marginLeft (px 10)
        , fill currentColor
        , cursor pointer
        , height (px 12)
        , width (px 12)
        , outline none

        , selector "&:focus"
          [ fill theme.colors.focus.color
          ]

        , selector "&:hover"
          [ fill theme.colors.primary.color
          ]
        ]
      ]

    , selector "&[readonly]"
      [ Mixins.readonly

      , selector "ui-icon-button"
        [ pointerEvents none
        ]
      ]

    , selector "&[disabled]"
      [ Mixins.disabled

      , selector "ui-tagger-tag"
        [ Mixins.disabledColors theme
        ]
      ]
    ]
