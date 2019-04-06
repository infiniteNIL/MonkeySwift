//
//  CompilerTests.swift
//  MonkeyLibTests
//
//  Created by Rod Schmidt on 3/24/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import XCTest
@testable import MonkeyLib

class CompilerTests: XCTestCase {

    struct Test {
        let input: String
        let expectedConstants: [Any]
        let expectedInstructions: [Instructions]
    }

    override func setUp() {
    }

    override func tearDown() {
    }

    func testIntegerArithmetic() {
        let tests = [
            Test(input: "1 + 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .add, operands: []),
                    make(op: .pop, operands: [])
                ]
            ),
            Test(input: "1; 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .pop, operands: []),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 - 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .sub, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 * 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .mul, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "2 / 1",
                 expectedConstants: [2, 1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .div, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "true",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "false",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushFalse, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 > 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .greaterThan, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 < 2",
                 expectedConstants: [2, 1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .greaterThan, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 == 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .equal, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 != 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .constant, operands: [UInt16(1)]),
                    make(op: .notEqual, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "true == false",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .pushFalse, operands: []),
                    make(op: .equal, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "true != false",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .pushFalse, operands: []),
                    make(op: .notEqual, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "-1",
                 expectedConstants: [1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .minus, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "!true",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .bang, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func runCompilerTests(_ tests: [Test]) {
        for t in tests {
            let program = parse(input: t.input)
            let compiler = Compiler()
            try? compiler.compile(node: program)

            let bytecode = compiler.bytecode()
            XCTAssertInstructions(t.expectedInstructions, bytecode.instructions)
            XCTAssertConstants(t.expectedConstants, bytecode.constants)
        }
    }

    private func parse(input: String) -> Program {
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        return p.parseProgram()!
    }

    func XCTAssertInstructions(_ expected: [Instructions], _ actual: Instructions, file: StaticString = #file, line: UInt = #line) {
        let concatted = concatInstructions(expected)
        XCTAssertEqual(actual.count, concatted.count, file: file, line: line)

        for (i, ins) in concatted.enumerated() {
            XCTAssertEqual(actual[i], ins, file: file, line: line)
        }
    }

    private func concatInstructions(_ s: [Instructions]) -> Instructions {
        return s.reduce([], +)
    }

    func XCTAssertConstants(_ expected: [Any], _ actual: [MonkeyObject], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(expected.count, actual.count, file: file, line: line)

        for (i, constant) in expected.enumerated() {
            switch constant {
            case is Int:
                XCTAssertIntegerObject(Int64(constant as! Int), actual[i])

            default:
                XCTFail()
            }
        }
    }

    func XCTAssertIntegerObject(_ expected: Int64, _ actual: MonkeyObject, file: StaticString = #file, line: UInt = #line) {
        let result = actual as? MonkeyInteger
        XCTAssertNotNil(result, file: file, line: line)
        XCTAssertEqual(result?.value, Int(expected), file: file, line: line)
    }

}
