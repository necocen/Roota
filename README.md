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
rootViewController.route(to: \.modal.grandchild)
```

`route(to:)` returns PromiseKit's `Guarantee<Void>` so that can be chained.

```swift
// Presents AnotherViewController, after presenting and dismissing ModalViewController.
rootViewController.route(to: \.modal).then { _ in rootViewController.route(to: \.another) }
```
