//
//  EvaluatorTests.swift
//  MerlinLibTests
//
//  Created by Rod Schmidt on 9/30/18.
//

import XCTest
@testable import MonkeyLib

class EvaluatorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEvalIntegerExpression() {
        struct Test {
            let input: String
            let expected: Int
        }

        let tests: [Test] = [
            Test(input: "5", expected: 5),
            Test(input: "10", expected: 10),
            Test(input: "-5", expected: -5),
            Test(input: "-10", expected: -10),
            Test(input: "5 + 5 + 5 + 5 - 10", expected: 10),
            Test(input: "2 * 2 * 2 * 2 * 2", expected: 32),
            Test(input: "-50 + 100 + -50", expected: 0),
            Test(input: "5 * 2 + 10", expected: 20),
            Test(input: "5 + 2 * 10", expected: 25),
            Test(input: "20 + 2 * -10", expected: 0),
            Test(input: "50 / 2 * 2 + 10", expected: 60),
            Test(input: "2 * (5 + 10)", expected: 30),
            Test(input: "3 * 3 * 3 + 10", expected: 37),
            Test(input: "3 * (3 * 3) + 10", expected: 37),
            Test(input: "(5 + 10 * 2 + 15 / 3) * 2 + -10", expected: 50),
        ]

        for t in tests {
            let evaluated = testEval(t.input)
            XCTAssertIntegerObject(evaluated, t.expected)
        }
    }

    func testEvalBooleanExpression() {
        struct Test {
            let input: String
            let expected: Bool
        }

        let tests: [Test] = [
            Test(input: "true", expected: true),
            Test(input: "false", expected: false),
            Test(input: "1 < 2", expected: true),
            Test(input: "1 > 2", expected: false),
            Test(input: "1 < 1", expected: false),
            Test(input: "1 > 1", expected: false),
            Test(input: "1 == 1", expected: true),
            Test(input: "1 != 1", expected: false),
            Test(input: "1 == 2", expected: false),
            Test(input: "1 != 2", expected: true),
            Test(input: "true == true", expected: true),
            Test(input: "false == false", expected: true),
            Test(input: "true == false", expected: false),
            Test(input: "true != false", expected: true),
            Test(input: "false != true", expected: true),
            Test(input: "(1 < 2) == true", expected: true),
            Test(input: "(1 < 2) == false", expected: false),
            Test(input: "(1 > 2) == true", expected: false),
            Test(input: "(1 > 2) == false", expected: true),
        ]

        for t in tests {
            let evaluated = testEval(t.input)
            XCTAssertBooleanObject(evaluated, t.expected)
        }
    }

    func testBangOperator() {
        struct Test {
            let input: String
            let expected: Bool
        }

        let tests: [Test] = [
            Test(input: "!true", expected: false),
            Test(input: "!false", expected: true),
            Test(input: "!5", expected: false),
            Test(input: "!!true", expected: true),
            Test(input: "!!false", expected: false),
            Test(input: "!!5", expected: true),
        ]

        for t in tests {
            let evaluated = testEval(t.input)
            XCTAssertBooleanObject(evaluated, t.expected)
        }
    }

    func testIfElseExpressions() {
        struct Test {
            let input: String
            let expected: Any?
        }

        let tests: [Test] = [
            Test(input: "if (true) { 10 }", expected: 10),
            Test(input: "if (false) { 10 }", expected: nil),
            Test(input: "if (1) { 10 }", expected: 10),
            Test(input: "if (1 < 2) { 10 }", expected: 10),
            Test(input: "if (1 > 2) { 10 }", expected: nil),
            Test(input: "if (1 > 2) { 10 } else { 20 }", expected: 20),
            Test(input: "if (1 < 2) { 10 } else { 20 }", expected: 10),
        ]

        for t in tests {
            let evaluated = testEval(t.input)
            if let expected = t.expected as? Int {
                XCTAssertIntegerObject(evaluated, expected)
            }
            else {
                XCTAssertNullObject(evaluated!)
            }
        }
    }

    func testReturnStatements() {
        struct Test {
            let input: String
            let expected: Int
        }

        let tests: [Test] = [
            Test(input: "return 10;", expected: 10),
            Test(input: "return 10; 9;", expected: 10),
            Test(input: "return 2 * 5; 9;", expected: 10),
            Test(input: "9; return 2 * 5; 9;", expected: 10),
            Test(input: "if (10 > 1) { if (10 > 1) { return 10; } return 1; }", expected: 10),
        ]

        for t in tests {
            let evaluated = testEval(t.input)
            XCTAssertIntegerObject(evaluated, t.expected)
        }
    }

    func testErrorHandling() {
        struct Test {
            let input: String
            let expectedMessage: String
        }

        let tests: [Test] = [
            Test(input: "5 + true;", expectedMessage: "type mismatch: INTEGER + BOOLEAN"),
            Test(input: "5 + true; 5;", expectedMessage: "type mismatch: INTEGER + BOOLEAN"),
            Test(input: "-true;", expectedMessage: "unknown operator: -BOOLEAN"),
            Test(input: "true + false;", expectedMessage: "unknown operator: BOOLEAN + BOOLEAN"),
            Test(input: "5; true + false; 5", expectedMessage: "unknown operator: BOOLEAN + BOOLEAN"),
            Test(input: "if (10 > 1) { true + false }", expectedMessage: "unknown operator: BOOLEAN + BOOLEAN"),
            Test(input: "if (10 > 1) { if (10 > 1) { return true + false; } return 1; }", expectedMessage: "unknown operator: BOOLEAN + BOOLEAN"),
        ]

        for t in tests {
            let evaluated = testEval(t.input)
            XCTAssertNotNil(evaluated as? ErrorValue, "No error object returned for input \(t.input). got \(String(describing: evaluated))")
            guard let errObj = evaluated as? ErrorValue else { break }
            XCTAssertEqual(errObj.message, t.expectedMessage, "wrong error message. expected=\(t.expectedMessage), got=\(errObj.message)")
        }
    }

    func testEval(_ input: String) -> MonkeyObject? {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        guard let program = parser.parseProgram() else { return nil }
        return eval(program)
    }

    func XCTAssertIntegerObject(_ object: MonkeyObject?, _ expected: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(object, "object is nil", file: file, line: line)
        guard object != nil else { return }
        let result = object as? MonkeyInteger
        XCTAssertNotNil(result, "object is not an Integer. got \(object!) (\(object!))", file: file, line: line)
        guard result != nil else { return }
        XCTAssertEqual(result!.value, expected, "object has wrong value. got \(result!.value), want \(expected)", file: file, line: line)
    }

    func XCTAssertBooleanObject(_ object: MonkeyObject?, _ expected: Bool, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(object, "object is nil", file: file, line: line)
        guard object != nil else { return }
        let result = object as? MonkeyBoolean
        XCTAssertNotNil(result, "object is not an Boolean. got \(object!) (\(object!))", file: file, line: line)
        guard result != nil else { return }
        XCTAssertEqual(result!.value, expected, "object has wrong value. got \(result!.value), want \(expected)", file: file, line: line)
    }

    func XCTAssertNullObject(_ object: MonkeyObject, file: StaticString = #file, line: UInt = #line) {
        let obj = object as? MonkeyNull
        XCTAssertNotNil(obj, "object is not NULL. got \(object) \(object)", file: file, line: line)
    }

}
