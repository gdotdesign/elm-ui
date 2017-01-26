module Ui.Styles.Layout exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins


style : Theme -> Node
style theme =
  mixin
    [ selectors
      [ "ui-layout-sidebar"
      , "ui-layout-website"
      , "ui-layout-app"
      ]
      [ minHeight (vh 100)
      , display flex
      ]

    , selector "ui-layout-app-wrapper"
      [ flexDirection column
      , minHeight (vh 11)
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

    , selector "ui-layout-website"
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
