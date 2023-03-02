//
//  APIConstants.swift
//  ChatApp
//
//  Created by Patrick on 02.03.2023..
//

import Foundation

struct APIConstants {
    static let baseURL = "http://192.168.88.251/"
    static let webSocketURL = "ws://192.168.88.251/"
    static let loginAPI = "login"
    static let fetchUsersAPI = "users?status=active"
    static let chatAPI = "chat"
    static let sendMessageAPI = "send"
}
