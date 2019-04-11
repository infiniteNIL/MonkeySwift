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

    func testCallingFunctionsWithArgumentsAndBindings() {
        let tests = [
            VMTestCase(input: """
                        let identity = fn(a) { a; };
                        identity(4);
                       """,
                       expected: 4),
            VMTestCase(input: """
                        let sum = fn(a, b) { a + b; };
                        sum(1, 2);
                       """,
                       expected: 3),
            VMTestCase(input: """
                        let sum = fn(a, b) { let c = a + b; c; };
                        sum(1, 2);
                       """,
                       expected: 3),
            VMTestCase(input: """
                        let sum = fn(a, b) { let c = a + b; c; };
                        sum(1, 2) + sum(3, 4);
                       """,
                       expected: 10),
            VMTestCase(input: """
                        let sum = fn(a, b) { let c = a + b; c; };
                        let outer = fn() {
                          sum(1, 2) + sum(3, 4);
                        };
                        outer();
                       """,
                       expected: 10),
            VMTestCase(input: """
                        let globalNum = 10;

                        let sum = fn(a, b) {
                            let c = a + b;
                            c + globalNum;
                        };

                        let outer = fn() {
                          sum(1, 2) + sum(3, 4) + globalNum;
                        };
                        outer() + globalNum;
                       """,
                       expected: 50),
        ]

        runVMTests(tests)
    }

    func testCallingFunctionsWithWrongArguments() {
        let tests = [
            VMTestCase(input: "fn() { 1; }(1);",
                       expected: "wrong number of arguments: want=0, got=1"),
            VMTestCase(input: "fn(a) { a; }();",
                       expected: "wrong number of arguments: want=1, got=0"),
            VMTestCase(input: "fn(a, b) { a + b; }(1);",
                       expected: "wrong number of arguments: want=2, got=1"),
        ]

        for t in tests {
            let program = parse(input: t.input)!
            let comp = Compiler()
            try? comp.compile(node: program)

            let vm = MonkeyVM(bytecode: comp.bytecode())
            do {
                try vm.run()
                XCTFail("No VM error")
            }
            catch {
                let error = error as? MonkeyVMError
                XCTAssertNotNil(error)
                XCTAssertEqual(error?.message, t.expected as? String)
            }
        }
    }

    func testBuiltinFunctions() {
        let tests = [
            VMTestCase(input: "len(\"\")", expected: 0),
            VMTestCase(input: "len(\"four\")", expected: 4),
            VMTestCase(input: "len(\"hello world\")", expected: 11),
            VMTestCase(input: "len(1)", expected: ErrorValue(message: "argument to 'len' not supported. got INTEGER")),
            VMTestCase(input: "len(\"one\", \"two\")", expected: ErrorValue(message: "wrong number of arguments. got=2, want=1")),
            VMTestCase(input: "len([1, 2, 3])", expected: 3),
            VMTestCase(input: "len([])", expected: 0),
            VMTestCase(input: "puts(\"hello\", \"world\")", expected: Null),
            VMTestCase(input: "first([1, 2, 3])", expected: 1),
            VMTestCase(input: "first([])", expected: Null),
            VMTestCase(input: "first(1)", expected: ErrorValue(message: "argument to 'first' must be ARRAY, got INTEGER")),
            VMTestCase(input: "last([1, 2, 3])", expected: 3),
            VMTestCase(input: "last([])", expected: Null),
            VMTestCase(input: "last(1)", expected: ErrorValue(message: "argument to 'last' must be ARRAY, got INTEGER")),
            VMTestCase(input: "rest([1, 2, 3])", expected: [2, 3]),
            VMTestCase(input: "rest([])", expected: Null),
            VMTestCase(input: "push([], 1)", expected: [1]),
            VMTestCase(input: "push(1, 1)", expected: ErrorValue(message: "argument to 'push' must be ARRAY, got INTEGER")),
        ]

        runVMTests(tests)
    }

    func testClosures() {
        let tests = [
            VMTestCase(input: """
                        let newClosure = fn(a) {
                          fn() { a; }
                        };
                        let closure = newClosure(99);
                        closure();
                       """,
                       expected: 99),
            VMTestCase(input: """
                        let newAdder = fn(a, b) {
                          fn(c) { a + b + c; };
                        };
                        let adder = newAdder(1, 2);
                        adder(8);
                       """,
                       expected: 11),
            VMTestCase(input: """
                        let newAdder = fn(a, b) {
                          let c = a + b;
                          fn(d) { c + d };
                        };
                        let adder = newAdder(1, 2);
                        adder(8);
                       """,
                       expected: 11),
            VMTestCase(input: """
                        let newAdderOuter = fn(a, b) {
                          let c = a + b;
                          fn(d) {
                            let e = d + c;
                            fn(f) { e + f; };
                          };
                        };
                        let newAdderInner = newAdderOuter(1, 2);
                        let adder = newAdderInner(3);
                        adder(8);
                       """,
                       expected: 14),
            VMTestCase(input: """
                        let a = 1;
                        let newAdderOuter = fn(b) {
                          fn(c) {
                            fn(d) { a + b + c + d };
                          };
                        };
                        let newAdderInner = newAdderOuter(2);
                        let adder = newAdderInner(3);
                        adder(8);
                       """,
                       expected: 14),
            VMTestCase(input: """
                        let newClosure = fn(a, b) {
                          let one = fn() { a; };
                          let two = fn() { b; };
                          fn() { one() + two(); };
                        };
                        let closure = newClosure(9, 90);
                        closure();
                       """,
                       expected: 99),
        ]

        runVMTests(tests)
    }

    func testRecursiveFunctions() {
        let tests = [
            VMTestCase(input: """
                         let countDown = fn(x) {
                           if (x == 0) {
                             return 0;
                           } else {
                             countDown(x - 1);
                           }
                         };
                         countDown(1);
                       """,
                       expected: 0),
            VMTestCase(input: """
                         let countDown = fn(x) {
                           if (x == 0) {
                             return 0;
                           } else {
                             countDown(x - 1);
                           }
                         };
                         let wrapper = fn() {
                           countDown(1);
                         };
                         wrapper();
                       """,
                       expected: 0),
            VMTestCase(input: """
                         let wrapper = fn() {
                           let countDown = fn(x) {
                             if (x == 0) {
                               return 0;
                             } else {
                               countDown(x - 1);
                             }
                           };
                           countDown(1);
                         };
                         wrapper();
                       """,
                       expected: 0),
        ]

        runVMTests(tests)
    }

    func testRecursiveFibonacci() {
        let tests = [
            VMTestCase(input: """
                         let fibonacci = fn(x) {
                           if (x == 0) {
                             return 0;
                           } else {
                             if (x == 1) {
                               return 1;
                             } else {
                               fibonacci(x - 1) + fibonacci(x - 2);
                             }
                           }
                         };
                         fibonacci(15);
                       """,
                       expected: 610),
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

        case is ErrorValue:
            let error = actual as? ErrorValue
            XCTAssertNotNil(error, "object is not an ErrorValue")
            XCTAssertEqual(error?.message, (expected as! ErrorValue).message)

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
