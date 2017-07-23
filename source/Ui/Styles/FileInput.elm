module Ui.Styles.FileInput exposing (..)

{-| Styles for a file-input.

@docs style, styleDetails
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for a detailed file-input
-}
styleDetails : Style
styleDetails =
  [ Mixins.defaults

  , border ((px 1) . solid . (varf "ui-file-input-border-color" "border-color"))
  , background (varf "ui-file-input-background" "colors-input-background")
  , borderRadius (varf "ui-file-input-border-radius" "border-radius")
  , fontFamily (varf "ui-file-input-font-family" "font-family")
  , color (varf "ui-file-input-text" "colors-input-text")
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
      [ color (varf "ui-file-input-hover" "colors-focus-background")
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
      [ color (varf "ui-file-input-hover" "colors-focus-background")
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
  |> mixin
  |> Ui.Styles.attributes "ui-file-input-details"


{-| Returns the style for a file-input.
-}
style : Style
style =
  [ Mixins.defaults

  , border ((px 1) . solid . (varf "ui-file-input-border-color" "border-color"))
  , background (varf "ui-file-input-background" "colors-input-background")
  , borderRadius (varf "ui-file-input-border-radius" "border-radius")
  , fontFamily (varf "ui-file-input-font-family" "font-family")
  , color (varf "ui-file-input-text" "colors-input-text")
  , height (px 36)
  , display flex

  , selector "ui-file-input-content"
    [ Mixins.ellipsis

    , padding (zero . (px 10))
    , lineHeight (px 34)
    , cursor pointer
    , flex_ "1"

    , selector "&:hover"
      [ color (varf "ui-file-input-hover" "colors-focus-background")
      ]
    ]

  , selector "ui-button[size=medium]"
    [ borderRadius
      ( zero .
        (varf "ui-file-input-border-radius" "border-radius") .
        (varf "ui-file-input-border-radius" "border-radius") .
        zero
      )
    , border ((px 1) . solid . (varf "ui-file-input-border-color" "border-color"))
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
  |> mixin
  |> Ui.Styles.attributes "ui-file-input"
