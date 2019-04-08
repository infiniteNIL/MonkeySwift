//
//  SymbolTableTests.swift
//  MonkeyLibTests
//
//  Created by Rod Schmidt on 4/8/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import XCTest
@testable import MonkeyLib

class SymbolTableTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testDefine() {
        let expected: [String: Symbol] = [
            "a": Symbol(name: "a", scope: .global, index: 0),
            "b": Symbol(name: "b", scope: .global, index: 1),
        ]

        let global = SymbolTable()

        let a = global.define(name: "a")
        XCTAssertEqual(a, expected["a"])

        let b = global.define(name: "b")
        XCTAssertEqual(b, expected["b"])
    }

    func testResolve() {
        let global = SymbolTable()
        global.define(name: "a")
        global.define(name: "b")

        let expected = [
            "a": Symbol(name: "a", scope: .global, index: 0),
            "b": Symbol(name: "b", scope: .global, index: 1),
        ]

        for sym in expected.values {
            let result = global.resolve(name: sym.name)
            XCTAssertNotNil(result, "name \(sym.name) is not resolvable")
            XCTAssertEqual(sym, result)
        }
    }

}
