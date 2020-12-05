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

            override func screen() -> ViewControllerA {
                ViewControllerA()
            }
        }
    }

    class ViewControllerB1: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerB1> {
            @Route(.push) var c1: ViewControllerC1.Routing

            override func screen() -> ViewControllerB1 {
                ViewControllerB1()
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
            @Route(.present) var modal: ViewControllerN.Routing
            override func screen() -> ViewControllerM {
                ViewControllerM()
            }
        }
    }

    class ViewControllerN: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerN> {
            override func screen() -> ViewControllerN {
                ViewControllerN()
            }
        }
    }

    class ViewControllerE: ViewController, Screen {
        class Routing: ScreenRouting<ViewControllerE> {
            @Route(.present) var nav: NavigationControllerA.Routing
            override func screen() -> RouteBackSpec.ViewControllerE {
                return ViewControllerE()
            }
        }
    }

    class NavigationControllerA: NavigationController, SequentialScreen {
        typealias RootScreen = ViewControllerA
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

            it("dismisses nested ViewController presentation") {
                waitUntil(timeout: .seconds(10)) { done in
                    vc.route(to: \.modal.modal).then { n -> Guarantee<ScreenProtocol> in
                        expect(n.presentingViewController).to(beAnInstanceOf(ViewControllerM.self))
                        return n.routeBack()
                    }.then { s -> Guarantee<ScreenProtocol> in
                        expect(s).to(beAnInstanceOf(ViewControllerM.self))
                        return s.routeBack()
                    }.done { _ in
                        expect(vc.presentedViewController).to(beNil())
                        done()
                    }
                }
            }
        }

        describe("NavigationController") {

            context("presented as root") {
                var navCon: NavigationControllerA!
                beforeEach {
                    navCon = NavigationControllerA.asRootScreen()
                    setupWindow(navCon)
                }

                it("pop to previous screen") {
                    waitUntil(timeout: .seconds(10)) { done in
                        navCon.route(to: \.a.b1.c1).then { c1 -> Guarantee<ScreenProtocol> in
                            c1.routeBack()
                        }.then { s -> Guarantee<ScreenProtocol> in
                            expect(navCon.screens.last).to(beAnInstanceOf(ViewControllerB1.self))
                            expect(s).to(beAnInstanceOf(ViewControllerB1.self))
                            return s.routeBack()
                        }.done { s in
                            expect(navCon.screens.last).to(beAnInstanceOf(ViewControllerA.self))
                            expect(s).to(beAnInstanceOf(ViewControllerA.self))
                            done()
                        }
                    }
                }
            }

            context("presented as modal") {
                var vc: ViewControllerE!
                beforeEach {
                    vc = ViewControllerE.asRootScreen()
                    setupWindow(vc)
                }

                it("dismisses when on root page") {
                    waitUntil(timeout: .seconds(10)) { done in
                        vc.route(to: \.nav.a.b1).then { b1 in b1.routeBack() }.then { a in a.routeBack() }.done { vc in
                            expect(vc).to(beAnInstanceOf(ViewControllerE.self))
                            expect(vc.presentedScreen).to(beNil())
                            done()
                        }
                    }
                }
            }
        }
    }
}
