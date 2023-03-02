//
//  ConversationsTest.swift
//  ChatAppTests
//
//  Created by Patrick on 14.02.2023..
//

import XCTest
@testable import ChatApp
import Combine

final class ConversationsTest: XCTestCase {

    var chatCoordinator: ChatCoordinator?
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        UserDefaults.standard.set("asdassdbkasdsajbasdjb", forKey: "CHAT_ID")

        self.chatCoordinator = ChatCoordinator(with: UINavigationController(), and: MockChatService())
        chatCoordinator?.start()
        chatCoordinator?.tabBarController?.selectedIndex = 1
        chatCoordinator?.chatService.recieveMessageData(Data())
    }

    override func tearDown() {
        chatCoordinator = nil
        UserDefaults.standard.set(nil, forKey: "CHAT_ID")
        cancellables = []
    }

    func testConversationsPopulateSuccess() {

        let expectation = XCTestExpectation(description: "test conversation populate")

        DispatchQueue.main.async {
            guard let conversations = self.chatCoordinator?.conversationsController?.conversations else {fatalError()}
            guard let conversationsList = self.chatCoordinator?.conversationsController?.conversationsList else {
                fatalError()
            }
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
            var viewController: ChatTableViewController?

            viewController = self.chatCoordinator?.navController.viewControllers.last as? ChatTableViewController
            XCTAssertNotNil(viewController)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    func testPopulateConversationViaChat() {
        chatCoordinator?.conversationsController?.openConversation(IndexPath(row: 0, section: 0))
        let expectation = XCTestExpectation(description: "populate conversations")

        DispatchQueue.main.async {
            var viewController: ChatTableViewController?
            viewController = self.chatCoordinator?.navController.viewControllers.last as? ChatTableViewController
            viewController?.viewDidLoad()
            viewController?.messageInputView.inputField.text = "sdasdasdsad"
            viewController?.messageInputView.sendMessage()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.chatCoordinator?.conversationsController?.$conversations.sink(receiveValue: { conversation in
                let chatCount = conversation.values.first?.count ?? 0
                XCTAssertTrue(chatCount > 1)
                expectation.fulfill()
            }).store(in: &self.cancellables)
        }

        wait(for: [expectation], timeout: 15)
    }
}
