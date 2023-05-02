//
//  UIButton+Extension.swift
//  ChatApp
//
//  Created by Patrick on 03.03.2023..
//

import UIKit

extension UIButton {
    /// Method creates `UIButton` instance with defined characteristics and UI elements.
    /// - Returns: Defined instance of `UIButton`
    func createPaperPlaneButton() -> UIButton {
        let buttonImage = UIImage(
            systemName: "paperplane.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))

        setImage(buttonImage, for: .normal)
        tintColor = ColorConstants.lightMain
        backgroundColor = ColorConstants.accentColor
        layer.cornerRadius = 22

        return self
    }

    /// Method creates instance of `UIButton` for ``LoginView``
    /// - Returns: Defined instance of `UIButton`
    /// > Button element contains title colors defined for normal and disabled cases.
    func createLoginButton() -> UIButton {
        layer.cornerRadius = 22
        setTitle("Register", for: .normal)
        titleLabel?.font = UIFont(name: SupremeFont.bold, size: 20)
        setTitleColor(ColorConstants.accentColor, for: .normal)
        setTitleColor(ColorConstants.darkMain, for: .disabled)
        tintColor = .white

        return self
    }
}
