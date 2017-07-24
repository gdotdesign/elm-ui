module Ui.Styles.Layout exposing (..)

{-| Styles for layouts.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles exposing (Style)

{-| Returns the style for layouts.
-}
style : Style
style =
  [ selectors
    [ "ui-layout-website"
    , "ui-layout-app"
    , "ui-layout-sidebar"
    ]
    [ minHeight (vh 100)
    , display flex
    ]

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
  |> mixin
  |> Ui.Styles.attributes ""
