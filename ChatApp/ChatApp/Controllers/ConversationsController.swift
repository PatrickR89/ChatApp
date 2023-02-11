//
//  ConversationsController.swift
//  ChatApp
//
//  Created by Patrick on 11.02.2023..
//

import UIKit

class ConversationsController {
    private(set) var conversations: [String: [MessageViewModel]] = [:]
    private var conversationsList: [String] = [] {
        didSet {
            updateSnapshot()
        }
    }

    var diffableDataSource: UITableViewDiffableDataSource<Int, String>?

    func setupDataSource(for tableView: UITableView) {
        let diffableDataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "conversation cell", for: indexPath) as? ConversationViewCell else {
                fatalError("cell not found")
            }
            let conversationTitle = self?.conversationsList[indexPath.row] ?? ""
            let conversationTime = self?.conversations[conversationTitle , default: []].last?.timestamp ?? ""
            let conversation = Conversation(withUser: conversationTitle, lastActivity: conversationTime)
            cell.setupCell(conversation)
            return cell
        }

        self.diffableDataSource = diffableDataSource
        updateSnapshot()
    }

    private func listConversations(_ username: String) {
        if let index = conversationsList.firstIndex(of: username) {
            conversationsList.remove(at: index)
        }

        conversationsList.insert(username, at: 0)
    }

    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()

        snapshot.appendSections([0])
        snapshot.appendItems(conversationsList, toSection: 0)

        diffableDataSource?.defaultRowAnimation = .fade
        diffableDataSource?.apply(snapshot)
    }
}

extension ConversationsController: ChatServiceDelegate {
    func recieveMessage(_ message: RecievedMessage) {
        let messageViewModel = MessageViewModel(message: message)
        conversations[message.sourceUsername, default: []].append(messageViewModel)
        listConversations(message.sourceUsername)
    }
}

extension ConversationsController: ChatControllerDelegate {
    func chatControllerDidSendMessage(_ message: SentMessage) {
        let messageViewModel = MessageViewModel(message: message)
        conversations[message.chatId, default: []].append(messageViewModel)
        listConversations(message.chatId)
    }
}
