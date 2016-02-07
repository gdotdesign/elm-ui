# Contributing
Any contributions are welcome.

## Installing dependencies
After cloning the repository you will need to install both **Elm** and **Node** dependencies:
  * To install the Node ones run `npm install` in the root of the directory
  * To install the Elm ones run `npm run elm-install` in the root of the directory

## Development environment
You can start the development environment with the `npm start` command, this will
start the same development server as the `elm-ui server`.

## The Main Module
The main module contains the **examples (kitchen sink)** of all components (which are used for tests).

## Styles
The stylesheet directory contains the styles for the components.

## Building
You can build the project with the `npm run build` command which is the same as
the `elm-ui build` command.

## Component Guidelines
You should keep in mind the following when submitting a new **component**:
  * The business logic of the component **must be implemented in elm**,
    in other words wrapping JavaScript components are not allowed
  * The components files should follow the current structure:
    * The Elm file should be under `source/ui/ComponentName.elm` (capitalized)
    * The Style file should be under `stylesheets/ui/ui-component-name.scss` (dasherized)
  * The source should be **documented** and **exposed** in the `elm-package.json`
    file for documentation purposes.
  * The views should use **lazy rendering** from `Html.Lazy`
  * The views should return a single **node** with a tag matching the filenames
    (dasherized) with the **ui-** prefix (`ui-component-name`).
  * It should be one of **4 types of components**
    * **static** - Doesn't have interactions (only view)
    * **interactive** - It must implement the **Elm Architecture** (Model, Action, init, update, view)
    * **interactive with effects** - Same as interactive but the `update` should return `(model, effect)`
    * **interactive with address (effects)** - Same as interactive but it takes addresses to send changes to
  * If the component is focusable the neccessary keyboard interface should be implemented
  * One or more examples should be added the kitchensink to show usage
  * Tests should be added for the most used configuration and states
