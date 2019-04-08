//
//  vm.swift
//  Monkey
//
//  Created by Rod Schmidt on 4/5/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

private let StackSize = 2048

enum MonkeyVMError: Error {
    case stackOverflow
    case unsupportTypesForBinaryOperation(MonkeyObjectType, MonkeyObjectType)
}

class MonkeyVM {
    let constants: [MonkeyObject]
    let instructions: Instructions
    var stack: [MonkeyObject]
    var sp: Int // Always points to the next value. Top of stack is stack[sp-1]

    init(bytecode: Bytecode) {
        instructions = bytecode.instructions
        constants = bytecode.constants
        stack = [MonkeyObject](repeating: MonkeyNull(), count: StackSize)
        sp = 0
    }

    func lastPopppedStackElem() -> MonkeyObject {
        return stack[sp]
    }

    func run() throws {
        var ip = 0
        while ip < instructions.count {
            guard let op = Opcode(rawValue: instructions[ip]) else {
                fatalError("Invalid opcode passed to VM")
            }

            switch op {
            case .constant:
                let bytes = Array(instructions[(ip + 1)...])
                let constIndex = Int(readUInt16(bytes))
                ip += 2
                try push(constants[constIndex])

            case .add, .sub, .mul, .div:
                try executeBinaryOperation(op)

            case .pop:
                pop()

            case .pushTrue:
                try push(True)

            case .pushFalse:
                try push(False)

            case .null:
                try push(Null)

            case .equal, .notEqual, .greaterThan:
                try executeComparison(op)

            case .bang:
                try executeBangOperator()

            case .minus:
                try executeMinusOperator()

            case .jumpNotTruthy:
                let bytes = Array(instructions[(ip + 1)...])
                let pos = Int(readUInt16(bytes))
                ip += 2
                let condition = pop()
                if !isTruthy(condition) {
                    ip = pos - 1
                }

            case .jump:
                let bytes = Array(instructions[(ip + 1)...])
                let pos = Int(readUInt16(bytes))
                ip = pos - 1

            case .getGlobal, .setGlobal: ()
            }

            ip += 1
        }
    }

    private func isTruthy(_ obj: MonkeyObject) -> Bool {
        switch obj.type() {
        case .booleanObj:   return (obj as! MonkeyBoolean).value
        case .nullObj:      return false

        default:
            return true
        }
    }

    private func executeMinusOperator() throws {
        let operand = pop()
        guard operand.type() == .integerObj else {
            fatalError("Unsupported type for negation")
        }

        let value = (operand as! MonkeyInteger).value
        try push(MonkeyInteger(value: -value))
    }

    private func executeBangOperator() throws {
        let operand = pop()

        if let bool = operand as? MonkeyBoolean {
            if bool == True {
                try push(False)
            }
            else {
                try push(True)
            }
        }
        else if operand as? MonkeyNull != nil {
            try push(True)
        }
        else {
            try push(False)
        }
    }

    private func executeComparison(_ op: Opcode) throws {
        let right = pop()
        let left = pop()

        if left.type() == .integerObj && right.type() == .integerObj {
            try executeIntegerComparison(op, left, right)
            return
        }

        let rhs = (right as! MonkeyBoolean).value
        let lhs = (left as! MonkeyBoolean).value

        switch op {
        case .equal:    return try push(nativeBoolToBooleanObject(rhs == lhs))
        case .notEqual: return try push(nativeBoolToBooleanObject(rhs != lhs))

        default:
            fatalError("Invalid operator \(op) for comparison")
        }
    }

    private func executeIntegerComparison(_ op: Opcode, _ left: MonkeyObject, _ right: MonkeyObject) throws {
        let leftValue = (left as! MonkeyInteger).value
        let rightValue = (right as! MonkeyInteger).value

        switch op {
        case .equal:        try push(nativeBoolToBooleanObject(rightValue == leftValue))
        case .notEqual:     try push(nativeBoolToBooleanObject(rightValue != leftValue))
        case .greaterThan:  try push(nativeBoolToBooleanObject(leftValue > rightValue))

        default:
            fatalError("Invalid operation: \(op)")
        }
    }

    private func nativeBoolToBooleanObject(_ input: Bool) -> MonkeyBoolean {
        return input ? True : False
    }

    private func executeBinaryOperation(_ op: Opcode) throws {
        let right = pop()
        let left = pop()

        let leftType = left.type()
        let rightType = right.type()

        if leftType == .integerObj && rightType == .integerObj {
            try executeBinaryIntegerOperation(op, left, right)
            return
        }

        throw MonkeyVMError.unsupportTypesForBinaryOperation(leftType, rightType)
    }

    private func executeBinaryIntegerOperation(_ op: Opcode, _ left: MonkeyObject, _ right: MonkeyObject) throws {
        let leftValue = (left as! MonkeyInteger).value
        let rightValue = (right as! MonkeyInteger).value
        let result: Int

        switch op {
        case .add: result = leftValue + rightValue
        case .sub: result = leftValue - rightValue
        case .mul: result = leftValue * rightValue
        case .div: result = leftValue / rightValue
        default:
            fatalError("Invalid integer operator: \(op)")
        }

        try push(MonkeyInteger(value: result))
    }

    private func push(_ o: MonkeyObject) throws {
        guard sp < StackSize else { throw MonkeyVMError.stackOverflow }

        stack[sp] = o
        sp += 1
    }

    @discardableResult
    private func pop() -> MonkeyObject {
        let o = stack[sp - 1]
        sp -= 1
        return o
    }
}
