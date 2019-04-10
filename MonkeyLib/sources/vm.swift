//
//  vm.swift
//  Monkey
//
//  Created by Rod Schmidt on 4/5/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

private let StackSize = 2048
public let GlobalConstantsSize = 65536
private let MaxFrames = 1024

enum MonkeyVMError: Error {
    case stackOverflow
    case unsupportTypesForBinaryOperation(MonkeyObjectType, MonkeyObjectType)
    case unknownStringOperator(UInt8)
    case wrongNumberOfArguments(Int)
}

class MonkeyVM {
    private let constants: [MonkeyObject]
    private var stack: [MonkeyObject]
    private var sp: Int // Always points to the next value. Top of stack is stack[sp-1]
    private(set) var globals: [MonkeyObject?]
    private var frames: [Frame] = []
    private var frameIndex: Int = 0

    init(bytecode: Bytecode) {
        constants = bytecode.constants
        stack = [MonkeyObject](repeating: MonkeyNull(), count: StackSize)
        sp = 0
        globals = [MonkeyObject?](repeating: nil, count: GlobalConstantsSize)

        let mainFn = CompiledFunction(instructions: bytecode.instructions, numLocals: 0, numParameters: 0)
        let mainFrame = Frame(fn: mainFn, basePointer: 0)

        frames.append(mainFrame)
        frameIndex = 1
    }

    convenience init(bytecode: Bytecode, globals: [MonkeyObject?]) {
        self.init(bytecode: bytecode)
        self.globals = globals
    }

    private func currentFrame() -> Frame {
        return frames[frameIndex - 1]
    }

    private func pushFrame(_ f: Frame) {
        frames.append(f)
        frameIndex += 1
    }

    @discardableResult
    private func popFrame() -> Frame {
        frameIndex -= 1
        return frames.removeLast()
    }

    func lastPopppedStackElem() -> MonkeyObject {
        return stack[sp]
    }

    func run() throws {
        while currentFrame().ip < currentFrame().instructions().count - 1 {
            currentFrame().ip += 1

            let ip = self.currentFrame().ip
            var ins = self.currentFrame().instructions()

            guard let op = Opcode(rawValue: ins[ip]) else {
                fatalError("Invalid opcode passed to VM")
            }

            switch op {
            case .constant:
                let bytes = Array(ins[(ip + 1)...])
                let constIndex = Int(readUInt16(bytes))
                currentFrame().ip += 2
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
                let bytes = Array(ins[(ip + 1)...])
                let pos = Int(readUInt16(bytes))
                currentFrame().ip += 2
                let condition = pop()
                if !isTruthy(condition) {
                    currentFrame().ip = pos - 1
                }

            case .jump:
                let bytes = Array(ins[(ip + 1)...])
                let pos = Int(readUInt16(bytes))
                currentFrame().ip = pos - 1

            case .setGlobal:
                let bytes = Array(ins[(ip + 1)...])
                let globalIndex = Int(readUInt16(bytes))
                currentFrame().ip += 2
                globals[globalIndex] = pop()

            case .getGlobal: ()
                let bytes = Array(ins[(ip + 1)...])
                let globalIndex = Int(readUInt16(bytes))
                currentFrame().ip += 2
                if let global = globals[globalIndex] {
                    try push(global)
                }
                else {
                    fatalError("Invalid global index")
                }

            case .array:
                let bytes = Array(ins[(ip + 1)...])
                let numElements = Int(readUInt16(bytes))
                currentFrame().ip += 2

                let array = buildArray(sp - numElements, sp)
                sp = sp - numElements
                try push(array)

            case .hash:
                let bytes = Array(ins[(ip + 1)...])
                let numElements = Int(readUInt16(bytes))
                currentFrame().ip += 2

                let hash = buildHash(sp - numElements, sp)
                sp = sp - numElements
                try push(hash)

            case .index:
                let index = pop()
                let left = pop()
                try executeIndexExpression(left, index)

            case .call:
                let bytes = Array(ins[(ip + 1)...])
                let numArgs = Int(readUInt8(bytes))
                currentFrame().ip += 1
                try callFunction(Int(numArgs))

            case .returnValue:
                let returnValue = pop()
                let frame = popFrame()
                sp = frame.basePointer - 1
                try push(returnValue)

            case .return:
                let frame = popFrame()
                sp = frame.basePointer - 1
                try push(Null)

            case .setLocal:
                let bytes = Array(ins[(ip + 1)...])
                let localIndex = readUInt8(bytes)
                currentFrame().ip += 1
                let frame = currentFrame()
                stack[frame.basePointer + Int(localIndex)] = pop()

            case .getLocal:
                let bytes = Array(ins[(ip + 1)...])
                let localIndex = readUInt8(bytes)
                currentFrame().ip += 1
                let frame = currentFrame()
                try push(stack[frame.basePointer + Int(localIndex)])

            case .getBuiltin:
                ()
            }
        }
    }

