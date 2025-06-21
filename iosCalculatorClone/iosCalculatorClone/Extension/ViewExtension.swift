//
//  ViewExtension.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/16/25.
//

import UIKit

extension ViewController {
    final func configureUI() {
        createButtonsFromArray()
        setAttributes()
        addTargets()
        setConstraints()
    }
    
    final private func createButtonsFromArray() {
        for (rowIndex, row) in calculatorLayout.enumerated() {
            for (colIndex, buttonType) in row.enumerated() {
                let button = createSingleButton(from: buttonType)
                
                button.tag = rowIndex * 10 + colIndex
                
                calculatorButtons.append(button)
            }
        }
    }
    
    final private func createSingleButton(from buttonType: CalculatorButtonType) -> MyButton {
        let button = MyButton(buttonType: buttonType)
        
        //  버튼 크기 계산
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 40   //  좌우 패딩 (20 + 20)
        let buttonSpacing: CGFloat = 10 * 3 //  버튼 간 간격 (3개의 간격)
        let availableWidth = screenWidth - padding - buttonSpacing
        let buttonSize = availableWidth / 4  //  4개 버튼으로 나누기
        
        //  폰트 사이즈를 버튼 사이즈에 맞게 설정
        let fontSize = buttonSize * 0.4
        button.titleLabel?.font = .systemFont(ofSize: fontSize)
        
        if case .clear(_) = buttonType {
            buttonStateManager.setClearButton(button)
        }
        
        //  아이콘이 이미지인 경우
        switch buttonType {
            case .image(_), .operatorImage(_), .mathOperator(_):
                //  이미지 크기를 버튼 크기의 비율로 설정
                let imageSize = buttonSize * 0.4
                
                // 이미지 크기, 색 조절
                button.imageView?.contentMode = .scaleAspectFit
                button.tintColor = buttonType.colors.text
                
                //  비율 기반 이미지 크기 설정
                let configuration = UIImage.SymbolConfiguration(pointSize: imageSize, weight: .medium)
                if let currentImage = button.image(for: .normal) {
                    let resizedImage = currentImage.withConfiguration(configuration)
                    button.setImage(resizedImage, for: .normal)
                }
                
                button.setTitle(nil, for: .normal)
            default:
                break
        }

        
        //  정사각형 버튼 보장
        button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        //  Aspect ratio 1:1 고정 (추가 보장)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        
        return button
    }
    
    final private func setAttributes() {
        view.backgroundColor = .black
        displayLabel.text = "0"
        displayLabel.textColor = .white
        displayLabel.font = .systemFont(ofSize: 60, weight: .light)
        displayLabel.textAlignment = .right
        displayLabel.numberOfLines = 1
        displayLabel.adjustsFontSizeToFitWidth = true
        displayLabel.minimumScaleFactor = 0.5
    }
    
    final private func addTargets() {
        for button in calculatorButtons {
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func buttonTapped(_ sender: MyButton) {
        guard let title = sender.title(for: .normal) else { return }
        
        let row = sender.tag / 10
        let col = sender.tag % 10
        let buttonType = calculatorLayout[row][col]
        
        switch buttonType {
            case .number(_):
                buttonStateManager.onNumberInput()
            case .clear:
                _ = buttonStateManager.handleClearButtonActinon()
            case .mathOperator("equal"):
                buttonStateManager.onCalculationComplete()
            default:
                break
        }
        
        print("button '\(title)' tapped - position: (\(row), \(col))")
        
        displayLabel.text = title
    }
    
    final private func setConstraints() {
        let buttonGrid = createButtonGrid()
        let mainStackView = UIStackView(arrangedSubviews: [displayLabel, buttonGrid])
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill
        mainStackView.spacing = 20
        
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 40   //  좌우 패딩 (20 + 20)
        let buttonSpacing: CGFloat = 10 * 3 //  버튼 간 간격 (3개의 간격)
        let availableWidth = screenWidth - padding - buttonSpacing
        let buttonSize = availableWidth / 4  //  4개 버튼으로 나누기
        let gridHeight = (buttonSize * 5) + (10 * 4)
        
        
        NSLayoutConstraint.activate([
//            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20 ),
            
            displayLabel.heightAnchor.constraint(equalToConstant: 100),
            buttonGrid.heightAnchor.constraint(equalToConstant: gridHeight),
            
        ])
    }
    
    final private func createButtonGrid() -> UIStackView {
        var rowStackViews: [UIStackView] = []
        
        for (rowIndex, row) in calculatorLayout.enumerated() {
            let buttonForRow = row.enumerated().map { (colIndex, _) in
                let tag = rowIndex * 10 + colIndex
                return calculatorButtons.first { $0.tag == tag } ?? UIView()
            }
            
            let rowStackView = UIStackView(arrangedSubviews: buttonForRow)
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.alignment = .center
            rowStackView.spacing = 10
            
            rowStackViews.append(rowStackView)
        }
        
        let gridStackView = UIStackView(arrangedSubviews: rowStackViews)
        gridStackView.axis = .vertical
        gridStackView.distribution = .fillEqually
        gridStackView.alignment = .fill
        gridStackView.spacing = 10
        
        return gridStackView
    }
}

extension ViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for button in calculatorButtons {
            //  완전한 원형 보장
            let size = min(button.frame.width, button.frame.height)
            button.layer.cornerRadius = size / 2
        }
    }
}
