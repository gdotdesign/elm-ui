module Ui.Styles.Tagger exposing (..)

{-| Styles for tagger.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a tagger.
-}
style : Style
style =
  [ Mixins.defaults

  , fontFamily (varf "ui-tagger-font-family" "font-family")
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

    , borderRadius (varf "ui-tagger-tag-border-radius" "border-radius")
    , backgroundColor (var "ui-tagget-tag-background" "#E9E9E9" )
    , color (var "ui-tagget-tag-text" "#616161" )
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
        [ fill (varf "ui-tagget-tag-focus" "colors-focus-background" )
        ]

      , selector "&:hover"
        [ fill (varf "ui-tagget-tag-hover" "colors-focus-background" )
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
      [ Mixins.disabledColors "ui-tagger"
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-tagger"
