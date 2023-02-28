//
//  LoginController.swift
//  ChatApp
//
//  Created by Patrick on 06.02.2023..
//

import UIKit
import Combine

protocol LoginControllerDelegate: AnyObject {
    func loginView(didRequestLoginFor user: LoginRequest)
}

class LoginController {

    @Published private(set) var inputIsValid: Bool
    @Published private(set) var isWaiting: Bool = false
    @Published private(set) var loginRequest = LoginRequest(username: "", name: "", surname: "") {
        didSet {
            validateInput()
        }
    }

    weak var delegate: LoginControllerDelegate?

    init() {
        inputIsValid = false
        validateInput()
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
        delegate?.loginView(didRequestLoginFor: loginRequest)
    }
}

extension LoginController: ChatServiceResponse {
    func chatService(_ isWaitingForResponse: Bool) {
        self.isWaiting = isWaitingForResponse
    }
}
