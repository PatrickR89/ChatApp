//
//  ChatTableViewController.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import UIKit

class ChatTableViewController: UIViewControllerWithKeyboard {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    lazy var messageInputView: MessageInputView = {
        let messageInputView = MessageInputView()
        return messageInputView
    } ()

    let chatController = ChatController()
    let keyboardLayoutObserver = KeyboardLayoutObserver()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        chatController.delegate = self
        self.addLayoutGuide(messageInputView, 0)
        keyboardLayoutObserver.startKeyboardObserver(for: self)
    }

    func setupUI() {
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        view.isUserInteractionEnabled = true
        view.backgroundColor = .systemBackground
        messageInputView.delegate = chatController
        tableView.register(MessageViewCell.self, forCellReuseIdentifier: "cell")
        chatController.setupDataSource(for: tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.translatesAutoresizingMaskIntoConstraints = false

        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension

        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor, constant: -5)
        ])
    }
}

extension ChatTableViewController: ChatControllerDelegate {
    func chatControllerDidAddMessage(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}
