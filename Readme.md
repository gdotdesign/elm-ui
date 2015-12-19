:warning: This library is still under development use it in production at your own risk.

------------------------

# Elm UI
An opinionated UI library for the web in Elm.

## Getting Started
For now, you will need to **clone** or **download** this repository into a directory for server reasons:
  * It uses **Native Modules** because of this its not included int the **Elm packages repository** 
  * It uses **Sass** to render the stylesheets and **Koa** to provide a development environment so it need some **Node Modules**

#### Prerequisites
* A working version of Elm v0.16
* A working version of Node

### Installing dependencies
You will need to install both **Elm** and **Node** dependencies:
  * To install the Node ones run `npm isntall` in the root of the directory
  * To install the Elm ones run `elm package install` in the root of the directory

### Development environment
You can start the development environment with the `npm start` command, this will start a server that listens on `http://localhost:8001`.

### The Main Module
Your applications main file lives in `source/Main.elm`, this will be the file that is compiled and served as your application. This is probably where you want to set up your [StartApp](https://github.com/evancz/start-app). By default the **examples (kitchensink)** of all components will be displayed.

### Styles
The main file for your applications styles is the `stylesheets/main.scss`, it will include all of the styles neccessary for the components defined by this library. You can add your styles here or import from anywhere inside the `stylesheets` directory.

### Building
You can build your application with the `npm build` command. This will:
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
Currently to only documentation is the Elm documentation that you can generate with the `elm-make --docs=documentation.json` and then opening it with the **preview** feature in [http://package.elm-lang.org/help/docs-preview](http://package.elm-lang.org/help/docs-preview).

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
