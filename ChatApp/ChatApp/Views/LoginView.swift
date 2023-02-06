//
//  LoginView.swift
//  ChatApp
//
//  Created by Patrick on 02.02.2023..
//

import UIKit
import Combine

class LoginView: UIView {

    let imageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "envelope.open.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 120, weight: UIImage.SymbolWeight.thin, scale: UIImage.SymbolScale.large))
        imageView.image = image
        imageView.tintColor = .black
        return imageView
    }()

    let firstNameInput: UITextField = {
        let inputField = UITextField().createInputField("Enter your first name")
        return inputField
    }()

    let lastNameInput: UITextField = {
        let inputField = UITextField().createInputField("Enter your last name")
        return inputField
    }()

    let usernameInput: UITextField = {
        let inputField = UITextField().createInputField("Enter your chat name")
        return inputField
    }()

    let confirmButton: UIButton = {
        let button = UIButton()

        button.layer.cornerRadius = 22
        button.backgroundColor = .systemBlue
        button.setTitle("Register", for: .normal)
        button.setTitle("Enter at least 4 characters in each field", for: .disabled)
        button.tintColor = .white

        return button
    }()

    var inputObserver: AnyCancellable?

    var loginController: LoginController?

    init(_ loginController: LoginController!) {
        self.loginController = loginController
        super.init(frame: .zero)
        setupInputBindings()
        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        let textFields = [usernameInput, firstNameInput, lastNameInput]
        let views: [UIView] = [imageView, confirmButton] + textFields

        views.forEach { view in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }

        textFields.forEach { textField in
            textField.delegate = self
            loginController?.addInputValidation(textField)
        }

        NSLayoutConstraint.activate([

            usernameInput.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            firstNameInput.topAnchor.constraint(equalTo: usernameInput.bottomAnchor, constant: 20),
            lastNameInput.topAnchor.constraint(equalTo: firstNameInput.bottomAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: usernameInput.topAnchor, constant: -100),
            confirmButton.topAnchor.constraint(equalTo: lastNameInput.bottomAnchor, constant: 20),
            usernameInput.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75),
            confirmButton.widthAnchor.constraint(equalTo: usernameInput.widthAnchor),
            firstNameInput.widthAnchor.constraint(equalTo: usernameInput.widthAnchor),
            lastNameInput.widthAnchor.constraint(equalTo: usernameInput.widthAnchor),
            usernameInput.heightAnchor.constraint(equalToConstant: 40),
            firstNameInput.heightAnchor.constraint(equalToConstant: 40),
            lastNameInput.heightAnchor.constraint(equalToConstant: 40),
            confirmButton.heightAnchor.constraint(equalTo: usernameInput.heightAnchor)

        ])
    }

    private func setupInputBindings() {
        inputObserver = loginController?.$inputsAreValid.sink(receiveValue: { [weak self] input in
            if input.values.contains(where: { valid in
                valid == false
            }) {
                self?.confirmButton.isEnabled = false
                self?.confirmButton.backgroundColor = .lightGray
            } else {
                self?.confirmButton.isEnabled = true
                self?.confirmButton.backgroundColor = .systemBlue
            }
        })
    }
}

extension LoginView: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        loginController?.validateInput(textField)
    }
}
