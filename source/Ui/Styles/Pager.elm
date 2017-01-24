module Ui.Styles.Pager exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins

style : Theme -> Node
style theme =
  selector "ui-pager"
    [ Mixins.defaults

    , position relative
    , overflow hidden
    , display block

    , selector "ui-page"
      [ transform [ translate3d zero zero zero ]
      , position absolute
      , width (pct 100)
      , display flex
      , bottom zero
      , top zero

      , selector "> *"
        [ flex_ "1" ]

      , selector "&[animating]"
        [ transition
          [ { easing = "cubic-bezier(0.77, 0, 0.175, 1)"
            , duration = (ms 500)
            , property = "left"
            , delay = (ms 0)
            }
          ]
        ]
      ]
    ]
