//
//  ConversationsController.swift
//  ChatApp
//
//  Created by Patrick on 11.02.2023..
//

import UIKit

protocol ConversationControllerActions: AnyObject {
    func conversationControllerDidSelect(_ user: String, _ conversation: [MessageViewModel])
}

class ConversationsController {
    private(set) var conversations: [String: [MessageViewModel]] = [:]
    private(set) var conversationsList: [String] = [] {
        didSet {
            updateSnapshot()
        }
    }

    weak var actions: ConversationControllerActions?
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
        guard let diffableDataSource = diffableDataSource else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()

        snapshot.appendSections([0])
        snapshot.appendItems(conversationsList, toSection: 0)

        diffableDataSource.defaultRowAnimation = .fade
        diffableDataSource.apply(snapshot)
    }

    func openConversation(_ indexPath: IndexPath) {
        guard let conversationIdentifier = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let conversation = conversations[conversationIdentifier] else {return}
        actions?.conversationControllerDidSelect(conversationIdentifier, conversation)
    }
}

extension ConversationsController: ChatServiceDelegate {
    func recieveMessage(_ message: RecievedMessage) {
        let messageViewModel = MessageViewModel(message: message)
        conversations[message.sourceUsername, default: []].append(messageViewModel)
        listConversations(message.sourceUsername)
    }
}

extension ConversationsController: ChatControllerActions {

    func chatControllerDidSendMessage(_ username: String, _ message: MessageViewModel) {
        conversations[username, default: []].append(message)
        listConversations(username)
    }
}
