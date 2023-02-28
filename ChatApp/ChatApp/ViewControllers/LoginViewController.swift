//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import UIKit

class LoginViewController: UIViewControllerWithKeyboard {

    var loginView: LoginView
    var loginController = LoginController()
    let keyboardLayoutObserver = KeyboardLayoutObserver()

    init(with service: ChatService) {
        self.loginView = LoginView(with: loginController)
        super.init(nibName: nil, bundle: nil)
        loginController.delegate = service
        service.responseDelegate = loginController
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        self.addLayoutGuide(loginView, 100.0)
        keyboardLayoutObserver.startKeyboardObserver(for: self)
        view.backgroundColor = .white
    }

    func setupUI() {
        loginView.setFrame(frame: view.frame)
        view.addSubview(loginView)
        loginView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
