//
//  ActiveUsersController.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit
import Combine
import Factory

//protocol ActiveUsersControllerDelegate: AnyObject {
//    func activeUsersControllerDidRequestUsers()
//}

protocol ActiveUsersControllerActions: AnyObject {
    func activeUsersControllerDidSelect(user: User)
}

class ActiveUsersController {

    @Injected(\.chatService) private var chatService
    @Published var users = [User]()

    var usersObserver: AnyCancellable?

//    weak var delegate: ActiveUsersControllerDelegate?
    weak var actions: ActiveUsersControllerActions?

    var diffableDataSource: UITableViewDiffableDataSource<Int, String>?

    init() {
        usersObserver = self.$users.sink(receiveValue: { [weak self] _ in
            self?.updateSnapshot()
        })
        users.append(User(username: "someone"))
        chatService.setDelegacy(controller: .active(self))
    }

    deinit {
        usersObserver = nil
    }

    func setupDataSource(for tableView: UITableView) {
        let diffableDataSource =
        UITableViewDiffableDataSource<
            Int, String>(tableView: tableView) { [weak self] tableView, indexPath, _ in

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "active user cell",
                for: indexPath) as? ActiveUserViewCell else {
                fatalError("cell not found")
            }

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

    // move to chatService
    func requestUsers() {
        chatService.fetchActiveUsers()
//        delegate?.activeUsersControllerDidRequestUsers()
    }

    func startConversation(_ indexPath: IndexPath) {
        guard let username = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let user = users.first(where: { $0.username == username}) else { return }
        actions?.activeUsersControllerDidSelect(user: user)
    }
}

extension ActiveUsersController: ChatServiceUsersDelegate {
    func chatService(didRecieve users: [User]) {
        self.users = users
    }
}
