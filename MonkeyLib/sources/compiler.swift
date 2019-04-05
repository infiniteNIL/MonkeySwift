//
//  compiler.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/24/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

class Compiler {
    private var instructions: Instructions
    private var constants: [MonkeyObject]

    init() {
        instructions = []
        constants = []
    }
    
    func compile(node: Node) throws {
        switch node {
        case is Program:
            let program = node as! Program
            for s in program.statements {
                try compile(node: s)
            }

        case is ExpressionStatement:
            let expressionStatment = node as! ExpressionStatement
            guard let expr = expressionStatment.expression else {
                fatalError("Expresssion statement has no expression")
            }
            try compile(node: expr)
            _ = emit(op: .pop, operands: [])

        case is InfixExpression:
            let infix = node as! InfixExpression
            try compile(node: infix.left)

            guard let right = infix.right else {
                fatalError("Infix expression has no right hand side")
            }
            try compile(node: right)

            switch infix.operator {
            case "+":   _ = emit(op: .add, operands: [])
            case "-":   _ = emit(op: .sub, operands: [])
            case "*":   _ = emit(op: .mul, operands: [])
            case "/":   _ = emit(op: .div, operands: [])

            default:
                fatalError("Unknown operator \(infix.operator)")
            }

        case is IntegerLiteral:
            let intLiteral = node as! IntegerLiteral
            let integer = MonkeyInteger(value: intLiteral.value)
            _ = emit(op: .constant, operands: [addConstant(obj: integer)])

        default:
            ()
        }
    }

    func bytecode() -> Bytecode {
        return Bytecode(instructions: instructions, constants: constants)
    }

    private func addConstant(obj: MonkeyObject) -> UInt16 {
        constants.append(obj)
        return UInt16(constants.count - 1)
    }

    func emit(op: Opcode, operands: [UInt16]) -> UInt16 {
        let ins = make(op: op, operands: operands)
        return addInstruction(ins)
    }

    private func addInstruction(_ ins: [UInt8]) -> UInt16 {
        let posNewInstruction = instructions.count
        instructions += ins
        return UInt16(posNewInstruction)
    }
}

struct Bytecode {
    let instructions: Instructions
    let constants: [MonkeyObject]
}
