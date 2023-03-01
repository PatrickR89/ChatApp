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

    let chatController: ChatController
    let keyboardLayoutObserver = KeyboardLayoutObserver()

    init(_ chatController: ChatController) {
        self.chatController = chatController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        title = chatController.chatId
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
    }

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
        messageInputView.delegate = chatController
        tableView.register(MessageViewCell.self, forCellReuseIdentifier: "cell")
        chatController.setupDataSource(for: tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.translatesAutoresizingMaskIntoConstraints = false

        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor, constant: -5)
        ])

        setupBackground()
    }

    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIConstants.backgroundColorDark.cgColor, UIConstants.backgroundColorLight.cgColor]
        gradient.frame = view.bounds
        gradient.startPoint = .init(x: 0, y: 0.3)
        gradient.endPoint = .init(x: 0, y: 0.7)
        view.layer.insertSublayer(gradient, at: 0)
    }
}

extension ChatTableViewController: ChatControllerDelegate {

    func chatControllerDidAddMessage(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}
