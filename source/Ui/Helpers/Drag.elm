module Ui.Helpers.Drag exposing
  ( Drag, Model, init, onMove, onEnd, lift, end, liftHandler, diff
  , relativePosition, relativePercentPosition )

{-| Low level helper functions for creating drag interactions.

# Model
@docs Drag, Model, init

# Events
@docs onMove, onEnd

# Lifecycle
@docs lift, end, liftHandler

# Functions
@docs diff, relativePosition, relativePercentPosition
-}

import Html.Events exposing (on)
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


{-| Representation of a model that supports drag:
  - **uid** - The unique identifier of the model
  - **drag** - The drag model
-}
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


{-| A event handler for a drag.
-}
liftHandler : (Position -> msg) -> Html.Attribute msg
liftHandler msg =
  on "mousedown" (Json.map (convertPosition msg) Mouse.position)


{-| Converts a position into a message.
-}
convertPosition : (Position -> msg) -> Mouse.Position -> msg
convertPosition msg pos =
  msg { top = toFloat pos.y, left = toFloat pos.x }


{-| Empty dimensinos used as a fallback.
-}
emptyDimensions : Dimensions
emptyDimensions =
  { height = 0
  , bottom = 0
  , width = 0
  , right = 0
  , left = 0
  , top = 0
  }


{-| Subscribe to move events of a drag.
-}
onMove : (Position -> msg) -> Model a -> Sub msg
onMove msg ({ drag } as model) =
  if drag.dragging then
    Mouse.moves (convertPosition msg)
  else
    Sub.none


{-| Subscribe to end events of a drag.
-}
onEnd : msg -> Model a -> Sub msg
onEnd msg ({ drag } as model) =
  if drag.dragging then
    Mouse.ups (always msg)
  else
    Sub.none


{-| Returns the difference between the start position and the given position.
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
      DOM.idSelector model.uid
        |> DOM.getDimensionsSync
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


{-| Ends a drag.
-}
end : Model a -> Model a
end ({ drag } as model) =
  if model.drag.dragging then
    { model | drag = { drag | dragging = False } }
  else
    model
