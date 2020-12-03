//
//  ViewControllerB.swift
//  Demo
//
//  Created by necocen on 2020/12/03.
//

import UIKit
import Roota

class ViewControllerB: UIViewController, Screen {
    class Routing: ScreenRouting<ViewControllerB> {
        override func screen() -> ViewControllerB {
            return UIStoryboard(name: "Storyboard", bundle: nil).instantiateViewController(identifier: "ViewControllerB")
        }
    }
}
