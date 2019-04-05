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
            VMTestCase(input: "1 + 2", expected: 2) // FIXME
        ]

        runVMTests(tests)
    }

    private func runVMTests(_ tests: [VMTestCase]) {
        for t in tests {
            let program = parse(input: t.input)!
            var comp = Compiler()
            XCTAssertTrue(comp.compile(node: program), "Compiler error")

            let vm = MonkeyVM(bytecode: comp.bytecode())
            try? vm.run()

            let stackElem = vm.stackTop()
            XCTAssertNotNil(stackElem)
            testExpectedObject(t.expected, stackElem!)
        }
    }

    private func testExpectedObject(_ expected: Any, _ actual: MonkeyObject) {
        switch expected {
        case is Int:
            XCTAssertIntegerObject(Int64(expected as! Int), actual)

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

}
