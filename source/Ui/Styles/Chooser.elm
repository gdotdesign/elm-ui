module Ui.Styles.Chooser exposing (..)

{-| Styles for a chooser.

@docs style, defaultStyle
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Mixins as Mixins
import Ui.Styles.Input as Input
import Ui.Styles exposing (Style)

import Regex

{-| Styles for a checkbox using the default theme.
-}
defaultStyle : Style
defaultStyle =
  Ui.Styles.attributes (style Theme.default)


{-| Returns the style node for a checkbox using the given theme.
-}
style : Theme -> Node
style theme =
  mixin
    [ Mixins.defaults

    , Input.inputStyle theme

    , color theme.colors.input.bw
    , display inlineBlock
    , position relative

    , selector "&:not([readonly]) input"
      [ cursor pointer
      ]

    , selector "input"
      [ zIndex 2
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
          ("linear-gradient(90deg, transparent, " ++
          theme.colors.input.color ++ " 70%)")
        , borderRadius (zero . theme.borderRadius . theme.borderRadius . zero)
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
            ("linear-gradient(90deg, transparent, " ++
            theme.colors.disabled.color ++ " 70%)")
          ]
        ]
      ]

    , selector "ui-dropdown-panel[style-id]"
      [ maxHeight (px 250)
      , padding (px 5)
      , display flex

      , selector "ui-scrolled-panel-wrapper:empty:before"
        [ contentString "No items to display!"
        , fontStyle italic
        , padding (px 12)
        , display block
        , opacity 0.5
        ]
      ]

    , selector "ui-chooser-item"
      [ Mixins.ellipsis

      , borderRadius theme.borderRadius
      , padding ((px 8) . (px 10))
      , paddingRight (px 30)
      , position relative
      , cursor pointer
      , display block

      , selector "&[intended]"
        [ background theme.chooser.intendedColors.background
        , color theme.chooser.intendedColors.text

        , selector "&:hover"
          [ background theme.chooser.intendedHoverColors.background
          , color theme.chooser.intendedHoverColors.text
          ]

        , selector "&:before"
          [ content
            ("url(\"data:image/svg+xml;utf8," ++
            (chevronRight theme.chooser.intendedColors.text) ++ "\")")
          , top "calc(50% - 7px)"
          , position absolute
          , fill currentColor
          , right (px 10)
          ]
        ]

      , selector "&:hover"
        [ background theme.chooser.hoverColors.background
        , color theme.chooser.hoverColors.text
        ]

      , selector "&[selected]"
        [ background theme.chooser.selectedColors.background
        , color theme.chooser.selectedColors.text

        , selector "&:hover"
          [ background theme.chooser.selectedHoverColors.background
          , color theme.chooser.selectedHoverColors.text
          ]
        ]

      , selector "&[selected][intended]"
        [ background theme.chooser.selectedIntendedColors.background
        , color theme.chooser.selectedIntendedColors.text

        , selector "&:hover"
          [ background theme.chooser.selectedIntendedHoverColors.background
          , color theme.chooser.selectedIntendedHoverColors.text
          ]

        , selector "&:before"
          [ content
            ("url(\"data:image/svg+xml;utf8," ++
            (chevronRight theme.chooser.selectedIntendedHoverColors.text) ++
            "\")")
          ]
        ]

      , selector "+ ui-chooser-item"
        [ marginTop (px 3)
        ]
      ]
    ]


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
