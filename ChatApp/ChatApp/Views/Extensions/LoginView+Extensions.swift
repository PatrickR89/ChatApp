//
//  LoginView+Extensions.swift
//  ChatApp
//
//  Created by Patrick on 28.02.2023..
//

import UIKit

extension LoginView {
    func addNameWarning() {
        addSubview(firstNameWarning)
        firstNameWarning.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            firstNameWarning.topAnchor.constraint(equalTo: firstNameInput.bottomAnchor, constant: 2),
            firstNameWarning.trailingAnchor.constraint(equalTo: firstNameInput.trailingAnchor)
        ])
    }

    func addLastNameWarning() {
        addSubview(lastNameWarning)
        lastNameWarning.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            lastNameWarning.topAnchor.constraint(equalTo: lastNameInput.bottomAnchor, constant: 2),
            lastNameWarning.trailingAnchor.constraint(equalTo: lastNameInput.trailingAnchor)
        ])
    }

    func addUsernameWarning() {
        addSubview(usernameWarning)
        usernameWarning.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            usernameWarning.topAnchor.constraint(equalTo: usernameInput.bottomAnchor, constant: 2),
            usernameWarning.trailingAnchor.constraint(equalTo: usernameInput.trailingAnchor)
        ])
    }
}
