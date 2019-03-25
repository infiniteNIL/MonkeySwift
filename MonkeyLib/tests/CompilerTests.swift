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
                    make(op: .opConstant, operands: [UInt16(0)]),
                    make(op: .opConstant, operands: [UInt16(1)])
                ]
            )
        ]

        runCompilerTests(tests)
    }

    func runCompilerTests(_ tests: [Test]) {
        for t in tests {
            let program = parse(input: t.input)
            let compiler = Compiler()
            let ok = compiler.compile(node: program)
            guard ok else {
                fatalError("compiler error: \(ok)")
            }

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
                break
            }
        }

        XCTFail()
    }

    func XCTAssertIntegerObject(_ expected: Int64, _ actual: MonkeyObject, file: StaticString = #file, line: UInt = #line) {
        let result = actual as? MonkeyInteger
        XCTAssertNotNil(result, file: file, line: line)
        XCTAssertEqual(result?.value, Int(expected), file: file, line: line)
    }

}
