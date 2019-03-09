//
//  ParserTests.swift
//  MerlinLibTests
//
//  Created by Rod Schmidt on 8/5/18.
//

import XCTest
@testable import MonkeyLib

class ParserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    struct ParserTest {
        let expectedIdentifier: String
    }

    func testLetStatements() {
        struct LetTest {
            let input: String
            let expectedIdentifier: String
            let expectedValue: Any
        }

        let tests: [LetTest] = [
            LetTest(input: "let x = 5;", expectedIdentifier: "x", expectedValue: 5),
            LetTest(input: "let y = true;", expectedIdentifier: "y", expectedValue: true),
            LetTest(input: "let foobar = y;", expectedIdentifier: "foobar", expectedValue: "y"),
        ]

        tests.forEach { t in
            let lexer = Lexer(input: t.input)
            let parser = Parser(lexer: lexer)
            let program = parser.parseProgram()
            checkParserErrors(parser)
            XCTAssertNotNil(program)
            XCTAssertEqual(program?.statements.count, 1)

            let stmt = program?.statements[0] as? LetStatement
            XCTAssertNotNil(stmt)
            XCTAssertLetStatement(stmt!, t.expectedIdentifier)

            let val = stmt!.value
            XCTAssertNotNil(val)
            XCTAssertLiteralExpression(val!, t.expectedValue)
        }
    }

    func checkParserErrors(_ parser: Parser) {
        parser.errors.forEach { print("parser error: \($0)") }
        XCTAssertEqual(parser.errors.count, 0)
    }

    func testReturnStatements() {
        struct ReturnTest {
            let input: String
            let expectedValue: Any
        }

        let tests: [ReturnTest] = [
            ReturnTest(input: "return 5;", expectedValue: 5),
            ReturnTest(input: "return true;", expectedValue: true),
            ReturnTest(input: "return y;", expectedValue: "y")
        ]

        for t in tests {
            let lexer = Lexer(input: t.input)
            let parser = Parser(lexer: lexer)
            let program = parser.parseProgram()
            checkParserErrors(parser)
            XCTAssertNotNil(program)

            let stmt = program?.statements[0] as? ReturnStatement
            XCTAssertNotNil(stmt)
            let val = stmt!.returnValue
            XCTAssertNotNil(val)
            XCTAssertLiteralExpression(val!, t.expectedValue)
        }
    }

    func testIdentifierExpression() {
        let input = "foobar;"

        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let program = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program!.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        XCTAssertIdentifier(stmt!.expression, "foobar")
    }

    func testIntegerLiteral() {
        let input = "5;"
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let program = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program!.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let literal = stmt!.expression as? IntegerLiteral
        XCTAssertIntegerLiteral(literal, 5)
    }

    func testBooleanLiteral() {
        let input = "true;"
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let program = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program!.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let literal = stmt!.expression as? BooleanLiteral
        XCTAssertBooleanLiteral(literal, true)
    }

    func testParsingPrefixExpressions() {
        struct PrefixTest {
            let input: String
            let `operator`: String
            let value: Any
        }

        let prefixTests = [
            PrefixTest(input: "!5", operator: "!", value: 5),
            PrefixTest(input: "-15", operator: "-", value: 15),
            PrefixTest(input: "!true", operator: "!", value: true),
            PrefixTest(input: "!false", operator: "!", value: false),
        ]

        prefixTests.forEach { t in
            let lexer = Lexer(input: t.input)
            let parser = Parser(lexer: lexer)
            let program = parser.parseProgram()
            checkParserErrors(parser)

            XCTAssertEqual(program?.statements.count, 1)

            let stmt = program!.statements[0] as? ExpressionStatement
            XCTAssertNotNil(stmt)

            let expr = stmt?.expression as? PrefixExpression
            XCTAssertNotNil(expr)
            XCTAssertEqual(expr!.operator, t.operator)

            XCTAssertLiteralExpression(expr!.right!, t.value)
        }
    }

    func testParsingInfixExpressions() {
        struct InfixTest {
            let input: String
            let leftValue: Any
            let `operator`: String
            let rightValue: Any
        }

        let infixTests = [
            InfixTest(input: "5 + 5", leftValue: 5, operator: "+", rightValue: 5),
            InfixTest(input: "5 - 5", leftValue: 5, operator: "-", rightValue: 5),
            InfixTest(input: "5 * 5", leftValue: 5, operator: "*", rightValue: 5),
            InfixTest(input: "5 / 5", leftValue: 5, operator: "/", rightValue: 5),
            InfixTest(input: "5 > 5", leftValue: 5, operator: ">", rightValue: 5),
            InfixTest(input: "5 < 5", leftValue: 5, operator: "<", rightValue: 5),
            InfixTest(input: "5 == 5", leftValue: 5, operator: "==", rightValue: 5),
            InfixTest(input: "5 != 5", leftValue: 5, operator: "!=", rightValue: 5),
            InfixTest(input: "true == true", leftValue: true, operator: "==", rightValue: true),
            InfixTest(input: "true != false", leftValue: true, operator: "!=", rightValue: false),
            InfixTest(input: "false == false", leftValue: false, operator: "==", rightValue: false),
        ]

        infixTests.forEach { t in
            let lexer = Lexer(input: t.input)
            let parser = Parser(lexer: lexer)
            let program = parser.parseProgram()
            checkParserErrors(parser)

            XCTAssertEqual(program?.statements.count, 1)

            let stmt = program!.statements[0] as? ExpressionStatement
            XCTAssertNotNil(stmt)

            let expr = stmt?.expression as? InfixExpression
            XCTAssertInfixExpression(expr, t.leftValue, operator: t.operator, t.rightValue)
        }
    }

    func testOperatorPrecedenceParsing() {
        struct PrecedenceTest {
            let input: String
            let expected: String
        }

        let tests = [
            PrecedenceTest(input: "-a * b", expected: "((-a) * b)"),
            PrecedenceTest(input: "!-a", expected: "(!(-a))"),
            PrecedenceTest(input: "a + b + c", expected: "((a + b) + c)"),
            PrecedenceTest(input: "a + b - c", expected: "((a + b) - c)"),
            PrecedenceTest(input: "a * b * c", expected: "((a * b) * c)"),
            PrecedenceTest(input: "a * b / c", expected: "((a * b) / c)"),
            PrecedenceTest(input: "a + b / c", expected: "(a + (b / c))"),
            PrecedenceTest(input: "a + b * c + d / e - f", expected: "(((a + (b * c)) + (d / e)) - f)"),
            PrecedenceTest(input: "3 + 4; -5 * 5", expected: "(3 + 4)((-5) * 5)"),
            PrecedenceTest(input: "5 > 4 == 3 < 4", expected: "((5 > 4) == (3 < 4))"),
            PrecedenceTest(input: "5 < 4 != 3 > 4", expected: "((5 < 4) != (3 > 4))"),
            PrecedenceTest(input: "3 + 4 * 5 == 3 * 1 + 4 * 5", expected: "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
            PrecedenceTest(input: "true", expected: "true"),
            PrecedenceTest(input: "false", expected: "false"),
            PrecedenceTest(input: "3 > 5 == false", expected: "((3 > 5) == false)"),
            PrecedenceTest(input: "3 < 5 == true", expected: "((3 < 5) == true)"),
            PrecedenceTest(input: "1 + (2 + 3) + 4", expected: "((1 + (2 + 3)) + 4)"),
            PrecedenceTest(input: "(5 + 5) * 2", expected: "((5 + 5) * 2)"),
            PrecedenceTest(input: "2 / (5 + 5)", expected: "(2 / (5 + 5))"),
            PrecedenceTest(input: "-(5 + 5)", expected: "(-(5 + 5))"),
            PrecedenceTest(input: "!(true == true)", expected: "(!(true == true))"),

            PrecedenceTest(input: "a + add(b * c) + d", expected: "((a + add((b * c))) + d)"),
            PrecedenceTest(input: "add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", expected: "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
            PrecedenceTest(input: "add(a + b + c * d / f + g)", expected: "add((((a + b) + ((c * d) / f)) + g))"),
        ]

        tests.forEach { t in
            let lexer = Lexer(input: t.input)
            let parser = Parser(lexer: lexer)
            let program = parser.parseProgram()
            checkParserErrors(parser)

            XCTAssertNotNil(program)
            let actual = program!.description
            XCTAssertEqual(actual, t.expected)
        }
    }

    func testIfExpression() {
        let input = "if (x < y) { x }"
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let prog = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertNotNil(prog)
        guard let program = prog else { return }

        XCTAssertEqual(program.statements.count, 1)
        let stmt = program.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let expr = stmt!.expression as? IfExpression
        XCTAssertNotNil(expr)

        XCTAssertInfixExpression(expr!.condition, "x", operator: "<", "y")
        XCTAssertEqual(expr!.consequence.statements.count, 1)
        let consequence = expr!.consequence.statements[0] as? ExpressionStatement
        XCTAssertNotNil(consequence)
        XCTAssertIdentifier(consequence!.expression, "x")
        XCTAssertNil(expr!.alternative)
    }

    func testIfElseExpression() {
        let input = "if (x < y) { x } else { y }"
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let prog = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertNotNil(prog)
        guard let program = prog else { return }

        XCTAssertEqual(program.statements.count, 1)
        let stmt = program.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let expr = stmt!.expression as? IfExpression
        XCTAssertNotNil(expr)

        XCTAssertInfixExpression(expr!.condition, "x", operator: "<", "y")
        XCTAssertEqual(expr!.consequence.statements.count, 1)
        let consequence = expr!.consequence.statements[0] as? ExpressionStatement
        XCTAssertNotNil(consequence)
        XCTAssertIdentifier(consequence!.expression, "x")

        XCTAssertEqual(expr!.alternative?.statements.count, 1)
        let alternative = expr!.alternative?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(alternative)
        XCTAssertIdentifier(alternative!.expression, "y")
    }

    func testFunctionLiteral() {
        let input = "fn(x, y) { x + y }"
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let prog = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertNotNil(prog)
        guard let program = prog else { return }

        XCTAssertEqual(program.statements.count, 1)
        let stmt = program.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let function = stmt!.expression as? FunctionLiteral
        XCTAssertNotNil(function, "Expression is not a function literal")

        XCTAssertEqual(function?.parameters.count, 2, "Function literal should have 2 arguments")
        XCTAssertLiteralExpression(function!.parameters[0], "x")
        XCTAssertLiteralExpression(function!.parameters[1], "y")

        XCTAssertEqual(function!.body.statements.count, 1)

        let bodyStmt = function!.body.statements[0] as? ExpressionStatement
        XCTAssertNotNil(bodyStmt)

        XCTAssertInfixExpression(bodyStmt?.expression, "x", operator: "+", "y")
    }

    func testFunctionParameterPassing() {
        struct ParameterPassingTest {
            let input: String
            let expectedParams: [String]
        }

        let tests: [ParameterPassingTest] = [
            ParameterPassingTest(input: "fn() {};", expectedParams: []),
            ParameterPassingTest(input: "fn(x) {};", expectedParams: ["x"]),
            ParameterPassingTest(input: "fn(x, y, z) {};", expectedParams: ["x", "y", "z"])
        ]

        tests.forEach { t in
            let lexer = Lexer(input: t.input)
            let parser = Parser(lexer: lexer)
            let program = parser.parseProgram()
            checkParserErrors(parser)
            XCTAssertNotNil(program)

            let stmt = program?.statements[0] as? ExpressionStatement
            let function = stmt?.expression as? FunctionLiteral
            XCTAssertNotNil(function)
            XCTAssertEqual(function!.parameters.count, t.expectedParams.count)

            for (i, ident) in t.expectedParams.enumerated() {
                XCTAssertLiteralExpression(function!.parameters[i], ident)
            }
        }
    }

    func testCallExpression() {
        let input = "add(1, 2 * 3, 4 + 5);"
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let exp = stmt?.expression as? CallExpression
        XCTAssertNotNil(exp)

        XCTAssertIdentifier(exp?.function, "add")
        XCTAssertEqual(exp?.arguments.count, 3)

        XCTAssertLiteralExpression(exp!.arguments[0], 1)
        XCTAssertInfixExpression(exp!.arguments[1], 2, operator: "*", 3)
        XCTAssertInfixExpression(exp!.arguments[2], 4, operator: "+", 5)
    }

    func XCTAssertIdentifier(_ expr: Expression?, _ value: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(expr as? Identifier, "expression is not an Identifier. Got \(String(describing: expr))", file: file, line: line)
        let ident = expr as! Identifier
        XCTAssertEqual(ident.value, value, "ident.value is not \(value), got \(ident.value)", file: file, line: line)
        XCTAssertEqual(ident.tokenLiteral(), value, "identifier token literal is not \(value), got \(ident.tokenLiteral())", file: file, line: line)
    }

    func XCTAssertIntegerLiteral(_ expr: Expression?, _ value: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(expr as? IntegerLiteral, "expression is not an integer, got \(String(describing: expr))", file: file, line: line)
        let integer = expr as! IntegerLiteral
        XCTAssertEqual(integer.value, value, "integer literal is not \(integer.value), got \(value)", file: file, line: line)
        XCTAssertEqual(integer.tokenLiteral(), String(value), "integer token literal is not \(value), got \(integer.tokenLiteral())", file: file, line: line)
    }

    func XCTAssertBooleanLiteral(_ expr: Expression?, _ value: Bool, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(expr as? BooleanLiteral, "expression is not a boolean, got \(String(describing: expr))", file: file, line: line)
        let b = expr as! BooleanLiteral
        XCTAssertEqual(b.value, value, "boolean literal is not \(b.value), got \(value)", file: file, line: line)
        XCTAssertEqual(b.tokenLiteral(), String(value), "boolean token literal is not \(value), got \(b.tokenLiteral())", file: file, line: line)
    }

    func XCTAssertLiteralExpression(_ expr: Expression, _ expected: Any, file: StaticString = #file, line: UInt = #line) {
        switch expected {
        case is Bool:
            return XCTAssertBooleanLiteral(expr, expected as! Bool, file: file, line: line)

        case is Int:
            return XCTAssertIntegerLiteral(expr, expected as! Int, file: file, line: line)

        case is String:
            return XCTAssertIdentifier(expr, expected as! String, file: file, line: line)

        default:
            XCTFail("Type of expr not handled")
        }
    }

    func XCTAssertInfixExpression(_ expr: Expression?, _ left: Any, operator: String, _ right: Any, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(expr as? InfixExpression, "expr is not an InfixExpression. Got \(String(describing: expr))", file: file, line: line)
        let infix = expr as! InfixExpression
        XCTAssertLiteralExpression(infix.left, left, file: file, line: line)
        XCTAssertEqual(infix.operator, `operator`, "expr operator is not \(`operator`)", file: file, line: line)
        XCTAssertLiteralExpression(infix.right!, right, file: file, line: line)
    }

    func XCTAssertLetStatement(_ s: Statement, _ name: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(s.tokenLiteral(), "let", "s.tokenLiteral not 'let'. got \(s.tokenLiteral())", file: file, line: line)
        let letStmt = s as? LetStatement
        XCTAssertNotNil(letStmt, "s not LetStatement. got \(s)", file: file, line: line)
        XCTAssertEqual(letStmt?.name.value, name, "letStmt.Name.Value not '\(name)'. got \(letStmt!.name.value)", file: file, line: line)
        XCTAssertEqual(letStmt?.name.tokenLiteral(), name, "letStmt.name.tokenLiteral() not '\(name)'. got \(letStmt!.name.tokenLiteral())", file: file, line: line)
    }

}
