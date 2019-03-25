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

    func testInstructionsString() {
        let instructions = [
            make(op: .opConstant, operands: [1]),
            make(op: .opConstant, operands: [2]),
            make(op: .opConstant, operands: [65535])
        ]
        let expected = """
            0000 OpConstant 1
            0003 OpConstant 2
            0006 Opconstant 65535
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
            Test(op: .opConstant, operands: [65535], bytesRead: 2)
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
