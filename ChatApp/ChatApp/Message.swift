//
//  Message.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

struct RecievedMessage {
    let sourceUsername: String
    let timestamp: TimeInterval
    let content: String
}

struct SentMessage {
    let content: String
}
