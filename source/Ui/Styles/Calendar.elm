module Ui.Styles.Calendar exposing (..)

{-| Styles for a calendar.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)


{-| Returns the style node for a calendar using the given theme.
-}
style : Style
style =
  [ Mixins.defaults

  , border ((px 1) . solid . (varf "ui-calendar-border-color" "border-color"))

  , backgroundColor (varf "ui-calendar-background" "colors-input-background")
  , color (varf "ui-calendar-text" "colors-input-text")

  , borderRadius (varf "ui-calendar-border-radius" "border-radius")
  , fontFamily (varf "ui-calendar-font-family" "font-family")

  , transform [ translate3d zero zero zero ]
  , display inlineBlock
  , userSelect none
  , padding (px 15)

  , selector "> ui-container"
    [ borderBottom ((px 1) . dashed . (varf "ui-calendar-border-color" "border-color"))
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
        [ fill (varf "ui-calendar-text-hover" "colors-focus-background")
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
    [ borderBottom ((px 1) . dashed . (varf "ui-calendar-border-color" "border-color"))
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
    [ borderRadius (varf "ui-calendar-border-radius" "border-radius")
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
      [ backgroundColor (varf "ui-calendar-cell-background" "colors-input-secondary-background")
      , color (varf "ui-calendar-cell-text" "colors-input-secondary-text")
      ]
    ]

  , selector "&:not([disabled])[selectable] ui-calendar-cell"
    [ selectors
      [ "&:not([inactive]):hover"
      , "&[selected]"
      ]
      [ backgroundColor (varf "ui-calendar-selected-cell-background" "colors-primary-background")
      , color (varf "ui-calendar-selected-cell-text" "colors-primary-text")
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
    [ Mixins.disabledColors "ui-calendar"
    , Mixins.disabled

    , borderColor transparent

    , selectors
      [ "> ui-container"
      , "ui-calendar-header"
      ]
      [ borderBottom ((px 1) . dashed . (var "ui-calendar-disabled-border-color" "#C7C7C7"))
      ]

    , selector "> *"
      [ pointerEvents none ]

    , selector "ui-calendar-cell"
      [ selector "&:not(:empty)"
        [ backgroundColor (varf "ui-calendar-cell-background" "colors-disabled-secondary-background")
        , color (varf "ui-calendar-cell-color" "colors-disabled-secondary-text")
        , opacity 0.5
        ]
      , selector "&[selected]"
        [ opacity 1
        ]
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-calendar"
