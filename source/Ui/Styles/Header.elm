module Ui.Styles.Header exposing (..)

{-| Styles for a header.

@docs style, variables
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (default)
import Ui.Styles.Mixins as Mixins
import Ui.Styles.Ripple as Ripple
import Ui.Styles exposing (Style)

import Html

{-| Variables for the styles of a button.
-}
variables : List (String, String)
variables =
  [ ("ui-header-background-bottom", default.header.colors.backgroundBottom)
  , ("ui-header-background-top", default.header.colors.backgroundTop)
  , ("ui-header-separator-color", default.header.colors.border)
  , ("ui-header-z-index", (toString default.zIndexes.header))
  , ("ui-header-text-shadow-color", "rgba(0,0,0,0.3)")
  , ("ui-header-color", default.header.colors.text)
  , ("ui-header-shadow-color", "rgba(0,0,0,0.1)")
  , ("ui-header-font-family", default.fontFamily)
  , ("ui-header-font-size", (px 20))
  , ("ui-header-height", (px 60))
  ]
    |> Ui.Styles.registerVariables


{-| Returns the style node for a header using the given theme.
-}
style : List (Html.Attribute msg)
style =
  [ background
      ( "linear-gradient(" ++
        (var "ui-header-background-top")  ++
        ", " ++
        (var "ui-header-background-bottom") ++
        ")"
      )
    , property "z-index" (var "ui-header-z-index")
    , fontFamily (var "ui-header-font-family")
    , padding (zero . (px 20))
    , position relative
    , flex_ "0 0 auto"

    , flexDirection row
    , alignItems center
    , display flex

    , height (var "ui-header-height")

    , boxShadow
      [ { color = (var "ui-header-shadow-color")
        , blur = (px 3)
        , inset = False
        , spread = zero
        , y = (px 2)
        , x = zero
        }
      , { color = (var "ui-header-shadow-color")
        , blur = (px 10)
        , inset = False
        , spread = zero
        , y = zero
        , x = zero
        }
      ]

  , selector "ui-header-separator"
    [ background (var "ui-header-separator-color")
    , margin (zero . (px 8))
    , height (pct 60)
    , width (px 2)
    ]

  , selector "ui-header-spacer"
    [ flex_ "1"
    ]

  , selector "ui-header-title"
    [ item
    ]

  , selector "ui-header-item"
    [ item
    ]

  , selector "ui-header-icon-item"
    [ item

    , selector "svg:not([ripple])"
      [ height (var "ui-header-font-size")
      , width (var "ui-header-font-size")
      , fill currentColor
      ]

    , selectors
      [ "svg + span"
      , "span + svg"
      ]
      [ marginLeft (px 12)
      ]
    ]

  , selector "ui-header-icon"
    [ item

    , selector "svg:not([ripple])"
      [ height (var "ui-header-font-size")
      , width (var "ui-header-font-size")
      , fill currentColor
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes
  |> Ui.Styles.apply

{-| Returns a style node for an header item.
-}
item : Node
item =
  mixin
    [ property "-webkit-filter"
      ("drop-shadow(0px 1px 0px " ++ (var "ui-header-text-shadow-color") ++ ")")
    , property "filter"
      ("drop-shadow(0px 1px 0px " ++ (var "ui-header-text-shadow-color") ++ ")")

    , fontSize (var "ui-header-font-size")
    , color (var "ui-header-color")
    , margin (zero . (px 2))
    , fontWeight bold
    , height inherit

    , selector "&[interactive] a"
      [ Ripple.style

      , borderRight ((px 1) . solid . transparent)
      , borderLeft ((px 1) . solid . transparent)
      , transform [ translate3d zero zero zero ]
      , textDecoration none
      , color currentColor
      , position relative
      , cursor pointer
      , transition
        [ { duration = (ms 200)
          , property = "all"
          , easing = "ease"
          , delay = (ms 0)
          }
        ]

      , selector "&:focus"
        [ borderColor "rgba(0,0,0,0.6)"
        , outline none
        , transition
          [ { duration = (ms 200)
            , delay = (ms 100)
            , property = "all"
            , easing = "ease"
            }
          ]
        ]

      , selector "&:active"
        [ borderColor "rgba(0,0,0,0.6)"
        ]
      ]

    , selector "&:not([interactive]) svg[ripple]"
      [ display none
      ]

    , selector "span"
      [ height (var "ui-header-font-size")
      ]

    , selector "a"
      [ padding (zero . (px 12))
      , textOverflow ellipsis
      , alignItems center
      , whiteSpace nowrap
      , fontSize inherit
      , userSelect none
      , height inherit
      , display flex
      ]
    ]
