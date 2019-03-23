//
//  quoteUnquoteTests.swift
//  MonkeyLibTests
//
//  Created by Rod Schmidt on 3/20/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import XCTest
@testable import MonkeyLib

class QuoteUnquoteTests: XCTestCase {

    override func setUp() {}

    override func tearDown() {}

    func testQuote() {
        struct Test {
            let input: String
            let expected: String
        }

        let tests = [
            Test(input: "quote(5)", expected: "5"),
            Test(input: "quote(5 + 8)", expected: "(5 + 8)"),
            Test(input: "quote(foobar)", expected: "foobar"),
            Test(input: "quote(foobar + barfoo)", expected: "(foobar + barfoo)"),
            Test(input: "let foobar = 8; quote(foobar)", expected: "foobar"),
            Test(input: "let foobar = 8; quote(unquote(foobar))", expected: "8"),
            Test(input: "quote(unquote(true))", expected: "true"),
            Test(input: "quote(unquote(true == false))", expected: "false"),
            Test(input: "quote(unquote(quote(4 + 4)))", expected: "(4 + 4)"),
            Test(input: "let quotedInfixExpression = quote(4 + 4); quote(unquote(4 + 4) + unquote(quotedInfixExpression))",
                 expected: "(8 + (4 + 4))"),
        ]

        for t in tests {
            let evaluated = testEval(t.input)
            let quote = evaluated as? MonkeyQuote
            XCTAssertNotNil(quote, "expected MonkeyQuote. got=\(String(describing: evaluated))")
            XCTAssertNotNil(quote?.node, "quote.node is nil")
            XCTAssertEqual(quote?.node.description, t.expected, "not equal. got=\(String(describing: quote?.node.description)), want=\(t.expected)")
        }
    }

    func testQuoteUnquote() {
        struct Test {
            let input: String
            let expected: String
        }

        let tests = [
            Test(input: "quote(unquote(4))", expected: "4"),
            Test(input: "quote(unquote(4 + 4))", expected: "8"),
            Test(input: "quote(8 + unquote(4 + 4))", expected: "(8 + 8)"),
            Test(input: "quote(unquote(4 + 4) + 8)", expected: "(8 + 8)"),
        ]

        for t in tests {
            let evaluated = testEval(t.input)
            let quote = evaluated as? MonkeyQuote
            XCTAssertNotNil(quote, "expected MonkeyQuote. got=\(String(describing: evaluated))")
            XCTAssertNotNil(quote?.node, "quote.node is nil")
            XCTAssertEqual(quote?.node.description, t.expected, "not equal. got=\(String(describing: quote?.node.description)), want=\(t.expected)")
        }
    }

}