    private func callFunction(_ numArgs: Int) throws {
        guard let fn = stack[sp - 1 - numArgs] as? CompiledFunction else {
            fatalError("CompiledFunction not on top of stack")
        }

        guard numArgs == fn.numParameters else {
            throw MonkeyVMError.wrongNumberOfArguments(numArgs)
        }

        let frame = Frame(fn: fn, basePointer: sp - numArgs)
        pushFrame(frame)
        sp = frame.basePointer + fn.numLocals
    }

    private func executeIndexExpression(_ left: MonkeyObject, _ index: MonkeyObject) throws {
        if left.type() == .arrayObj && index.type() == .integerObj {
            try executeArrayIndex(left, index)
        }
        else if left.type() == .hashObj {
            try executeHashIndex(left, index)
        }
        else {
            fatalError("index operator not supported: \(left.type())")
        }
    }

    private func executeArrayIndex(_ array: MonkeyObject, _ index: MonkeyObject) throws {
        let arrayObject = array as! MonkeyArray
        let i = (index as! MonkeyInteger).value
        let max = arrayObject.elements.count - 1
        if i < 0 || i > max {
            try push(Null)
        }
        else {
            try push(arrayObject.elements[i])
        }
    }

    private func executeHashIndex(_ hash: MonkeyObject, _ index: MonkeyObject) throws {
        let hashObject = hash as! MonkeyHash
        guard let key = index as? MonkeyHashable else {
            fatalError("Unusable as hash key: \(index.type())")
        }
        
        if let pair = hashObject.pairs[key.hashKey()] {
            try push(pair.value)
        }
        else {
            try push(Null)
        }
    }

    private func buildHash(_ startIndex: Int, _ endIndex: Int) -> MonkeyObject {
        var hashedPairs = [HashKey: HashPair]()

        var i = startIndex
        while i < endIndex {
            let key = stack[i]
            let value = stack[i + 1]
            let pair = HashPair(key: key, value: value)
            if let hashKey = key as? MonkeyHashable {
                hashedPairs[hashKey.hashKey()] = pair
            }
            else {
                fatalError("unusable as hash key: \(key.type())")
            }

            i += 2
        }

        return MonkeyHash(pairs: hashedPairs)
    }

    private func buildArray(_ startIndex: Int, _ endIndex: Int) -> MonkeyObject {
        var elements = [MonkeyObject?].init(repeating: nil, count: endIndex - startIndex)
        for i in startIndex..<endIndex {
            elements[i - startIndex] = stack[i]
        }
        return MonkeyArray(elements: elements as! [MonkeyObject])
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
        }
        else if leftType == .stringObj && rightType == .stringObj {
            try executeBinaryStringOperation(op, left, right)
        }
        else {
            throw MonkeyVMError.unsupportTypesForBinaryOperation(leftType, rightType)
        }
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

    private func executeBinaryStringOperation(_ op: Opcode, _ left: MonkeyObject, _ right: MonkeyObject) throws {
        guard op == .add else { throw MonkeyVMError.unknownStringOperator(op.rawValue) }

        let leftValue = (left as! MonkeyString).value
        let rightValue = (right as! MonkeyString).value
        try push(MonkeyString(value: leftValue + rightValue))
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
