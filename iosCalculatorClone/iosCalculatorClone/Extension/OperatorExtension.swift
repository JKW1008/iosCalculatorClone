//
//  OperatorExtension.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/22/25.
//

import UIKit

class CalculatorBrain {
    private var currentValue: Double = 0
    private var previousValue: Double = 0
    private var pendingOperation: SelectedOperator?
    private var isWaitingForSecondOperand: Bool = false
    
    func setOperand(_ operand: Double) {
        currentValue = operand
        isWaitingForSecondOperand = false
        
        print("set operand \(operand)")
    }
    
    func performOperation(_ operation: SelectedOperator) {
        switch operation {
            case .plus, .minus, .multiply, .divide:
                handlBinaryOperation(operation)
            case .equal:
                handleEqualOperation()
        }
    }
    
    func getResult() -> Double {
        return currentValue
    }
    
    func clear() {
        currentValue = 0
        previousValue = 0
        pendingOperation = nil
        isWaitingForSecondOperand = false
    }
    
    func getPendingOperation() -> SelectedOperator? {
        return pendingOperation
    }
    
    private func handlBinaryOperation(_ operation: SelectedOperator) {
        if let pendingOp = pendingOperation, !isWaitingForSecondOperand {
            executeCalculation(pendingOp)
        } else {
            previousValue = currentValue
        }
        pendingOperation = operation
        isWaitingForSecondOperand = true
    }
    
    private func handleEqualOperation() {
        if let pendingOp = pendingOperation, !isWaitingForSecondOperand {
            executeCalculation(pendingOp)
            pendingOperation = nil
            isWaitingForSecondOperand = true
        }
    }
    
    private func executeCalculation(_ operation: SelectedOperator) {
        let result: Double
        
        switch operation {
            case .plus: result = previousValue + currentValue
            case .minus: result = previousValue - currentValue
            case .multiply: result = previousValue * currentValue
            case .divide:
                if currentValue == 0 {
                    result = 0
                } else {
                    result = previousValue / currentValue
                }
            case .equal:
                result = currentValue
        }
        currentValue = result
        previousValue = result
    }
    
}

extension CalculatorBrain {
    static func operationFromString(_ operatorString: String) -> SelectedOperator? {
        return SelectedOperator.fromString(operatorString)
    }
}
