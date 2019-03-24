//
//  CodeTests.swift
//  MonkeyLibTests
//
//  Created by Rod Schmidt on 3/23/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import XCTest
@testable import MonkeyLib

class CodeTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testMake() {
        struct Test {
            let op: Opcode
            let operands: [UInt16]
            let expected: [UInt8]
        }

        let tests = [
            Test(op: .opConstant, operands: [65534], expected: [Opcode.opConstant.rawValue, 255, 254])
        ]

        for t in tests {
            let instruction = make(op: t.op, operands: t.operands)
            XCTAssertEqual(instruction.count, t.expected.count)

            for (i, _) in t.expected.enumerated() {
                XCTAssertEqual(instruction[i], t.expected[i])
            }
        }
    }

}
