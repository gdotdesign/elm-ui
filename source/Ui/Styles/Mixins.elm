module Ui.Styles.Mixins exposing (..)

{-| This module contains mixins for the components styles.

@docs placeholder, defaults, focused, focusedIdle, ellipsis, disabled
@docs disabledColors, disabledCursor, readonlyCursor, readonly
-}
import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Regex

{-| Mixis in the selectors for styling the placeholder.
-}
placeholder : List Node -> Node
placeholder nodes =
  mixin
    [ selectors
      [ "&::-webkit-input-placeholder"
      , "&::-moz-placeholder"
      , "&:-ms-input-placeholder"
      , "&:-moz-placeholder"
      ] nodes
    ]


{-| Mixins in the default values.
-}
defaults : Node
defaults =
  mixin
    [ property "-webkit-tap-highlight-color" "rgba(0,0,0,0)"
    , property "-webkit-touch-callout" none
    , boxSizing borderBox
    ]


{-| Mixins in the idle focused state.
-}
focusedIdle : Theme -> Node
focusedIdle theme =
  mixin
    [ transition
      [ { property = "box-shadow"
        , duration = ms 400
        , easing = "linear"
        , delay = ms 0
        }
      ]
    , boxShadow theme.focusShadowsIdle
    ]


{-| Mixins in the focused state.
-}
focused : Theme -> Node
focused theme =
  mixin
    [ transition
      [ { property = "box-shadow"
        , duration = ms 200
        , easing = "linear"
        , delay = ms 0
        }
      ]
    , boxShadow theme.focusShadows
    , outline none
    ]


{-| Mixins in the properties to make text use ellipsis.
-}
ellipsis : Node
ellipsis =
  mixin
    [ textOverflow Css.Properties.ellipsis
    , whiteSpace nowrap
    , overflow hidden
    ]


{-| Mixis in the disabled colors.
-}
disabledColors : Theme -> Node
disabledColors theme =
  mixin
    [ backgroundColor theme.colors.disabled.color
    , color theme.colors.disabled.bw
    ]


{-| The value for the disabled cursor.
-}
disabledCursor : String
disabledCursor =
  """
  <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 48.901367 31.675499' width='48.901' height='31.675'>
    <path d='M26.05.127C25.53.043 24.996 0 24.45 0c-5.52 0-10 4.478-10 10s4.48 10 10 10c.546 0 1.08-.044 1.6-.128 4.763-.766 8.4-4.895 8.4-9.872 0-4.978-3.637-9.107-8.4-9.873zM16.778 10c0-4.237 3.436-7.672 7.673-7.672.587 0 1.158.066 1.707.19.926.21 1.788.59 2.555 1.1l-2.555 2.556-8.09 8.085c-.812-1.22-1.29-2.685-1.29-4.26zm9.38 7.48c-.55.126-1.12.19-1.708.19-1.576 0-3.04-.474-4.26-1.29l5.966-5.966L30.83 5.74c.817 1.218 1.29 2.683 1.29 4.26.002 3.65-2.548 6.704-5.963 7.48z' clip-rule='evenodd' fill-rule='evenodd'/>
    <g style='line-height:125%' font-size='10' font-family='sans-serif' letter-spacing='0' word-spacing='0'>
      <path d='M.986 25.054v5.67h1.192q1.51 0 2.207-.684.703-.684.703-2.158 0-1.465-.703-2.144-.698-.684-2.207-.684H.986zM0 24.244h2.026q2.12 0 3.11.884.992.88.992 2.754 0 1.884-.996 2.768-.996.884-3.106.884H0v-7.29zM7.695 24.244h.987v7.29h-.987v-7.29zM15.015 24.483v.962q-.562-.27-1.06-.4-.498-.132-.962-.132-.806 0-1.245.312-.435.313-.435.89 0 .482.29.73.292.246 1.102.397l.596.122q1.104.21 1.627.742.527.528.527 1.416 0 1.06-.713 1.607-.707.545-2.08.545-.516 0-1.102-.117-.58-.117-1.206-.346v-1.016q.6.337 1.176.508.576.17 1.133.17.846 0 1.305-.33.46-.333.46-.95 0-.536-.333-.838-.327-.303-1.08-.455l-.6-.116q-1.103-.22-1.597-.688-.493-.47-.493-1.304 0-.967.68-1.523.683-.558 1.88-.558.512 0 1.044.093t1.09.278zM19.624 25.216l-1.338 3.627h2.68l-1.342-3.627zm-.557-.972h1.12l2.777 7.29h-1.026l-.664-1.87h-3.286l-.664 1.87h-1.04l2.783-7.29zM25.01 28.052v2.67h1.582q.796 0 1.177-.326.384-.332.384-1.01 0-.684-.385-1.006-.382-.328-1.178-.328H25.01zm0-2.998v2.198h1.46q.722 0 1.074-.27.356-.272.356-.83 0-.55-.356-.824-.352-.274-1.074-.274h-1.46zm-.987-.81h2.52q1.128 0 1.738.47.612.467.612 1.332 0 .67-.313 1.064-.313.396-.92.493.73.156 1.13.655.404.493.404 1.235 0 .976-.664 1.51-.664.53-1.89.53h-2.617v-7.29zM30.88 24.244h.985v6.46h3.55v.83H30.88v-7.29zM36.445 24.244h4.61v.83h-3.623v2.158h3.47v.83h-3.47v2.642h3.71v.83h-4.697v-7.29zM43.76 25.054v5.67h1.19q1.51 0 2.208-.684.703-.684.703-2.158 0-1.465-.702-2.144-.698-.684-2.207-.684h-1.19zm-.987-.81H44.8q2.12 0 3.11.884.99.88.99 2.754 0 1.884-.995 2.768-.996.884-3.105.884h-2.027v-7.29z'/>
    </g>
  </svg>
  """
  |> Regex.replace Regex.All (Regex.regex "\\n\\s*") (\_ -> "")


