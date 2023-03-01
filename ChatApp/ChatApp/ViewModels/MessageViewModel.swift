//
//  MessageViewModel.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

enum Sender {
    case me
    case other(_ name: String)
}

struct MessageViewModel {
    let id: UUID
    let sender: Sender
    let timestamp: String
    let content: String
    var isExpanded: Bool

    init(message: SentMessage) {
        self.id = UUID()
        self.sender = Sender.me
        self.content = message.content
        let currentDate = Date().timeIntervalSince1970
        self.timestamp = DateFormatters.formatMessageTimestamp(currentDate)
        self.isExpanded = false
    }

    init(message: RecievedMessage) {
        self.id = UUID()
        self.sender = Sender.other(message.sourceUsername)
        self.timestamp = DateFormatters.formatMessageTimestamp(message.timestamp)
        self.content = message.content
        self.isExpanded = false
    }
}
