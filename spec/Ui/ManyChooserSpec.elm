import Spec exposing (..)

import Html exposing (div)
import Ui.Chooser
import Set

type alias Model =
  List (Int, Ui.Chooser.Model)

type Msg
  = Chooser Int Ui.Chooser.Msg

items : List Ui.Chooser.Item
items =
  List.range 0 100
  |> List.map toString
  |> List.map (\index -> { id = index, label = index , value = index } )

init : () -> Model
init _ =
  List.range 0 100
  |> List.map
    ( \index ->
      ( index
      , Ui.Chooser.init ()
        |> Ui.Chooser.items items
        |> Ui.Chooser.renderWhenClosed False
      )
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
  case msg_ of
    Chooser index msg ->
      let
        updatedData =
          List.map updateChooser model

        updatedChoosers =
          List.map (\(i, (chooser, cmd)) -> (i, chooser)) updatedData

        command =
          updatedData
            |> List.map (\(i, (chooser, cmd)) -> Cmd.map (Chooser i) cmd )
            |> Cmd.batch

        values =
          updatedChoosers
          |> List.map Tuple.second
          |> List.map .selected
          |> List.foldr Set.union Set.empty

        updateChooser (i, chooser) =
          if index == i then
            ( i, Ui.Chooser.update msg chooser )
          else
            ( i, ( chooser, Cmd.none ) )

        updateOtherChooser (i, chooser) =
          if index == i then
            ( i, chooser )
          else
            let
              filteredItems =
                List.filter
                  (\item ->
                    (not (Set.member item.value values)) ||
                    (Set.member item.value chooser.selected)
                  )
                  items
            in
              (i, Ui.Chooser.items filteredItems chooser)

        otherChoosers =
          List.map updateOtherChooser updatedChoosers
      in
        ( otherChoosers, command )

view : Model -> Html.Html Msg
view model =
  div []
    ( List.map
      ( \(index, chooser) ->
        Html.map (Chooser index) (Ui.Chooser.view chooser)
      )
      model
    )


specs : Node
specs =
  describe "Many choosers"
    []

main =
  runWithProgram
    { subscriptions = \_ -> Sub.none
    , init = init
    , update = update
    , view = view
    } specs
