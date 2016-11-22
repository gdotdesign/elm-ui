module Ui.Helpers.Drag_ exposing (..)

{-| Low level helper functions for creating drag interactions.

    drag = Drag.init

    -- Later on when the mouse is down
    Drag.lift position drag

    -- During move calulate things when necessary
    distanceMoved = Drag.diff position drag

    -- When the mouse is released
    Drag.end drag

# Model
@docs Drag, Model, init, emptyDimensions

# Events
@docs onMove, onEnd

# Lifecycle
@docs lift, end, liftHandler

# Functions
@docs diff, relativePosition, relativePercentPosition
-}
import Html.Events.Options exposing (preventDefaultOptions)
import Html.Events exposing (onWithOptions)
import Html

import Json.Decode as Json

import DOM exposing (Position, Dimensions)
import DOM.Window

import Mouse


{-| Representation of a drag:
  - **mouseStartPosition** - The start position of the mouse
  - **dimensions** - The associated element's dimensions
  - **dragging** - Whether or not the drag is active
-}
type alias Drag =
  { startPosition : Position
  , dimensions : Dimensions
  , dragging : Bool
  }

{-|-}
type alias Model a =
  { a
  | uid : String
  , drag : Drag
  }

{-| Initializes a drag model.
-}
init : Drag
init =
  { startPosition = { left = 0, top = 0 }
  , dimensions = emptyDimensions
  , dragging = False
  }

{-|-}
liftHandler : (Position -> msg) -> Html.Attribute msg
liftHandler msg =
  onWithOptions
    "mousedown"
    preventDefaultOptions
    (Json.map (\pos -> msg { top = toFloat pos.y, left = toFloat pos.x } ) Mouse.position)


{-|-}
emptyDimensions : Dimensions
emptyDimensions =
  { height = 0
  , bottom = 0
  , width = 0
  , right = 0
  , left = 0
  , top = 0
  }

{-|-}
onMove : (Position -> msg) -> Model a -> Sub msg
onMove msg ({ drag } as model) =
  if drag.dragging then
    Mouse.moves (\{ x, y } -> msg { top = toFloat y, left = toFloat x })
  else
    Sub.none


{-|-}
onEnd : msg -> Model a -> Sub msg
onEnd msg ({ drag } as model) =
  if drag.dragging then
    Mouse.ups (\_ -> msg)
  else
    Sub.none

{-| Calculates the difference between the start position and the given position.
-}
diff : Position -> Model a -> Position
diff { left, top } ({ drag } as model) =
  { left = left - drag.startPosition.left
  , top = top - drag.startPosition.top
  }


{-| Returns the given points relative position to the dimensions of the drag.
-}
relativePosition : Position -> Model a -> Position
relativePosition { left, top } ({ drag } as model) =
  { left = left - (drag.dimensions.left + (DOM.Window.scrollLeft ()))
  , top = top - (drag.dimensions.top + (DOM.Window.scrollTop ()))
  }


{-| Returns the give points relative position to the dimensions of the drag as
a percentage.
-}
relativePercentPosition : Position -> Model a -> Position
relativePercentPosition position ({ drag } as model) =
  let
    point =
      relativePosition position model
  in
    { left = point.left / drag.dimensions.width
    , top = point.top / drag.dimensions.height
    }


{-| Starts a drag.
-}
lift : Position -> Model a -> Model a
lift position ({ drag } as model) =
  let
    dimensions =
      DOM.getDimensionsSync (DOM.idSelector model.uid)
        |> Result.withDefault emptyDimensions
  in
    { model
      | drag =
        { drag
        | startPosition = position
        , dimensions = dimensions
        , dragging = True
        }
    }


{-| Handles the "mouseup" event, if the given pressed value is False
stopping the drag.
-}
end : Model a -> Model a
end ({ drag } as model) =
  if model.drag.dragging then
    { model | drag = { drag | dragging = False } }
  else
    model
