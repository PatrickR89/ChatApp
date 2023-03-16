//
//  CurrentUserModel.swift
//  ChatApp
//
//  Created by Patrick on 15.03.2023..
//

import Foundation
import RealmSwift

class CurrenUserModel: Object {
    @Persisted (primaryKey: true) var username: String
    @Persisted var name: String
    @Persisted var lastname: String

    convenience init(username: String, name: String, lastname: String) {
        self.init()
        self.username = username
        self.name = name
        self.lastname = lastname
    }
}

class TokenModel: Object {
    @Persisted (primaryKey: true) var username: String
    @Persisted var token: String

    convenience init(username: String, token: String) {
        self.init()
        self.username = username
        self.token = token
    }
}
