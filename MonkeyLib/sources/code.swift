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
    case constant
    case add
    case pop
    case sub
    case mul
    case div
    case pushTrue
    case pushFalse
    case equal
    case notEqual
    case greaterThan
    case minus
    case bang
    case jumpNotTruthy
    case jump
    case null
    case getGlobal
    case setGlobal
    case array
}

struct Definition {
    let name: String
    let operandWidths: [Int]
}

let definitions: [Opcode: Definition] = [
    .constant:      Definition(name: "Constant", operandWidths: [2]),
    .add:           Definition(name: "Add", operandWidths: []),
    .pop:           Definition(name: "Pop", operandWidths: []),
    .sub:           Definition(name: "Sub", operandWidths: []),
    .mul:           Definition(name: "Mul", operandWidths: []),
    .div:           Definition(name: "Div", operandWidths: []),
    .pushTrue:      Definition(name: "True", operandWidths: []),
    .pushFalse:     Definition(name: "False", operandWidths: []),
    .equal:         Definition(name: "Equal", operandWidths: []),
    .notEqual:      Definition(name: "NotEqual", operandWidths: []),
    .greaterThan:   Definition(name: "GreaterThan", operandWidths: []),
    .minus:         Definition(name: "Minus", operandWidths: []),
    .bang:          Definition(name: "Bang", operandWidths: []),
    .jumpNotTruthy: Definition(name: "JumpNotTruthy", operandWidths: [2]),
    .jump:          Definition(name: "Jump", operandWidths: [2]),
    .null:          Definition(name: "Null", operandWidths: []),
    .getGlobal:     Definition(name: "GetGlobal", operandWidths: [2]),
    .setGlobal:     Definition(name: "SetGlobal", operandWidths: [2]),
    .array:         Definition(name: "Array", operandWidths: [2]),
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

func string(instructions: Instructions) -> String {
    var out = ""

    var i = 0
    while i < instructions.count {
        guard let def = lookup(op: instructions[i]) else {
            print("ERROR: \(instructions[i])")
            continue
        }

        let (operands, read) = readOperands(def: def, ins: Array(instructions[(i+1)...]))
        out = out.appendingFormat("%04d %@\n", i, formatInstruction(def, operands))

        i += 1 + read
    }

    return out
}

private func formatInstruction(_ def: Definition, _ operands: [Int]) -> String {
    let operandCount = def.operandWidths.count
    guard operands.count == operandCount else {
        return "ERROR: operand len \(operands.count) does not match defined \(operandCount)\n"
    }

    switch operandCount {
    case 0: return def.name
    case 1: return "\(def.name) \(operands[0])"

    default:
        break
    }

    return "ERROR: unhandled operandCount for \(def.name)\n"
}

func readOperands(def: Definition, ins: Instructions) -> ([Int], Int) {
    var operands = Array<Int>(repeating: 0, count: def.operandWidths.count)
    var offset = 0

    for (i, width) in def.operandWidths.enumerated() {
        switch width {
        case 2:
            operands[i] = Int(readUInt16(Array(ins[offset...])))

        default:
            break
        }

        offset += width
    }

    return (operands, offset)
}

func readUInt16(_ ins: Instructions) -> UInt16 {
    return UInt16(ins[1]) | UInt16(ins[0]) << 8
}
