:warning: This library is still under development use it in production at your own risk. :warning:

------------------------

# Elm UI
An opinionated UI library for the web in Elm, following the **Elm Architecture**.

[![Build Status](https://travis-ci.org/gdotdesign/elm-ui.svg?branch=master)](https://travis-ci.org/gdotdesign/elm-ui)

## Implemented Componets
All of the components **business logic** is written completely in Elm (while using the minimum **Native** bindings possible).

Interactive components so far:
- [x] Ui.App - The base for a web or mobile application
- [x] Ui.Button - Basic button component with different sizes and styles
- [x] Ui.Calendar - A calendar component (orignially for the date picker)
- [x] Ui.Checkbox - Basic checkobx with three variations (checkbox, toggle, radio)
- [x] Ui.Chooser - A searchable, customizable select box with lots of features
- [x] Ui.ColorPanel - An interface for manipulating a **hue**, **saturation** and **value** properties of a color
- [x] Ui.ColorPicker - An input for selecting a color with a color panel
- [x] Ui.DatePicker - A date picker component using a calendar
- [x] Ui.Image - An image that fades when loaded
- [x] Ui.DropdownMenu - A dropdown menu that is always visible on the screen
- [x] Ui.InplaceInput - An input that can be edited in place (display and form view with a save button)
- [x] Ui.Input - Basic input component
- [x] Ui.Modal - A base for modal dialogs
- [x] Ui.NotificationCenter - A component for displaying messages to the user
- [x] Ui.NumberPad - An interface for providing number values (like a calculator or lock screen)
- [x] Ui.NumberRange - An interface for maniuplating a number value by dragging
- [x] Ui.Pager - A pager component
- [x] Ui.Slider - A slider component
- [x] Ui.Textarea - An automatically growing textarea
- [x] Ui.Ratings - A ratings component

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
- [x] Ui.fab - Floating action button

Planned components:
- [ ] Ui.Tabs - A tab component
- [ ] Ui.Upload - A file upload component
- [ ] Ui.ButtonGroup - A component for selecting a value via buttons
- [ ] Ui.MaskedInput - An input component where the value is masked by a pattern
- [ ] Ui.CheckboxGroup - A component for selecting a value via checkboxes


## Getting Started
For now, you will need to **clone** or **download** this repository into a directory for server reasons:
  * It uses **Native Modules** because of this its not included int the **Elm packages repository**
  * It uses **Sass** to render the stylesheets
  * It uses **Koa** to provide a development environment
  * It uses **Gulp** to build the final files

#### Prerequisites
* A working version of Node at least (v4)

### Installing dependencies
You will need to install both **Elm** and **Node** dependencies:
  * To install the Node ones run `npm install` in the root of the directory
  * To install the Elm ones run `npm run elm-install` in the root of the directory

### Development environment
You can start the development environment with the `npm start` command, this will start a server that listens on `http://localhost:8001`.

### The Main Module
Your applications main file lives in `source/Main.elm`, this will be the file that is compiled and served as your application. This is probably where you want to set up your [StartApp](https://github.com/evancz/start-app). By default the **examples (kitchen sink)** of all components will be displayed (which are used for tests).

### Styles
The main file for your applications styles is the `stylesheets/main.scss`, it will include all of the styles neccessary for the components defined by this library. You can add your styles here or import from anywhere inside the `stylesheets` directory.

### Building
You can build your application with the `npm run build` command. This will:
 * Compile and uglify your the Elm files into the `dist/main.js`
 * Compile, autoprefix and uglify your the stylesheets into `dist/main.css`
 * Build the `dist/index.html`
 * Copy all of the static assets from the `public` folder into `dist`,

You should end up with something like this:
```
dist/
 - index.html
 - main.css
 - main.js
 - static files
 ..
```

## Documentation
Currently the only documentation is the Elm documentation that you can generate with the `npm run elm-docs` and then opening the `documentation.json` with the **preview** feature in [http://package.elm-lang.org/help/docs-preview](http://package.elm-lang.org/help/docs-preview).

## Contributing
Any contributions are welcome, you should keep in mind the following when submitting a new **component**:
  * The business logic of the component **must be implemented in elm**, in other words wrapping JavaScript components are not allowed
  * The components files should follow the current structure:
    * The Elm file should be under `source/ui/ComponentName.elm` (capitalized)
    * The Style file should be under `stylesheets/ui/component-name.elm` (dasherized)
  * The source should be **documented** and **exposed** in the `elm-package.json` file for documentation purposes.
  * The views should use **lazy rendering** from `Html.Lazy`
  * The views should return a single **node** with a tag matching the filenames (dasherized) with the **ui-** prefix (`ui-component-name`).
  * It should be one of **3 types of components**
    * **static** - Doesn't have interactions (only view)
    * **interactive** - It must implement the **Elm Architecture** (Model, Action, init, update, view)
    * **interactive with effects** - Same as interactive but the `update` should return `(model, effect)`
  * If the component is focusable the neccessary keyboard interface should be implemented
  * One or more examples should be added the kitchensink to show usage.
  * Tests should be added for the most used configuration and states
