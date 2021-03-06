//
//  ParserTests.swift
//  MerlinLibTests
//
//  Created by Rod Schmidt on 8/5/18.
//

import XCTest
@testable import MonkeyLib

class ParserTests: XCTestCase {

    func testLetStatements() {
        struct Test {
            let input: String
            let expectedIdentifier: String
            let expectedValue: Any

            init(_ input: String, _ identifier: String, _ value: Any) {
                self.input = input
                self.expectedIdentifier = identifier
                self.expectedValue = value
            }
        }

        let tests = [
            Test("let x = 5;", "x", 5),
            Test("let y = true;", "y", true),
            Test("let foobar = y;", "foobar", "y"),
        ]

        for t in tests {
            let parser = createParser(t.input)
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

    func testReturnStatements() {
        struct Test {
            let input: String
            let expectedValue: Any

            init(_ input: String, _ value: Any) {
                self.input = input
                expectedValue = value
            }
        }

        let tests = [
            Test("return 5;", 5),
            Test("return true;", true),
            Test("return y;", "y")
        ]

        for t in tests {
            let parser = createParser(t.input)
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
        let parser = createParser("foobar;")
        let program = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program!.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        XCTAssertIdentifier(stmt!.expression, "foobar")
    }

    func testIntegerLiteral() {
        let parser = createParser("5;")
        let program = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program!.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let literal = stmt!.expression as? IntegerLiteral
        XCTAssertIntegerLiteral(literal, 5)
    }

    func testStringLiteralExpression() {
        let parser = createParser("\"hello world\";")
        let program = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program!.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let literal = stmt!.expression as? StringLiteral
        XCTAssertStringLiteral(literal, "hello world")
    }

    func testBooleanLiteral() {
        let parser = createParser("true;")
        let program = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program!.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let literal = stmt!.expression as? BooleanLiteral
        XCTAssertBooleanLiteral(literal, true)
    }

    func testParsingPrefixExpressions() {
        struct Test {
            let input: String
            let `operator`: String
            let value: Any

            init(_ input: String, _ op: String, _ value: Any) {
                self.input = input
                self.operator = op
                self.value = value
            }
        }

        let tests = [
            Test("!5", "!", 5),
            Test("-15", "-", 15),
            Test("!true", "!", true),
            Test("!false", "!", false),
        ]

        for t in tests {
            let parser = createParser(t.input)
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
        struct Test {
            let input: String
            let leftValue: Any
            let `operator`: String
            let rightValue: Any

            init(_ input: String, _ left: Any, _ op: String, _ right: Any) {
                self.input = input
                leftValue = left
                self.operator = op
                rightValue = right
            }
        }

        let tests = [
            Test("5 + 5", 5, "+", 5),
            Test("5 - 5", 5, "-", 5),
            Test("5 * 5", 5, "*", 5),
            Test("5 / 5", 5, "/", 5),
            Test("5 > 5", 5, ">", 5),
            Test("5 < 5", 5, "<", 5),
            Test("5 == 5", 5, "==", 5),
            Test("5 != 5", 5, "!=", 5),
            Test("true == true", true, "==", true),
            Test("true != false", true, "!=", false),
            Test("false == false", false, "==", false),
        ]

        for t in tests {
            let parser = createParser(t.input)
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
        struct Test {
            let input: String
            let expected: String

            init(_ input: String, _ expected: String) {
                self.input = input
                self.expected = expected
            }
        }

        let tests = [
            Test("-a * b", "((-a) * b)"),
            Test("!-a", "(!(-a))"),
            Test("a + b + c", "((a + b) + c)"),
            Test("a + b - c", "((a + b) - c)"),
            Test("a * b * c", "((a * b) * c)"),
            Test("a * b / c", "((a * b) / c)"),
            Test("a + b / c", "(a + (b / c))"),
            Test("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
            Test("3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"),
            Test("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
            Test("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"),
            Test("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
            Test("true", "true"),
            Test("false", "false"),
            Test("3 > 5 == false", "((3 > 5) == false)"),
            Test("3 < 5 == true", "((3 < 5) == true)"),
            Test("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
            Test("(5 + 5) * 2", "((5 + 5) * 2)"),
            Test("2 / (5 + 5)", "(2 / (5 + 5))"),
            Test("-(5 + 5)", "(-(5 + 5))"),
            Test("!(true == true)", "(!(true == true))"),

            Test("a + add(b * c) + d", "((a + add((b * c))) + d)"),
            Test("add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
            Test("add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))"),

            Test("a * [1, 2, 3, 4][b * c] * d", "((a * ([1, 2, 3, 4][(b * c)])) * d)"),
            Test("add(a * b[2], b[1], 2 * [1, 2][1])", "add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))"),
        ]

        for t in tests {
            let parser = createParser(t.input)
            let program = parser.parseProgram()
            checkParserErrors(parser)

            XCTAssertNotNil(program)
            let actual = program!.description
            XCTAssertEqual(actual, t.expected)
        }
    }

    func testIfExpression() {
        let parser = createParser("if (x < y) { x }")
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
        let parser = createParser("if (x < y) { x } else { y }")
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
        let parser = createParser("fn(x, y) { x + y }")
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

    func testFunctionLiteralWithName() {
        let parser = createParser("let myFunction = fn() { };")
        let prog = parser.parseProgram()
        checkParserErrors(parser)

        XCTAssertNotNil(prog)
        guard let program = prog else { return }

        XCTAssertEqual(program.statements.count, 1)
        let stmt = program.statements[0] as? LetStatement
        XCTAssertNotNil(stmt, "program.statements[0] is not LetStatement. got=\(program.statements[0])")

        let function = stmt!.value as? FunctionLiteral
        XCTAssertNotNil(function, "Expression is not a function literal")

        XCTAssertEqual(function?.name, "myFunction", "function literal name wrong. want 'myFunction', got=\(String(describing: function?.name))")
    }

    func testFunctionParameterPassing() {
        struct Test {
            let input: String
            let expectedParams: [String]

            init(_ input: String, _ params: [String]) {
                self.input = input
                expectedParams = params
            }
        }

        let tests = [
            Test("fn() {};", []),
            Test("fn(x) {};", ["x"]),
            Test("fn(x, y, z) {};", ["x", "y", "z"])
        ]

        for t in tests {
            let parser = createParser(t.input)
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
        let parser = createParser("add(1, 2 * 3, 4 + 5);")
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

    func testParsingArrayLiterals() {
        let parser = createParser("[1, 2 * 2, 3 + 3]")
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let array = stmt?.expression as? ArrayLiteral
        XCTAssertNotNil(array)

        XCTAssertEqual(array?.elements.count, 3)

        XCTAssertIntegerLiteral(array?.elements[0], 1)
        XCTAssertInfixExpression(array?.elements[1], 2, operator: "*", 2)
        XCTAssertInfixExpression(array?.elements[2], 3, operator: "+", 3)
    }

    func testParsingIndexExpressions() {
        let parser = createParser("myArray[1 + 1]")
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let indexExp = stmt?.expression as? IndexExpression
        XCTAssertNotNil(indexExp)

        XCTAssertIdentifier(indexExp?.left, "myArray")
        XCTAssertInfixExpression(indexExp?.index, 1, operator: "+", 1)
    }

    func testParsingHashLiterals() {
        let parser = createParser("{\"one\": 1, \"two\": 2, \"three\": 3}")
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let hash = stmt?.expression as? HashLiteral
        XCTAssertNotNil(hash, "exp is not a HashLiteral. got=\(String(describing: stmt?.expression))")

        XCTAssertEqual(hash?.pairs.count, 3, "hash.pairs has wrong length. got=\(String(describing: hash?.pairs.count))")

        let expected = ["one": 1, "two": 2, "three": 3]
        for (key, value) in hash?.pairs ?? [] {
            let literal = key as? StringLiteral
            XCTAssertNotNil(literal, "key is not StringLiteral. got=\(key)")
            let expectedValue = expected[literal?.description ?? ""] ?? 0
            XCTAssertIntegerLiteral(value, expectedValue)
        }
    }

    func testParsingHashLiteralsWithIntegerKeys() {
        let parser = createParser("{1: 1, 2: 2, 3: 3}")
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let hash = stmt?.expression as? HashLiteral
        XCTAssertNotNil(hash, "exp is not a HashLiteral. got=\(String(describing: stmt?.expression))")

        XCTAssertEqual(hash?.pairs.count, 3, "hash.pairs has wrong length. got=\(String(describing: hash?.pairs.count))")

        let expected = [1: 1, 2: 2, 3: 3]
        for (key, value) in hash?.pairs ?? [] {
            let literal = key as? IntegerLiteral
            XCTAssertNotNil(literal, "key is not IntegerLiteral. got=\(key)")
            let expectedValue = expected[literal?.value ?? 0] ?? 0
            XCTAssertIntegerLiteral(value, expectedValue)
        }
    }

    func testParsingHashLiteralsWithBooleanKeys() {
        let parser = createParser("{true: 1, false: 0}")
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let hash = stmt?.expression as? HashLiteral
        XCTAssertNotNil(hash, "exp is not a HashLiteral. got=\(String(describing: stmt?.expression))")

        XCTAssertEqual(hash?.pairs.count, 2, "hash.pairs has wrong length. got=\(String(describing: hash?.pairs.count))")

        let expected = [true: 1, false: 0]
        for (key, value) in hash?.pairs ?? [] {
            let literal = key as? BooleanLiteral
            XCTAssertNotNil(literal, "key is not BooleanLiteral. got=\(key)")
            let expectedValue = expected[literal!.value]!
            XCTAssertIntegerLiteral(value, expectedValue)
        }
    }

    func testParsingEmptyHashLiterals() {
        let parser = createParser("{}")
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let hash = stmt?.expression as? HashLiteral
        XCTAssertNotNil(hash, "exp is not a HashLiteral. got=\(String(describing: stmt?.expression))")

        XCTAssertEqual(hash?.pairs.count, 0, "hash.pairs has wrong length. got=\(String(describing: hash?.pairs.count))")
    }

    func testParsingHashLiteralsWithExpressions() {
        let parser = createParser("{\"one\": 0 + 1, \"two\": 10 - 8, \"three\": 15 / 5}")
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let hash = stmt?.expression as? HashLiteral
        XCTAssertNotNil(hash, "exp is not a HashLiteral. got=\(String(describing: stmt?.expression))")

        XCTAssertEqual(hash?.pairs.count, 3, "hash.pairs has wrong length. got=\(String(describing: hash?.pairs.count))")

        let tests = [
            "one":      { (e: Expression) in self.XCTAssertInfixExpression(e, 0, operator: "+", 1) },
            "two":      { (e: Expression) in self.XCTAssertInfixExpression(e, 10, operator: "-", 8) },
            "three":    { (e: Expression) in self.XCTAssertInfixExpression(e, 15, operator: "/", 5) },
        ]

        for (key, value) in hash?.pairs ?? [] {
            let literal = key as? StringLiteral
            XCTAssertNotNil(literal, "key is not StringLiteral. got=\(key)")

            let testFunc = tests[literal!.description]
            XCTAssertNotNil(testFunc, "No test funcdtion for key \(literal!.description) found")
            if testFunc != nil {
                testFunc!(value)
            }
        }
    }

    func testMacroLiteralParsing() {
        let parser = createParser("macro(x, y) { x + y; }")
        let program = parser.parseProgram()
        XCTAssertNotNil(program)
        checkParserErrors(parser)

        XCTAssertEqual(program?.statements.count, 1)

        let stmt = program?.statements[0] as? ExpressionStatement
        XCTAssertNotNil(stmt)

        let macro = stmt?.expression as? MacroLiteral
        XCTAssertNotNil(hash, "exp is not a MacroLiteral. got=\(String(describing: stmt?.expression))")
        XCTAssertEqual(macro?.parameters.count, 2)

        XCTAssertLiteralExpression(macro!.parameters[0], "x")
        XCTAssertLiteralExpression(macro!.parameters[1], "y")

        XCTAssertEqual(macro?.body.statements.count, 1)

        let bodyStmt = macro?.body.statements[0] as? ExpressionStatement
        XCTAssertNotNil(bodyStmt, "macro body stmt is not an ExpressionStmt")

        XCTAssertInfixExpression(bodyStmt!.expression, "x", operator: "+", "y")
    }

    private func createParser(_ input: String) -> Parser {
        let lexer = Lexer(input: input)
        return Parser(lexer: lexer)
    }

    func checkParserErrors(_ parser: Parser) {
        parser.errors.forEach { print("parser error: \($0)") }
        XCTAssertEqual(parser.errors.count, 0)
    }

    func XCTAssertIdentifier(_ expr: Expression?, _ value: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(expr as? Identifier, "expression is not an Identifier. Got \(String(describing: expr))", file: file, line: line)
        let ident = expr as! Identifier
        XCTAssertEqual(ident.value, value, "ident.value is not \(value), got \(ident.value)", file: file, line: line)
        XCTAssertEqual(ident.tokenLiteral, value, "identifier token literal is not \(value), got \(ident.tokenLiteral)", file: file, line: line)
    }

    func XCTAssertIntegerLiteral(_ expr: Expression?, _ value: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(expr as? IntegerLiteral, "expression is not an integer, got \(String(describing: expr))", file: file, line: line)
        let integer = expr as! IntegerLiteral
        XCTAssertEqual(integer.value, value, "integer literal is not \(integer.value), got \(value)", file: file, line: line)
        XCTAssertEqual(integer.tokenLiteral, String(value), "integer token literal is not \(value), got \(integer.tokenLiteral)", file: file, line: line)
    }

    func XCTAssertStringLiteral(_ expr: Expression?, _ value: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(expr as? StringLiteral, "expression is not a string, got \(String(describing: expr))", file: file, line: line)
        let string = expr as! StringLiteral
        XCTAssertEqual(string.value, value, "string literal is not \(string.value), got \(value)", file: file, line: line)
        XCTAssertEqual(string.tokenLiteral, String(value), "string token literal is not \(value), got \(string.tokenLiteral)", file: file, line: line)
    }

    func XCTAssertBooleanLiteral(_ expr: Expression?, _ value: Bool, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(expr as? BooleanLiteral, "expression is not a boolean, got \(String(describing: expr))", file: file, line: line)
        let b = expr as! BooleanLiteral
        XCTAssertEqual(b.value, value, "boolean literal is not \(b.value), got \(value)", file: file, line: line)
        XCTAssertEqual(b.tokenLiteral, String(value), "boolean token literal is not \(value), got \(b.tokenLiteral)", file: file, line: line)
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
        XCTAssertEqual(s.tokenLiteral, "let", "s.tokenLiteral not 'let'. got \(s.tokenLiteral)", file: file, line: line)
        let letStmt = s as? LetStatement
        XCTAssertNotNil(letStmt, "s not LetStatement. got \(s)", file: file, line: line)
        XCTAssertEqual(letStmt?.name.value, name, "letStmt.Name.Value not '\(name)'. got \(letStmt!.name.value)", file: file, line: line)
        XCTAssertEqual(letStmt?.name.tokenLiteral, name, "letStmt.name.tokenLiteral() not '\(name)'. got \(letStmt!.name.tokenLiteral)", file: file, line: line)
    }

}
