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
            "c": Symbol(name: "c", scope: .local, index: 0),
            "d": Symbol(name: "d", scope: .local, index: 1),
            "e": Symbol(name: "e", scope: .local, index: 0),
            "f": Symbol(name: "f", scope: .local, index: 1),
        ]

        let global = SymbolTable()

        let a = global.define(name: "a")
        XCTAssertEqual(a, expected["a"])

        let b = global.define(name: "b")
        XCTAssertEqual(b, expected["b"])

        let firstLocal = SymbolTable(global)

        let c = firstLocal.define(name: "c")
        XCTAssertEqual(c, expected["c"])

        let d = firstLocal.define(name: "d")
        XCTAssertEqual(d, expected["d"])

        let secondLocal = SymbolTable(firstLocal)

        let e = secondLocal.define(name: "e")
        XCTAssertEqual(e, expected["e"])

        let f = secondLocal.define(name: "f")
        XCTAssertEqual(f, expected["f"])
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

    func testResolveLocal() {
        let global = SymbolTable()
        global.define(name: "a")
        global.define(name: "b")

        let local = SymbolTable(global)
        local.define(name: "c")
        local.define(name: "d")

        let expected = [
            Symbol(name: "a", scope: .global, index: 0),
            Symbol(name: "b", scope: .global, index: 1),
            Symbol(name: "c", scope: .local, index: 0),
            Symbol(name: "d", scope: .local, index: 1),
        ]

        for sym in expected {
            let result = local.resolve(name: sym.name)
            XCTAssertNotNil(result, "name \(sym.name) is not resolvable")
            XCTAssertEqual(sym, result)
        }
    }

    func testResolveNestedLocal() {
        let global = SymbolTable()
        global.define(name: "a")
        global.define(name: "b")

        let firstLocal = SymbolTable(global)
        firstLocal.define(name: "c")
        firstLocal.define(name: "d")

        let secondLocal = SymbolTable(firstLocal)
        secondLocal.define(name: "e")
        secondLocal.define(name: "f")

        struct Test {
            let table: SymbolTable
            let expectedSymbols: [Symbol]
        }

        let tests = [
            Test(table: firstLocal, expectedSymbols: [
                    Symbol(name: "a", scope: .global, index: 0),
                    Symbol(name: "b", scope: .global, index: 1),
                    Symbol(name: "c", scope: .local, index: 0),
                    Symbol(name: "d", scope: .local, index: 1),
                ]),
            Test(table: secondLocal, expectedSymbols: [
                Symbol(name: "a", scope: .global, index: 0),
                Symbol(name: "b", scope: .global, index: 1),
                Symbol(name: "e", scope: .local, index: 0),
                Symbol(name: "f", scope: .local, index: 1),
                ]),
        ]

        for t in tests {
            for sym in t.expectedSymbols {
                let result = t.table.resolve(name: sym.name)
                XCTAssertNotNil(result, "name \(sym.name) is not resolvable")
                XCTAssertEqual(sym, result)
            }
        }
    }

}
