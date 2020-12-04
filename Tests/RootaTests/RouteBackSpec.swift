//
//  RouteBackSpec.swift
//  RootaTests
//
//  Created by necocen on 2020/12/03.
//

import XCTest
import Nimble
import PromiseKit
import Quick
import Roota

class RouteBackSpec: QuickSpec {
    class ViewControllerA: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerA> {
            @Route(.push) var b1: ViewControllerB1.Routing
            @Route(.present) var b2: ViewControllerB2.Routing
            @Route(.push) var p: ViewControllerP.Routing

            override func screen() -> ViewControllerA {
                ViewControllerA()
            }
        }
    }

    class ViewControllerB1: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerB1> {
            @Route(.push) var c1: ViewControllerC1.Routing
            @Route(.push) var c2: ViewControllerC2.Routing

            override func screen() -> ViewControllerB1 {
                ViewControllerB1()
            }
        }
    }

    class ViewControllerB2: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerB2> {
            override func screen() -> ViewControllerB2 {
                ViewControllerB2()
            }
        }
    }

    class ViewControllerC1: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerC1> {
            override func screen() -> ViewControllerC1 {
                return ViewControllerC1()
            }
        }
    }

    class ViewControllerC2: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerC2> {
            override func screen() -> ViewControllerC2 {
                return ViewControllerC2()
            }
        }
    }

    class ViewControllerD: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerD> {
            @Route(.present) var modal: ViewControllerM.Routing
            override func screen() -> ViewControllerD {
                return ViewControllerD()
            }
        }
    }

    class ViewControllerM: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerM> {
            override func screen() -> ViewControllerM {
                ViewControllerM()
            }
        }
    }

    class ViewControllerP: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerP> {
            @Route(.present) var modal: ViewControllerM.Routing
            @Route(.push) var d: ViewControllerD.Routing
            @Route(.push) var p: ViewControllerP.Routing
            var param: Int = 0

            override func isEqual(to another: RoutingProtocol) -> Bool {
                guard let another = another as? Self else { return false }
                return param == another.param
            }

            override func screen() -> ViewControllerP {
                return ViewControllerP(param: param)
            }
        }

        let param: Int
        init(param: Int) {
            self.param = param
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }

    class NavigationControllerA: NavigationController, SequentialScreen {
        class Routing: ScreenRouting<NavigationControllerA> {
            @Route(.root) var a: ViewControllerA.Routing
            @Route(.present) var modal: ViewControllerM.Routing

            override func screen() -> NavigationControllerA {
                NavigationControllerA(rootViewController: a.instantiate())
            }
        }
    }

    override func spec() {
        describe("ViewController") {
            var vc: ViewControllerD!
            beforeEach {
                vc = ViewControllerD.asRootScreen()
                setupWindow(vc)
            }

            it("dismisses presented ViewController") {
                waitUntil(timeout: .seconds(10)) { done in
                    vc.route(to: \.modal).then { m -> Guarantee<ScreenProtocol> in
                        expect(vc.presentedViewController).to(beAnInstanceOf(ViewControllerM.self))
                        return m.routeBack()
                    }.done { _ in
                        expect(vc.presentedViewController).to(beNil())
                        done()
                    }
                }
            }

        }

        describe("UINavigationController") {
            var navCon: NavigationControllerA!
            beforeEach {
                navCon = NavigationControllerA.asRootScreen()
                setupWindow(navCon)
            }

            it("push/popを正しくハンドルすること") {
                waitUntil(timeout: .seconds(10)) { done in
                    navCon.route(to: \.a.b1).then { b1 -> Guarantee<ViewControllerC1> in
                        expect(navCon.viewControllers.count).to(equal(2))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        return b1.route(to: \.c1)
                    }.then { _ -> Guarantee<ViewControllerB1> in
                        expect(navCon.viewControllers.count).to(equal(3))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerC1.self))
                        return navCon.route(to: \.a.b1)
                    }.then { _ -> Guarantee<ViewControllerA> in
                        expect(navCon.viewControllers.count).to(equal(2))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        return navCon.route(to: \.a)
                    }.then { _ -> Guarantee<ViewControllerC1> in
                        expect(navCon.viewControllers.count).to(equal(1))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        return navCon.route(to: \.a.b1.c1)
                    }.then { _ -> Guarantee<ViewControllerC2> in
                        expect(navCon.viewControllers.count).to(equal(3))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerC1.self))
                        return navCon.route(to: \.a.b1.c2)
                    }.then { _ -> Guarantee<ViewControllerA> in
                        expect(navCon.viewControllers.count).to(equal(3))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerC2.self))
                        return navCon.route(to: \.a)
                    }.done { _ in
                        expect(navCon.viewControllers.count).to(equal(1))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        done()
                    }
                }
            }

            it("push/popとpresent/dismissを正しくハンドルすること") {
                waitUntil(timeout: .seconds(10)) { done in
                    navCon.route(to: \.a.b1).then { b1 -> Guarantee<ViewControllerC1> in
                        expect(navCon.viewControllers.count).to(equal(2))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        return b1.route(to: \.c1)
                    }.then { c1 -> Guarantee<ViewControllerB2> in
                        expect(navCon.viewControllers.count).to(equal(3))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerC1.self))
                        return c1.route(from: NavigationControllerA.self, to: \.a.b2)
                    }.then { b2 -> Guarantee<ViewControllerC1> in
                        expect(navCon.viewControllers.count).to(equal(1))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.presentedViewController).to(beAnInstanceOf(ViewControllerB2.self))
                        return b2.route(from: NavigationControllerA.self, to: \.a.b1.c1)
                    }.then { c1 -> Guarantee<ViewControllerA> in
                        expect(navCon.viewControllers.count).to(equal(3))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerC1.self))
                        return c1.route(from: NavigationControllerA.self, to: \.a)
                    }.done { _ in
                        expect(navCon.viewControllers.count).to(equal(1))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        done()
                    }
                }
            }

            it("直接モーダルをpresentできること") {
                waitUntil(timeout: .seconds(10)) { done in
                    navCon.route(to: \.a.b1).then { _ -> Guarantee<ViewControllerM> in
                        expect(navCon.viewControllers.count).to(equal(2))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        return navCon.route(to: \.modal)
                    }.then { _ -> Guarantee<ViewControllerC1> in
                        expect(navCon.presentedViewController).to(beAnInstanceOf(ViewControllerM.self))
                        return navCon.route(to: \.a.b1.c1)
                    }.done { _ in
                        expect(navCon.viewControllers.count).to(equal(3))
                        expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                        expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerB1.self))
                        expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerC1.self))
                        done()
                    }
                }
            }

            context("ViewControllerにパラメータがあるとき") {
                it("パラメータが同じ場合は同じ画面と判定すること") {
                    waitUntil(timeout: .seconds(10)) { done in
                        navCon.route(to: \.a.p, with: \.param, 1).then { _ -> Guarantee<ViewControllerM> in
                            expect(navCon.viewControllers.count).to(equal(2))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(1))
                            return navCon.route(to: navCon.descendant(\.a.p).with(\.param, is: 1).modal)
                        }.then { _ -> Guarantee<ViewControllerM> in
                            expect(navCon.viewControllers.count).to(equal(2))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(1))
                            expect(navCon.presentedViewController).to(beAnInstanceOf(ViewControllerM.self))
                            return navCon.route(to: navCon.descendant(\.a.p).with(\.param, is: 2).modal)
                        }.then { _ -> Guarantee<ViewControllerP> in
                            expect(navCon.viewControllers.count).to(equal(2))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(2))
                            expect(navCon.presentedViewController).to(beAnInstanceOf(ViewControllerM.self))
                            return navCon.route(to: \.a.p, with: \.param, 3)
                        }.then { _ -> Guarantee<ViewControllerD> in
                            expect(navCon.viewControllers.count).to(equal(2))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(3))
                            return navCon.route(to: navCon.descendant(\.a.p).with(\.param, is: 4).d)
                        }.then { _ -> Guarantee<ViewControllerD> in
                            expect(navCon.viewControllers.count).to(equal(3))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerD.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(4))
                            return navCon.route(to: navCon.descendant(\.a.p).with(\.param, is: 5).d)
                        }.done { _ in
                            expect(navCon.viewControllers.count).to(equal(3))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerD.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(5))
                            done()
                        }
                    }
                }

                it("別パラメータの同一ViewControllerに遷移できること") {
                    waitUntil(timeout: .seconds(10)) { done in
                        navCon.route(to: \.a.p, with: \.param, 1).then { _ -> Guarantee<ViewControllerP> in
                            expect(navCon.viewControllers.count).to(equal(2))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(1))
                            return navCon.route(to: navCon.descendant(\.a.p).with(\.param, is: 1).p.with(\.param, is: 2))
                        }.then { _ -> Guarantee<ViewControllerP> in
                            expect(navCon.viewControllers.count).to(equal(3))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerP.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(1))
                            expect((navCon.viewControllers[2] as! ViewControllerP).param).to(equal(2))
                            return navCon.route(to: navCon.descendant(\.a.p).with(\.param, is: 3).p.with(\.param, is: 2))
                        }.done { _ in
                            expect(navCon.viewControllers.count).to(equal(3))
                            expect(navCon.viewControllers[0]).to(beAnInstanceOf(ViewControllerA.self))
                            expect(navCon.viewControllers[1]).to(beAnInstanceOf(ViewControllerP.self))
                            expect(navCon.viewControllers[2]).to(beAnInstanceOf(ViewControllerP.self))
                            expect((navCon.viewControllers[1] as! ViewControllerP).param).to(equal(3))
                            expect((navCon.viewControllers[2] as! ViewControllerP).param).to(equal(2))
                            done()
                        }
                    }
                }
            }
        }
    }
}
