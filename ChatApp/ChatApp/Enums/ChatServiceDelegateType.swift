//
//  ChatServiceDelegateType.swift
//  ChatApp
//
//  Created by Patrick on 02.05.2023..
//

import Foundation

/// Experimantal enum, used to reduce code for delegates contained in ``ChatService`` in order to register classes for required delegates
enum ChatServiceDelegateType {
    case login (LoginController)
    case main (MainCoordinator)
    case active (ActiveUsersController)
    case conversation (ConversationsController)
    case chat (ChatController)

    /// Variable containing selected class, providing it to ``ChatService``
    var controller: Any {
        switch self {
        case .login(let loginController):
            return loginController
        case .main(let mainCoordinator):
            return mainCoordinator
        case .active(let activeUsersController):
            return activeUsersController
        case .conversation(let conversationsController):
            return conversationsController
        case .chat(let chatController):
            return chatController
        }
    }
}
