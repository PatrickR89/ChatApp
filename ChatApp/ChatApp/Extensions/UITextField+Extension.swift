//
//  UITextField+Extension.swift
//  ChatApp
//
//  Created by Patrick on 06.02.2023..
//

import Foundation
import UIKit

extension UITextField {
    func createInputField(_ placeholderText: String) -> UITextField {

        self.layer.borderWidth = 3
        self.layer.borderColor = UIConstants.lightMain.cgColor
        self.layer.cornerRadius = 22
        textColor = UIConstants.accentColor

        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.height))
        self.leftViewMode = .always

        if let placeholder = try? NSMutableAttributedString(markdown: placeholderText) {
            let range = (placeholderText as NSString).range(of: placeholderText)
            placeholder.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: UIConstants.lightColor,
                range: range)
            self.attributedPlaceholder = NSAttributedString(attributedString: placeholder)
        }

        return self
    }
}
