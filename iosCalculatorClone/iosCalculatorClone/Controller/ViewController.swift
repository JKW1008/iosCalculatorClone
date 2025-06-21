//
//  ViewController.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/16/25.
//

import UIKit
import Symbols

class ViewController: UIViewController {
    
    let allView = UIView()
    var calculatorButtons: [MyButton] = []
    let displayLabel = UILabel()
//    let btn1 = MyButton(title: "AC", color: .systemGray, textColor: .systemBackground)
    let buttonStateManager = ButtonStateManager()
    let calculatorLayout: [[CalculatorButtonType]] =  [
        [.clear("AC"), .operatorImage("plus.forwardslash.minus"), .operatorImage("percent"), .mathOperator("divide")],
        [.number("7"), .number("8"), .number("9"), .mathOperator("multiply")],
        [.number("4"), .number("5"), .number("6"), .mathOperator("minus")],
        [.number("1"), .number("2"), .number("3"), .mathOperator("plus")],
        [.image("candybarphone"), .number("0"), .number("."), .mathOperator("equal")]
    ]
    
//    for i in calculatorButtons {
//        calculatorButtons[i].frame = CGsize(width: 80, height: 80)
//        calculatorButtons[i].layer.cornerRadius = calculatorButtons[i].frame.width / 2
//    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        btn1.frame = CGRect(x: 20, y: 350, width: 80, height: 80)
//        btn1.layer.cornerRadius = btn1.frame.width / 2
//
//        view.addSubview(btn1)
        configureUI()
    }
}

