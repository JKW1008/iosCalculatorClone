//
//  ButtonStateManager.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/20/25.
//

import UIKit

class ButtonStateManager {
    private var currentState: ClearButtonState = .allClear
    private weak var clearButton: MyButton?
    private var selectedOperator: SelectedOperator?
    private var startNewInput: Bool = false
    
    func setClearButton(_ button: MyButton) {
        self.clearButton = button
        updateClearButtonUI()
    }
    
    func setStartNewInput(_ flag: Bool) {
        startNewInput = flag
    }
    
    func getCurrentState() -> ClearButtonState {
        return currentState
    }
    
    func getStartNewInput() -> Bool {
        return startNewInput
    }
    
    func updateState(to newState: ClearButtonState) {
        guard currentState != newState else { return }  //  같은 상태면 무시
        
        currentState =   newState
        updateClearButtonUI()
        
        print("State changed to : \(newState)")
    }
    
    func onNumberInput() {
        switch currentState {
            case .allClear, .calculated:
                updateState(to: .clear)
            case .clear:
                break
        }
    }
    
    func onCalculationComplete() {
        updateState(to: .calculated)
    }
    
    func onClearButtonPressed() {
        switch currentState {
            case .allClear:
                break
            case .clear:
                updateState(to: .allClear)
            case .calculated:
                updateState(to: .allClear)
        }
    }
    
    func handleClearButtonAction() -> ClearButtonAction {
        switch currentState {
            case .allClear:
                return .allClear
            case .clear:
                return .deleteLast
            case .calculated:
                return .allClear
        }
    }
    
    private func updateClearButtonUI() {
        guard let button = clearButton else { return }
        
        switch currentState {
            case .allClear, .calculated:
                button.setTitle("AC", for: .normal)
                button.setImage(nil, for: .normal)
            case .clear:
                button.setTitle(nil, for: .normal)
                let deleteImage = UIImage(systemName: "delete.left")
                button.setImage(deleteImage, for: .normal)
                
                let screenWidth = UIScreen.main.bounds.width
                let padding: CGFloat = 40   //  좌우 패딩 (20 + 20)
                let buttonSpacing: CGFloat = 10 * 3 //  버튼 간 간격 (3개의 간격)
                let availableWidth = screenWidth - padding - buttonSpacing
                let buttonSize = availableWidth / 4  //  4개 버튼으로 나누기
                let imageSize = buttonSize * 0.4
                button.imageView?.contentMode = .scaleAspectFit
                button.tintColor = .white
                if let image = deleteImage {
                    let configuration = UIImage.SymbolConfiguration(pointSize: imageSize, weight: .medium)
                    let resizedImage = image.withConfiguration(configuration)
                    button.setImage(resizedImage, for: .normal)
                }
        }
    }
    
    func setSelectedOperator(_ operation: SelectedOperator?) {
        selectedOperator = operation
        
        if operation != nil && operation != .equal {
            setStartNewInput(true)
            print("🔄 Set shouldStartNewInput = true for operation: \(operation?.symbol ?? "nil")")
        }
    }
    
    func getSelectedOperator() -> SelectedOperator? {
        return selectedOperator
    }
}
