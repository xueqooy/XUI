# XUI

XUI is a UI component library for iOS development. It provides a collection of common UI elements and utilities to streamline development and improve productivity.

[![XUI](https://img.shields.io/badge/platform-iOS-blue)](https://github.com/xueqooy/XUI)
[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)

## Components

### Util
| Name | Description |
|--------------|--------------|
|**Colors**|Common color definition.|
|**Fonts**| Common font definition.|
|**Icons**|Common icon definition.|
|**Strings**|Localized strings definition.|
|**RichText**|Handling and displaying rich text, allowing you to construct rich text using DSL.|
|**KeyboardManager**|A utility to manage the keyboard’s behavior.|
|**HapticFeedback**|A utility to provide tactile feedback to users by triggering haptic vibrations.|
|**SingleSelectionGroup**|A UI component that allows users to select only one item from a group of options, useful for radio-button-like behavior.|
|**ViewFrameObserver**|An observer that monitors and responds to changes in a view's frame.|
|**OrientationObserver**|A utility to observe and respond to changes in device orientation.|
|**Device**|A helper class that provides information about the device.|
|**HighlightableTapGestureRecognizer**|A custom gesture recognizer that detects tap events and highlights the tapped element.|
|**ProgressiveGestureRecognizer**|A gesture recognizer that allows you to detect and handle ongoing gestures with progressive feedback.|
|**UIView+DockedKeyboardLayoutGuide**|A UIView extension that provides a layout guide that helps in adjusting views when the keyboard is displayed.|
|**UIView+EndEditingTapGesture**|A UIView extension that adds a gesture recognizer to dismiss the keyboard when the user taps outside the text field or editable area.|
|**UIView+CustomSpacingAfter**|A UIView extension that allows you to customize the spacing between UI elements in stack.|
|**UIScrollView+ AutomaticAdjustmentBasedOnKeyboardHeightChange**|An extension for UIScrollView that automatically adjusts the content inset when the keyboard appears or disappears.|
|**UIViewController+ViewState**|An extension for UIViewController that manages and tracks the view’s state (such as `notLoaded`, `didLoad`, `willAppear`, `isAppearing`, `didAppear`, `willDisappear`, or `didDisappear`|

### Control
| Name                | Description                                        |
|--------------------------|----------------------------------------------------|
| **Button**               | A customizable button based on configuration.        |
| **InputField**           | A basic text input field for single-line input.    |
| **MultilineInputField**  | A text input field that supports multiple lines.   |
| **PasswordInputField**   | An input field for entering passwords securely.    |
| **SearchInputField**     | A text field designed for search input.            |
| **MobileNumberInputField**| A field for entering mobile phone numbers.         |
| **SelectInputField**     | A drop-down menu for selecting one option.         |
| **InsetTextField**       | A text field with padding to enhance appearance.   |
| **CodeInputView**        | A view for inputting and displaying codes.         |
| **SegmentControl**       | A segmented control for switching between options. |
| **OptionControl**        | A control for choosing between multiple options.   |
| **PageControl**          | A control that indicates the current page in a set of pages. |
| **Switch**               | A toggle switch to turn settings on or off.        |
| **RefreshControl**       | A control for triggering pull-to-refresh actions. |
| **RangeSlider**          | A slider for selecting a range of values.          |

### Presentation
| Name               | Description                                          |
|-------------------------|------------------------------------------------------|
| **DrawerController**     | A controller for managing side drawer navigation.     |
| **PopupController**      | A controller for displaying modal popups.            |
| **CoachmarkController**  | A controller for displaying onboarding coach marks.  |
| **ActionSheet**          | A menu that slides up from the bottom for options.   |
| **ConfirmationDialog**   | A dialog box for confirming user actions.            |
| **ToastView**            | A non-intrusive, brief message displayed at the bottom. |
| **Tooltip**              | A small pop-up that provides helpful hints or info.  |
| **Popover**              | A pop-up that displays content above a UI element.    |
| **OptionMenu**           | A menu for selecting options from a list.            |
| **ContentPresenter**     | A tool for presenting content in a flexible way.    |

### View
| Name                 | Description                                           |
|---------------------------|-------------------------------------------------------|
| **FormView**               | A flexible, keyboard-aware and scrollable container based on UIStackView. |
| **VStackView**             | A vertical stack view that arranges its children vertically. |
| **HStackView**             | A horizontal stack view that arranges its children horizontally. |
| **WrapperView**            | A container view used for wrapping other views with additional functionality. |
| **SegmentedPageView**      | A view that displays pages with segmented control navigation. |
| **NestedScrollingView**    | A scrollable view that supports nested scrollable components. |
| **ListController**         | A controller that manages a list of items for display in a list view. |
| **CarouselView**           | A view that displays items in a scrolling carousel format. |
| **TripleImageView**        | A view that displays three images in a single view. |
| **PlaybackProgressView**   | A view that shows the current playback progress of a media file. |
| **BadgeView**              | A view that displays a badge or notification indicator. |
| **LinkedLabel**            | A label that contains linked text that can trigger actions. |
| **InsetLabel**             | A label with padding (inset) around the text. |
| **TextView**               | A view for displaying and editing multi-line text. |
| **ActivityIndicatorView**  | A view that shows a loading spinner to indicate ongoing activity. |
| **SpacerView**             | A view used to create space between elements in layouts. |
| **SeparatorView**          | A view that provides a visual separator between UI elements. |
| **SketchView**             | A view that allows for drawing or sketching within it. |
| **BackgroundView**         | A view that provides a background layer for other views. |
| **TitleAndSubtitleView**   | A view displaying a title and subtitle for information display. |
| **SteppedProgress**        | A view showing progress through discrete steps or stages. |
| **FilterSortActionView**   | A view that allows users to filter and sort data or content. |
| **EmptyView**              | A view displayed when there is no content available to show. |
| **AvatarView**             | A view that displays a user avatar or profile image. |
| **MediaView**              | A view for displaying various types of media content (e.g., images, videos). |
| **MessageInputBar**        | A bar that provides an input area for typing messages. |
| **MessageActionView**      | A view for actions related to a message (e.g., reply, delete). |
| **PersonaView**            | A view displaying personal profile summary. |

## Note

This repository does not provide any installation methods like CocoaPods or Swift Package Manager. You are free to copy the codebase and make any custom modifications as per your requirements.

## License

XUI is licensed under the MIT License. See [LICENSE](LICENSE) for more information.

## Contact

- GitHub: [https://github.com/xueqooy/XUI](https://github.com/xueqooy/XUI)
- Email: xue_qooy@163.com
