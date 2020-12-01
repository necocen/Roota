//
//  NavigationControllerScreen.swift
//  
//
//  Created by necocen on 2020/12/02.
//

import UIKit
import PromiseKit
import Roota

public class NavigationControllerScreen<Root: Screen & UIViewController>: UINavigationController, SequentialScreen where Root.Routing: ScreenRouting<Root> {
    public class Routing: ScreenRouting<NavigationControllerScreen> {
        @Route(.root) var root: Root.Routing

        public override func screen() -> NavigationControllerScreen<Root> {
            return NavigationControllerScreen(rootViewController: root.instantiate())
        }
    }
}

