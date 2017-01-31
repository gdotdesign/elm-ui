import Spec exposing (..)

import Steps exposing (..)
import Json.Encode as Json
import Ui.Container
import Ui.Ratings
import Html


view : Ui.Ratings.Model -> Html.Html Ui.Ratings.Msg
view model =
  Ui.Container.row []
    [ Ui.Ratings.view model
    , Ui.Ratings.view { model | disabled = True }
    , Ui.Ratings.view { model | readonly = True }
    ]


assertStarFull index =
  assert.attributeContains
    { selector = "ui-ratings-star:nth-child(" ++ (toString index) ++ ") path"
    , attribute = "d"
    , text = "M23"
    }


assertStarEmpty index =
  assert.attributeContains
    { selector = "ui-ratings-star:nth-child(" ++ (toString index) ++ ") path"
    , attribute = "d"
    , text = "M36"
    }


specs : Node
specs =
  describe "Ui.Ratings"
    [ it "has tabindex"
      [ assert.elementPresent "ui-ratings[tabindex]"
      ]
    , context "Disabled"
      [ it "does not have tabindex"
        [ assert.elementPresent "ui-ratings[disabled]"
        , assert.not.elementPresent "ui-ratings[disabled][tabindex]"
        ]
      ]
    , context "Readonly"
      [ it "has tabindex"
        [ assert.elementPresent "ui-ratings[readonly][tabindex]"
        ]
      ]
    , context "Keys"
      [ before
        [ steps.click "ui-ratings-star:nth-child(3)" ]
      , context "Up arrow"
        [ it "increments the value"
          [ assertStarEmpty 4
          , keyDown 38 "ui-ratings"
          , assertStarFull 4
          ]
        ]
      , context "Right arrow"
        [ it "increments the value"
          [ assertStarEmpty 4
          , keyDown 39 "ui-ratings"
          , assertStarFull 4
          ]
        ]
      , context "Down arrow"
        [ it "increments the value"
          [ assertStarFull 3
          , keyDown 40 "ui-ratings"
          , assertStarEmpty 3
          ]
        ]
      , context "Left arrow"
        [ it "increments the value"
          [ assertStarFull 3
          , keyDown 37 "ui-ratings"
          , assertStarEmpty 3
          ]
        ]
      ]
    , context "Clicking on a start"
      [ it "selects stars up until that star"
        [ assertStarEmpty 1
        , assertStarEmpty 2
        , steps.click "ui-ratings-star:nth-child(3)"
        , assertStarFull 1
        , assertStarFull 2
        , assertStarFull 3
        , assertStarEmpty 4
        ]
      ]
    , context "Selecting"
      [ before
        [ assertStarEmpty 1
        , assertStarEmpty 2
        , steps.dispatchEvent "mouseenter" (Json.object []) "ui-ratings-star:nth-child(2)"
        , assertStarFull 1
        , assertStarFull 2
        ]
      , context "Hovering over a star"
        [ it "sets the temporary value up until that star"
          [ assertStarEmpty 3
          ]
        ]
      , context "Moving the mouse out of a star"
        [ it "removes the temporary value"
          [ steps.dispatchEvent "mouseleave" (Json.object []) "ui-ratings-star:nth-child(2)"
          , assertStarEmpty 1
          , assertStarEmpty 2
          ]
        ]
      ]
    ]


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = Ui.Ratings.update
    , init = Ui.Ratings.init
    , view = view
    } specs
