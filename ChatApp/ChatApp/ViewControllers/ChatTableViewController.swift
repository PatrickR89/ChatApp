//
//  ChatTableViewController.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import UIKit

class ChatTableViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        return tableView
    }()

    lazy var messageInputView: MessageInputView = {
        let messageInputView = MessageInputView()
        return messageInputView
    } ()

    let chatController = ChatController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }

    func setupUI() {
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        view.isUserInteractionEnabled = true
        messageInputView.delegate = chatController
        tableView.register(MessageViewCell.self, forCellReuseIdentifier: "cell")
        chatController.setupDataSource(for: tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.translatesAutoresizingMaskIntoConstraints = false

        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension

        NSLayoutConstraint.activate([
            messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor, constant: -5)
        ])
    }
}

extension ChatTableViewController: UITableViewDelegate {
}

