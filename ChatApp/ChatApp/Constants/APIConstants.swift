//
//  APIConstants.swift
//  ChatApp
//
//  Created by Patrick on 02.03.2023..
//

import Foundation

/// Container containing required `API` values for HTTP requests, saved as `String`, when needed cast to `URL`
struct APIConstants {
    /// Base `URL` for connecting to server, logging in/out, sending messages
    static let baseURL = "http://192.168.88.251/"
    /// Web socket API which requires open port for listening for messages
    static let webSocketURL = "ws://192.168.88.251/"
    /// String element required for complete login `API`
    static let loginAPI = "login"
    /// String element required for fetching active users
    static let fetchUsersAPI = "users?status=active"
    /// String element required for web socket
    static let chatAPI = "chat"
    /// String element required for sending messages
    static let sendMessageAPI = "send"
}
