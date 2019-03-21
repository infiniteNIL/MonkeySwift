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
