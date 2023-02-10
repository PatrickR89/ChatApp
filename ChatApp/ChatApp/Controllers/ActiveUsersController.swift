//
//  ActiveUsersController.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit

class ActiveUsersController {
    var users = [User]()
    var diffableDataSource: UITableViewDiffableDataSource<Int, String>?

    func setupDataSource(for tableView: UITableView) {
        let diffableDataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) { [weak self] tableView,indexPath,itemIdentifier in

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserViewCell else { fatalError("cell not found")}

//            cell.viewModel = self?.users[indexPath.row]

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
}

extension ActiveUsersController: ChatServiceUsersDelegate {
    func service(didRecieve users: [User]) {
        self.users = users
    }
}
