:warning: This library is still under development use it in production at your own risk. :warning:

------------------------

# Elm UI
An opinionated **UI library** and **application framework** for the web in *Elm*,
following the **Elm Architecture**.

[![Build Status](https://travis-ci.org/gdotdesign/elm-ui.svg?branch=master)](https://travis-ci.org/gdotdesign/elm-ui)
[![NPM Package](https://d25lcipzij17d.cloudfront.net/badge.svg?id=js&type=6&v=0.1.3&x2=0)](https://www.npmjs.com/package/elm-ui)
[![Dependencies](https://david-dm.org/gdotdesign/elm-ui.svg)](https://david-dm.org/gdotdesign/elm-ui)

## Getting Started
Elm-UI provides you the following features:
* An application framework:
  - **Elm** is used for the frontend logic
  - **Sass** is used for the stylesheets
  - **Lots of components** ready to be used
  - Support for **environment configurations**
* A development workflow:
  - A **command** for **scaffolding a project** with a demo to quickly get started
  - A **development server** which will reload your page when an **Elm** file is
    changed and inject the css when a **Sass** file is changed (via BrowserSync)
  - The **error messages** are displayed (with color if available) in the
    browser both for **Elm** and **Sass**
  - A **build command** to build your final files
* [Conventions](https://github.com/gdotdesign/elm-ui/wiki/Conventions) to keep
things simple

### Installing
Elm-UI is avaiable as a **command line client** via NPM:

`npm install elm-ui -g`

See [Command Line Interface (CLI)](https://github.com/gdotdesign/elm-ui/wiki/Command-Line-Interface)
for documentation.

### Scaffolding a new Project
To scaffold a new project just use the `elm-ui init my-project-name` command.

### The elm-ui.json
The project configuration lives in the **elm-ui.json** file, which is a clone
of **Elms elm-package.json** file. This is needed because the *Elm Pacakge Manager*
doesn't support installing packages from Github, so Elm-UI manages the the actual
**elm-package-json**.

You can add elm packages and source directories that you need into the
**elm-ui.json** file. Elm-UI dependecies are automatically added when installing,
you can see them [here](https://github.com/gdotdesign/elm-ui/blob/master/elm-package.json).

### Installing Packages
After you scaffolded a project you need to install **Elm** packages with the
`elm-ui install` command.

### Starting the development server
Use the `elm-ui server` to start a development server.

There are three applications are available on different ports:
* **localhost:8001** - The main application
* **localhost:8002** - The proxied application that reloads on changes
* **localhost:8003** - The [BrowserSync](https://www.browsersync.io/) UI (options)

### Building
* Build the final files with `elm-ui build` into **dist** directory.

## Implemented Componets
All of the components **business logic** is written completely in Elm
(while using the minimum **Native** bindings possible).

Interactive components so far:
- [x] Ui.App - The base for a web or mobile application
- [x] Ui.Button - Basic button component with different sizes and styles
- [x] Ui.ButtonGroup - A component for handling multiple buttons in a row
- [x] Ui.Calendar - A calendar component (orignially for the date picker)
- [x] Ui.Checkbox - Basic checkobx with three variations (checkbox, toggle, radio)
- [x] Ui.Chooser - A searchable, customizable select box with lots of features
- [x] Ui.ColorPanel - An interface for manipulating a **hue**, **saturation** and **value** properties of a color
- [x] Ui.ColorPicker - An input for selecting a color with a color panel
- [x] Ui.DatePicker - A date picker component using a calendar
- [x] Ui.DropdownMenu - A dropdown menu that is always visible on the screen
- [x] Ui.Image - An image that fades when loaded
- [x] Ui.InplaceInput - An input that can be edited in place (display and form view with a save button)
- [x] Ui.Input - Basic input component
- [x] Ui.Loader - A loader component
- [x] Ui.Modal - A base for modal dialogs
- [x] Ui.NotificationCenter - A component for displaying messages to the user
- [x] Ui.NumberPad - An interface for providing number values (like a calculator or lock screen)
- [x] Ui.NumberRange - An interface for maniuplating a number value by dragging
- [x] Ui.Pager - A pager component
- [x] Ui.Ratings - A ratings component
- [x] Ui.SearchInput - An input component for handling text search
- [x] Ui.Slider - A slider component
- [x] Ui.Tagger - A component to manage tags on an entity
- [x] Ui.Textarea - An automatically growing textarea
- [x] Ui.Time - A component to show relative time

Static components so far:
- [x] Ui.Container - A flexbox container for layouts
- [x] Ui.IconButton - A button with an icon on the left or right side
- [x] Ui.icon - Icons from Ionicons
- [x] Ui.title - Title
- [x] Ui.subTitle - Subtitle
- [x] Ui.panel - Panel for grouping content
- [x] Ui.inputGroup - Container for and input and a label
- [x] Ui.header - A mobile header
- [x] Ui.headerTitle - A title for a mobile header
- [x] Ui.headerIcon - An icon to be used in a header
- [x] Ui.fab - Floating action button

Planned components:
- [ ] Ui.Tabs - A tab component
- [ ] Ui.Upload - A file upload component
- [ ] Ui.MaskedInput - An input component where the value is masked by a pattern
- [ ] Ui.CheckboxGroup - A component for selecting a value via checkboxes

## Documentation
Currently the only documentation is the Elm documentation that you can generate
with the `npm run elm-docs` and then opening the `documentation.json` with the
**preview** feature in [http://package.elm-lang.org/help/docs-preview](http://package.elm-lang.org/help/docs-preview).
