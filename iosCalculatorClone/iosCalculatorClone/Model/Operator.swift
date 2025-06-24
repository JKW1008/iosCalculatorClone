//
//  Operator.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/22/25.
//


enum SelectedOperator {
    case plus
    case minus
    case multiply
    case divide
    case modulo
    case equal
    
    static func fromString(_ operatorString: String) -> SelectedOperator? {
        switch operatorString {
            case "plus": return .plus
            case "minus": return .minus
            case "multiply": return .multiply
            case "divide": return .divide
            case "percent": return .modulo
            case "equal": return .equal
            default: return nil
        }
    }
    
    var symbol: String {
        switch self {
            case .plus: return "+"
            case .minus: return "-"
            case .multiply: return "×"
            case .divide: return "÷"
            case .modulo: return "%"
            case .equal: return "="
        }
    }
    
    var isBinaryOperator: Bool {
        switch self {
            case .plus, .minus, .multiply, .divide, .modulo: return true
            case .equal: return false
        }
    }
}
