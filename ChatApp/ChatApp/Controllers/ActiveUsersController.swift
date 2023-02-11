//
//  ActiveUsersController.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit
import Combine

protocol ActiveUsersControllerDelegate: AnyObject {
    func activeUsersControllerDidRequestUsers()
}

class ActiveUsersController {

    // users published mainly for test purposes
    @Published var users = [User]()

    var usersObserver: AnyCancellable?

    weak var delegate: ActiveUsersControllerDelegate?
    var diffableDataSource: UITableViewDiffableDataSource<Int, String>?

    init() {
        usersObserver = self.$users.sink(receiveValue: { [weak self] _ in
            self?.updateSnapshot()
        })
    }

    deinit {
        usersObserver = nil
    }

    func setupDataSource(for tableView: UITableView) {
        let diffableDataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) { [weak self] tableView,indexPath,itemIdentifier in

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "active user cell", for: indexPath) as? UserViewCell else { fatalError("cell not found")}

            cell.setupUI((self?.users[indexPath.row]) ?? User(username: ""))

            return cell
        }

        self.diffableDataSource = diffableDataSource
        updateSnapshot()
    }

    func updateSnapshot() {
        guard let diffableDataSource = diffableDataSource else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        let userIds = users.map { $0.username }

        snapshot.appendItems(userIds, toSection: 0)

        diffableDataSource.apply(snapshot)
    }

    func requestUsers() {
        delegate?.activeUsersControllerDidRequestUsers()
    }
}

extension ActiveUsersController: ChatServiceUsersDelegate {
    func service(didRecieve users: [User]) {
        self.users = users
    }
}
