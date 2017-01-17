module Ui.Styles.Mixins exposing (..)

import Css.Properties exposing (..)
import Css exposing (..)

ellipsis : Node
ellipsis =
  mixin
    [ textOverflow Css.Properties.ellipsis
    , whiteSpace nowrap
    , overflow hidden
    ]
