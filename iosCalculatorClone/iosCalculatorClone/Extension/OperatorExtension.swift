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
        if pendingOperation != nil && isWaitingForSecondOperand {
             isWaitingForSecondOperand = false
             print("🔢 Set isWaitingForSecondOperand = false")
         }
         
         print("🔢 setOperand: previous=\(previousValue), current=\(currentValue), pending=\(pendingOperation?.symbol ?? "nil"), waiting=\(isWaitingForSecondOperand)")
         
         // 디버깅: 수식 확인
         if let expression = getDisplayExpression() {
             print("🔢 Expression should be: '\(expression)'")
         }
        print("set operand \(operand)")
    }
    
    func getDisplayExpression() -> String? {
        print("🔢 getDisplayExpression called:")
        print("🔢 - pendingOperation: \(pendingOperation?.symbol ?? "nil")")
        print("🔢 - isWaitingForSecondOperand: \(isWaitingForSecondOperand)")
        guard let operation = pendingOperation else {
            print("🔢 - Returning nil (no operation or waiting)")

            return nil }
        
        if isWaitingForSecondOperand {
            return "\(formatNumber(previousValue))\(operation.symbol)"
        } else {
            return "\(formatNumber(previousValue))\(operation.symbol)\(formatNumber(currentValue))"
        }
    }
    
    func getpreviousValue() -> String? {
        return String(previousValue)
    }
    
    private func formatNumber(_ value: Double) -> String {

        if value.truncatingRemainder(dividingBy: 1) == 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            
            if let formattedString = formatter.string(from: NSNumber(value: value)) {
                return formattedString
            }
        }
        return String(value)
    }
    
    func performOperation(_ operation: SelectedOperator) {
        switch operation {
            case .plus, .minus, .multiply, .divide, .modulo:
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
                    result = Double.nan
                } else {
                    result = previousValue / currentValue
                }
            case .modulo:
                if currentValue == 0 {
                    result = 0
                } else {
                    result = previousValue.truncatingRemainder(dividingBy: currentValue)
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
