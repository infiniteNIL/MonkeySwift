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
                token: Token(type: .let, literal: "let"),
                name: Identifier(
                    token: Token(type: .ident, literal: "myVar"),
                    value: "myVar"
                ),
                value: Identifier(
                    token: Token(type: .ident, literal: "anotherVar"),
                    value: "anotherVar"
                )
            )

        ])

        XCTAssertEqual(program.description, "let myVar = anotherVar;")
    }

}
