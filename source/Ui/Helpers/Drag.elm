module Ui.Helpers.Drag where

import Html.Extra

type alias Model =
  { dragging : Bool
  , dimensions : Html.Extra.Dimensions
  , mouseStartPosition : Html.Extra.Position
  }

type alias Point =
  { top : Float
  , left : Float
  }

diff : Int -> Int -> Model -> Point
diff x y model =
  { top = (toFloat y) - model.mouseStartPosition.pageY
  , left = (toFloat x) - model.mouseStartPosition.pageX
  }

init : Model
init =
  { dragging = False
  , dimensions = { top = 0, left = 0, width = 0, height = 0 }
  , mouseStartPosition = { pageX = 0, pageY = 0 }
  }

lift : Html.Extra.Dimensions -> Html.Extra.Position -> Model -> Model
lift dimensions position model =
  { model | dragging = True
          , dimensions = dimensions
          , mouseStartPosition = position }

handleClick : Bool -> Model -> Model
handleClick pressed model =
  if not pressed && model.dragging then
    { model | dragging = False }
  else
    model

updateDimensions : Html.Extra.Dimensions -> Model -> Model
updateDimensions dimensions model =
  { model | dimensions = dimensions }
