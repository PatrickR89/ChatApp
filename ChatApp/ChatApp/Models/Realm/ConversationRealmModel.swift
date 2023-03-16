//
//  ConversationRealmModel.swift
//  ChatApp
//
//  Created by Patrick on 15.03.2023..
//

import Foundation
import RealmSwift

class PendingMessageModel: Object {
    @Persisted (primaryKey: true) var id: UUID
    @Persisted var reciever: String
    @Persisted var message: String

    convenience init(id: UUID, reciever: String, message: String) {
        self.init()
        self.id = id
        self.reciever = reciever
        self.message = message
    }

}

class ConversationRealmModel: Object {
    @Persisted (primaryKey: true) var user: String
    @Persisted var messages: List<UUID>

    convenience init(user: String, conversation: [UUID]) {
        self.init()
        self.user = user
        conversation.forEach { id in
            messages.append(id)
        }
    }
}

class MessageRealmModel: Object {
    @Persisted (primaryKey: true) var id: UUID
    @Persisted var sender: SenderRealmModel?
    @Persisted var timestamp: Double
    @Persisted var content: String

    convenience init(message: MessageViewModel) {
        self.init()
        self.id = message.id
        self.sender = SenderRealmModel(messageSender: message.sender)
        self.timestamp = convertDate(message.timestamp)
        self.content = message.content
    }

    func convertDate(_ date: String) -> Double {
        guard let newDate = ISO8601DateFormatter().date(from: date) else { return Date().timeIntervalSince1970}
        return Date().timeIntervalSince1970 - Date().timeIntervalSince(newDate)
    }
}

class SenderRealmModel: Object {
    @Persisted var sender: SenderType
    @Persisted var name: String?
    @Persisted var isSent: Bool?

    convenience init(messageSender: Sender) {
        self.init()
        self.sender = .myself
        switch messageSender {
        case .myself(let isSent):
            self.sender = .myself
            self.isSent = isSent
        case .other(let name):
            self.sender = .other
            self.name = name
        }
    }
}

enum SenderType: String, PersistableEnum {
    case myself
    case other
}
