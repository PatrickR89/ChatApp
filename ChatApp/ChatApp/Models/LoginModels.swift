//
//  LoginModels.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

struct LoginRequest: Codable {
    var username: String
    var name: String
    var surname: String
}

struct LoginResponse: Codable {
    var token: String
}
