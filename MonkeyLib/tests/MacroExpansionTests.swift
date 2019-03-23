//
//  MacroExpansionTests.swift
//  MonkeyLibTests
//
//  Created by Rod Schmidt on 3/23/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation
import XCTest
@testable import MonkeyLib

class MacroExpansionTests: XCTestCase {

    override func setUp() {}

    override func tearDown() {}

    func testDefineMacros() {
        let input = """
            let number = 1;
            let function = fn(x, y) { x + y };
            let mymacro = macro(x, y) { x + y; };
        """

        let env = Environment()
        var program = testParseProgram(input)!

        defineMacros(&program, env)

        XCTAssertEqual(program.statements.count, 2)

        XCTAssertNil(env.get(name: "number"))
        XCTAssertNil(env.get(name: "function"))

        let macro = env.get(name: "mymacro") as? Macro
        XCTAssertNotNil(macro)
        XCTAssertEqual(macro?.parameters.count, 2)
        XCTAssertEqual(macro?.parameters[0].description, "x")
        XCTAssertEqual(macro?.parameters[1].description, "y")

        let expectedBody = "(x + y)"
        XCTAssertEqual(macro?.body.description, expectedBody)
    }

    func testExpandMacros() {
        struct Test {
            let input: String
            let expected: String
        }

        let tests = [
            Test(input: """
                            let infixExpression = macro() { quote(1 + 2); };
                            infixExpression();
                        """,
                 expected: "(1 + 2)"
            ),
            Test(input: """
                            let reverse = macro(a, b) { quote(unquote(b) - unquote(a)); };
                            reverse(2 + 2, 10 - 5);
                        """,
                 expected: "(10 - 5) - (2 + 2)"
            ),
            Test(input: """
                            let unless = macro(condition, consequence, alternative) {
                                quote(if (!(unquote(condition))) {
                                    unquote(consequence);
                                } else {
                                    unquote(alternative);
                                });
                            };

                            unless(10 > 5, puts("not greater"), puts("greater"));
                        """,
                 expected: "if (!(10 > 5)) { puts(\"not greater\") } else { puts(\"greater\") }"
            )
        ]

        for t in tests {
            let expected = testParseProgram(t.expected)!
            var program = testParseProgram(t.input)!

            let env = Environment()
            defineMacros(&program, env)
            let expanded = expandMacros(program, env)

            XCTAssertEqual(expanded.description, expected.description)
        }
    }

    private func testParseProgram(_ input: String) -> Program? {
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        return p.parseProgram()
    }
}
