//
//  IsTextEvent.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/20/25.
//

import UIKit

class NumberInputHandler {
    private weak var displayLabel: UILabel?
    private weak var stateManager: ButtonStateManager?
    
    init(displayLabel: UILabel, stateManager: ButtonStateManager) {
        self.displayLabel = displayLabel
        self.stateManager = stateManager
    }
    
    private lazy var integerFromatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    func handleNumberInput(_ number: String) {
        guard let stateManager = stateManager, let displayLabel = displayLabel else { return }
        print("🔢 handleNumberInput called with: \(number)")
        print("🔢 shouldStartNewInput: \(stateManager.getStartNewInput())")
        if stateManager.getStartNewInput() {
            stateManager.setStartNewInput(false)
            startNewNumberInput(number)
            stateManager.onNumberInput()
            formatDisplayWithCommas()
            return
        }
        
        let currentState = stateManager.getCurrentState()
        let currentText = displayLabel.text ?? "0"
        
        switch currentState {
            case .allClear:
                startNewNumberInput(number)
                stateManager.onNumberInput()
                
            case .calculated:
                startNewNumberInput(number)
                stateManager.onNumberInput()
                
            case .clear:
                continueNumberInput(currentText: currentText, newDigit: number)
        }
        formatDisplayWithCommas()
        print ("Number input: \(number), Display: \(displayLabel.text ?? "")")
    }
    
    private func startNewNumberInput(_ number: String) {
        guard let displayLabel = displayLabel else { return }
        
        if number == "0" {
            displayLabel.text = "0"
        } else {
            displayLabel.text = number
        }
    }
    
    func handleDecimalInput() {
        guard let displayLabel = displayLabel,
              let statemanager = stateManager else { return }
        let currentText = displayLabel.text ?? "0"
        let currentState = statemanager.getCurrentState()
        
        if currentText.contains(".") {
            return
        }
        
        switch currentState {
            case .allClear, .calculated:
                displayLabel.text = "0."
                stateManager?.onNumberInput()
            
            case .clear:
                displayLabel.text = currentText + "."
        }
        
        print("Deciaml input, Display: \(displayLabel.text ?? "")")
    }
    
    func getCurrentValue() -> Double? {
        guard let displayLabel = displayLabel, let text = displayLabel.text else {
            return nil
        }
        
        var numbersOnly = text.replacingOccurrences(of: ",", with: "")
        
        if numbersOnly.hasPrefix("(") && numbersOnly.hasSuffix(")") {
            numbersOnly = String(numbersOnly.dropFirst().dropLast())
        }
        
        let decimal = NSDecimalNumber(string: numbersOnly)
        if decimal != NSDecimalNumber.notANumber {
            return decimal.doubleValue
        }
        
        return nil
    }
    
    func setDisplayValue(_ value: Double) {
        guard let displayLabel = displayLabel else { return }
        
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            displayLabel.text = String(format: "%0.f", value)
        } else {
            displayLabel.text = String(format: "%0.8g", value)
        }
        
//        limitDisplayLength()
    }
    
    func clearDisplay() {
        displayLabel?.text = "0"
    }
    
    private func continueNumberInput(currentText: String, newDigit: String) {
        guard let displayLabel = displayLabel else { return }
        
        if currentText == "0" && newDigit != "0" {
            displayLabel.text = newDigit
        } else {
            displayLabel.text = currentText + newDigit
        }
//        limitDisplayLength()
        formatDisplayWithCommas()
    }
    
    private func formatDisplayWithCommas() {
        guard let displayLabel = displayLabel, let text = displayLabel.text else { return }
        
        let numbersOnly = text .replacingOccurrences(of: ",", with: "")
        
        guard numbersOnly.contains(".") else {
            let decimal = NSDecimalNumber(string: numbersOnly)
            if decimal != NSDecimalNumber.notANumber {
                if let formattedString = integerFromatter.string(from: decimal) {
                    displayLabel.text = formattedString
                }
            }
            return
        }
        
        // 소수점이 있는 경우
        let parts = numbersOnly.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return }
        
        let integerPart = String(parts[0])
        let decimalPart = String(parts[1])
        
        let decimal = NSDecimalNumber(string: integerPart)
        if decimal != NSDecimalNumber.notANumber {
            if let formattedInteager = integerFromatter.string(from: decimal) {
                displayLabel.text = formattedInteager + "." + decimalPart
            }
        }
    }
    
    func deleteLastCharacter() {
        guard let displayLabel = displayLabel, let text = displayLabel.text else { return }
        print("🗑️ Deleting from: '\(text)', length: \(text.count)")
        if text.count > 1 {
            displayLabel.text = String(text.dropLast())
        } else {
            displayLabel.text = "0"
            stateManager?.updateState(to: .allClear)
        }
        print("Delete last character, Display: \(displayLabel.text ?? "")")
    }

    
//    private func limitDisplayLength() {
//        guard let displayLabel = displayLabel else { return }
//    }
    
    func toggleSign() {
        guard let displayLabel = displayLabel, let currentValue = getCurrentValue() else {
            return
        }
        
        if currentValue > 0 {
            displayLabel.text = "(-\(Int(currentValue)))"
        } else if currentValue > 0 {
            let positiveValue = abs(currentValue)
            if positiveValue.truncatingRemainder(dividingBy: 1) == 0 {
                displayLabel.text = String(format: "%.0f", positiveValue)
            } else {
                displayLabel.text = String(positiveValue)
            }
        }
    }
}

extension NumberInputHandler {
    func isValidNumber() -> Bool {
        guard let displayLabel = displayLabel, let text = displayLabel.text else { return false }
        
        return Double(text) != nil
    }
    
    func isInteger() -> Bool {
        let value = getCurrentValue()
        return value?.truncatingRemainder(dividingBy: 1) == 0
    }
    
    func getDisplayText() -> String {
        return displayLabel?.text ?? "0"
    }
}
