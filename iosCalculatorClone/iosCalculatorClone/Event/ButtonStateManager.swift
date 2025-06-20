//
//  ButtonStateManager.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/20/25.
//

class ButtonStateManager {
    private var currentState: ClearButtonState = .allClear
    private weak var clearButton: MyButton?
    
    func setClearButton(_ button: MyButton) {
        self.clearButton = button
        updateClearButtonUI()
    }
    
    func getCurrentStaet() -> ClearButtonState {
        return currentState
    }
    
    func updateState(to newState: ClearButtonState) {
        guard currentState != newState else { return }  //  같은 상태면 무시
        
        currentState =   newState
        updateStateUI()
        
    }
}
