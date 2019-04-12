//
//  ASTTests.swift
//  MerlinLibTests
//
//  Created by Rod Schmidt on 8/11/18.
//

import XCTest
@testable import MonkeyLib

class ASTTests: XCTestCase {

    func testCustomStringConvertible() {
        let program = Program(statements: [
            LetStatement(
                token: Token(.let, "let"),
                name: Identifier(
                    token: Token(.ident, "myVar"),
                    value: "myVar"
                ),
                value: Identifier(
                    token: Token(.ident, "anotherVar"),
                    value: "anotherVar"
                )
            )

        ])

        XCTAssertEqual(program.description, "let myVar = anotherVar;")
    }

}
