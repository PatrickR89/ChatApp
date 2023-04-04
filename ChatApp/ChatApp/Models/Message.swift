//
//  Message.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

struct RecievedMessage: Codable {
    let sourceUsername: String
    let timestamp: TimeInterval
    let content: String
}

struct SentMessage: Codable {
    let content: String
    let chatId: String
}

struct PendingMessage {
    let id: UUID
    let chatId: String
    let content: String
    var timestamp: TimeInterval

    init(message: SentMessage, id: UUID) {
        self.chatId = message.chatId
        self.content = message.content
        self.id = id
        self.timestamp = Date().timeIntervalSince1970
    }
}