{-| The value for the readonly cursor.
-}
readonlyCursor : String
readonlyCursor =
  """
  <svg xmlns='http://www.w3.org/2000/svg' version='1' viewBox='0 0 52.548828 24.244142' width='52.549' height='24.244'>
    <path d='M26.402 0c-.61-.007-1.22.045-1.83.154-1.108.198-2.177.61-3.177 1.122-1.566.8-2.996 1.903-4.242 3.14-.23.228-.46.462-.67.71-.278.33-.278.723 0 1.054.64.756 1.398 1.428 2.17 2.043 1.662 1.325 3.563 2.433 5.66 2.88 1.214.256 2.435.267 3.654.05 1.108-.2 2.177-.612 3.178-1.123 1.566-.8 2.995-1.903 4.24-3.14.232-.228.46-.462.67-.71.113-.112.185-.257.21-.41v-.004l.003-.02.002-.02c0-.003 0-.007.002-.01V5.69c.002-.012.002-.024.002-.037v-.037c0-.01-.002-.017-.003-.025v-.01c0-.007 0-.013-.002-.02l-.003-.02v-.002c-.025-.155-.098-.3-.21-.412-.637-.756-1.396-1.43-2.168-2.043C32.225 1.758 30.324.65 28.225.203 27.62.076 27.01.01 26.402.002zm-.128 1.805c2.126 0 3.848 1.723 3.848 3.848S28.4 9.5 26.274 9.5c-2.125 0-3.848-1.722-3.848-3.847s1.723-3.848 3.848-3.848zm0 2.574A1.274 1.274 0 0 0 25 5.652a1.274 1.274 0 0 0 1.274 1.274 1.274 1.274 0 0 0 1.274-1.274 1.274 1.274 0 0 0-1.274-1.274z'/>
    <g style='line-height:125%' font-size='10' font-family='sans-serif' letter-spacing='0' word-spacing='0'>
      <path d='M3.457 20.685q.317.107.615.46.303.35.606.965l1 1.993H4.62l-.93-1.87q-.363-.733-.705-.972-.337-.24-.922-.24H.987v3.083H0v-7.29h2.227q1.25 0 1.865.522t.615 1.577q0 .69-.322 1.143-.318.454-.928.63zm-2.47-3.062v2.588h1.24q.712 0 1.074-.326.367-.332.367-.972 0-.64-.366-.962-.36-.327-1.073-.327H.987zM6.953 16.813h4.61v.83H7.938V19.8h3.47v.83H7.94v2.642h3.71v.83H6.953v-7.29zM15.718 17.784l-1.338 3.628h2.68l-1.342-3.628zm-.557-.97h1.12l2.778 7.29h-1.026l-.664-1.872h-3.286l-.664 1.87h-1.04l2.783-7.29zM21.104 17.623v5.67h1.19q1.51 0 2.208-.685.703-.683.703-2.158 0-1.465-.703-2.143-.698-.684-2.207-.684h-1.19zm-.987-.81h2.027q2.12 0 3.11.883.99.88.99 2.754 0 1.885-.995 2.77-.997.883-3.106.883h-2.027v-7.29zM30.77 17.48q-1.073 0-1.707.802-.63.8-.63 2.183 0 1.377.63 2.178.634.8 1.708.8 1.076 0 1.7-.8.63-.8.63-2.178 0-1.382-.63-2.183-.624-.8-1.7-.8zm0-.8q1.535 0 2.453 1.03.918 1.026.918 2.755 0 1.723-.917 2.754-.918 1.024-2.452 1.024-1.537 0-2.46-1.025-.917-1.027-.917-2.755 0-1.73.918-2.754.923-1.03 2.46-1.03zM35.684 16.813h1.328l3.232 6.098v-6.097h.957v7.29h-1.327l-3.232-6.1v6.1h-.956v-7.29zM43.164 16.813h.986v6.46h3.55v.83h-4.536v-7.29zM46.4 16.813h1.06l2.022 2.998 2.007-2.997h1.06l-2.58 3.818v3.473h-.99V20.63l-2.58-3.817z'/>
    </g>
  </svg>
  """
  |> Regex.replace Regex.All (Regex.regex "\\n\\s*") (\_ -> "")


{-| Mixins in the disabled cursor and makes the node not selectable.
-}
disabled : Node
disabled =
  mixin
    [ cursor ("url(\"data:image/svg+xml;utf8," ++ disabledCursor ++ "\") 24 15, auto !important")
    , userSelect none
    ]


{-| Mixins in the readonly cursor.
-}
readonly : Node
readonly =
  mixin
    [ cursor ("url(\"data:image/svg+xml;utf8," ++ readonlyCursor ++ "\") 26 12, auto")
    ]
