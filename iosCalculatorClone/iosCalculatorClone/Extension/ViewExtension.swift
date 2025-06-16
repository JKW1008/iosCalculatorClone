//
//  ViewExtension.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/16/25.
//

import UIKit

extension ViewController {
    final func configureUI() {
        setAttributes()
        addTarget()
        setConstraints()
    }
    
    final private func setAttributes() {
        allView.backgroundColor = .black
    }
    
    final private func addTarget() {
//        btn1.addTarget(self, action: #selector(btn1), for: <#T##UIControl.Event#>)
    }
    
    final private func setConstraints() {
        let stackView = UIStackView(arrangedSubviews: [allView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        let stackBtn = UIStackView(arrangedSubviews: [btn1])
        stackBtn.axis = .vertical
        stackBtn.distribution = .fill
        stackBtn.spacing = 400
        

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackBtn)
        stackBtn.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor ),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 160),
            stackBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            stackBtn.widthAnchor.constraint(equalToConstant: 130)
        ])

    }
}
