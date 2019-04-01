//
//  compiler.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/24/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

struct Compiler {
    private var instructions: Instructions
    private var constants: [MonkeyObject]

    init() {
        instructions = []
        constants = []
    }
    
    mutating func compile(node: Node) -> Bool {
        switch node {
        case is Program:
            let program = node as! Program
            for s in program.statements {
                if !compile(node: s) {
                    return false
                }
            }

        case is ExpressionStatement:
            let expressionStatment = node as! ExpressionStatement
            guard let expr = expressionStatment.expression else { return false }
            if !compile(node: expr) {
                return false
            }

        case is InfixExpression:
            let infix = node as! InfixExpression
            if !compile(node: infix.left) {
                return false
            }

            guard let right = infix.right else { return false }
            if !compile(node: right) {
                return false
            }

        case is IntegerLiteral:
            let intLiteral = node as! IntegerLiteral
            let integer = MonkeyInteger(value: intLiteral.value)
            _ = emit(op: .opConstant, operands: [addConstant(obj: integer)])

        default:
            return false
        }

        return true
    }

    func bytecode() -> Bytecode {
        return Bytecode(instructions: instructions, constants: constants)
    }

    mutating private func addConstant(obj: MonkeyObject) -> UInt16 {
        constants.append(obj)
        return UInt16(constants.count - 1)
    }

    mutating func emit(op: Opcode, operands: [UInt16]) -> UInt16 {
        let ins = make(op: op, operands: operands)
        return addInstruction(ins)
    }

    mutating private func addInstruction(_ ins: [UInt8]) -> UInt16 {
        let posNewInstruction = instructions.count
        instructions += ins
        return UInt16(posNewInstruction)
    }
}

struct Bytecode {
    let instructions: Instructions
    let constants: [MonkeyObject]
}
