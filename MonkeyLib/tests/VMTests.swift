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
            VMTestCase(input: "!(if (false) { 5; })", expected: true),
        ]

        runVMTests(tests)
    }

    func testConditionals() {
        let tests = [
            VMTestCase(input: "if (true) { 10 }", expected: 10),
            VMTestCase(input: "if (true) { 10 } else { 20 }", expected: 10),
            VMTestCase(input: "if (false) { 10 } else { 20 }", expected: 20),
            VMTestCase(input: "if (1) { 10 }", expected: 10),
            VMTestCase(input: "if (1 < 2) { 10 }", expected: 10),
            VMTestCase(input: "if (1 < 2) { 10 } else { 20 }", expected: 10),
            VMTestCase(input: "if (1 > 2) { 10 } else { 20 }", expected: 20),
            VMTestCase(input: "if (1 > 2) { 10 }", expected: Null),
            VMTestCase(input: "if (false) { 10 }", expected: Null),
            VMTestCase(input: "if ((if (false) { 10 })) { 10 } else { 20 }", expected: 20),
        ]

        runVMTests(tests)
    }

    func testGlobalLetStatements() {
        let tests = [
            VMTestCase(input: "let one = 1; one", expected: 1),
            VMTestCase(input: "let one = 1; let two = 2; one + two", expected: 3),
            VMTestCase(input: "let one = 1; let two = one + one; one + two", expected: 3),
        ]

        runVMTests(tests)
    }

    func testStringExpressions() {
        let tests = [
            VMTestCase(input: "\"monkey\"", expected: "monkey"),
            VMTestCase(input: "\"mon\" + \"key\"", expected: "monkey"),
            VMTestCase(input: "\"mon\" + \"key\" + \"banana\"", expected: "monkeybanana"),
        ]

        runVMTests(tests)
    }

    func testArrayLiterals() {
        let tests = [
            VMTestCase(input: "[]", expected: []),
            VMTestCase(input: "[1, 2, 3]", expected: [1, 2, 3]),
            VMTestCase(input: "[1 + 2, 3 * 4, 5 + 6]", expected: [3, 12, 11]),
        ]

        runVMTests(tests)
    }

    func testHashLiterals() {
        let tests = [
            VMTestCase(input: "{}", expected: [:]),
            VMTestCase(input: "{1: 2, 2: 3}", expected: [1: 2, 2: 3]),
            VMTestCase(input: "{1 + 1: 2 * 2, 3 + 3: 4 * 4}", expected: [2: 4, 6: 16]),
        ]

        runVMTests(tests)
    }

    func testIndexExpressions() {
        let tests = [
            VMTestCase(input: "[1, 2, 3][1]", expected: 2),
            VMTestCase(input: "[1, 2, 3][0 + 2]", expected: 3),
            VMTestCase(input: "[[1, 1, 1]][0][0]", expected: 1),
            VMTestCase(input: "[][0]", expected: Null),
            VMTestCase(input: "[1, 2, 3][99]", expected: Null),
            VMTestCase(input: "[1][-1]", expected: Null),
            VMTestCase(input: "{1: 1, 2: 2}[1]", expected: 1),
            VMTestCase(input: "{1: 1, 2: 2}[2]", expected: 2),
            VMTestCase(input: "{1: 1}[0]", expected: Null),
            VMTestCase(input: "{}[0]", expected: Null),
        ]

        runVMTests(tests)
    }

    func testCallingFunctionsWithoutArguments() {
        let tests = [
            VMTestCase(input: "let fivePlusTen = fn() { 5 + 10; }; fivePlusTen();",
                       expected: 15),
            VMTestCase(input: "let one = fn() { 1; }; let two = fn() { 2; }; one() + two()",
                       expected: 3),
            VMTestCase(input: "let a = fn() { 1 }; let b = fn() { a() + 1 }; let c = fn() { b() + 1 }; c();",
                       expected: 3),
        ]

        runVMTests(tests)
    }

    func testCallingFunctionsWithReturnStatement() {
        let tests = [
            VMTestCase(input: """
                        let earlyExit = fn() { return 99; 100; };
                        earlyExit();
                       """,
                       expected: 99),
            VMTestCase(input: """
                        let earlyExit = fn() { return 99; return 100; };
                        earlyExit();
                       """,
                       expected: 99),
        ]

        runVMTests(tests)
    }

    func testFunctionsWithoutReturnValue() {
        let tests = [
            VMTestCase(input: """
                        let noReturn = fn() { };
                        noReturn();
                       """,
                       expected: Null),
            VMTestCase(input: """
                        let noReturn = fn() { };
                        let noReturnTwo = fn() { noReturn(); };
                        noReturn();
                        noReturnTwo();
                       """,
                       expected: Null),
        ]

        runVMTests(tests)
    }

    func testFirstClassFunctions() {
        let tests = [
            VMTestCase(input: """
                        let returnsOne = fn() { 1; };
                        let returnsOneReturner = fn() { returnsOne; };
                        returnsOneReturner()();
                       """,
                       expected: 1),
            VMTestCase(input: """
                        let returnsOneReturner = fn() {
                          let returnsOne = fn() { 1; };
                          returnsOne;
                        };
                        returnsOneReturner()();
                       """,
                       expected: 1),
        ]

        runVMTests(tests)
    }

    func testCallingFunctionsWithBindings() {
        let tests = [
            VMTestCase(input: """
                        let one = fn() { let one = 1; one };
                        one();
                       """,
                       expected: 1),
            VMTestCase(input: """
                        let oneAndTwo = fn() { let one = 1; let two = 2; one + two; };
                        oneAndTwo();
                       """,
                       expected: 3),
            VMTestCase(input: """
                        let oneAndTwo = fn() { let one = 1; let two = 2; one + two; };
                        let threeAndFour = fn() { let three = 3; let four = 4; three + four; };
                        oneAndTwo() + threeAndFour();
                       """,
                       expected: 10),
            VMTestCase(input: """
                        let firstFoobar = fn() { let foobar = 50; foobar; };
                        let secondFoobar = fn() { let foobar = 100; foobar; };
                        firstFoobar() + secondFoobar();
                       """,
                       expected: 150),
            VMTestCase(input: """
                        let globalSeed = 50;
                        let minusOne = fn() {
                          let num = 1;
                          globalSeed - num;
                        }
                        let minusTwo = fn() {
                          let num = 2;
                          globalSeed - num;
                        }
                        minusOne() + minusTwo();
                       """,
                       expected: 97),
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

        case is MonkeyNull:
            XCTAssert(actual is MonkeyNull)

        case is String:
            XCTAssertStringObject(expected as! String, actual)

        case is Array<Int>:
            let expectedArray = expected as! Array<Int>
            let array = actual as? MonkeyArray
            XCTAssertNotNil(array)
            XCTAssertEqual(array?.elements.count, expectedArray.count)
            for (i, expectedElem) in expectedArray.enumerated() {
                XCTAssertIntegerObject(Int64(expectedElem), array!.elements[i])
            }

        case is Dictionary<Int, Int>:
            let expectedDict = expected as! Dictionary<Int, Int>
            let hash = actual as? MonkeyHash
            XCTAssertNotNil(hash, "object is not a hash. got=\(actual)")
            XCTAssertEqual(hash?.pairs.count, expectedDict.keys.count)
            for (expectedKey, expectedValue) in expectedDict {
                let hashKey = HashKey(type: .integerObj, value: expectedKey)
                let pair = hash?.pairs[hashKey]
                XCTAssertNotNil(pair, "no pair given key in Pairs")
                XCTAssertIntegerObject(Int64(expectedValue), pair!.value)
            }

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

    func XCTAssertStringObject(_ expected: String, _ actual: MonkeyObject, file: StaticString = #file, line: UInt = #line) {
        let result = actual as? MonkeyString
        XCTAssertNotNil(result, "object is not a String. got \(actual)", file: file, line: line)
        guard result != nil else { return }
        XCTAssertEqual(result!.value, expected, "object has wrong value. got \(result!.value), want \(expected)", file: file, line: line)
    }
}
