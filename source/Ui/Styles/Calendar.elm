module Ui.Styles.Calendar exposing (..)

{-| Styles for a calendar.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a calendar using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a calendar using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , border ((px 1) . solid . theme.colors.border)
    , backgroundColor theme.colors.input.color
    , transform [ translate3d zero zero zero ]
    , borderRadius theme.borderRadius
    , color theme.colors.input.bw
    , fontFamily theme.fontFamily
    , display inlineBlock
    , userSelect none
    , padding (px 15)

    , selector "> ui-container"
      [ borderBottom ((px 1) . dashed . theme.colors.border)
      , padding (zero . (px 5) . (px 10) . (px 5))
      , alignItems center
      , height (px 35)

      , selector "div"
        [ justifyContent center
        , position relative
        , alignItems center
        , display flex
        , top (px 2)
        , flex_ "1"
        ]

      , selector "svg"
        [ fill currentColor
        , cursor pointer
        , height (px 16)
        , width (px 16)

        , selector "&:hover"
          [ fill theme.colors.focus.color
          ]
        ]
      ]

    , selector "ui-calendar-table"
      [ justifyContent spaceAround
      , width (px 300)
      , flexWrap wrap
      , display flex
      ]

    , selector "ui-calendar-header"
      [ borderBottom ((px 1) . dashed . theme.colors.border)
      , justifyContent spaceAround
      , marginBottom (px 5)
      , width (px 300)
      , display flex

      , selector "span"
        [ textTransform uppercase
        , margin ((px 7) . zero)
        , textAlign center
        , fontSize (px 12)
        , fontWeight bold
        , width (px 34)
        , opacity 0.7
        ]
      ]

    , selector "ui-calendar-cell"
      [ borderRadius theme.borderRadius
      , justifyContent center
      , lineHeight (px 36)
      , height (px 34)
      , width (px 34)
      , margin (px 4)
      , display flex

      , selector "&[inactive]"
        [ opacity 0.25
        ]

      , selector "&:not(:empty)"
        [ backgroundColor theme.colors.inputSecondary.color
        , color theme.colors.inputSecondary.bw
        ]
      ]

    , selector "&:not([disabled])[selectable] ui-calendar-cell"
      [ selectors
        [ "&:not([inactive]):hover"
        , "&[selected]"
        ]
        [ backgroundColor theme.colors.primary.color
        , color theme.colors.primary.bw
        , fontWeight bold
        , cursor pointer
        ]
      ]

    , selector "&[readonly]"
      [ Mixins.readonly

      , selector "> *"
        [ pointerEvents none ]

      , selector "svg"
        [ display none ]
      ]

    , selector "&[disabled]"
      [ Mixins.disabled

      , backgroundColor theme.colors.disabled.color
      , color theme.colors.disabled.bw
      , borderColor transparent

      , selectors
        [ "> ui-container"
        , "ui-calendar-header"
        ]
        [ borderBottom ((px 1) . dashed . theme.colors.borderDisabled)
        ]

      , selector "> *"
        [ pointerEvents none ]

      , selector "ui-calendar-cell"
        [ selector "&:not(:empty)"
          [ backgroundColor theme.colors.disabledSecondary.color
          , color theme.colors.disabledSecondary.bw
          , opacity 0.5
          ]
        , selector "&[selected]"
          [ opacity 1
          ]
        ]
      ]
    ]
