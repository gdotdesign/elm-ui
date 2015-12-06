module Main where

import StartApp
import Effects
import Signal exposing (forwardTo)
import Task

import Ui.App
import Ui

type Action
  = App Ui.App.Action

init =
  ({ app = Ui.App.init }, Effects.none)

view address model =
  Ui.App.view (forwardTo address App) model.app []

update action model =
  (model, Effects.none)

app =
  StartApp.start { init = init
                 , view = view
                 , update = update
                 , inputs = [] }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
