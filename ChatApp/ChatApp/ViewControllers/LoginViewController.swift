//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import UIKit

class LoginViewController: UIViewController {

    var loginView: LoginView
    var loginButtonController = LoginButtonController()

    init(with service: ChatService) {
        self.loginView = LoginView(with: loginButtonController)
        super.init(nibName: nil, bundle: nil)
        loginView.delegate = service
        service.responseDelegate = loginButtonController
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        view.backgroundColor = .white
    }

    func setupUI() {
        view.addSubview(loginView)
        loginView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

