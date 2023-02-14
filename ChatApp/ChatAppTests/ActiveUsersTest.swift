//
//  ActiveUsersTest.swift
//  ChatAppTests
//
//  Created by Patrick on 11.02.2023..
//

import XCTest
@testable import ChatApp
import Combine

final class ActiveUsersTest: XCTestCase {

    var chatCoordinator: ChatCoordinator?
    var cancellable: AnyCancellable?

    override func setUp() {
        self.chatCoordinator = ChatCoordinator(with: UINavigationController(), and: MockChatService())
        chatCoordinator?.start()
    }

    override func tearDown() {
        chatCoordinator = nil
        cancellable = nil
    }

    func testFetchActiveUsers() throws {
        let expectation = XCTestExpectation(description: "populate users")

        cancellable = chatCoordinator?.activeUsersController?.$users.sink(receiveValue: { users in
            XCTAssertTrue(users.count > 0)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 5)
    }

    func testTableViewPopulate() {
        let numOfRows = chatCoordinator?.activeUsersViewController?.tableView.numberOfRows(inSection: 0) ?? 0
        XCTAssertTrue(numOfRows > 0)
    }

    func testSuccessOpenningChat() {
        chatCoordinator?.activeUsersController?.startConversation(IndexPath(row: 0, section: 0))
        let expectation = XCTestExpectation(description: "open chat")

        DispatchQueue.main.async {
            var VC: ChatTableViewController? = nil

            VC = self.chatCoordinator?.navController.viewControllers.last as? ChatTableViewController
            XCTAssertNotNil(VC)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}
