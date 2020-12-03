//
//  ViewControllerA.swift
//  Demo
//
//  Created by necocen on 2020/12/03.
//

import UIKit
import Roota
import RootaUI

class ViewControllerA: UIViewController, Screen {
    class Routing: ScreenRouting<ViewControllerA> {
        override func screen() -> ViewControllerA {
            return UIStoryboard(name: "Storyboard", bundle: nil).instantiateViewController(identifier: "ViewControllerA")
        }
    }
}
