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
    private let maxDigits = 9
    
    init(displayLabel: UILabel, stateManager: ButtonStateManager) {
        self.displayLabel = displayLabel
        self.stateManager = stateManager
    }
    
    func handleNumberInput(_ number: String) {
        guard let stateManager = stateManager, let displayLabel = displayLabel else { return }
        
        let currentState = stateManager.getCurrentStaet()
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
        let currentState = statemanager.getCurrentStaet()
        
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
        guard let displayLabel = displayLabel, let text = displayLabel.text, let value = Double(text) else {
            return nil
        }
        return value
    }
    
    func setDisplayValue(_ value: Double) {
        guard let displayLabel = displayLabel else { return }
        
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            displayLabel.text = String(format: "%0.f", value)
        } else {
            displayLabel.text = String(format: "%0.8g", value)
        }
        
        limitDisplayLength()
    }
    
    func clearDisplay() {
        displayLabel?.text = "0"
    }
    
    private func continueNumberInput(currentText: String, newDigit: String) {
        guard let displayLabel = displayLabel else { return }
        
        if currentText.count >= maxDigits {
            return
        }
        
        if currentText == "0" && newDigit != "0" {
            displayLabel.text = newDigit
        } else {
            displayLabel.text = currentText + newDigit
        }
        limitDisplayLength()
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
    
    private func limitDisplayLength() {
        guard let displayLabel = displayLabel, let text = displayLabel.text, text.count > maxDigits else { return }
        
        let endIndex = text.index(text.startIndex, offsetBy: maxDigits)
        displayLabel.text = String(text[..<endIndex])
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
