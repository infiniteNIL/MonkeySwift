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
            Test(op: .constant, operands: [65534], expected: [Opcode.constant.rawValue, 255, 254]),
            Test(op: .add, operands: [], expected: [Opcode.add.rawValue])
        ]

        for t in tests {
            let instruction = make(op: t.op, operands: t.operands)
            XCTAssertEqual(instruction.count, t.expected.count)

            for (i, _) in t.expected.enumerated() {
                XCTAssertEqual(instruction[i], t.expected[i])
            }
        }
    }

    func testInstructionsString() {
        let instructions = [
            make(op:. add, operands: []),
            make(op: .constant, operands: [2]),
            make(op: .constant, operands: [65535])
        ]
        let expected = """
            0000 Add
            0001 Constant 2
            0004 Constant 65535\n
            """

        var concatted = Instructions()
        for ins in instructions {
            concatted += ins
        }

        XCTAssertEqual(string(instructions: concatted), expected)
    }

    func testReadOperands() {
        struct Test {
            let op: Opcode
            let operands: [UInt16]
            let bytesRead: Int
        }

        let tests = [
            Test(op: .constant, operands: [65535], bytesRead: 2)
        ]

        for t in tests {
            let instruction = make(op: t.op, operands: t.operands)

            let def = lookup(op: t.op.rawValue)
            XCTAssertNotNil(def)

            let (operandsRead, n) = readOperands(def: def!, ins: Array(instruction.dropFirst()))
            XCTAssertEqual(n, t.bytesRead)

            for (i, want) in t.operands.enumerated() {
                XCTAssertEqual(operandsRead[i], Int(want))
            }
        }
    }

}
