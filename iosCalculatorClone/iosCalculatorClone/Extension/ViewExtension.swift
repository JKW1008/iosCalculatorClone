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
    
    private func calculateButtonSize() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 40   //  좌우 패딩 (20 + 20)
        let buttonSpacing: CGFloat = 10 * 3 //  버튼 간 간격 (3개의 간격)
        let availableWidth = screenWidth - padding - buttonSpacing
        return availableWidth / 4   //  4개 버튼으로 나누기
    }
    
    private func calculateGridHeight() -> CGFloat {
        let buttonSize = calculateButtonSize()
        return (buttonSize * 5) + (10 * 4)
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
        let buttonSize = calculateButtonSize()
        
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
        configureDisplayScrollView()
    }
    
    private func configureDisplayScrollView() {
        let buttonSize = calculateButtonSize()
        let baseFontSize = buttonSize * 0.8
        
        //  ScrollView 설정
        displayScrollView.showsVerticalScrollIndicator = false
        displayScrollView.showsHorizontalScrollIndicator = false
        displayScrollView.bounces = true
//        displayScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        displayLabel.text = "0"
        displayLabel.textColor = .white
        displayLabel.font = .monospacedDigitSystemFont(ofSize: baseFontSize, weight: .light)
        displayLabel.textAlignment = .right
        displayLabel.numberOfLines = 1
        displayLabel.adjustsFontSizeToFitWidth = false
        displayLabel.minimumScaleFactor = 1.0
        displayLabel.lineBreakMode = .byClipping
        displayLabel.translatesAutoresizingMaskIntoConstraints = true
        
        displayScrollView.addSubview(displayLabel)
        displayScrollView.contentSize = CGSize(width: 100, height: 100)
//        NSLayoutConstraint.activate([
//            displayLabel.topAnchor.constraint(equalTo: displayScrollView.topAnchor),
//            displayLabel.bottomAnchor.constraint(equalTo: displayScrollView.bottomAnchor),
//            displayLabel.leadingAnchor.constraint(equalTo: displayScrollView.leadingAnchor),
//            displayLabel.trailingAnchor.constraint(equalTo: displayScrollView.trailingAnchor),
//            displayLabel.heightAnchor.constraint(equalTo: displayScrollView.heightAnchor),
//            
//            displayLabel.widthAnchor.constraint(greaterThanOrEqualTo: displayScrollView.widthAnchor)
//        ])
    }
    
    final private func addTargets() {
        for button in calculatorButtons {
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func buttonTapped(_ sender: MyButton) {
        let row = sender.tag / 10
        let col = sender.tag % 10
        let buttonType = calculatorLayout[row][col]
        
        switch buttonType {
            case .number(let number):
                //  실제 숫자값을 NumberInputHandler로 전달
                numberInputHandler.handleNumberInput(number)
                //  상태 업데이트
                buttonStateManager.onNumberInput()
                
                //  계산기 값.전달
                guard let currentValue = numberInputHandler.getCurrentValue() else { return }
                calculatorBrain.setOperand(currentValue)
                
                print("🔢 After setOperand:")
                print("🔢 - Previous: \(String(describing: calculatorBrain.getpreviousValue()))")  // private이면 getPreviousValue() 메서드 필요
                print("🔢 - Current: \(calculatorBrain.getResult())")
                print("🔢 - Pending: \(calculatorBrain.getPendingOperation()?.symbol ?? "nil")")
                
                // 👇 숫자 입력 후 수식이 있으면 수식 표시
                if let expression = calculatorBrain.getDisplayExpression() {
                    print("🔢 - Expression: \(expression)")
                    displayLabel.text = expression  // 직접 설정
                    numberInputHandler.updateScrollPosition()  // 스크롤 업데이트
                    print("🔢 Display after setting: '\(displayLabel.text ?? "")'")
                } else {
                    print("🔢 No expression, keeping current display")
                }
                
            case .number("."):
                numberInputHandler.handleDecimalInput()
                buttonStateManager.onNumberInput()
                

            case .clear(_):
                let action = buttonStateManager.handleClearButtonAction()
                switch action {
                    case .allClear:
                        numberInputHandler.clearDisplay()
                        calculatorBrain.clear()
                        buttonStateManager.onClearButtonPressed()
                    case .deleteLast:
                        numberInputHandler.deleteLastCharacter()
                }
            case .mathOperator(let op):
                if let operation = SelectedOperator.fromString(op) {
                    calculatorBrain.performOperation(operation)
                    
                    let result = calculatorBrain.getResult()
                    numberInputHandler.setDisplayValueWithExpression(result, brain: calculatorBrain)
                    
                    if operation == .equal {
                        buttonStateManager.onCalculationComplete()
                        buttonStateManager.setSelectedOperator(nil)
                    } else {
                        buttonStateManager.setSelectedOperator(operation)
                    }
                }
            case .operatorImage("plus.forwardslash.minus"):
                numberInputHandler.toggleSign()
            case .operatorImage("percent"):
                print("🔘 Percent button pressed!")
                if let operation = SelectedOperator.fromString("percent") {
                    print("🔘 Percent operation created")

                    calculatorBrain.performOperation(operation)
                    
                    let result = calculatorBrain.getResult()
                    numberInputHandler.setDisplayValue(result)
                    buttonStateManager.setSelectedOperator(operation)
                }
                
                guard let currentValue = numberInputHandler.getCurrentValue() else { return }
                calculatorBrain.setOperand(currentValue)
            default:
                break
        }
    }
    
    final private func setConstraints() {
        
        let buttonGrid = createButtonGrid()
        let mainStackView = UIStackView(arrangedSubviews: [displayScrollView, buttonGrid])
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill
        mainStackView.spacing = 20
        
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        let gridHeight = calculateGridHeight()
        
        NSLayoutConstraint.activate([
//            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20 ),
            
            displayScrollView.heightAnchor.constraint(equalToConstant: 100),
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
        
        if displayLabel.frame.width == 0 || displayLabel.frame.height == 0 {
            let scrollHeight = displayScrollView.frame.height
            let scrollWidth = displayScrollView.frame.width
            // Label 초기 크기 설정
            displayLabel.frame = CGRect(x: 0, y: 0, width: scrollWidth, height: scrollHeight)
            
            // ScrollView contentSize 초기 설정
            displayScrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        }
    }
}
