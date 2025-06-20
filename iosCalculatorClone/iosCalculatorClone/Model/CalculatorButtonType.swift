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
    case image(String)
    case operatorImage(String)
    
    var title: String {
        switch self {
            case .number(let title):
                return title
            case .function(let title):
                return title
            case .clear(let title):
                return title
            case .image(_), .operatorImage(_), .mathOperator(_):
                return ""
        }
    }
    
    var imageName: String? {
        switch self {
            case .image(let imageName), .operatorImage(let imageName), .mathOperator(let imageName):
                return imageName
            default:
                return nil
        }
    }
    
    var colors: (background: UIColor, text: UIColor) {
        switch self {
            case .number, .image:
                return (.deepDarkGray, .white)
            case .mathOperator:
                return (.systemOrange, .white)
            case .function, .clear, .operatorImage:
                return (.darkGray, .white)
        }
    }
}
