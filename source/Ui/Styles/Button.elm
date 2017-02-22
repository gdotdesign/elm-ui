module Ui.Styles.Button exposing (..)

{-| Styles for a button.

@docs style, defaultStyle
-}
import Ui.Css.Properties exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Ripple as Ripple
import Ui.Styles.Mixins as Mixins

import Html.Styles exposing (Style, styles, selector, pseudo)
import Html

rippleSytle = Ripple.style

{-| Styles for a button using the default theme.
-}
defaultStyle : Html.Attribute msg
defaultStyle =
  style Theme.default


{-| Returns the style node for a button using the given theme.
-}
style : Theme -> Html.Attribute msg
style theme =
  styles
    ( [ Mixins.defaults
      , rippleSytle.base
      , userSelect none

      , [ borderRadius theme.borderRadius
        , fontFamily theme.fontFamily
        , justifyContent center
        , display inlineFlex
        , alignItems center
        , textAlign center
        , fontWeight bold
        , cursor pointer
        , outline none
        ]
      ]
      |> List.concat
    )

    ( [ selector "span"
        ( [ Mixins.ellipsis
          , [ alignSelf stretch
            ]
          ]
          |> List.concat
        )

      , selector "> *"
        [ pointerEvents none
        ]

      , pseudo "[size=medium]"
        [ padding (zero . (px 24))
        , fontSize (px 16)
        , height (px 36)
        ]

      , pseudo "[size=medium] span"
        [ lineHeight (px 36)
        ]

      , pseudo "[size=big]"
        [ padding (zero . (px 30))
        , fontSize (px 22)
        , height (px 50)
        ]

      , pseudo "[size=big] span"
        [ lineHeight (px 52)
        ]

      , pseudo "[size=small]"
        [ padding (zero . (px 16))
        , fontSize (px 12)
        , height (px 26)
        ]

      , pseudo "[size=small] span"
        [ lineHeight (px 26)
        ]

      , pseudo "[disabled]"
        ( [ Mixins.disabledColors theme
          , Mixins.disabled
          ]
          |> List.concat
        )

      , pseudo "[readonly]"
        Mixins.readonly

      , pseudo ":not([disabled])[kind=primary]"
        [ backgroundColor theme.colors.primary.color
        , color theme.colors.primary.bw
        ]

      , pseudo ":not([disabled])[kind=secondary]"
        [ backgroundColor theme.colors.secondary.color
        , color theme.colors.secondary.bw
        ]

      , pseudo ":not([disabled])[kind=warning]"
        [ backgroundColor theme.colors.warning.color
        , color theme.colors.warning.bw
        ]

      , pseudo ":not([disabled])[kind=success]"
        [ backgroundColor theme.colors.success.color
        , color theme.colors.success.bw
        ]

      , pseudo ":not([disabled])[kind=danger]"
        [ backgroundColor theme.colors.danger.color
        , color theme.colors.danger.bw
        ]
      ] ++ rippleSytle.selectors
    )
