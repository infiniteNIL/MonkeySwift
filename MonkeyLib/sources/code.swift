//
//  code.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/23/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

typealias Instructions = [UInt8]

enum Opcode: UInt8 {
    case opConstant
}

struct Definition {
    let name: String
    let operandWidths: [Int]
}

let definitions: [Opcode: Definition] = [
    .opConstant: Definition(name: "OpConstant", operandWidths: [2])
]

func lookup(op: UInt8) -> Definition? {
    guard let opcode = Opcode(rawValue: op) else {
        fatalError("Invalid opcode: \(op)")
    }
    return definitions[opcode]
}

func make(op: Opcode, operands: [UInt16]) -> [UInt8] {
    guard let def = definitions[op] else { return [] }

    var instructionLen = 1
    for w in def.operandWidths {
        instructionLen += w
    }

    var instruction = Array<UInt8>(repeating: 0, count: instructionLen)
    instruction[0] = op.rawValue

    var offset = 1
    for (i, o) in operands.enumerated() {
        let width = def.operandWidths[i]
        switch width {
        case 2:
            instruction[offset] = UInt8(o >> 8)
            instruction[offset + 1] = UInt8(o & 0x00ff)

        default:
            break
        }
        offset += width
    }

    return instruction
}
