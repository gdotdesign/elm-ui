# Changelog

## 0.1.3

### New Components
- **Ui.ButtonGroup** - A component for handling multiple buttons together
- **Ui.Tagger**	- A component for managing tags on an entity
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
