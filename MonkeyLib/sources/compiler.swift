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
            emit(op: .pop, operands: [])

        case is PrefixExpression:
            let prefix = node as! PrefixExpression
            guard let right = prefix.right else {
                fatalError("prefix expression has no right hand side")
            }
            try compile(node: right)

            switch prefix.operator {
            case "!": emit(op: .bang, operands: [])
            case "-": emit(op: .minus, operands: [])
            default:
                fatalError("Invalid prefix operator: \(prefix.operator)")
            }

        case is InfixExpression:
            let infix = node as! InfixExpression
            guard let right = infix.right else {
                fatalError("Infix expression has no right hand side")
            }
            if infix.operator == "<" {
                try compile(node: right)
                try compile(node: infix.left)
                emit(op: .greaterThan, operands: [])
                return
            }

            try compile(node: infix.left)
            try compile(node: right)

            switch infix.operator {
            case "+":   emit(op: .add, operands: [])
            case "-":   emit(op: .sub, operands: [])
            case "*":   emit(op: .mul, operands: [])
            case "/":   emit(op: .div, operands: [])
            case ">":   emit(op: .greaterThan, operands: [])
            case "==":  emit(op: .equal, operands: [])
            case "!=":  emit(op: .notEqual, operands: [])

            default:
                fatalError("Unknown operator \(infix.operator)")
            }

        case is IntegerLiteral:
            let intLiteral = node as! IntegerLiteral
            let integer = MonkeyInteger(value: intLiteral.value)
            _ = emit(op: .constant, operands: [addConstant(obj: integer)])

        case is BooleanLiteral:
            let boolLiteral = node as! BooleanLiteral
            emit(op: boolLiteral.value ? .pushTrue : .pushFalse, operands: [])

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

    @discardableResult
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
