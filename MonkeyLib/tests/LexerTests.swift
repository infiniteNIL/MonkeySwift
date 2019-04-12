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

    struct Test {
        let expectedType: TokenType
        let expectedLiteral: String

        init(_ type: TokenType, _ literal: String) {
            expectedType = type
            expectedLiteral = literal
        }
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
            "foobar"
            "foo bar"
            [1, 2];
            {"foo": "bar"}
            macro(x, y) { x + y; };
        """

        let tests = [
            Test(.let, "let"),
            Test(.ident, "five"),
            Test(.assign, "="),
            Test(.int, "5"),
            Test(.semicolon, ";"),
            Test(.let, "let"),
            Test(.ident, "ten"),
            Test(.assign, "="),
            Test(.int, "10"),
            Test(.semicolon, ";"),
            Test(.let, "let"),
            Test(.ident, "add"),
            Test(.assign, "="),
            Test(.function, "fn"),
            Test(.lparen, "("),
            Test(.ident, "x"),
            Test(.comma, ","),
            Test(.ident, "y"),
            Test(.rparen, ")"),
            Test(.lbrace, "{"),
            Test(.ident, "x"),
            Test(.plus, "+"),
            Test(.ident, "y"),
            Test(.semicolon, ";"),
            Test(.rbrace, "}"),
            Test(.semicolon, ";"),
            Test(.let, "let"),
            Test(.ident, "result"),
            Test(.assign, "="),
            Test(.ident, "add"),
            Test(.lparen, "("),
            Test(.ident, "five"),
            Test(.comma, ","),
            Test(.int, "10"),
            Test(.rparen, ")"),
            Test(.semicolon, ";"),

            Test(.bang, "!"),
            Test(.minus, "-"),
            Test(.slash, "/"),
            Test(.asterisk, "*"),
            Test(.int, "5"),
            Test(.semicolon, ";"),

            Test(.int, "5"),
            Test(.lt, "<"),
            Test(.int, "10"),
            Test(.gt, ">"),
            Test(.int, "5"),
            Test(.semicolon, ";"),

            Test(.if, "if"),
            Test(.lparen, "("),
            Test(.int, "5"),
            Test(.lt, "<"),
            Test(.int, "10"),
            Test(.rparen, ")"),
            Test(.lbrace, "{"),
            Test(.return, "return"),
            Test(.true, "true"),
            Test(.semicolon, ";"),
            Test(.rbrace, "}"),
            Test(.else, "else"),
            Test(.lbrace, "{"),
            Test(.return, "return"),
            Test(.false, "false"),
            Test(.semicolon, ";"),
            Test(.rbrace, "}"),

            Test(.int, "10"),
            Test(.equal, "=="),
            Test(.int, "10"),
            Test(.semicolon, ";"),

            Test(.int, "10"),
            Test(.notEqual, "!="),
            Test(.int, "9"),
            Test(.semicolon, ";"),

            Test(.string, "foobar"),
            Test(.string, "foo bar"),

            Test(.lbracket, "["),
            Test(.int, "1"),
            Test(.comma, ","),
            Test(.int, "2"),
            Test(.rbracket, "]"),
            Test(.semicolon, ";"),

            Test(.lbrace, "{"),
            Test(.string, "foo"),
            Test(.colon, ":"),
            Test(.string, "bar"),
            Test(.rbrace, "}"),

            Test(.macro, "macro"),
            Test(.lparen, "("),
            Test(.ident, "x"),
            Test(.comma, ","),
            Test(.ident, "y"),
            Test(.rparen, ")"),
            Test(.lbrace, "{"),
            Test(.ident, "x"),
            Test(.plus, "+"),
            Test(.ident, "y"),
            Test(.semicolon, ";"),
            Test(.rbrace, "}"),
            Test(.semicolon, ";"),

            Test(.eof, ""),
        ]

        let l = Lexer(input: input)

        for test in tests {
            let token = l.nextToken()
            XCTAssertEqual(token.type, test.expectedType)
            XCTAssertEqual(token.literal, test.expectedLiteral)
        }
    }
    
}
