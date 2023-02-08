//
//  ChatController.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation
import UIKit

class ChatController {

    var messages: [MessageViewModel] = [] {
        didSet {
            updateSnapshot()
        }
    }

    var chatId: String = UserDefaults().string(forKey: "CHAT_ID") ?? "0" // UUID().uuidString

    let chatService: ChatService

    var diffableDataSource: UITableViewDiffableDataSource<Int, UUID>?

    init() {
        self.chatService = ChatService()
        chatService.delegate = self
    }

    func setupDataSource(for tableView: UITableView) {
        let diffableDataSource = UITableViewDiffableDataSource<Int, UUID>(tableView: tableView) { [weak self] tableView,indexPath,itemIdentifier in

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MessageViewCell else { fatalError("cell not found")}

            cell.viewModel = self?.messages[indexPath.row]

            return cell
        }

        self.diffableDataSource = diffableDataSource
        updateSnapshot()
    }

    func updateSnapshot() {
        guard let diffableDataSource = diffableDataSource else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        let msgIds = messages.map { $0.id }
        snapshot.appendItems(msgIds, toSection: 0)
        diffableDataSource.apply(snapshot)
    }
}

extension ChatController: MessageInputViewDelegate {
    func messageInputView(didSend message: String) {

//        let sentMessage = SentMessage(content: message, chatId: "1")
         let sentMessage = SentMessage(content: message, chatId: self.chatId)
        let messageViewModel = MessageViewModel(message: sentMessage)
        messages.append(messageViewModel)

        chatService.sendMessage(sentMessage)
    }
}

extension ChatController: ChatServiceDelegate {
    func recieveMessage(_ message: RecievedMessage) {
        let messageViewModel = MessageViewModel(message: message)
        messages.append(messageViewModel)
    }
}
