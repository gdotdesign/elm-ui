module Ui.Styles.FileInput exposing (..)

{-| Styles for a file-input.

@docs style, styleDetails, defaultStyle, defaultStyleDetails
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for a file-input using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Styles for a file-input using the default theme.
-}
defaultStyleDetails : Style
defaultStyleDetails =
  Ui.Styles.attributes (styleDetails Theme.default)


{-| Returns the style node for a file-input using the given theme.
-}
styleDetails : Theme -> Node
styleDetails theme =
  mixin
    [ Mixins.defaults

    , border ((px 1) . solid . theme.colors.border)
    , background theme.colors.input.color
    , borderRadius theme.borderRadius
    , color theme.colors.input.bw
    , fontFamily theme.fontFamily
    , padding (px 20)
    , display flex

    , selector "ui-file-input-info"
      [ height (px 70)
      , cursor pointer
      , display block
      , minWidth zero
      , flex_ "1"

      , selector "> *"
        [ Mixins.ellipsis
        ]

      , selector "&:hover"
        [ color theme.colors.focus.color
        ]
      ]

    , selector "ui-button[size=medium]"
      [ flexDirection "column"
      , marginLeft (px 20)
      , flex_ "0 0 auto"
      , height auto
      ]

    , selector "ui-file-input-no-file"
      [ alignItems center
      , fontSize (px 20)
      , height (px 70)
      , minWidth zero
      , display flex
      , flex_ "1"

      , selector "&:hover"
        [ color theme.colors.focus.color
        , cursor pointer
        ]
      ]

    , selectors
      [ "ui-file-input-size"
      , "ui-file-input-type"
      ]
      [ fontSize (px 14)
      , display block
      ]

    , selector "ui-file-input-name"
      [ marginBottom (px 5)
      , fontSize (px 20)
      , display block
      ]

    , selector "&[readonly]"
      [ Mixins.readonly

      , selectors
        [ "ui-file-input-no-file"
        , "ui-file-input-info"
        ]
        [ pointerEvents none
        ]
      ]

    , selector "&[disabled]"
      [ Mixins.disabled

      , selectors
        [ "ui-file-input-no-file"
        , "ui-file-input-info"
        ]
        [ pointerEvents none
        , opacity 0.5
        ]
      ]
    ]


{-| Returns the style node for a file-input using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , border ((px 1) . solid . theme.colors.border)
    , background theme.colors.input.color
    , borderRadius theme.borderRadius
    , color theme.colors.input.bw
    , fontFamily theme.fontFamily
    , height (px 36)
    , display flex

    , selector "ui-file-input-content"
      [ Mixins.ellipsis

      , padding (zero . (px 10))
      , lineHeight (px 34)
      , cursor pointer
      , flex_ "1"

      , selector "&:hover"
        [ color theme.colors.focus.color
        ]
      ]

    , selector "ui-button[size=medium]"
      [ borderRadius (zero . theme.borderRadius . theme.borderRadius . zero)
      , border ((px 1) . solid . theme.colors.border)
      , position relative
      , right (px -1)
      , top (px -1)

      , selector "span"
        [ lineHeight (px 34)
        ]
      ]

    , selector "&[readonly]"
      [ Mixins.readonly

      , selector "ui-file-input-content"
        [ pointerEvents none
        ]
      ]

    , selector "&[disabled]"
      [ Mixins.disabled

      , selector "ui-file-input-content"
        [ pointerEvents none
        , opacity 0.5
        ]
      ]
    ]
