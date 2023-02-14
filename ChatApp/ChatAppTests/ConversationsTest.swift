//
//  ConversationsTest.swift
//  ChatAppTests
//
//  Created by Patrick on 14.02.2023..
//

import XCTest
@testable import ChatApp

final class ConversationsTest: XCTestCase {

    var chatCoordinator: ChatCoordinator?

    override func setUp() {
        self.chatCoordinator = ChatCoordinator(with: UINavigationController(), and: MockChatService())
        chatCoordinator?.start()
        chatCoordinator?.tabBarController?.selectedIndex = 1
        chatCoordinator?.chatService.recieveMessageData(Data())
    }

    override func tearDown() {
        chatCoordinator = nil
    }

    func testConversationsPopulateSuccess() {

        let expectation = XCTestExpectation(description: "test conversation populate")

        DispatchQueue.main.async {
            guard let conversations = self.chatCoordinator?.conversationsController?.conversations else {fatalError()}
            guard let conversationsList = self.chatCoordinator?.conversationsController?.conversationsList else {fatalError()}
            XCTAssertFalse(conversations.isEmpty)
            XCTAssertFalse(conversationsList.isEmpty)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)
    }

    func testTableViewPopulate() {
        let numOfRows = chatCoordinator?.convViewController?.tableView.numberOfRows(inSection: 0) ?? 0
        XCTAssertTrue(numOfRows > 0)
    }

    func testOpenChatSuccess() {
        chatCoordinator?.conversationsController?.openConversation(IndexPath(row: 0, section: 0))
        let expectation = XCTestExpectation(description: "open chat from conversations")

        DispatchQueue.main.async {
            var viewController: ChatTableViewController? = nil

            viewController = self.chatCoordinator?.navController.viewControllers.last as? ChatTableViewController
            XCTAssertNotNil(viewController)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }
}
