//
//  DatabaseService.swift
//  ChatApp
//
//  Created by Patrick on 14.03.2023..
//

import Foundation
import RealmSwift

class DatabaseService {
    private let realm: Realm
    private var username: String?
    private var token: String?

    init(realm: Realm) {
        self.realm = realm
    }

    func saveUser(username: String, name: String, lastname: String) {

        self.username = username
        let newUser = CurrenUserModel(username: username, name: name, lastname: lastname)

        do {
            try realm.write {
                realm.add(newUser)
            }
        } catch {
            print("❌ error saving user", error.localizedDescription)
        }
    }

    func saveToken(username: String, token: String) {
        let tokenModel = TokenModel(username: username, token: token)

        do {
            try realm.write {
                realm.add(tokenModel)
            }
        } catch {
            print("❌ error saving token", error.localizedDescription)
        }
    }

    func loadUser() {
        let result = realm.objects(CurrenUserModel.self)

        let currentUser = result[0]
        username = currentUser.username

        let token = realm.object(ofType: TokenModel.self, forPrimaryKey: currentUser.username)
        self.token = token?.token
    }

    func deleteUser() {
        let user = realm.object(ofType: CurrenUserModel.self, forPrimaryKey: username)
        let conversations = realm.objects(ConversationRealmModel.self)
        let messages = realm.objects(MessageRealmModel.self)
        let token = realm.object(ofType: TokenModel.self, forPrimaryKey: username)

        do {
            try realm.write {
                realm.delete(messages)
                realm.delete(conversations)
                if let user {
                    realm.delete(user)
                }

                if let token {
                    realm.delete(token)
                }
            }
        } catch {
            print("❌ error deleting user", error.localizedDescription)
        }
    }

    func saveMessage(conversationWith user: String, _ message: MessageViewModel) {
        let model = MessageRealmModel(message: message)
        if let savedConversation = realm.object(ofType: ConversationRealmModel.self, forPrimaryKey: user) {
            let messageList = savedConversation.messages
            messageList.append(message.id)

            do {
                try realm.write {
                    savedConversation.messages = messageList
                    realm.add(model)
                }
            } catch {
                print("❌ error saving message", error.localizedDescription)
            }
        } else {
            let newConversation = ConversationRealmModel(user: user, conversation: [message.id])

            do {
                try realm.write {
                    realm.add(model)
                    realm.add(newConversation)
                }
            } catch {
                print("❌ error saving message", error.localizedDescription)
            }
        }
    }

    func loadMessages() {
        let conversations = realm.objects(ConversationRealmModel.self)
        conversations.forEach { conversation in
            var messages = [MessageViewModel]()
            conversation.messages.forEach { id in
                if let message = realm.object(ofType: MessageRealmModel.self, forPrimaryKey: id) {
                    messages.append(MessageViewModel(realmMessage: message))
                }
            }
            // return or delegate conversation to conversations dictionary under
            // name of conversations with array of viewModels
        }
    }

    func flagMessage(_ id: UUID, isSent: Bool) {
        guard let message = realm.object(ofType: MessageRealmModel.self, forPrimaryKey: id) else { return }

        do {
            try realm.write {
                message.sender.isSent = isSent
            }
        } catch {
            print("❌ error saving message", error.localizedDescription)
        }
    }
}
