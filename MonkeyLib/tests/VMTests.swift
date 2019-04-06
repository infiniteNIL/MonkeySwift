//
//  VMTests.swift
//  MonkeyLibTests
//
//  Created by Rod Schmidt on 4/5/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import XCTest
@testable import MonkeyLib

class VMTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    struct VMTestCase {
        let input: String
        let expected: Any
    }

    func testIntegerArithmetic() {
        let tests = [
            VMTestCase(input: "1", expected: 1),
            VMTestCase(input: "2", expected: 2),
            VMTestCase(input: "1 - 2", expected: -1),
            VMTestCase(input: "1 * 2", expected: 2),
            VMTestCase(input: "4 / 2", expected: 2),
            VMTestCase(input: "50 / 2 * 2 + 10 - 5", expected: 55),
            VMTestCase(input: "5 + 5 + 5 + 5 - 10", expected: 10),
            VMTestCase(input: "2 * 2 * 2 * 2 * 2", expected: 32),
            VMTestCase(input: "5 * 2 + 10", expected: 20),
            VMTestCase(input: "5 + 2 * 10", expected: 25),
            VMTestCase(input: "5 * (2 + 10)", expected: 60),
            VMTestCase(input: "1 < 2", expected: true),
            VMTestCase(input: "1 > 2", expected: false),
            VMTestCase(input: "1 < 1", expected: false),
            VMTestCase(input: "1 > 1", expected: false),
            VMTestCase(input: "1 == 1", expected: true),
            VMTestCase(input: "1 != 1", expected: false),
            VMTestCase(input: "1 == 2", expected: false),
            VMTestCase(input: "1 != 2", expected: true),
            VMTestCase(input: "true == true", expected: true),
            VMTestCase(input: "false == false", expected: true),
            VMTestCase(input: "true == false", expected: false),
            VMTestCase(input: "true != false", expected: true),
            VMTestCase(input: "false != true", expected: true),
            VMTestCase(input: "(1 < 2) == true", expected: true),
            VMTestCase(input: "(1 < 2) == false", expected: false),
            VMTestCase(input: "(1 > 2) == true", expected: false),
            VMTestCase(input: "(1 > 2) == false", expected: true),
            VMTestCase(input: "-5", expected: -5),
            VMTestCase(input: "-10", expected: -10),
            VMTestCase(input: "-50 + 100 + -50", expected: 0),
            VMTestCase(input: "(5 + 10 * 2 + 15 / 3) * 2 + -10", expected: 50),
            VMTestCase(input: "!true", expected: false),
            VMTestCase(input: "!false", expected: true),
            VMTestCase(input: "!5", expected: false),
            VMTestCase(input: "!!true", expected: true),
            VMTestCase(input: "!!false", expected: false),
            VMTestCase(input: "!!5", expected: true),
        ]

        runVMTests(tests)
    }

    func testBooleanExpressions() {
        let tests = [
            VMTestCase(input: "true", expected: true),
            VMTestCase(input: "false", expected: false),
        ]

        runVMTests(tests)
    }

    private func runVMTests(_ tests: [VMTestCase]) {
        for t in tests {
            let program = parse(input: t.input)!
            let comp = Compiler()
            try? comp.compile(node: program)

            let vm = MonkeyVM(bytecode: comp.bytecode())
            try? vm.run()

            let stackElem = vm.lastPopppedStackElem()
            testExpectedObject(t.expected, stackElem)
        }
    }

    private func testExpectedObject(_ expected: Any, _ actual: MonkeyObject) {
        switch expected {
        case is Int:
            XCTAssertIntegerObject(Int64(expected as! Int), actual)

        case is Bool:
            XCTAssertBooleanObject(expected as! Bool, actual)

        default:
            XCTFail()
        }
    }

    private func parse(input: String) -> Program? {
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        return p.parseProgram()
    }

    private func XCTAssertIntegerObject(_ expected: Int64, _ actual: MonkeyObject, file: StaticString = #file, line: UInt = #line) {
        let result = actual as? MonkeyInteger
        XCTAssertNotNil(result, file: file, line: line)
        XCTAssertEqual(result?.value, Int(expected), file: file, line: line)
    }

    func XCTAssertBooleanObject(_ expected: Bool, _ actual: MonkeyObject, file: StaticString = #file, line: UInt = #line) {
        let result = actual as? MonkeyBoolean
        XCTAssertNotNil(result, "object is not an Boolean. got \(actual)", file: file, line: line)
        guard result != nil else { return }
        XCTAssertEqual(result!.value, expected, "object has wrong value. got \(result!.value), want \(expected)", file: file, line: line)
    }

}
