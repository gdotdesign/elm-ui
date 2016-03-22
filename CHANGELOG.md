# Changelog

## 0.1.5

### Pull Requests Closed
- [Changing mgold's elm-date-format dependency for more powerful rluiten…](https://github.com/gdotdesign/elm-ui/pull/17)
- [Fix typo in README](https://github.com/gdotdesign/elm-ui/pull/15)
- [Fix typo in documentation](https://github.com/gdotdesign/elm-ui/pull/14)
- [Fix documentation for iconAttributes](https://github.com/gdotdesign/elm-ui/pull/13)
- [Tabs +1](https://github.com/gdotdesign/elm-ui/issues/20)

### New Components
- **Ui.Tabs** - A component to handle tabbed contents
- **Ui.scrolledPanel** - A static component for scrollable content (scrollbar styled for Chrome)

### Changes
- Now using **elm-date-extra** for date formatting instead of **elm-date-format**
- Unified how values are set for components with **setValue**:
  - **Ui.Chooser.select** renamed to **Ui.Chooser.setValue**
  - **setValue** functions no longer send the given value to the valueAddress
  - Added **setAndSendValue** to some components
- Header componets are moved into a seprate module:
  - **Ui.header** is now **Ui.Header.view**
  - **Ui.headerIcon** is now **Ui.Header.icon**
  - **Ui.headerTitle** is now **Ui.Header.title**
  - Added **Ui.Header.separator**
  - Added **Ui.Header.item**
  - Added **Ui.Header.iconItem**

### CLI
- Added **docs** command to generate Elm documentation.
- Added **start** alias for **server** command.
- Environment data and Elm app initialization is now bundled into JS file

### Ui.Container
- **render** function is now exposed

### Ui.Input
- Added **focus** function to focus a **Ui.Input** component

### Ui.Textarea
- Added **focus** function to focus a **Ui.Textarea** component

### Ui.Tags
- Added ability to tab to the remove icons

### Html.Extra
- Added **onWheel** event handler
- Added **deltaDecoder** to decode wheel deltas

### Native.Browser
- Changed how DOM elements are accessed internally
- Added **haveSelector** function to check for an element in the DOM
- Added **atElement** decoder which tries to find the first child element with the given selector
- Added **closest** decoder which tries to find the closest element with the given selector
- Added **focusTask** to focus an element with the given selector as a Task

### Native.LocalStorage
- Changed it to use Task instead of Result
- Added support for [chrome.storage](https://developer.chrome.com/extensions/storage) storage.

## 0.1.3

### New Components
- **Ui.ButtonGroup** - A component for handling multiple buttons together
- **Ui.Tagger** - A component for managing tags on an entity
- **Ui.Time** - A component for displaying relative time
- **Ui.Loader** - A loader component (with a timeout before showing)
- **Ui.SearchInput** - A component for handling text search
- **Ui.breadcrumbs** - A component for displaying breadcrumbs navigation
- **Ui.headerIcon** - Added to be used in specifically in **Ui.header**

### Component Changes
- **Ui.text** is now **Ui.textBlock** to avoid collision with **Html.text**
- Added remaining variations to **Ui.Container**
- Providing a placeholder for **Ui.Icon** is now mandatory
- Switched the **viewModel** and **address** parameters in **Ui.NumberPad**
  to be more consistent with the other components
- Changed the default colors for **success, danger** and **warning**

### Fixes
- Fixed an issue with Safari slowness #5
- Fixed an issue that prevented Elm-UI from working in Safari
- Fixed **Ui.Choosers closeOnSelect** behavior when pressing the **enter key**
- Optimized rendering of many components
- Optimized rendering of the KitchenSink demo (~5ms down from ~16ms)
