//
//  ActiveUsersViewController.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit

protocol ChatTabBarChildDelegate: AnyObject {
    func tabBarChild(didSet title: String)
}

class ActiveUsersViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    let controller: ActiveUsersController
    weak var titleDelegate: ChatTabBarChildDelegate?

    init(_ controller: ActiveUsersController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        titleDelegate?.tabBarChild(didSet: "Active Users")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.addSubview(tableView)
        controller.requestUsers()
        controller.setupDataSource(for: tableView)
        tableView.register(UserViewCell.self, forCellReuseIdentifier: "active user cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension ActiveUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller.startConversation(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
