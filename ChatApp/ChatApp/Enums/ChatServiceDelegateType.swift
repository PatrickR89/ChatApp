//
//  ChatServiceDelegateType.swift
//  ChatApp
//
//  Created by Patrick on 02.05.2023..
//

import Foundation

enum ChatServiceDelegateType {
    case login (LoginController)
    case main (MainCoordinator)
    case active (ActiveUsersController)
    case conversation (ConversationsController)
    case chat (ChatController)

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
