//
//  MessageViewModel.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

enum Sender {
    case myself(_ isSent: Bool?)
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
        self.sender = Sender.myself(nil)
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

    init(realmMessage: MessageRealmModel) {
        self.id = realmMessage.id

        switch realmMessage.sender.sender {
        case .myself:
            self.sender = .myself(realmMessage.sender.isSent)
        case .other:
            self.sender = .other(realmMessage.sender.name ?? "unknown")
        }
        self.timestamp = DateFormatters.formatMessageTimestamp(realmMessage.timestamp)
        self.content = realmMessage.content
        self.isExpanded = false
    }
}
