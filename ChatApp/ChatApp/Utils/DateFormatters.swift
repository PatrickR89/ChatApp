//
//  DateFormatters.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

class DateFormatters {
    /// Variable containing instance of `DateFormatter` with specified style for styling message timestamps.
    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        return formatter
    }()

    /// Method which creates `String` value from given `TimeInterval`.
    /// - Parameter time: `TimeInterval` etiher created by application for ``SentMessage``,
    /// or generated server side for ``RecievedMessage``
    /// - Returns: Value as `String`, in order to be presented as timestamp of message.
    static func formatMessageTimestamp(_ time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)

        return formatter.string(from: date)
    }
}
