//
//  LoginTests.swift
//  ChatAppTests
//
//  Created by Patrick on 08.02.2023..
//

import XCTest
import Combine
@testable import ChatApp

final class LoginTests: XCTestCase {

    var mainCoordinator: MainCoordinator?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        self.mainCoordinator = MainCoordinator(UINavigationController(), MockChatService())
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.set(nil, forKey: "CHAT_ID")
        cancellables.removeAll()
        mainCoordinator = nil
    }

    func testLogin() throws {
        let loginRequest = LoginRequest(username: "asdasd", name: "asdsadasd", surname: "afsdffdsd")

        mainCoordinator?.chatService.login(loginRequest)

        mainCoordinator!.$token
            .sink { token in
                XCTAssertTrue(token != nil, "Token should not be nil")
                XCTAssertTrue(UserDefaults().string(forKey: "CHAT_ID") != nil)
            }
            .store(in: &cancellables)
    }
}
