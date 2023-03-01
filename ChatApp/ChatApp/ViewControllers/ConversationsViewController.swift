//
//  ConversationsViewController.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit

class ConversationsViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    let controller: ConversationsController
    weak var titleDelegate: ChatTabBarChildDelegate?

    init(_ controller: ConversationsController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        titleDelegate?.tabBarChild(didSet: "Conversations")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.addSubview(tableView)
        controller.setupDataSource(for: tableView)
        tableView.register(ConversationViewCell.self, forCellReuseIdentifier: "conversation cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.backgroundColor = .clear

        controller.test()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension ConversationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller.openConversation(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
