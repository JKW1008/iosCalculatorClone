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
    private var actualNumericValue: Double = 0
    
    init(displayLabel: UILabel, stateManager: ButtonStateManager) {
        self.displayLabel = displayLabel
        self.stateManager = stateManager
    }
    
    private lazy var integerFormatter: NumberFormatter = {
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
            if let displayValue = getCurrentValueFromDisplay() {
                actualNumericValue = displayValue
            }
            return
        }
        let currentState = stateManager.getCurrentState()
        let currentText = displayLabel.text ?? "0"
        
        let operators = ["+", "-", "×", "÷", "%"]
        let isExpression = operators.contains { currentText.contains($0) }
        
        if isExpression {
            // 수식 상태에서는 마지막 숫자에 추가
            print("🔢 Expression detected, continuing with last number")
            continueWithExpression(currentText: currentText, newDigit: number)
            // getCurrentValueFromDisplay로 actualNumericValue 업데이트
            if let displayValue = getCurrentValueFromDisplay() {
                actualNumericValue = displayValue
                print("🔢 actualNumericValue updated to: \(actualNumericValue)")
            }
            return
        }
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
        
        print("🔢 Before actualNumericValue update:")
        print("🔢 - Display text: '\(displayLabel.text ?? "")'")
        
        if let displayValue = getCurrentValueFromDisplay() {
            actualNumericValue = displayValue
            print("🔢 actualNumericValue updated to: \(actualNumericValue)")
        }
    }
    
    private func continueWithExpression(currentText: String, newDigit: String) {
        guard let displayLabel = displayLabel else { return }
        
        let operators = ["+", "-", "×", "÷", "%"]
        for op in operators {
            if let lastOpIndex = currentText.lastIndex(of: Character(op)) {
                let beforeOperator = String(currentText[...lastOpIndex])
                let afterOperator = String(currentText[currentText.index(after: lastOpIndex)...])
                
                let newNumber = afterOperator.isEmpty ? newDigit : afterOperator + newDigit
                displayLabel.text = beforeOperator + newNumber
                return
            }
        }
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
    
    private func getCurrentValueFromDisplay() -> Double? {
        guard let displayLabel = displayLabel, let text = displayLabel.text else {
            return nil
        }
        
        if text == "정의되지 않음" {
            return Double.nan
        }
        let operators = ["+", "-", "×", "÷", "%"]
        for op in operators {
            if text.contains(op) {
                if let lastOpIndex = text.lastIndex(of: Character(op)) {
                    let afterOperator = String(text[text.index(after: lastOpIndex)...])
                    let numbersOnly = afterOperator.replacingOccurrences(of: ",", with: "")
                    
                    if !numbersOnly.isEmpty {
                        let decimal = NSDecimalNumber(string: numbersOnly)
                        if decimal != NSDecimalNumber.notANumber {
                            return decimal.doubleValue
                        }
                        
                    }
                }
            }
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
    
    func getCurrentValue() -> Double? {
        return actualNumericValue
    }
    
    
    func setDisplayValue(_ value: Double) {
        guard let displayLabel = displayLabel else { return }
        
        if value.isNaN {
            displayLabel.text = "정의되지 않음"
            updateScrollPosition()
            return
        }
        
        if value.isInfinite {
            displayLabel.text = value > 0 ? "∞" : "-∞"
            updateScrollPosition()
            return
        }
        
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            displayLabel.text = String(format: "%0.f", value)
        } else {
            displayLabel.text = String(format: "%0.8g", value)
        }
        
//        limitDisplayLength()
        formatDisplayWithCommas()
        actualNumericValue = value  // 👈 추가
        print("🔢 actualNumericValue set to: \(actualNumericValue) via setDisplayValue")
    }
    
    func setDisplayValueWithExpression(_ value: Double, brain: CalculatorBrain) {
        guard let displayLabel = displayLabel else { return }
        if let expression = brain.getDisplayExpression() {
            displayLabel.text = expression
        } else {
            setDisplayValue(value)
            return
        }
        updateScrollPosition()
    }
    
    func clearDisplay() {
        displayLabel?.text = "0"
        actualNumericValue = 0.0
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
                if let formattedString = integerFormatter.string(from: decimal) {
                    displayLabel.text = formattedString
                }
            }
            updateScrollPosition()
            return
        }
        
        // 소수점이 있는 경우
        let parts = numbersOnly.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return }
        
        let integerPart = String(parts[0])
        let decimalPart = String(parts[1])
        
        let decimal = NSDecimalNumber(string: integerPart)
        if decimal != NSDecimalNumber.notANumber {
            if let formattedInteager = integerFormatter.string(from: decimal) {
                displayLabel.text = formattedInteager + "." + decimalPart
            }
        }
        updateScrollPosition()
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
        } else if currentValue < 0 {
            let positiveValue = abs(currentValue)
            if positiveValue.truncatingRemainder(dividingBy: 1) == 0 {
                displayLabel.text = String(format: "%.0f", positiveValue)
            } else {
                displayLabel.text = String(positiveValue)
            }
        }
    }
    
//    private func updateScrollPosition() {
//        DispatchQueue.main.async {
//            guard let scrollView = self.displayLabel?.superview as? UIScrollView else { return }
//            
//            let text = self.displayLabel?.text ?? ""
//            let font = self.displayLabel?.font ?? UIFont.systemFont(ofSize: 30)
//            let textSize = text.size(withAttributes: [.font: font])
//            
//            
//            let scrollHeight = scrollView.frame.height
//            let scrollWidth = scrollView.frame.width
//            let labelWidth = max(textSize.width, scrollWidth)
//            self.displayLabel?.frame = CGRect(x: 0, y: 0, width: labelWidth, height: scrollHeight)
//            
//            scrollView.contentSize = CGSize(width: labelWidth, height: scrollHeight)
//            
//            if labelWidth > scrollWidth {
//                let offsetX = labelWidth - scrollWidth
//                scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
//            } else {
//                scrollView.setContentOffset(.zero, animated: true)
//            }
//        }
//    }
    func updateScrollPosition() {
        DispatchQueue.main.async {
            guard let scrollView = self.displayLabel?.superview as? UIScrollView else { return }
            
            let text = self.displayLabel?.text ?? ""
            let font = self.displayLabel?.font ?? UIFont.systemFont(ofSize: 30)
            let textSize = text.size(withAttributes: [.font: font])
            
            let scrollHeight = scrollView.frame.height
            let scrollWidth = scrollView.frame.width
            let labelWidth = max(textSize.width + 20, scrollWidth)  // 👈 여유 공간 추가
            
            self.displayLabel?.frame = CGRect(x: 0, y: 0, width: labelWidth, height: scrollHeight)
            scrollView.contentSize = CGSize(width: labelWidth, height: scrollHeight)
                    
            if labelWidth > scrollWidth {
                let offsetX = labelWidth - scrollWidth
                scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)  // 👈 animated: false로 변경
            } else {
                scrollView.setContentOffset(.zero, animated: false)
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
