//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Alexander Kompch on 03.11.15.
//  Copyright (c) 2015 Alexander Kompch. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable  //enums can have functions and computed properties
        //in SWIFT you can associate data with the cases in the enum
    {
        case Operand(Double) //in case enum is an operand a double is associated with it, that is the actual value of the operand
        case UnaryOperation(String, Double -> Double) //String will be the mathematical symbol, and a function
        case BinaryOperation(String, (Double, Double) -> Double)
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol,_):
                    return symbol
                    
                }
            }
        }
    }
    
    
    private var opStack = [Op]() //empty Array of Op named opStack to store operand and operations; Array of Op(s) and these ops are either Operand or one of the two Operations; () is caling an initializer in Array
    
    private let knownOps = [String:Op]() //instance variable of type Dictionary <Key>:<Value type>; the () is calling an initializer in Dictionary
    
    init() {  // an initializer in CalculatorBrain that has no arguments
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√") { sqrt($0) }
    }
    
    private func evaluate(ops: [Op]) -> (result:Double?, remainingOps:[Op]) {
        if !ops.isEmpty {
            var remaingOps = ops  //ops is passed by value when evalute is called and is set immutable; so a local mutable copy of that array needs to be made of it to pull values of the stack
            let op = remaingOps.removeLast()
            switch op {  //switch is how you pull associated vales out of enum
            case Op.Operand(let operand): //let the associated value be assigned to a constant named operand; var is also possible instead of let
                return (operand, remaingOps) //operand is an end case in the recursion; evaluate is done
            case Op.UnaryOperation(_, let operation):  //the actual symbol in this case is irrelevant, just the operation (Double -> Double) is needed
                let operandEvaluation = evaluate(remaingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case Op.BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remaingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand (operand: Double) -> Double? {
        opStack.append(Op.Operand(operand)) //appends operand to the stack and assiciates the value for operand with it
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] { //look the passed Symbol up in knownOps; the return type <operation> is an <Optional Op>
            opStack.append(operation)
        }
    return evaluate()
    }
    
}
