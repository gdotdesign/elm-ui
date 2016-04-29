module Ui.Helpers.Drag exposing (..) -- where

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
import Html.Events.Geometry exposing (MousePosition, ElementDimensions)

import Ui.Helpers.Emitter as Emitter

import Json.Encode as JE
import Json.Decode as JD

{-| Represents a drag. -}
type alias Model =
  { mouseStartPosition : MousePosition
  , dimensions : ElementDimensions
  , dragging : Bool
  }

{-| Represents a point. -}
type alias Point =
  { left : Float
  , top : Float
  }

subscriptions : ((Float, Float) -> msg) -> (Bool -> msg) -> Sub msg
subscriptions move click =
  let
    decoder = Emitter.decode (JD.tuple2 (,) JD.float JD.float) (0,0)
    decoder2 = Emitter.decode (JD.bool) False
  in
    Sub.batch [ Emitter.listen "mouse-move" (decoder move)
              , Emitter.listen "mouse-click" (decoder2 click)
              ]

{-| Initilalizes a drag model. -}
init : Model
init =
  { dimensions = { top = 0
                 , left = 0
                 , width = 0
                 , height = 0
                 , bottom = 0
                 , right = 0 }
  , mouseStartPosition = { left = 0, top = 0 }
  , dragging = False
  }

{-| Calculates the difference between the start position and
the given position. -}
diff : Float -> Float -> Model -> Point
diff left top model =
  { left = left - model.mouseStartPosition.left
  , top = top - model.mouseStartPosition.top
  }

{-| Returns the given points relative position to the
dimensions of the drag. -}
relativePosition : Float -> Float -> Model -> Point
relativePosition left top model =
  { left = left - model.dimensions.left
  , top = top - model.dimensions.top
  }

{-| Returns the give points relative position to the
dimensions of the drag as a percentage. -}
relativePercentPosition : Float -> Float -> Model -> Point
relativePercentPosition left top model =
  let
    point = relativePosition left top model
  in
    { top = point.top / model.dimensions.height
    , left = point.left / model.dimensions.width
    }

{-| Starts a drag. -}
lift : ElementDimensions -> MousePosition -> Model -> Model
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
