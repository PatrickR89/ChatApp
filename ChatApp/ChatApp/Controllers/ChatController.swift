//
//  ChatController.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation
import UIKit

protocol ChatControllerDelegate: AnyObject {
    func chatControllerDidAddMessage(at index: Int)
    func chatControllerDidSendMessage(_ message: SentMessage)
}

extension ChatControllerDelegate {
    func chatControllerDidAddMessage(at index: Int){}
    func chatControllerDidSendMessage(_ message: SentMessage){}
}

class ChatController {

    var messages: [MessageViewModel] {
        didSet {
            updateSnapshot()
            delegate?.chatControllerDidAddMessage(at: messages.count - 1)
        }
    }

    var chatId: String

    let chatService: ChatService
    weak var delegate: ChatControllerDelegate?

    var diffableDataSource: UITableViewDiffableDataSource<Int, UUID>?

    init(_ chatId: String, _ messages: [MessageViewModel]) {
        self.chatId = chatId
        self.messages = messages
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

        for message in messages {
            switch message.sender {
            case .me:
                diffableDataSource.defaultRowAnimation = .right
            case .other:
                diffableDataSource.defaultRowAnimation = .left
            }
            snapshot.appendItems([message.id], toSection: 0)
        }
        diffableDataSource.apply(snapshot)
    }
}

extension ChatController: MessageInputViewDelegate {
    func messageInputView(didSend message: String) {

        let sentMessage = SentMessage(content: message, chatId: self.chatId)
        delegate?.chatControllerDidSendMessage(sentMessage)
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
