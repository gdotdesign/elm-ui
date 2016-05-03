module Ui.Helpers.Drag exposing (..)

{-| Low level helper functions for creating drag interactions.

    drag = Drag.init

    -- Later on when the mouse is down
    Drag.lift dimensions startPosition drag

    -- During mouse move calulate things when necessary
    distanceMoved = Drag.diff pageX pageY drag

    -- When the mouse is released
    Drag.handleClick False drag

# Model
@docs Point, Model, init, subscriptions

# Lifecycle
@docs lift, handleClick

# Functions
@docs diff, relativePosition, relativePercentPosition
-}

-- where

import Html.Events.Geometry exposing (MousePosition, ElementDimensions)
import Mouse

{-| Representation of a drag:
  - **mouseStartPosition** - The start position of the mouse
  - **dimensions** - The associated element's dimensions
  - **dragging** - Whether or not the drag is active
-}
type alias Model =
  { mouseStartPosition : MousePosition
  , dimensions : ElementDimensions
  , dragging : Bool
  }


{-| Representation a point:
  - **left** - The left position
  - **top** - The top position
-}
type alias Point =
  { left : Float
  , top : Float
  }


{-| Initializes a drag model.
-}
init : Model
init =
  { mouseStartPosition = { left = 0, top = 0 }
  , dragging = False
  , dimensions =
      { height = 0
      , bottom = 0
      , width = 0
      , right = 0
      , left = 0
      , top = 0
      }
  }


{-| Creates subscriptions for a drag with the message for mouse move and
mouse click.
-}
subscriptions : (( Float, Float ) -> msg) -> (Bool -> msg) -> Bool -> Sub msg
subscriptions move click dragging =
  if dragging then
    Sub.batch
      [ Mouse.moves (move << (\{x,y} -> (toFloat x, toFloat y)))
      , Mouse.ups (click << (\_ -> False))
      ]
  else
    Sub.none


{-| Calculates the difference between the start position and the given position.
-}
diff : Float -> Float -> Model -> Point
diff left top model =
  { left = left - model.mouseStartPosition.left
  , top = top - model.mouseStartPosition.top
  }


{-| Returns the given points relative position to the dimensions of the drag.
-}
relativePosition : Float -> Float -> Model -> Point
relativePosition left top model =
  { left = left - model.dimensions.left
  , top = top - model.dimensions.top
  }


{-| Returns the give points relative position to the dimensions of the drag as
a percentage.
-}
relativePercentPosition : Float -> Float -> Model -> Point
relativePercentPosition left top model =
  let
    point =
      relativePosition left top model
  in
    { left = point.left / model.dimensions.width
    , top = point.top / model.dimensions.height
    }


{-| Starts a drag.
-}
lift : ElementDimensions -> MousePosition -> Model -> Model
lift dimensions position model =
  { model
    | mouseStartPosition = position
    , dimensions = dimensions
    , dragging = True
  }


{-| Handles the "mouseup" event, if the given pressed value is False
stopping the drag.
-}
handleClick : Bool -> Model -> Model
handleClick pressed model =
  if not pressed && model.dragging then
    { model | dragging = False }
  else
    model
