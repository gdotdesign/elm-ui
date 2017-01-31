import Spec exposing (..)

import Html exposing (div, text)
import Task exposing (Task)
import Ui.Container


type alias Model
  = String


type Msg
  = NoOp


init : () -> Model
init _ =
  ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
  div []
    [ Ui.Container.row []
      [ div [] [ text "a" ]
      , div [] [ text "b" ]
      , div [] [ text "c" ]
      ]
    , Ui.Container.rowCenter []
      [ div [] [ text "a" ]
      , div [] [ text "b" ]
      , div [] [ text "c" ]
      ]
    , Ui.Container.rowEnd []
      [ div [] [ text "a" ]
      , div [] [ text "b" ]
      , div [] [ text "c" ]
      ]
    , Ui.Container.column []
      [ div [] [ text "a" ]
      , div [] [ text "b" ]
      , div [] [ text "c" ]
      ]
    , Ui.Container.columnCenter []
      [ div [] [ text "a" ]
      , div [] [ text "b" ]
      , div [] [ text "c" ]
      ]
    , Ui.Container.columnEnd []
      [ div [] [ text "a" ]
      , div [] [ text "b" ]
      , div [] [ text "c" ]
      ]
    , Ui.Container.view
      { direction = "row"
      , compact = True
      , align = "start"
      }
      []
      [ div [] [ text "a" ]
      , div [] [ text "b" ]
      , div [] [ text "c" ]
      ]
    , Ui.Container.view
      { direction = "column"
      , compact = True
      , align = "start"
      }
      []
      [ div [] [ text "a" ]
      , div [] [ text "b" ]
      , div [] [ text "c" ]
      ]
    ]


displayAssertions : String -> String -> String -> List (Task Never Outcome)
displayAssertions selector direction justify =
  [ assert.elementPresent selector
  , assert.styleEquals
    { style = "display"
    , value = "flex"
    , selector = selector
    }
  , assert.styleEquals
    { style = "flex-direction"
    , value = direction
    , selector = selector
    }
  , assert.styleEquals
    { style = "justify-content"
    , value = justify
    , selector = selector
    }
  ]


specs : Node
specs =
  describe "Ui.Container"
    [ context "spacing"
      [ context "compact"
        [ it "does not add space between elements"
          [ assert.not.styleEquals
            { selector = "ui-container[direction=row][compact] div:nth-child(2)"
            , style = "margin-left"
            , value = "10px"
            }
          , assert.not.styleEquals
            { selector = "ui-container[direction=column][compact] div:nth-child(2)"
            , style = "margin-top"
            , value = "10px"
            }
          ]
        ]
      , context "row"
        [ it "adds space between elements"
          [ assert.styleEquals
            { selector = "ui-container[direction=row] div:nth-child(2)"
            , style = "margin-left"
            , value = "10px"
            }
          ]
        ]
      , context "column"
        [ it "adds space between elements"
          [ assert.not.styleEquals
            { selector = "ui-container[direction=column] div:first-child"
            , style = "margin-top"
            , value = "10px"
            }
          , assert.styleEquals
            { selector = "ui-container[direction=column] div:nth-child(2)"
            , style = "margin-top"
            , value = "10px"
            }
          ]
        ]
      ]
    , context "row"
      [ it "start"
        (displayAssertions
          "ui-container[direction=row][align=start]"
          "row"
          "flex-start")
      , it "center"
        (displayAssertions
          "ui-container[direction=row][align=center]"
          "row"
          "center")
      , it "end"
        (displayAssertions
          "ui-container[direction=row][align=end]"
          "row"
          "flex-end")
      ]
    , context "column"
      [ it "start"
        (displayAssertions
          "ui-container[direction=column][align=start]"
          "column"
          "flex-start")
      , it "center"
        (displayAssertions
          "ui-container[direction=column][align=center]"
          "column"
          "center")
      , it "end"
        (displayAssertions
          "ui-container[direction=column][align=end]"
          "column"
          "flex-end")
      ]
    ]


main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , update = update
    , view = view
    , init = init
    } specs
