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

    func testDefineResolveBuiltins() {
        let global = SymbolTable()
        let firstLocal = SymbolTable(global)
        let secondLocal = SymbolTable(firstLocal)

        let expected = [
            Symbol(name: "a", scope: .builtin, index: 0),
            Symbol(name: "c", scope: .builtin, index: 1),
            Symbol(name: "e", scope: .builtin, index: 2),
            Symbol(name: "f", scope: .builtin, index: 3),
        ]

        for (i, symbol) in expected.enumerated() {
            global.defineBuiltin(i, symbol.name)
        }

        for table in [global, firstLocal, secondLocal] {
            for sym in expected {
                let result = table.resolve(name: sym.name)
                XCTAssertNotNil(result, "name \(sym.name) is not resolvable")
                XCTAssertEqual(result, sym, "expected \(sym.name) to resolve to \(sym), got=\(String(describing: result))")
            }
        }
    }

    func testResolveFree() {
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
            let expectedFreeSymbols: [Symbol]
        }

        let tests = [
            Test(table: firstLocal,
                 expectedSymbols: [
                    Symbol(name: "a", scope: .global, index: 0),
                    Symbol(name: "b", scope: .global, index: 1),
                    Symbol(name: "c", scope: .local, index: 0),
                    Symbol(name: "d", scope: .local, index: 1),
                 ],
                 expectedFreeSymbols: [] as [Symbol]),
            Test(table: secondLocal,
                 expectedSymbols: [
                    Symbol(name: "a", scope: .global, index: 0),
                    Symbol(name: "b", scope: .global, index: 1),
                    Symbol(name: "c", scope: .free, index: 0),
                    Symbol(name: "d", scope: .free, index: 1),
                    Symbol(name: "e", scope: .local, index: 0),
                    Symbol(name: "f", scope: .local, index: 1),
                 ],
                 expectedFreeSymbols: [
                    Symbol(name: "c", scope: .local, index: 0),
                    Symbol(name: "d", scope: .local, index: 1),
                 ]),
        ]

        for t in tests {
            for sym in t.expectedSymbols {
                let result = t.table.resolve(name: sym.name)
                XCTAssertNotNil(result, "name \(sym.name) is not resolvable")
                XCTAssertEqual(result, sym, "expected \(sym.name) to resolve to \(sym), got=\(String(describing: result))")
            }

            XCTAssertEqual(t.table.freeSymbols.count, t.expectedFreeSymbols.count)

            for (i, sym) in t.expectedFreeSymbols.enumerated() {
                let result = t.table.freeSymbols[i]
                XCTAssertEqual(result, sym, "wrong free symbol. got=\(result), want=\(sym)")
            }
        }
    }

    func testResolveUnresolvableFree() {
        let global = SymbolTable()
        global.define(name: "a")

        let firstLocal = SymbolTable(global)
        firstLocal.define(name: "c")

        let secondLocal = SymbolTable(firstLocal)
        secondLocal.define(name: "e")
        secondLocal.define(name: "f")

        let expected = [
            Symbol(name: "a", scope: .global, index: 0),
            Symbol(name: "c", scope: .free, index: 0),
            Symbol(name: "e", scope: .local, index: 0),
            Symbol(name: "f", scope: .local, index: 1),
        ]

        for sym in expected {
            let result = secondLocal.resolve(name: sym.name)
            XCTAssertNotNil(result, "name \(sym.name) is not resolvable")
            XCTAssertEqual(result, sym, "expected \(sym.name) to resolve to \(sym), got=\(String(describing: result))")
        }

        let expectedUnresolvable = [
            "b",
            "d",
        ]

        for name in expectedUnresolvable {
            let result = secondLocal.resolve(name: name)
            XCTAssertNil(result, "name \(name) is resolvable, but was not expected to")
        }
    }

    func testDefineAndResolveFunctionName() {
        let global = SymbolTable()
        global.defineFunctionName("a")

        let expected = Symbol(name: "a", scope: .function, index: 0)

        let result = global.resolve(name: expected.name)
        XCTAssertNotNil(result, "function name \(expected.name) is not resolvable")
        XCTAssertEqual(result, expected, "expected \(expected.name) to resolve to \(expected), got=\(String(describing: result))")
    }

    func testShadowingFunctionName() {
        let global = SymbolTable()
        global.defineFunctionName("a")
        global.define(name: "a")

        let expected = Symbol(name: "a", scope: .global, index: 0)

        let result = global.resolve(name: expected.name)
        XCTAssertNotNil(result, "function name \(expected.name) is not resolvable")
        XCTAssertEqual(result, expected, "expected \(expected.name) to resolve to \(expected), got=\(String(describing: result))")
    }

}
