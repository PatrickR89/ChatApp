//
//  UILabel+Extensions.swift
//  ChatApp
//
//  Created by Patrick on 03.03.2023..
//

import UIKit

extension UILabel {
    func createMsgContentLabel() -> UILabel {
        numberOfLines = 0
        font = UIFont(name: SupremeFont.regular, size: 17)
        textColor = ColorConstants.lightColor

        return self
    }

    func createMsgTimestampLabel() -> UILabel {
        numberOfLines = 1
        font = UIFont(name: SupremeFont.lightItalic, size: 12)
        textColor = ColorConstants.lightMain

        return self
    }

    func createWarningLabel(_ message: String) -> UILabel {
        font = UIFont(name: SupremeFont.boldItalic, size: 12)
        textColor = ColorConstants.accentColor
        text = message
        return self
    }
}
