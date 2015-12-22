module Ui.Helpers.Drag where

{-| Helper functions for handling drags.

    drag = Drag.init
    -- Later on when the mouse is down
    Drag.lift dimensions startPosition drag
    -- During mouse move calulate things when necessary
    distanceMoved = Drag.diff pageX pageY drag
    -- When the mouse is released
    Drag.handleClick False drag

# Model
@docs Point, Model, init

# Lifecycle
@docs lift, handleClick

# Functions
@docs diff, relativePosition, relativePercentPosition
-}
import Html.Extra

{-| Represents a drag. -}
type alias Model =
  { mouseStartPosition : Html.Extra.Position
  , dimensions : Html.Extra.Dimensions
  , dragging : Bool
  }

{-| Represents a point. -}
type alias Point =
  { left : Float
  , top : Float
  }

{-| Initilalizes a drag model. -}
init : Model
init =
  { dimensions = { top = 0
                 , left = 0
                 , width = 0
                 , height = 0
                 , bottom = 0
                 , right = 0 }
  , mouseStartPosition = { pageX = 0, pageY = 0 }
  , dragging = False
  }

{-| Calculates the difference between the start position and
the given position. -}
diff : Int -> Int -> Model -> Point
diff x y model =
  { left = (toFloat x) - model.mouseStartPosition.pageX
  , top = (toFloat y) - model.mouseStartPosition.pageY
  }

{-| Returns the given points relative position to the
dimensions of the drag. -}
relativePosition : Int -> Int -> Model -> Point
relativePosition x y model =
  { left = (toFloat x) - model.dimensions.left
  , top = (toFloat y) - model.dimensions.top
  }

{-| Returns the give points relative position to the
dimensions of the drag as a percentage. -}
relativePercentPosition : Int -> Int -> Model -> Point
relativePercentPosition x y model =
  let
    point = relativePosition x y model
  in
    { top = point.top / model.dimensions.height
    , left = point.left / model.dimensions.width
    }

{-| Starts a drag. -}
lift : Html.Extra.Dimensions -> Html.Extra.Position -> Model -> Model
lift dimensions position model =
  { model | mouseStartPosition = position
          , dimensions = dimensions
          , dragging = True
          }

{-| Handles the "mouseup" event, if the given pressed value is False
stopping the drag. -}
handleClick : Bool -> Model -> Model
handleClick pressed model =
  if not pressed && model.dragging then
    { model | dragging = False }
  else
    model
