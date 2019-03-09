//
//  LexerTests.swift
//  MerlinTests
//
//  Created by Rod Schmidt on 8/4/18.
//  Copyright © 2018 infiniteNIL. All rights reserved.
//

import XCTest
@testable import MonkeyLib

class LexerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    struct LexerTest {
        let expectedType: TokenType
        let expectedLiteral: String
    }

    func testNextToken() {
        let input = """
            let five = 5;
            let ten = 10;

            let add = fn(x, y) {
              x + y;
            };

            let result = add(five, 10);
            !-/*5;
            5 < 10 > 5;

            if (5 < 10) {
                return true;
            } else {
                return false;
            }

            10 == 10;
            10 != 9;
        """

        let tests: [LexerTest] = [
            LexerTest(expectedType: .let, expectedLiteral: "let"),
            LexerTest(expectedType: .ident, expectedLiteral: "five"),
            LexerTest(expectedType: .assign, expectedLiteral: "="),
            LexerTest(expectedType: .int, expectedLiteral: "5"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),
            LexerTest(expectedType: .let, expectedLiteral: "let"),
            LexerTest(expectedType: .ident, expectedLiteral: "ten"),
            LexerTest(expectedType: .assign, expectedLiteral: "="),
            LexerTest(expectedType: .int, expectedLiteral: "10"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),
            LexerTest(expectedType: .let, expectedLiteral: "let"),
            LexerTest(expectedType: .ident, expectedLiteral: "add"),
            LexerTest(expectedType: .assign, expectedLiteral: "="),
            LexerTest(expectedType: .function, expectedLiteral: "fn"),
            LexerTest(expectedType: .lparen, expectedLiteral: "("),
            LexerTest(expectedType: .ident, expectedLiteral: "x"),
            LexerTest(expectedType: .comma, expectedLiteral: ","),
            LexerTest(expectedType: .ident, expectedLiteral: "y"),
            LexerTest(expectedType: .rparen, expectedLiteral: ")"),
            LexerTest(expectedType: .lbrace, expectedLiteral: "{"),
            LexerTest(expectedType: .ident, expectedLiteral: "x"),
            LexerTest(expectedType: .plus, expectedLiteral: "+"),
            LexerTest(expectedType: .ident, expectedLiteral: "y"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),
            LexerTest(expectedType: .rbrace, expectedLiteral: "}"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),
            LexerTest(expectedType: .let, expectedLiteral: "let"),
            LexerTest(expectedType: .ident, expectedLiteral: "result"),
            LexerTest(expectedType: .assign, expectedLiteral: "="),
            LexerTest(expectedType: .ident, expectedLiteral: "add"),
            LexerTest(expectedType: .lparen, expectedLiteral: "("),
            LexerTest(expectedType: .ident, expectedLiteral: "five"),
            LexerTest(expectedType: .comma, expectedLiteral: ","),
            LexerTest(expectedType: .int, expectedLiteral: "10"),
            LexerTest(expectedType: .rparen, expectedLiteral: ")"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),

            LexerTest(expectedType: .bang, expectedLiteral: "!"),
            LexerTest(expectedType: .minus, expectedLiteral: "-"),
            LexerTest(expectedType: .slash, expectedLiteral: "/"),
            LexerTest(expectedType: .asterisk, expectedLiteral: "*"),
            LexerTest(expectedType: .int, expectedLiteral: "5"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),

            LexerTest(expectedType: .int, expectedLiteral: "5"),
            LexerTest(expectedType: .lt, expectedLiteral: "<"),
            LexerTest(expectedType: .int, expectedLiteral: "10"),
            LexerTest(expectedType: .gt, expectedLiteral: ">"),
            LexerTest(expectedType: .int, expectedLiteral: "5"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),

            LexerTest(expectedType: .if, expectedLiteral: "if"),
            LexerTest(expectedType: .lparen, expectedLiteral: "("),
            LexerTest(expectedType: .int, expectedLiteral: "5"),
            LexerTest(expectedType: .lt, expectedLiteral: "<"),
            LexerTest(expectedType: .int, expectedLiteral: "10"),
            LexerTest(expectedType: .rparen, expectedLiteral: ")"),
            LexerTest(expectedType: .lbrace, expectedLiteral: "{"),
            LexerTest(expectedType: .return, expectedLiteral: "return"),
            LexerTest(expectedType: .true, expectedLiteral: "true"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),
            LexerTest(expectedType: .rbrace, expectedLiteral: "}"),
            LexerTest(expectedType: .else, expectedLiteral: "else"),
            LexerTest(expectedType: .lbrace, expectedLiteral: "{"),
            LexerTest(expectedType: .return, expectedLiteral: "return"),
            LexerTest(expectedType: .false, expectedLiteral: "false"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),
            LexerTest(expectedType: .rbrace, expectedLiteral: "}"),

            LexerTest(expectedType: .int, expectedLiteral: "10"),
            LexerTest(expectedType: .equal, expectedLiteral: "=="),
            LexerTest(expectedType: .int, expectedLiteral: "10"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),

            LexerTest(expectedType: .int, expectedLiteral: "10"),
            LexerTest(expectedType: .notEqual, expectedLiteral: "!="),
            LexerTest(expectedType: .int, expectedLiteral: "9"),
            LexerTest(expectedType: .semicolon, expectedLiteral: ";"),

            LexerTest(expectedType: .eof, expectedLiteral: ""),
        ]

        let l = Lexer(input: input)

        for test in tests {
            let token = l.nextToken()
            XCTAssertEqual(token.type, test.expectedType)
            XCTAssertEqual(token.literal, test.expectedLiteral)
        }
    }
    
}
