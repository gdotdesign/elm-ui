module Ui.Styles.InplaceInput exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Container as Container
import Ui.Styles.Textarea as Textarea
import Ui.Styles.Button as Button
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  mixin
    [ Container.style theme
    , Button.style theme
    , Textarea.style theme

    , selector "ui-inplace-input"
      [ display inlineBlock

      , selector "ui-textarea"
        [ zIndex 0 ]

      , selector "ui-inplace-input-content"
        [ fontFamily theme.fontFamily
        , color theme.colors.input.bw
        , padding ((px 6) . (px 9))
        , wordBreak breakWord
        , lineHeight (px 24)
        , whiteSpace preWrap
        , cursor pointer
        , display block

        , selector "&:empty:before"
          [ content "attr(placeholder)"
          , cursor pointer
          , opacity 0.5
          ]
        ]
      ]
    ]
