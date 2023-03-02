//
//  DateFormatters.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

class DateFormatters {
    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        return formatter
    }()

    static func formatMessageTimestamp(_ time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)

        return formatter.string(from: date)
    }
}
