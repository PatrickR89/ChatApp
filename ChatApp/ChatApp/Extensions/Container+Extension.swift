//
//  Container+Extension.swift
//  ChatApp
//
//  Created by Patrick on 19.04.2023..
//

import Foundation
import Factory

extension Container {
    /// Singleton instance of ``ChatService`` embedded in `Factory`
    ///  in order to reduce code, number  of required delegates,
    /// and make `chatService` available throughout whole app.
    var chatService: Factory<ChatService> { self { ChatService() }.singleton }
    /// Singleton instance of ``DatabaseService`` embedded in `Factory`
    /// in order to reduce code, number of required delegates,
    /// and make `databaseService` available throughout whole app.
    var databaseService: Factory<DatabaseService> { self {DatabaseService(
        realm: DatabaseProvider.initiateRealm()
    ) }.singleton }
}
