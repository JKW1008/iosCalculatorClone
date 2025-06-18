//
//  Calc.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/18/25.
//

import UIKit

enum CalculatorButtonType {
    case number(String)
    case mathOperator(String)
    case function(String)
    case clear(String)
    
    var title: String {
        switch self {
            case .number(let title):
                return title
            case .mathOperator(let title):
                return title
            case .function(let title):
                return title
            case .clear(let title):
                return title
        }
    }
    
    var colors: (background: UIColor, text: UIColor) {
        switch self {
            case .number:
                return (.systemGray2, .white)
            case .mathOperator:
                return (.systemOrange, .white)
            case .function, .clear:
                return (.systemGray, .white)
        }
    }
}
