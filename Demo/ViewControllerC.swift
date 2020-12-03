//
//  ViewControllerC.swift
//  Demo
//
//  Created by necocen on 2020/12/03.
//

import UIKit
import Roota

class ViewControllerC: UIViewController, Screen {
    class Routing: ScreenRouting<ViewControllerC> {
        override func screen() -> ViewControllerC {
            return UIStoryboard(name: "Storyboard", bundle: nil).instantiateViewController(identifier: "ViewControllerC")
        }
    }
}
