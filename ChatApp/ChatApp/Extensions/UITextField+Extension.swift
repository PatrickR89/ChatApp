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

        layer.borderWidth = 3
        layer.borderColor = ColorConstants.lightMain.cgColor
        layer.cornerRadius = 22
        textColor = ColorConstants.accentColor
        font = UIFont(name: SupremeFont.regular, size: 17)

        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.height))
        leftViewMode = .always

        if let placeholder = try? NSMutableAttributedString(markdown: placeholderText) {
            let range = (placeholderText as NSString).range(of: placeholderText)
            placeholder.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: ColorConstants.lightColor,
                range: range)
            attributedPlaceholder = NSAttributedString(attributedString: placeholder)
        }

        return self
    }

    func createMessageInputField() -> UITextField {
        backgroundColor = ColorConstants.lightColor
        textColor = ColorConstants.accentColor
        text = ""
        isUserInteractionEnabled = true
        layer.cornerRadius = 22
        autocorrectionType = .no
        autocapitalizationType = .none
        font = UIFont(name: SupremeFont.medium, size: 17)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.height))
        leftViewMode = .always
        if let placeholder = try? NSAttributedString(markdown: "Enter your message...") {
            attributedPlaceholder = NSAttributedString(attributedString: placeholder)
        }

        return self
    }
}
