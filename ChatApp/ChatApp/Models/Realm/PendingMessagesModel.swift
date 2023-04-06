//
//  PendingMessagesModel.swift
//  ChatApp
//
//  Created by Patrick on 06.04.2023..
//

import Foundation
import RealmSwift

class PendingMessages: Object {
    @Persisted (primaryKey: true) var token: String
    @Persisted var messageIds: List<UUID>

    convenience init(token: String, ids: [UUID]) {
        self.init()
        self.token = token
        ids.forEach { id in
            self.messageIds.append(id)
        }
    }
}
