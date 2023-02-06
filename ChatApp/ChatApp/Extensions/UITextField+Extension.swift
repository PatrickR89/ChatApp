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

        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 22
        self.textColor = .black

        let placeholder = try! NSAttributedString(markdown: placeholderText)
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftViewMode = .always
        self.attributedPlaceholder = NSAttributedString(attributedString: placeholder)

        return self
    }
}
