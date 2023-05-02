//
//  DatabaseService.swift
//  ChatApp
//
//  Created by Patrick on 14.03.2023..
//

import Foundation
import RealmSwift
import Factory

protocol DatabaseServiceDelegate: AnyObject {
    func databaseService(didRecieve token: String)
}

class DatabaseService {
    @Injected(\.chatService) private var chatService
    private let realm: Realm
    private var username: String?
    private var token: String?
    weak var delegate: DatabaseServiceDelegate?

    init(realm: Realm) {
        self.realm = realm
        loadUser()
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

        guard !result.isEmpty else {
            print("❌ no user in database")
            return
        }

        let currentUser = result[0]
        username = currentUser.username
    }

    func loadToken() {
        guard let username else {
            print("❌ user was not found")
            return
        }
        guard let token = realm.object(ofType: TokenModel.self, forPrimaryKey: username) else {
            print("❌ error loading token")
            return
        }
        self.token = token.token
        delegate?.databaseService(didRecieve: token.token)
        chatService.setToken(token.token)
    }

    func deleteUser() {
        let user = realm.object(ofType: CurrenUserModel.self, forPrimaryKey: username)
        let conversations = realm.objects(ConversationRealmModel.self)
        let messages = realm.objects(MessageRealmModel.self)
        let token = realm.object(ofType: TokenModel.self, forPrimaryKey: username)
        let pendingMessages = realm.object(ofType: PendingMessages.self, forPrimaryKey: username)

        do {
            try realm.write {
                realm.delete(messages)
                realm.delete(conversations)

                if let pendingMessages {
                    realm.delete(pendingMessages)
                }

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
                print("❌ error saving message for existing conversation", error.localizedDescription)
            }
        } else {
            let newConversation = ConversationRealmModel(user: user, conversation: [message.id])

            do {
                try realm.write {
                    realm.add(model)
                    realm.add(newConversation)
                }
            } catch {
                print("❌ error saving message for new conversation", error.localizedDescription)
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

    func savePendingMessages(messages: [PendingMessage]) {
        let messageIds = messages.map { $0.id }
        guard let token else { return }
        guard let pendingMessages = realm.object(ofType: PendingMessages.self, forPrimaryKey: username) else {
            let model = PendingMessages(token: token, ids: messageIds)

            do {
                try realm.write({
                    realm.add(model)
                })
            } catch {
                print("❌ error occured while creating pending messages")
            }

            return
        }
        let idList = List<UUID>()
        messageIds.forEach { id in
            idList.append(id)
        }
        do {
            try realm.write {
                pendingMessages.messageIds = idList
            }
        } catch {
            print("❌ error occured while saving pending messages")
        }

    }

    func loadPendingMessages() {
        guard let messageModel = realm.object(ofType: PendingMessages.self, forPrimaryKey: username) else { return }

        var pendingMessages = [PendingMessage]()
        messageModel.messageIds.forEach { id in
            guard let message = realm.object(ofType: MessageRealmModel.self, forPrimaryKey: id) else {
                return
            }
            guard let sender = message.sender?.name else {
                return
            }
            let pendingMessage = PendingMessage(message: SentMessage(content: message.content, chatId: sender), id: id)
            pendingMessages.append(pendingMessage)
        }

        chatService.populatePendingMessages(pendingMessages)
    }

    func flagMessage(_ id: UUID, isSent: Bool) {
        guard let message = realm.object(ofType: MessageRealmModel.self, forPrimaryKey: id) else { return }

        do {
            try realm.write {
                message.sender?.isSent = isSent
            }
        } catch {
            print("❌ error saving message", error.localizedDescription)
        }
    }
}
