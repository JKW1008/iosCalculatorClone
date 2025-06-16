//
//  ViewController.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/16/25.
//

import UIKit

class ViewController: UIViewController {
    
    let allView = UIView()
    let btn1 = MyButton(title: "7")
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        btn1.frame = CGRect(x: 50, y: 100, width: 60, height: 60)
        btn1.layer.cornerRadius = 30
        view.addSubview(btn1)
        //configureUI()

    
    }
}

