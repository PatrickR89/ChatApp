//
//  UILabel+Extensions.swift
//  ChatApp
//
//  Created by Patrick on 03.03.2023..
//

import UIKit

extension UILabel {
    /// Method creates instance of `UILabel`,
    /// which presents message content as an
    ///  element of ``MessageViewCell`` in ``ChatTableViewController``
    /// - Returns: Instance of `UILable` with unlimited number of lines, and text attributes which give an easily readable content
    func createMsgContentLabel() -> UILabel {
        numberOfLines = 0
        font = UIFont(name: SupremeFont.regular, size: 17)
        textColor = ColorConstants.lightColor

        return self
    }

    /// Method which creates instance of `UILabel`,
    /// presenting timestamp of the message, as a element of ``MessageViewCell``
    /// - Returns: Defined instance of `UILabel`
    /// creating visible but smaller content with informational characteristics.
    func createMsgTimestampLabel() -> UILabel {
        numberOfLines = 1
        font = UIFont(name: SupremeFont.lightItalic, size: 12)
        textColor = ColorConstants.lightMain

        return self
    }

    /// Method which creates an instance of `UILabel` for presenting Error messages to user, as notifications.
    /// - Parameter message: `String` value, containing error message recieved from ``ChatService``
    /// - Returns: Instance of `UILabel` with defined visuals and message.
    func createWarningLabel(_ message: String) -> UILabel {
        font = UIFont(name: SupremeFont.boldItalic, size: 12)
        textColor = ColorConstants.accentColor
        text = message
        return self
    }
}
