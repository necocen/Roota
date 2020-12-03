# Roota

A simple routing library for Swift.

## Usage
Classes which conformed to `Screen` protocol can use `route(to:)` method to show other `Screen`s.

```swift
import UIKit
import Roota
import RootaUI // Required to give default implementations to UIViewController.

class RootViewController: UIViewController, Screen {
    class Routing: ScreenRouting<RootViewController> {
        // Defining available routes:
        @Route(.present) var modal: ModalViewController.Routing
        @Route(.present) var another: AnotherViewController.Routing
        // Defining how to instantiate:
        override func screen() -> RootViewController {
            return RootViewController()
        }
    }
}

class ModalViewController: UIViewController, Screen {
    class Routing: ScreenRouting<ModalViewController> {
        @Route(.present) var grandchild: GrandchildViewController.Routing

        override func screen() -> ModalViewController {
            return ModalViewController()
        }
    }
}

// ...

let rootViewController = RootViewController.asRootScreen()
rootViewController.route(to: \.modal) // Presents ModalViewControler as modal.
```

Moving to grandchild `Screen` is easy.

```swift
// Presents ModalViewController, and then presents GrandchildViewController.
rootViewController.route(to: \.modal.grandchild)
```

`route(to:)` returns PromiseKit's `Guarantee<Screen>` so that can be chained.

```swift
// This line is equivalent to above example; presents ModalViewController and GrandchildViewController.
rootViewController.route(to: \.modal).then { modal in modal.route(to: \.grandchild) }

// You may need to specify return type explicitly (when your chaining function is not one-liner.)
rootViewController.route(to: \.modal).then { modal -> Guarantee<GrandchildViewController> in
    print(modal)
    return modal.route(to: \.grandchild)
}
```
