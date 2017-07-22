module Ui.Styles.Chooser exposing (..)

{-| Styles for a chooser.

@docs style
-}
import Ui.Css.Properties exposing (..)
import Ui.Css exposing (..)

import Ui.Styles.Mixins as Mixins
import Ui.Styles.Input as Input
import Ui.Styles exposing (Style)

import Regex

{-| Returns the style for a chooser.
-}
style : Style
style =
  [ Mixins.defaults


  , display inlineBlock
  , position relative

  , selector "&:not([readonly]) input"
    [ cursor pointer
    ]

  , selector "input"
    [ Input.base "ui-chooser"
    , zIndex 2
    ]

  , selector "&:before"
    [ borderColor (currentColor . transparent . transparent)
    , borderWidth ((px 6) . (px 5) . zero)
    , borderStyle solid

    , pointerEvents none

    , transform [ scale 0.6 ]
    , opacity 0
    , transition
      [ { easing = "ease"
        , property = "all"
        , duration = (ms 320)
        , delay = (ms 0)
        }
      ]

    , top "calc(50% - 3px)"
    , position absolute
    , contentString ""
    , right (px 15)
    , height zero
    , width zero
    , zIndex 4
    ]

  , selectors
    [ "&:not([searchable])"
    , "&[searchable]:not([open])"
    ]
    [ selector "&::after"
      [ background
        ( "linear-gradient(90deg, transparent, " ++
          (varf "ui-chooser-background" "colors-input-background") ++
          " 70%)")
      , borderRadius
        ( zero .
          (varf "ui-chooser-border-radius" "border-radius") .
          (varf "ui-chooser-border-radius" "border-radius") .
          zero
        )
      , pointerEvents none
      , position absolute
      , width (pct 33.33)
      , contentString ""
      , bottom (px 4)
      , right (px 4)
      , top (px 4)
      , zIndex 3
      ]

    , selector "&::before"
      [ transform [ scale 1]
      , opacity 0.6
      ]
    ]

  , selector "&[disabled]"
    [ selectors
      [ "&:not([searchable])"
      , "&[searchable]:not([open])"
      ]
      [ selector "&::after"
        [ background
          ( "linear-gradient(90deg, transparent, " ++
            (varf "ui-chooser-disabled-background" "colors-disabled-background") ++
            " 70%)")
        ]
      ]
    ]

  , selector "ui-dropdown-panel"
    [ maxHeight (px 250)
    , padding (px 5)
    , display flex
    ]

  , selector "ui-chooser-empty-content"
    [ fontStyle italic
    , padding (px 12)
    , display block
    , opacity 0.5
    ]

  , selector "ui-chooser-item"
    [ Mixins.ellipsis

    , borderRadius (varf "ui-chooser-border-radius" "border-radius")
    , padding ((px 8) . (px 10))
    , paddingRight (px 30)
    , position relative
    , cursor pointer
    , display block

    , selector "&[intended]"
      [ background (var "ui-chooser-intended-background" "#EEE")
      , color (var "ui-chooser-intended-text" "#707070")

      , selector "&:hover"
        [ background (var "ui-chooser-intended-hover-background" "#DDD")
        , color (var "ui-chooser-intended-hover-text" "#707070")
        ]

      , selector "&:before"
        [ content
          ("url(\"data:image/svg+xml;utf8," ++
          (chevronRight (var "ui-chooser-intended-text" "#707070")) ++ "\")")
        , top "calc(50% - 7px)"
        , position absolute
        , fill currentColor
        , right (px 10)
        ]
      ]

    , selector "&:hover"
      [ background (var "ui-chooser-hover-background" "#F0F0F0")
      , color (var "ui-chooser-hover-text" "#707070")
      ]

    , selector "&[selected]"
      [ background (varf "ui-chooser-selected-background" "colors-primary-background")
      , color (varf "ui-chooser-selected-text" "colors-primary-text")

      , selector "&:hover"
        [ background (var "ui-chooser-selected-hover-background" "#1F97E2")
        , color (var "ui-chooser-selected-hover-text" "#FFFFFF")
        ]
      ]

    , selector "&[selected][intended]"
      [ background (var "ui-chooser-selected-intended-background" "#1070AC")
      , color (var "ui-chooser-selected-intended-text" "#FFFFFF")

      , selector "&:hover"
        [ background (var "ui-chooser-selected-intended-hover-background" "#0C5989")
        , color (var "ui-chooser-selected-intended-hover-text" "#FFFFFF")
        ]

      , selector "&:before"
        [ content
          ("url(\"data:image/svg+xml;utf8," ++
          (chevronRight (var "ui-chooser-selected-intended-hover-text" "#FFFFFF") ++
          "\")"))
        ]
      ]

    , selector "+ ui-chooser-item"
      [ marginTop (px 3)
      ]
    ]
  ]
  |> mixin
  |> Ui.Styles.attributes "ui-chooser"


{-| Chevron right icon.
-}
chevronRight : String -> String
chevronRight color =
  ("""
  <svg xmlns='http://www.w3.org/2000/svg' width='8' height='14' viewBox='0 0 8 13.999605' fill='""" ++ color ++ """'>
    <path d='M2.676 6.998l5.227-5.442c.132-.135.128-.357-.006-.494L6.963.105C6.828-.032 6.61-.035 6.478.1L.095 6.744c-.07.07-.1.163-.094.253-.002.094.03.185.095.254l6.383 6.65c.13.133.35.13.485-.007l.934-.957c.135-.137.138-.36.006-.494L2.676 7z'/>
    </svg>
  """)
  |> Regex.replace Regex.All (Regex.regex "\\n\\s*") (\_ -> "")
