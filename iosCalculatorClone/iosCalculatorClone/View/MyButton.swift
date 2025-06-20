//
//  UIButton.swift
//  iosCalculatorClone
//
//  Created by 정강우 on 6/16/25.
//

import UIKit

class   MyButton: UIButton {

    convenience init(title: String? = nil, image: String? = nil, color: UIColor, textColor: UIColor){
        self.init(frame: .zero)
        setTitle(title, for: .normal)
        if let imageName = image {
            setImage(UIImage(systemName: imageName), for: .normal)
        }
        setTitleColor(textColor, for: .normal)
        backgroundColor = color
    }
    
    convenience init(buttonType: CalculatorButtonType, fontSize: CGFloat = 30) {
        let colors = buttonType.colors
        self.init(title: buttonType.title,
                  image: buttonType.imageName,
                  color: colors.background,
                  textColor: colors.text)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("fatal Error")
    }
    
    private func commonInit() {
        backgroundColor = .systemGray
        layer.cornerRadius = 6
        titleLabel?.font = .systemFont(ofSize: 30)
        layer.borderColor = .none
        layer.borderWidth = 0.5
    }
    
    override var isEnabled: Bool {
        didSet { updateStateUI() }
    }
    
    override var isHighlighted: Bool {
        didSet { updateStateUI() }
    }
    
    private func updateStateUI() {
        switch state {
            case .normal:
                DispatchQueue.main.async {
                    self.backgroundColor = .none
                }
            case .highlighted:
                DispatchQueue.main.async {
                    self.backgroundColor = .none
                }
            case .disabled:
                DispatchQueue.main.async {
                    self.backgroundColor = .none
                }
            default:
                break
        }
    }
}
