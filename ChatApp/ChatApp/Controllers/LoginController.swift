//
//  LoginController.swift
//  ChatApp
//
//  Created by Patrick on 06.02.2023..
//

import UIKit
import Combine
import Factory

protocol LoginControllerDelegate: AnyObject {
    func loginView(didRequestLoginFor user: LoginRequest)
}

class LoginController {
    @Injected (\.chatService) private var chatService
    @Published private(set) var inputIsValid: Bool
    @Published private(set) var isWaiting: Bool = false
    @Published private(set) var loginRequest = LoginRequest(username: "", name: "", surname: "") {
        didSet {
            validateInput()
        }
    }

    init() {
        inputIsValid = false
        validateInput()
        chatService.setDelegacy(controller: .login(self))
    }

    func validateInput() {
        if loginRequest.name.count < 4 || loginRequest.surname.count < 4 || loginRequest.username.count < 4 {
            inputIsValid = false
        } else {
            inputIsValid = true
        }
    }

    func setLoginRequest(_ value: String, _ position: InputType) {
        switch position {
        case .username:
            loginRequest.username = value
        case .firstName:
            loginRequest.name = value
        case .lastName:
            loginRequest.surname = value
        }
    }

    func sendLoginRequest() {
        chatService.login(loginRequest)
    }
}

extension LoginController: ChatServiceResponse {
    func chatService(_ isWaitingForResponse: Bool) {
        self.isWaiting = isWaitingForResponse
    }
}
