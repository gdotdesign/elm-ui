module Ui.Styles.Layout exposing (..)

{-| Styles for layouts.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Styles for layouts using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for layouts using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ minHeight (vh 100)
    , display flex

    , selector "ui-layout-app-wrapper"
      [ flexDirection column
      , minHeight inherit
      , display flex
      , flex_ "1"
      ]

    , selectors
      [ "ui-layout-sidebar-content"
      , "ui-layout-website-content"
      , "ui-layout-app-content"
      ]
      [ display block
      , flex_ "1"
      ]

    , selector "&[kind=website]"
      [ flexDirection column
      ]

    , selectors
      [ "ui-layout-sidebar-bar"
      , "ui-layout-app-sidebar"
      , "ui-layout-app-toolbar"
      , "ui-layout-website-header"
      , "ui-layout-website-footer"
      ]
      [ flex_ "0 0 auto"
      ]
    ]
