//
//  Container+Extension.swift
//  ChatApp
//
//  Created by Patrick on 19.04.2023..
//

import Foundation
import Factory

extension Container {
    var chatService: Factory<ChatServiceType> { self { ChatService() }.singleton }
//    var databaseService: Factory<DatabaseService> { self {DatabaseService(realm: <#Realm#>) }.singleton }
}
